"""Unit orchestration using Python's standard library and git/gh/tmux."""
import argparse
from collections import Counter
from contextlib import contextmanager
from dataclasses import dataclass
import fcntl
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
from urllib.parse import urlparse


class UnitError(Exception):
    pass


class Quit(Exception):
    pass


def run(args, cwd=None, check=True, capture=True):
    result = subprocess.run(
        [str(a) for a in args], cwd=cwd,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
        text=True, errors="replace",
    )
    if check and result.returncode:
        raise UnitError((result.stderr or result.stdout or f"Command failed: {args[0]}").strip())
    return result


def clean(value):
    return "".join(c if c.isprintable() else " " for c in str(value))


STYLES = {
    "heading": "1;34",
    "branch": "36",
    "commit": "33",
    "author": "35",
    "action": "1;36",
    "success": "32",
    "warning": "1;33",
    "error": "1;31",
    "muted": "2",
    "prompt": "1;36",
}


def styled(message, role=None):
    """Use the terminal's ANSI palette, never a hard-coded RGB theme."""
    message = clean(message)
    if role and sys.stdout.isatty() and "NO_COLOR" not in os.environ and os.environ.get("TERM") != "dumb":
        return f"\033[{STYLES[role]}m{message}\033[0m"
    return message


def say(message, role=None):
    print(styled(message, role), flush=True)


def line(*parts):
    """Render separately styled fields while sanitizing every source value."""
    print("".join(styled(*part) if isinstance(part, tuple) else styled(part) for part in parts), flush=True)


def confirm(message, force):
    if force:
        return True
    if not sys.stdin.isatty():
        raise UnitError("Confirmation requires a terminal; use -f or -n.")
    answer = input(styled(message, "prompt") + " " + styled("[y/N/q]", "muted") + " ").strip().lower()
    if answer == "q":
        raise Quit()
    return answer == "y"


@dataclass
class Worktree:
    path: Path
    branch: str = ""
    head: str = ""
    locked: bool = False
    prunable: bool = False


class Repo:
    def __init__(self):
        common = run(["git", "rev-parse", "--path-format=absolute", "--git-common-dir"])
        self.common = Path(common.stdout.strip()).resolve()
        self.root = self.common.parent
        if self.common.name != ".git":
            raise UnitError("Units require a non-bare repository with a main .git directory.")
        configured = Path(os.environ.get("DOTF_AGENTS_WORKTREE_DIR") or ".agents")
        self.base = (self.root / configured).resolve()
        if self.base == self.root or self.base in self.root.parents:
            raise UnitError("The agents directory must not be the repository root or its ancestor.")
        self.session = re.sub(r"[^a-z0-9-]+", "-", self.root.name.lower()).strip("-")

    def git(self, *args, cwd=None, **kwargs):
        return run(["git", *args], cwd=cwd or self.root, **kwargs)

    def config(self, key):
        return self.git("config", "--get", key, check=False).stdout.strip()

    def managed(self, path):
        path = Path(path).resolve()
        return path != self.base and self.base in path.parents

    def ticket(self, path):
        return str(Path(path).resolve().relative_to(self.base))

    def worktrees(self):
        result, record = [], {}
        for field in self.git("worktree", "list", "--porcelain", "-z").stdout.split("\0"):
            if not field:
                if "worktree" in record:
                    result.append(Worktree(
                        Path(record["worktree"]).resolve(),
                        record.get("branch", "").removeprefix("refs/heads/"),
                        record.get("HEAD", ""), "locked" in record, "prunable" in record,
                    ))
                record = {}
            else:
                key, _, value = field.partition(" ")
                record[key] = value
        return result

    def oid(self, ref):
        return self.git("rev-parse", "--verify", "--end-of-options", ref + "^{commit}", check=False).stdout.strip()

    def valid_name(self, name):
        if not name or Path(name).is_absolute() or any(p in (".", "..") for p in name.split("/")):
            raise UnitError(f"Invalid unit name: {clean(name)}")
        if self.git("check-ref-format", "--branch", name, check=False).returncode:
            raise UnitError(f"Invalid branch name: {clean(name)}")
        path = (self.base / name).resolve()
        if not self.managed(path):
            raise UnitError(f"Unit path escapes agents directory: {clean(name)}")
        return path

    def blocked(self, wt):
        if wt.locked or wt.prunable or not wt.path.is_dir():
            return "locked, prunable or missing worktree"
        for marker in ("rebase-merge", "rebase-apply", "MERGE_HEAD", "CHERRY_PICK_HEAD", "REVERT_HEAD", "sequencer", "BISECT_START"):
            path = self.git("rev-parse", "--path-format=absolute", "--git-path", marker, cwd=wt.path).stdout.strip()
            if Path(path).exists():
                return f"unfinished Git operation ({marker})"
        if not wt.branch:
            return "detached HEAD"
        if self.git("status", "--porcelain", "--untracked-files=normal", cwd=wt.path).stdout:
            return "uncommitted or untracked changes"
        return ""

    def warn_name(self, wt):
        if self.managed(wt.path) and wt.branch and self.ticket(wt.path) != wt.branch:
            say("  WARNING: branch/worktree naming mismatch", "warning")
            say(f"    Worktree: {self.ticket(wt.path)}; branch: {wt.branch}")

    @contextmanager
    def lock(self, dry_run):
        if dry_run:
            yield
            return
        with (self.common / "unit-operation.lock").open("a") as handle:
            try:
                fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError:
                raise UnitError("Another unit sync/import is running in this repository.") from None
            try:
                yield
            finally:
                fcntl.flock(handle, fcntl.LOCK_UN)


