#!/usr/bin/env python3
import argparse
import hashlib
import json
import os
import subprocess
import sys


def run_metadata(manifest_path, filter_platform=None):
    cmd = [
        "cargo",
        "metadata",
        "--format-version",
        "1",
        "--manifest-path",
        manifest_path,
    ]
    if filter_platform:
        cmd.extend(["--filter-platform", filter_platform])
    result = subprocess.run(cmd, check=True, stdout=subprocess.PIPE, text=True)
    return json.loads(result.stdout)


def get_target_package_id(metadata, manifest_path):
    manifest_path = os.path.realpath(manifest_path)
    for package in metadata.get("packages", []):
        pkg_manifest = os.path.realpath(package.get("manifest_path", ""))
        if pkg_manifest == manifest_path:
            return package.get("id")
    return None


def collect_closure(metadata, target_id):
    id_to_node = {node["id"]: node for node in metadata.get("resolve", {}).get("nodes", [])}
    seen = set()
    queue = [target_id]

    while queue:
        current = queue.pop()
        if current in seen:
            continue
        seen.add(current)

        node = id_to_node.get(current)
        if not node:
            continue
        for dep in node.get("deps", []):
            dep_id = dep.get("pkg")
            if dep_id:
                queue.append(dep_id)

    return seen


def rustc_cfg():
    result = subprocess.run(["rustc", "--print", "cfg"], check=True, stdout=subprocess.PIPE, text=True)
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]

def rustc_sysroot():
    result = subprocess.run(["rustc", "--print", "sysroot"], check=True, stdout=subprocess.PIPE, text=True)
    return result.stdout.strip()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest-path", required=True)
    parser.add_argument("--out-dir", required=True)
    parser.add_argument("--filter-platform")
    parser.add_argument("--skip-sysroot-src", action="store_true")
    args = parser.parse_args()

    metadata = run_metadata(args.manifest_path, args.filter_platform)
    target_id = get_target_package_id(metadata, args.manifest_path)
    if not target_id:
        print("error: could not locate target package", file=sys.stderr)
        return 1

    closure_ids = collect_closure(metadata, target_id)
    id_to_pkg = {pkg["id"]: pkg for pkg in metadata.get("packages", [])}

    cfgs = rustc_cfg()
    crates = []
    pkg_to_lib = {}
    pkg_to_proc_macro = {}

    for pkg_id in closure_ids:
        pkg = id_to_pkg.get(pkg_id)
        if not pkg:
            continue
        is_root = pkg_id == target_id
        for target in pkg.get("targets", []):
            kind = set(target.get("kind", []))
            is_proc_macro = "proc-macro" in kind
            is_lib = "lib" in kind
            is_bin = "bin" in kind

            if is_proc_macro or is_lib or (is_root and is_bin):
                crate_index = len(crates)
                crate_entry = {
                    "root_module": target.get("src_path"),
                    "edition": target.get("edition"),
                    "deps": [],
                    "cfg": cfgs,
                    "env": {},
                    "is_workspace_member": pkg.get("source") is None,
                    "is_proc_macro": is_proc_macro,
                    "proc_macro_dylib_path": None,
                    "display_name": target.get("name"),
                    "crate_id": f"{pkg.get('name')}:{target.get('name')}",
                    "_pkg_id": pkg_id,
                }
                crates.append(crate_entry)

                if is_proc_macro:
                    pkg_to_proc_macro[pkg_id] = crate_index
                elif is_lib:
                    pkg_to_lib[pkg_id] = crate_index

    id_to_node = {node["id"]: node for node in metadata.get("resolve", {}).get("nodes", [])}
    for crate in crates:
        pkg_id = crate.get("_pkg_id")
        node = id_to_node.get(pkg_id)
        if not node:
            continue
        for dep in node.get("deps", []):
            dep_id = dep.get("pkg")
            if dep_id not in closure_ids:
                continue
            target_index = pkg_to_lib.get(dep_id) or pkg_to_proc_macro.get(dep_id)
            if target_index is None:
                continue
            crate["deps"].append({"crate": target_index, "name": dep.get("name")})

    for crate in crates:
        crate.pop("_pkg_id", None)

    sysroot = rustc_sysroot()
    sysroot_src = os.path.join(sysroot, "lib", "rustlib", "src", "rust", "library")

    project = {
        "crates": crates,
        "sysroot": sysroot,
    }
    if not args.skip_sysroot_src and os.path.isdir(sysroot_src):
        project["sysroot_src"] = sysroot_src

    digest_seed = os.path.realpath(args.manifest_path)
    if args.filter_platform:
        digest_seed += "|" + args.filter_platform
    if args.skip_sysroot_src:
        digest_seed += "|skip-sysroot-src"
    digest = hashlib.sha1(digest_seed.encode()).hexdigest()[:12]
    out_dir = os.path.join(args.out_dir, digest)
    os.makedirs(out_dir, exist_ok=True)

    out_path = os.path.join(out_dir, "rust-project.json")
    with open(out_path, "w", encoding="utf-8") as handle:
        json.dump(project, handle, indent=2, sort_keys=True)
        handle.write("\n")

    print(out_path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
