#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os, sys, re, stat, shutil, argparse, subprocess, filecmp, difflib, time
from pathlib import Path
from typing import List, Tuple, Optional

# ---------------- CONFIG ----------------
BASE_ENV = Path("/proj5/REL/env_scripts")
SVN_BASE = "http://localhost/svn/env_scripts"
DEFAULT_DIR_MODE = 0o775
RELEASE_DIR_MODE  = 0o555  # after publish, make read/exec only
# ----------------------------------------

def run(cmd: List[str], cwd: Optional[Path] = None, check: bool = True) -> str:
    # Python 3.6 compatibility: use universal_newlines instead of text=True
    kwargs = {
        "stdout": subprocess.PIPE,
        "stderr": subprocess.STDOUT,
        "universal_newlines": True
    }
    if cwd is not None:
        kwargs["cwd"] = str(cwd)
    p = subprocess.run(cmd, **kwargs)
    if check and p.returncode != 0:
        print(p.stdout, end="")
        raise SystemExit("[ERROR] command failed: " + " ".join(cmd))
    return p.stdout

def ensure_dir(p: Path, mode: int = DEFAULT_DIR_MODE):
    p.mkdir(parents=True, exist_ok=True)
    try:
        os.chmod(p, mode)
    except Exception:
        pass

def read_lines(f: Path) -> List[str]:
    try:
        # Path.read_text supports errors= in 3.6
        return f.read_text(errors="ignore").splitlines(keepends=True)
    except Exception:
        return [f"<<binary or unreadable: {f}>>\n"]

def diff_files(a: Path, b: Path) -> List[str]:
    return list(difflib.unified_diff(read_lines(a), read_lines(b), fromfile=str(a), tofile=str(b)))

def compare_dirs(new: Path, old: Path):
    """
    Compare ONLY file contents.
    Ignore directories, permissions, mtimes, __pycache__, .svn
    """
    def list_files(root: Path) -> set:
        files = set()
        for r, dnames, fnames in os.walk(str(root)):
            dnames[:] = [d for d in dnames if not d.startswith('.') and d != "__pycache__"]
            for f in fnames:
                if f.startswith('.') or f.endswith('.pyc'):
                    continue
                rp = Path(r) / f
                files.add(rp.relative_to(root))
        return files

    if not old or not old.exists():
        return (sorted([new / p for p in list_files(new)]), [], [])

    a = list_files(new)
    b = list_files(old)

    added   = [new / rel for rel in sorted(a - b)]
    removed = [old / rel for rel in sorted(b - a)]

    changed = []
    for rel in sorted(a & b):
        na, ob = new / rel, old / rel
        try:
            if not filecmp.cmp(str(na), str(ob), shallow=False):
                changed.append((na, ob))
        except Exception:
            changed.append((na, ob))

    return (added, removed, changed)

def print_diff_summary(added, removed, changed):
    if added:
        print("\n[Added]")
        for p in added:
            print("  +", p)
    if removed:
        print("\n[Removed]")
        for p in removed:
            print("  -", p)
    if changed:
        print("\n[Changed]")
        for a, _ in changed:
            print("  *", a)

def update_latest_symlink(base: Path, target: Path):
    link = base / "latest"
    if link.is_symlink() or link.exists():
        link.unlink()
    link.symlink_to(target.name)  # relative link

def lock_release_dir(p: Path):
    for root, dirs, files in os.walk(str(p)):
        try:
            os.chmod(root, RELEASE_DIR_MODE)
        except Exception:
            pass
        for d in dirs:
            try:
                os.chmod(os.path.join(root, d), RELEASE_DIR_MODE)
            except Exception:
                pass
        for f in files:
            try:
                os.chmod(os.path.join(root, f), stat.S_IRUSR | stat.S_IRGRP | stat.S_IROTH)
            except Exception:
                pass

def svn_checkout(svn_url: str, dest: Path):
    print("[SVN] checkout {} -> {}".format(svn_url, dest))
    run(["svn", "checkout", svn_url, str(dest)], check=True)

def next_version_name(base: Path) -> Tuple[Optional[Path], str, Path]:
    """
    Projects/infra auto-increment versions as v1, v2, v3...
    """
    latest = base / "latest"
    prev_dir = latest.resolve() if latest.is_symlink() else None

    if not prev_dir or not prev_dir.exists():
        # Accept older style (v_1) and newer style (v1) when scanning
        existing = [p for p in base.glob("v*") if p.is_dir()]
        if existing:
            def parse_ver(name: str) -> int:
                m = re.match(r"^v_?(\d+)$", name)
                return int(m.group(1)) if m else -1
            existing.sort(key=lambda x: parse_ver(x.name))
            prev_dir = existing[-1]

    if not prev_dir:
        new_name = "v1"
        return None, new_name, base / new_name

    m = re.match(r"^v_?(\d+)$", prev_dir.name or "")
    cur = int(m.group(1)) if m else 0
    new_name = "v{}".format(cur + 1)
    return prev_dir, new_name, base / new_name