def summary(counts):
    roles = {"failed": "error", "blocked": "warning", "unprocessed": "warning",
             "declined": "warning", "planned": "action", "scheduled": "action"}
    parts = [("Done. ", "heading")]
    for index, (key, value) in enumerate(counts.items()):
        if index:
            parts.append(", ")
        parts.append((f"{key}: {value}", roles.get(key, "success") if value else "muted"))
    line(*parts)


def sync(repo, opts):
    if not opts.dry_run:
        result = repo.git("fetch", "origin", f"+refs/heads/{opts.base}:refs/remotes/origin/{opts.base}", check=False, capture=False)
        if result.returncode:
            raise UnitError(f"Could not fetch origin/{opts.base}; check origin or choose --base explicitly.")
    else:
        say("Preview uses cached origin refs; no fetch or rebase will run.", "warning")
    target = repo.oid("refs/remotes/origin/" + opts.base)
    if not target:
        raise UnitError(f"origin/{opts.base} is unavailable; choose --base explicitly.")
    worktrees = repo.worktrees()
    if opts.all:
        worktrees = sorted((w for w in worktrees if repo.managed(w.path)), key=lambda w: str(w.path))
    else:
        current = Path(run(["git", "rev-parse", "--show-toplevel"]).stdout.strip()).resolve()
        worktrees = [w for w in worktrees if w.path == current]
    line(("Target: ", "muted"), (f"origin/{opts.base}", "branch"), " @ ",
         (target[:8], "commit"), (f"; {len(worktrees)} worktree(s)", "muted"))
    counts = Counter(rebased=0, current=0, declined=0, blocked=0, failed=0, planned=0, unprocessed=len(worktrees))
    try:
        for index, wt in enumerate(worktrees, 1):
            label = repo.ticket(wt.path) if repo.managed(wt.path) else str(wt.path)
            say("")
            say(f"[{index}/{len(worktrees)}] {label}", "heading")
            line(("  Branch: ", "muted"), (wt.branch or "(detached)", "branch"))
            repo.warn_name(wt)
            reason = repo.blocked(wt)
            if reason or wt.branch in (opts.base, "main", "master"):
                say(f"  BLOCKED: {reason or 'base branch is not a unit topic branch'}", "warning")
                counts["blocked"] += 1
                counts["unprocessed"] -= 1
                continue
            incoming = int(repo.git("rev-list", "--count", f"{wt.head}..{target}").stdout)
            own = int(repo.git("rev-list", "--count", f"{target}..{wt.head}").stdout)
            line(("  State: ", "muted"), ("clean", "success"), "; ", (str(own), "action"),
                 " branch-only commits; ", (str(incoming), "warning"), " incoming commits")
            if not incoming:
                say("  Already current", "success")
                counts["current"] += 1
                counts["unprocessed"] -= 1
                continue
            for commit in repo.git("log", "-5", "--format=%h%x00%ad%x00%an%x00%s", "--date=short", f"{wt.head}..{target}").stdout.splitlines():
                sha, date, name, subject = commit.split("\0", 3)
                line("    ", (sha, "commit"), "  ", (date, "muted"), "  ",
                     (name, "author"), "  ", subject)
            if incoming > 5:
                say(f"    … {incoming - 5} older commits omitted", "muted")
            if opts.dry_run:
                counts["planned"] += 1
            elif not confirm("Rebase?", opts.force):
                counts["declined"] += 1
            else:
                branch = repo.git("symbolic-ref", "--quiet", "--short", "HEAD", cwd=wt.path, check=False).stdout.strip()
                if branch != wt.branch or repo.oid("refs/heads/" + wt.branch) != wt.head or repo.blocked(wt):
                    say("  BLOCKED: worktree changed since the summary", "warning")
                    counts["blocked"] += 1
                else:
                    result = repo.git("-c", "core.editor=true", "rebase", "--no-autostash", "--no-update-refs", target, cwd=wt.path, check=False, capture=False)
                    if result.returncode:
                        paths = [repo.git("rev-parse", "--path-format=absolute", "--git-path", p, cwd=wt.path).stdout.strip() for p in ("rebase-merge", "rebase-apply")]
                        if any(Path(p).exists() for p in paths):
                            abort = repo.git("rebase", "--abort", cwd=wt.path, check=False, capture=False)
                            if abort.returncode:
                                counts["failed"] += 1
                                counts["unprocessed"] -= 1
                                raise UnitError(f"Abort failed in {wt.path}; recover with git -C '{wt.path}' rebase --abort.")
                        if repo.oid("refs/heads/" + wt.branch) != wt.head:
                            counts["failed"] += 1
                            counts["unprocessed"] -= 1
                            raise UnitError(f"Rebase failed and {wt.branch} moved from {wt.head}; inspect {wt.path} before retrying.")
                        say(f"  FAILED: rebase aborted; branch retained at {wt.head[:8]} ({wt.path})", "error")
                        counts["failed"] += 1
                    else:
                        say("  Rebase successful", "success")
                        counts["rebased"] += 1
            counts["unprocessed"] -= 1
    except Quit:
        say("Stopping.")
    finally:
        summary(counts)
    return int(bool(counts["failed"] or counts["blocked"] or counts["unprocessed"]))


