---
name: units
description: Use when the user wants to manage git worktrees as units of work for parallel agent workflows using the unit-* CLI commands.
---

# Units - Git Worktree Management

Manage git worktrees as units of work for parallel agent workflows.

## Instructions

When invoked, run the appropriate `unit-*` command and report the result. The user will handle directory changes themselves.

### Available Commands

| Command | Description |
|---------|-------------|
| `/units` or `/units list` | List all worktrees and their occupancy |
| `/units new <ticket>` | Create/open worktree + tmux unit window |
| `/units open <ticket>` | Create/open worktree + tmux unit window |
| `/units attach <ticket>` | Mark attachment to existing worktree |
| `/units complete <ticket>` | Cleanup worktree after merge |
| `/units sync` | Review/rebase current branch onto origin/master |
| `/units sync --all` | Review/rebase every managed worktree (alias usa) |
| `/units import prs` | Create missing units for the Git user's open PRs (alias uip) |
| `/units import branches` | Create missing units for the Git user's branch namespace (alias uib) |

## Command Details

### `/units` or `/units list`

```bash
unit-list
```

### `/units new <ticket>`

```bash
unit-new <ticket-name>
```

After running, report that the tmux unit window was opened and include the path:

```
Unit window opened: /path/to/.agents/<ticket>
```

### `/units open <ticket>`

```bash
unit-open <ticket-name>
```

### `/units attach <ticket>`

```bash
unit-attach <ticket-name>
```

After running, output the path for the user to cd into.

### `/units complete <ticket>`

```bash
unit-complete -y <ticket-name>
```

### `/units sync`

Run from within the worktree:

```bash
unit-sync
```

Use `unit-sync --all` (`usa`) to iterate all registered worktrees under the
configured agents directory. The default target is `origin/master`; use
`--base main` or another branch explicitly. Summaries show at most five incoming
commits with author, date and subject, plus branch/worktree naming warnings.
Conflicts are aborted and reported, then the batch continues. Failed/blocked
units produce a nonzero exit. Dirty or in-progress worktrees are not stashed.

### `/units import prs` and `/units import branches`

```bash
unit-import prs                       # uip: my open PRs, including drafts
unit-import prs --ready               # only non-draft PRs
unit-import prs --all                 # everyone in origin's GitHub repo
unit-import branches                 # uib: my <author>/ origin branches
unit-import branches --prefix alex/   # explicit namespace
```

The author defaults to `unit.author`, `github.user`, then the repository's Git
`user.name`. Use `--author LOGIN` to override or `--author @me` for the `gh`
account. Git display names need a login override. Branch ownership is a namespace
convention, not commit authorship. `--ready` in branch mode joins open non-draft
PR metadata and retains the namespace filter. `--all` removes author filtering.

Imports only create missing worktrees/windows by default. Existing worktrees,
commits and panes stay intact. Fork PRs get a namespaced local branch/ticket.
`--exact` additionally opens missing windows and closes extra/duplicate managed
unit windows in this repo; it keeps root/utility windows, worktrees and branches.
The chosen filters define the desired window set, including when author-filtered.
Closures terminate panes and are shown with pane commands before confirmation.
Failed imports or incomplete discovery prevent closures. An authenticated,
successful empty result may close all managed unit windows.

Shared flags: `-f/--force` skips prompts; `--ask` explicitly requests the default
per-action `y/N/q` prompt; `-n/--dry-run` previews without local changes.
`-a/--all` expands the selection, `-b/--base` selects the rebase target or filters
PR base, and imports accept `-A/--author`, `-p/--prefix`, `-r/--ready`, `-e/--exact`.
Noninteractive runs require `-f` or `-n` when an action needs confirmation.
Force never resets/stashes branches or overrides blocked worktrees.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `DOTF_AGENTS_WORKTREE_DIR` | `.agents` | Worktree directory name |

## Pane Naming

Format: `{repo}:{role}:{ticket}` where role is `main`, `right`, or `bottom`.