def tool_version_dirs(base: Path, version: str) -> Tuple[Optional[Path], Path]:
    """
    Tools are explicit versions: --version 2 -> v2
    Accept old latest targets too.
    """
    prev = (base / "latest").resolve() if (base / "latest").is_symlink() else None
    new_dir = base / "v{}".format(version)
    return prev, new_dir

def safe_reset(base: Path):
    if base.exists():
        ts = time.strftime("%Y%m%d_%H%M%S")
        backup = base.parent / "{}.bak_{}".format(base.name, ts)
        print("[RESET] Moving {} -> {}".format(base, backup))
        base.rename(backup)
    ensure_dir(base)

def manage_project_or_infra(base: Path, svn_url: str, reset: bool):
    if reset:
        safe_reset(base)
    ensure_dir(base)

    prev_dir, new_name, new_dir = next_version_name(base)
    if new_dir.exists():
        raise SystemExit("[ERROR] {} already exists. Choose reset or verify 'latest'.".format(new_dir))

    svn_checkout(svn_url, new_dir)

    if prev_dir and prev_dir.exists():
        added, removed, changed = compare_dirs(new_dir, prev_dir)
        if not added and not removed and not changed:
            print("[NO-OP] No changes vs previous. Cleaning up and keeping existing latest.")
            shutil.rmtree(str(new_dir))
            update_latest_symlink(base, prev_dir)
            return
        print_diff_summary(added, removed, changed)

    lock_release_dir(new_dir)
    update_latest_symlink(base, new_dir)
    print("[OK] New version {} published at {}".format(new_name, new_dir))
    print("[OK] latest -> {}".format(new_name))

def manage_tool(base: Path, svn_url: str, version: str, reset: bool):
    if not version:
        raise SystemExit("[ERROR] --version is required for --category tools")
    if reset:
        safe_reset(base)
    ensure_dir(base)

    prev_dir, new_dir = tool_version_dirs(base, version)
    if new_dir.exists():
        raise SystemExit("[ERROR] {} already exists. Pick a different --version or --reset first.".format(new_dir))

    svn_checkout(svn_url, new_dir)

    if prev_dir and prev_dir.exists():
        added, removed, changed = compare_dirs(new_dir, prev_dir)
        if not added and not removed and not changed:
            print("[NO-OP] No changes vs previous. Cleaning up, not switching 'latest'.")
            shutil.rmtree(str(new_dir))
            update_latest_symlink(base, prev_dir)
            return
        print_diff_summary(added, removed, changed)

    lock_release_dir(new_dir)
    update_latest_symlink(base, new_dir)
    print("[OK] Tool release {} published at {}".format(new_dir.name, new_dir))
    print("[OK] latest -> {}".format(new_dir.name))

def main():
    ap = argparse.ArgumentParser(description="Release script for /proj5/REL/env_scripts")
    ap.add_argument("--category", required=True, choices=["projects", "tools", "infra"], help="Release category")
    ap.add_argument("--proj", help="Project name (for --category projects)")
    ap.add_argument("--tool", help="Tool name (for --category tools)")
    ap.add_argument("--version", help="Tool version label (for --category tools); numeric recommended (e.g., 2)")
    ap.add_argument("--svn-base", default=SVN_BASE, help="Override SVN base URL")
    ap.add_argument("--reset", action="store_true", help="Re-initialize the category path (moves old tree to *.bak_<ts>)")
    args = ap.parse_args()

    if args.category == "projects":
        if not args.proj:
            raise SystemExit("[ERROR] --proj is mandatory for --category projects")
        base = BASE_ENV / "projects" / args.proj
        svn_url = "{}/projects/{}".format(args.svn_base, args.proj)
        manage_project_or_infra(base, svn_url, args.reset)

    elif args.category == "infra":
        base = BASE_ENV / "infra"
        svn_url = "{}/infra".format(args.svn_base)
        manage_project_or_infra(base, svn_url, args.reset)

    elif args.category == "tools":
        if not args.tool:
            raise SystemExit("[ERROR] --tool is mandatory for --category tools")
        base = BASE_ENV / "tools" / args.tool
        svn_url = "{}/tools/{}".format(args.svn_base, args.tool)
        manage_tool(base, svn_url, args.version, args.reset)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n[INTERRUPTED]")
        sys.exit(130)