@dataclass
class Source:
    branch: str
    ref: str
    oid: str
    title: str
    author: str = ""
    identity: str = ""
    upstream: str = ""


def github_repo(repo):
    # Preserve the logical GitHub identity when Git rewrites transport URLs.
    url = repo.config("remote.origin.url")
    if not url:
        raise UnitError("No origin remote is configured.")
    if "://" in url:
        parsed = urlparse(url)
        host, path = parsed.hostname, parsed.path.lstrip("/")
    else:
        match = re.fullmatch(r"(?:[^@/:]+@)?([^/:]+):(.+)", url)
        if not match:
            raise UnitError("PR discovery requires a GitHub origin URL.")
        host, path = match.groups()
    path = path.removesuffix(".git").rstrip("/")
    if not host or not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", path):
        raise UnitError("Cannot resolve GitHub host/owner/repo from origin.")
    return host, path


def gh_json(host, *args):
    output = run(["gh", "api", "--hostname", host, *args]).stdout
    try:
        return json.loads(output)
    except ValueError:
        raise UnitError("gh returned invalid JSON; discovery is incomplete.") from None


def author(repo, requested, host=None):
    login = requested or repo.config("unit.author") or repo.config("github.user") or repo.config("user.name")
    if login == "@me":
        if host is None:
            host, _ = github_repo(repo)
        login = gh_json(host, "user")["login"]
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9-]*", login or ""):
        raise UnitError("Git identity is not a GitHub login; use --author LOGIN or git config unit.author LOGIN.")
    if host:
        login = gh_json(host, "users/" + login)["login"]
    return login


def pulls(host, name):
    pages = gh_json(host, "--method", "GET", "--paginate", "--slurp", f"repos/{name}/pulls", "-f", "state=open", "-f", "per_page=100")
    if not isinstance(pages, list) or any(not isinstance(page, list) for page in pages):
        raise UnitError("Incomplete PR discovery; expected all paginated results.")
    result = []
    for page in pages:
        for pr in page:
            if not isinstance(pr, dict) or not all(key in pr for key in ("number", "title", "user", "head", "base", "draft", "state")):
                raise UnitError("Incomplete PR metadata; reconciliation cancelled.")
            if pr["state"] == "open":
                result.append(pr)
    return result


def discover(repo, opts):
    if opts.kind == "prs" or opts.ready:
        host, name = github_repo(repo)
        login = None if opts.all else author(repo, opts.author, host)
        prs = pulls(host, name)
        prs = [p for p in prs if (login is None or p["user"]["login"].lower() == login.lower())
               and (not opts.ready or not p["draft"]) and (not opts.base or p["base"]["ref"] == opts.base)]
    else:
        prs = []
        login = None if opts.all or opts.prefix is not None else author(repo, opts.author)
    if opts.kind == "prs":
        sources = []
        for pr in prs:
            head = pr["head"]
            same_repo = (head.get("repo") or {}).get("full_name", "").lower() == name.lower()
            owner = head.get("label", "").partition(":")[0] or pr["user"]["login"]
            branch = head["ref"] if same_repo else f"pr/{pr['number']}/{owner}/{head['ref']}"
            repo.valid_name(branch)
            sources.append(Source(branch, f"refs/pull/{pr['number']}/head", head["sha"],
                                  f"#{pr['number']} {pr['title']}", pr["user"]["login"],
                                  f"{host}/{name}#{pr['number']}", f"origin/{head['ref']}" if same_repo else ""))
        return sources
    prefix = opts.prefix if opts.prefix is not None else ((login + "/") if login else "")
    ready = {p["head"]["ref"] for p in prs if (p["head"].get("repo") or {}).get("full_name", "").lower() == name.lower()} if opts.ready else None
    default = repo.git("symbolic-ref", "--quiet", "refs/remotes/origin/HEAD", check=False).stdout.strip().removeprefix("refs/remotes/origin/")
    sources = []
    for line in repo.git("ls-remote", "--heads", "origin").stdout.splitlines():
        oid, ref = line.split("\t", 1)
        branch = ref.removeprefix("refs/heads/")
        if branch in ("main", "master", default) or not branch.startswith(prefix) or (ready is not None and branch not in ready):
            continue
        repo.valid_name(branch)
        sources.append(Source(branch, ref, oid, branch, login or "", upstream="origin/" + branch))
    return sorted(sources, key=lambda s: s.branch)


def windows(repo):
    if not shutil.which("tmux"):
        return []
    result = run(["tmux", "list-windows", "-a", "-F", "#{window_id}\t#{session_name}\t#{@unit_path}\t#{@unit_repo_root}"], check=False)
    if result.returncode:
        if run(["tmux", "list-sessions"], check=False).returncode == 0:
            raise UnitError("Unable to read tmux windows.")
        return []
    result_windows, seen = [], set()
    for line in result.stdout.splitlines():
        window, session, path, root = line.split("\t")
        if window not in seen and path and repo.managed(Path(path)) and (root == str(repo.root) or (not root and session == repo.session)):
            result_windows.append((window, Path(path).resolve()))
            seen.add(window)
    return result_windows


def open_unit(repo, ticket, branch, ref):
    executable = Path(__file__).resolve().parent.parent / "bin" / "unit-new"
    run([executable, "--start-ref", ref, "--no-fetch", "--background", ticket, branch], cwd=repo.root, capture=False)


def current_window():
    pane = os.environ.get("TMUX_PANE")
    if not os.environ.get("TMUX") or not pane:
        return ""
    return run(["tmux", "display-message", "-p", "-t", pane, "#{window_id}"], check=False).stdout.strip()


def defer_window_close(window):
    # Closing our own controlling terminal would interrupt the remaining actions
    # and summary. A detached helper waits for this CLI to exit first.
    helper = """
import os, subprocess, sys, time
parent, window, tmux = int(sys.argv[1]), sys.argv[2], sys.argv[3]
for _ in range(1200):
    try:
        os.kill(parent, 0)
    except ProcessLookupError:
        subprocess.run([tmux, 'kill-window', '-t', window], check=False)
        break
    time.sleep(0.05)
"""
    subprocess.Popen([sys.executable, "-c", helper, str(os.getpid()), window, shutil.which("tmux")],
                     start_new_session=True, stdin=subprocess.DEVNULL,
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def import_units(repo, opts):
    if opts.exact and not shutil.which("tmux"):
        raise UnitError("--exact requires tmux.")
    sources = discover(repo, opts)
    if not opts.dry_run:
        repo.git("fetch", "--prune", "origin", "+refs/heads/*:refs/remotes/origin/*", capture=False)
    counts = Counter(created=0, existing=0, opened=0, closed=0, scheduled=0, declined=0, failed=0, planned=0)
    desired, completed_branches = set(), set()
    all_worktrees = repo.worktrees()
    recorded_sources = {w.branch: repo.config(f"branch.{w.branch}.unitSource") for w in all_worktrees if w.branch} if opts.kind == "prs" else {}
    say(f"Selected {len(sources)} {opts.kind}; {'exact unit-window reconciliation' if opts.exact else 'create missing worktrees only'}", "heading")
    try:
        for source in sources:
            say("")
            say(source.title, "heading")
            line(("  Author: ", "muted"), (source.author or "(all)", "author"),
                 ("; branch: ", "muted"), (source.branch, "branch"))
            if source.branch in completed_branches:
                say("  Shares an already selected worktree", "muted")
                continue
            matching = [w for w in all_worktrees if w.branch and (w.branch == source.branch or
                        (source.identity and recorded_sources.get(w.branch) == source.identity))]
            if len(matching) > 1:
                say("  FAILED: multiple worktrees match this source", "error")
                counts["failed"] += 1
                continue
            if matching:
                wt = matching[0]
                if not repo.managed(wt.path) or wt.prunable or not wt.path.is_dir():
                    say(f"  FAILED: source checked out outside available managed worktrees ({wt.path})", "error")
                    counts["failed"] += 1
                    continue
                repo.warn_name(wt)
                desired.add(wt.path)
                counts["existing"] += 1
                line(("  Existing: ", "success"), str(wt.path))
                if opts.exact and not any(path == wt.path for _, path in windows(repo)):
                    if opts.dry_run:
                        say("  Would open missing window", "action")
                        counts["planned"] += 1
                    elif confirm("Open missing window?", opts.force):
                        try:
                            open_unit(repo, repo.ticket(wt.path), wt.branch, "refs/heads/" + wt.branch)
                            counts["opened"] += 1
                        except UnitError as error:
                            say(f"  FAILED: {error}", "error")
                            counts["failed"] += 1
                    else:
                        counts["declined"] += 1
                completed_branches.add(source.branch)
                continue
            path = repo.valid_name(source.branch)
            desired.add(path)
            local = repo.oid("refs/heads/" + source.branch)
            recorded = repo.config(f"branch.{source.branch}.unitSource")
            if path.exists() or path.is_symlink() or (local and local != source.oid and (not source.identity or recorded != source.identity)):
                say(f"  FAILED: unrelated path/local branch collision ({path})", "error")
                counts["failed"] += 1
                continue
            line(("  CREATE: ", "action"), str(path))
            if opts.dry_run:
                counts["planned"] += 1
                completed_branches.add(source.branch)
                continue
            if not confirm("Import?", opts.force):
                counts["declined"] += 1
                continue
            try:
                if source.identity:
                    destination = "refs/unit-import/pr/" + source.identity.rsplit("#", 1)[1]
                    repo.git("fetch", "origin", f"+{source.ref}:{destination}", capture=False)
                else:
                    destination = "refs/remotes/" + source.upstream
                actual = repo.oid(destination)
                if actual != source.oid:
                    raise UnitError("Remote head changed during discovery; rerun to review the new head.")
                open_unit(repo, source.branch, source.branch, destination)
                if source.identity:
                    repo.git("config", f"branch.{source.branch}.unitSource", source.identity)
                if source.upstream and repo.oid("refs/remotes/" + source.upstream) == actual:
                    repo.git("branch", "--set-upstream-to=" + source.upstream, source.branch)
                counts["created"] += 1
                say("  Unit created", "success")
                completed_branches.add(source.branch)
            except UnitError as error:
                say(f"  FAILED: {error}", "error")
                counts["failed"] += 1
        if opts.exact:
            if counts["failed"] or counts["declined"]:
                say("Window closures cancelled: imports failed or were declined.", "warning")
            else:
                keep, closures = set(), []
                for window, path in windows(repo):
                    if path in desired and path not in keep:
                        keep.add(path)
                    else:
                        closures.append((window, path))
                if not opts.dry_run and keep != desired:
                    raise UnitError("Required windows are missing; window closures cancelled.")
                active_window = current_window()
                # Prompt for the active window last, and do not terminate this
                # CLI until all other window actions have completed.
                closures.sort(key=lambda item: item[0] == active_window)
                for window, path in closures:
                    commands = run(["tmux", "list-panes", "-t", window, "-F", "#{pane_current_command}"], check=False).stdout.splitlines()
                    say(f"  CLOSE: {repo.ticket(path)} ({window}); panes: {', '.join(commands)}", "warning")
                    if opts.dry_run:
                        counts["planned"] += 1
                    elif confirm("Close window and terminate its panes?", opts.force):
                        if (window, path) not in windows(repo):
                            raise UnitError("Window ownership changed; rerun reconciliation.")
                        if window == active_window:
                            defer_window_close(window)
                            say("  Current window will close after this command exits.")
                            counts["scheduled"] += 1
                        else:
                            run(["tmux", "kill-window", "-t", window])
                            counts["closed"] += 1
                    else:
                        counts["declined"] += 1
    except Quit:
        say("Stopping; no further actions or window closures.")
        counts["declined"] += 1
    finally:
        summary(counts)
    return int(bool(counts["failed"] or (opts.exact and counts["declined"])))


def parser(mode):
    result = argparse.ArgumentParser(prog="unit-" + mode, description=(
        "Rebase units onto origin/master. Conflicts are aborted and reported." if mode == "sync" else
        "Create missing units from origin PRs or branches; defaults to the Git user."))
    if mode == "import":
        result.add_argument("kind", choices=("prs", "branches"))
        result.add_argument("-A", "--author", help="GitHub login; default: unit.author, github.user, user.name")
        result.add_argument("-p", "--prefix", help="literal branch prefix (branches only)")
        result.add_argument("-r", "--ready", action="store_true", help="only open non-draft PRs / their origin branches")
        result.add_argument("-e", "--exact", action="store_true", help="reconcile managed windows; retain worktrees and branches")
    result.add_argument("-a", "--all", action="store_true", help="all managed worktrees" if mode == "sync" else "all authors / origin branches")
    result.add_argument("-b", "--base", default="master" if mode == "sync" else None, help="base branch (default: master)" if mode == "sync" else "filter PR base branch")
    confirmation = result.add_mutually_exclusive_group()
    confirmation.add_argument("-f", "--force", action="store_true", help="skip confirmation prompts; retain failure safeguards")
    confirmation.add_argument("--ask", action="store_true", help="prompt per action (default)")
    result.add_argument("-n", "--dry-run", action="store_true", help="preview only; no local changes")
    return result


def main(mode):
    cli = parser(mode)
    opts = cli.parse_args()
    if mode == "import":
        if opts.all and opts.author:
            cli.error("--all and --author are mutually exclusive")
        if opts.kind == "prs" and opts.prefix is not None:
            cli.error("--prefix applies to branches only")
        if opts.kind == "branches" and opts.base and not opts.ready:
            cli.error("--base requires --ready in branch mode")
        if opts.kind == "branches" and opts.prefix is not None and opts.author and not opts.ready:
            cli.error("use --prefix or --author, not both (except with --ready)")
    try:
        repo = Repo()
        if opts.base and repo.git("check-ref-format", "refs/heads/" + opts.base, check=False).returncode:
            raise UnitError("--base must be a valid branch name.")
        with repo.lock(opts.dry_run):
            return sync(repo, opts) if mode == "sync" else import_units(repo, opts)
    except (UnitError, OSError, KeyError, TypeError, ValueError) as error:
        say(f"Error: {error}", "error")
        return 1
    except (KeyboardInterrupt, EOFError):
        say("Interrupted; inspect Git state before retrying.", "warning")
        return 130
