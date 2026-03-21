#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import json
import os
from pathlib import Path
import shutil
import sys
import subprocess
import re
from typing import Dict, List, Optional, Tuple
import pwd
import tempfile
import time

# -------------------------
# Domain -> Linux group mapping
# -------------------------
DOMAIN_GROUPS = {
    "verification": "verif",
    "adesign":      "ades",
    "dft":          "dft",
    "alayout":      "alay",
    "pd":           "pdes",
    "design":       "ddes",
}
ALL_DOMAINS = list(DOMAIN_GROUPS.keys())

DIR_MODE = 0o3775  # rwxrwsr-x with SGID

# -------------------------
# Helpers
# -------------------------
def mode_str(mode: int) -> str:
    return oct(mode).replace("0o", "")

def run(cmd: List[str], check=True, capture=False, cwd: Optional[str] = None) -> subprocess.CompletedProcess:
    """
    Python 3.6-safe wrapper.
    - If capture=True, returns stdout/stderr as strings using universal_newlines=True.
    """
    if capture:
        return subprocess.run(
            cmd,
            check=check,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            cwd=cwd
        )
    return subprocess.run(cmd, check=check, cwd=cwd)

def warn(msg: str):
    print(f"[WARN] {msg}", file=sys.stderr)

def die(msg: str, code: int = 2):
    print(f"[ERROR] {msg}", file=sys.stderr)
    sys.exit(code)

def user_exists_local(uid: str) -> bool:
    """Check if a Linux user exists on this system (local/LDAP/IPA via NSS)."""
    uid = (uid or "").strip()
    if not uid:
        return False
    try:
        pwd.getpwnam(uid)
        return True
    except KeyError:
        return False
    except Exception as e:
        warn(f"user_exists_local({uid}) check failed: {e}")
        return False

def ensure_dir(path: Path, group: str, dry_run: bool, owner_user: Optional[str] = None):
    """
    Create dir (if missing), then enforce:
      - chmod DIR_MODE
      - chgrp group
      - optional chown owner_user (user workspace folders)
    """
    actions = []

    if not path.exists():
        actions.append(f"mkdir -p {path}")
        if not dry_run:
            path.mkdir(parents=True, exist_ok=True)

    actions.append(f"chmod {mode_str(DIR_MODE)} {path}")
    if not dry_run:
        try:
            os.chmod(path, DIR_MODE)
        except PermissionError as e:
            warn(f"chmod failed for {path}: {e}")

    actions.append(f"chgrp {group} {path}")
    if not dry_run:
        try:
            shutil.chown(path, group=group)
        except LookupError:
            warn(f"Group '{group}' not found on this system for {path}.")
        except PermissionError as e:
            warn(f"chgrp failed for {path}: {e}")

    if owner_user:
        actions.append(f"chown {owner_user}:{group} {path}")
        if not dry_run:
            try:
                shutil.chown(path, user=owner_user, group=group)
            except LookupError:
                warn(f"User '{owner_user}' not found on this system for {path}.")
            except PermissionError as e:
                warn(f"chown failed for {path}: {e}")

    print(" ; ".join(actions))

def normalize_domains(dom_arg: Optional[str]):
    if not dom_arg:
        return ALL_DOMAINS
    wanted = [d.strip() for d in dom_arg.split(",") if d.strip()]
    norm = []
    lower_map = {k.lower(): k for k in ALL_DOMAINS}
    for w in wanted:
        key = w.lower()
        if key in lower_map:
            norm.append(lower_map[key]); continue
        candidates = [orig for low, orig in lower_map.items() if low.startswith(key)]
        if len(candidates) == 1:
            norm.append(candidates[0])
        elif len(candidates) > 1:
            die(f"Ambiguous domain '{w}': matches {candidates}", 2)
        else:
            die(f"Unknown domain '{w}'. Valid: {', '.join(ALL_DOMAINS)}", 2)
    seen, out = set(), []
    for d in norm:
        if d not in seen:
            out.append(d); seen.add(d)
    return out

def json_domain_to_folder(dom: str) -> Optional[str]:
    if not dom:
        return None
    d = dom.strip().lower()
    alias = {
        "verif": "verification",
        "verification": "verification",
        "pd": "pd",
        "pdes": "pd",
        "physicaldesign": "pd",
        "physical_design": "pd",
        "design": "design",
        "ddes": "design",
        "dft": "dft",
        "alayout": "alayout",
        "layout": "alayout",
        "adesign": "adesign",
        "analog": "adesign",
        "analogdesign": "adesign",
    }
    d = re.sub(r"[^a-z]", "", d)
    return alias.get(d, d if d in DOMAIN_GROUPS else None)

def load_users_json(path: Path) -> Dict:
    try:
        with path.open("r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        die(f"Failed to read JSON {path}: {e}", 2)

# -------------------------
# Project tree creation (unchanged)
# -------------------------
def create_project_tree(base: Path, proj: str, project_group: str, domains, dry_run: bool, label: str,
                        create_user_dirs: bool, users_by_domain: Dict[str, List[str]],
                        require_user_exists: bool = True):
    if not base.exists():
        die(f"{label} base path does not exist: {base}", 1)

    proj_dirname = proj.lower()
    root = base / proj_dirname
    print(f"\n==> {label} Project root: {root} (group: {project_group})")
    ensure_dir(root, project_group, dry_run)

    for dom in domains:
        dom_group = DOMAIN_GROUPS[dom]
        dom_dir = root / dom
        users_dir = dom_dir / "users"

        print(f"==> {label} Domain: {dom}  Path: {dom_dir}  Group: {dom_group}")
        ensure_dir(dom_dir, dom_group, dry_run)
        ensure_dir(users_dir, dom_group, dry_run)

        if create_user_dirs:
            ulist = users_by_domain.get(dom, [])
            if ulist:
                print(f"    -> Creating user dirs under {users_dir} for: {', '.join(ulist)}")

            for u in ulist:
                u = (u or "").strip()
                if not u:
                    continue
                if require_user_exists and (not user_exists_local(u)):
                    warn(f"Skipping workspace for missing user '{u}' (not found on system): {users_dir / u}")
                    continue
                ensure_dir(users_dir / u, dom_group, dry_run, owner_user=u)

# -------------------------
# Samba provisioning (SSH + sudo samba-tool)
# -------------------------
def ssh_samba_tool(host: str, ssh_user: str, samba_cmd: List[str], dry_run: bool,
                   ssh_key: str,
                   timeout_sec: int = 8):
    full = [
        "ssh",
        "-i", ssh_key,
        "-o", "BatchMode=yes",
        "-o", "StrictHostKeyChecking=accept-new",
        "-o", f"ConnectTimeout={timeout_sec}",
        f"{ssh_user}@{host}",
        "sudo", "-n",
    ] + samba_cmd

    if dry_run:
        print("[DRY] " + " ".join(full))
        return subprocess.CompletedProcess(full, 0)

    p = subprocess.run(full, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    if p.returncode != 0:
        out = (p.stdout or "").strip()
        err = (p.stderr or "").strip()
        raise RuntimeError(
            "Remote command failed\n"
            f"  rc={p.returncode}\n"
            f"  CMD: {' '.join(full)}\n"
            f"  STDOUT: {out}\n"
            f"  STDERR: {err}"
        )
    return p

def ensure_samba_group_and_members(host: str, ssh_user: str, group: str, members: List[str],
                                  dry_run: bool, ssh_key: str):
    uniq = []
    seen = set()
    for m in members:
        m = (m or "").strip()
        if m and m not in seen:
            uniq.append(m); seen.add(m)

    exists = True
    try:
        ssh_samba_tool(host, ssh_user, ["samba-tool", "group", "show", group], dry_run, ssh_key)
    except Exception:
        exists = False

    if not exists:
        print(f"==> Creating Samba group: {group} on {host}")
        ssh_samba_tool(host, ssh_user, ["samba-tool", "group", "add", group], dry_run, ssh_key)

    if not uniq:
        print("==> No members to add to Samba group.")
        return

    print(f"==> Adding {len(uniq)} members to Samba group '{group}' on {host}")
    ok = 0
    fail = 0
    for u in uniq:
        try:
            ssh_samba_tool(host, ssh_user, ["samba-tool", "group", "addmembers", group, u], dry_run, ssh_key)
            print(f"    [OK] {u}")
            ok += 1
        except Exception as e:
            warn(f"Failed to add {u}: {e}")
            fail += 1
    print(f"==> Samba addmembers summary: OK={ok} FAIL={fail}")

# -------------------------
# SVN repo creation (same)
# -------------------------
def create_svn_repo(repo_root: Path, svn_base_url: str, project: str, domains: List[str],
                    svn_http_user: Optional[str], svn_http_pass: Optional[str],
                    dry_run: bool):
    repo_path = repo_root / project
    repo_url = f"{svn_base_url.rstrip('/')}/{project}"

    print(f"\n==> SVN repo path: {repo_path}")
    print(f"==> SVN repo url : {repo_url}")

    if not repo_root.exists():
        cmd = ["sudo", "mkdir", "-p", str(repo_root)]
        if dry_run:
            print("[DRY] " + " ".join(cmd))
        else:
            run(cmd, check=True)

        for cmd2 in (["sudo", "chown", "-R", "apache:apache", str(repo_root)],
                     ["sudo", "chmod", "-R", "2775", str(repo_root)]):
            if dry_run:
                print("[DRY] " + " ".join(cmd2))
            else:
                subprocess.run(cmd2, check=False)

    if (repo_path / "conf").is_dir() and (repo_path / "db").is_dir():
        print("==> Repo already exists on disk. Skipping svnadmin create.")
    else:
        cmd = ["sudo", "-u", "apache", "svnadmin", "create", str(repo_path)]
        if dry_run:
            print("[DRY] " + " ".join(cmd))
        else:
            run(cmd, check=True)

        for cmd2 in (["sudo", "chown", "-R", "apache:apache", str(repo_path)],
                     ["sudo", "chmod", "-R", "2775", str(repo_path)]):
            if dry_run:
                print("[DRY] " + " ".join(cmd2))
            else:
                subprocess.run(cmd2, check=False)

    auth = []
    if svn_http_user:
        auth += ["--username", svn_http_user]
    if svn_http_pass is not None and svn_http_pass != "":
        auth += ["--non-interactive", "--password", svn_http_pass]

    def svn_mkdir(urls: List[str], msg: str):
        cmd = ["svn", "mkdir"] + auth + ["-m", msg] + urls
        if dry_run:
            print("[DRY] " + " ".join(cmd))
            return
        subprocess.run(cmd, check=False)

    print("==> Creating trunk/branches/tags...")
    svn_mkdir([f"{repo_url}/trunk", f"{repo_url}/branches", f"{repo_url}/tags"],
              "Create standard layout (trunk/branches/tags)")

    print("==> Creating domain folders under trunk...")
    for d in domains:
        svn_mkdir([f"{repo_url}/trunk/{d}"], f"Add domain folder {d}")

# -------------------------
# Blocks parsing / SVN blocks / authz update
# -------------------------
def sanitize_block_name(name: str) -> str:
    n = (name or "").strip()
    n = re.sub(r"\s+", "_", n)
    n = re.sub(r"[^A-Za-z0-9_\-\.]", "_", n)
    n = re.sub(r"_+", "_", n)
    return n.strip("._-") or "BLOCK"

def extract_blocks_per_user(data: Dict) -> Dict[str, List[str]]:
    """
    Builds { block_name: [uid1, uid2, ...] }
    Supports JSON keys:
      - assigned_blocks (preferred)
      - blocks (legacy/backward compatibility)
    """
    out: Dict[str, List[str]] = {}
    for u in data.get("users", []):
        uid = (u.get("uid") or "").strip()
        if not uid:
            continue

        blocks = u.get("assigned_blocks", None)
        if not blocks:
            blocks = u.get("blocks", None)

        if not blocks:
            continue

        if isinstance(blocks, str):
            blocks = [b.strip() for b in blocks.split(",") if b.strip()]
        if not isinstance(blocks, list):
            continue

        for b in blocks:
            bname = sanitize_block_name(str(b))
            out.setdefault(bname, [])
            if uid not in out[bname]:
                out[bname].append(uid)

    return out

def create_svn_blocks(svn_base_url: str, project: str,
                      blocks_map: Dict[str, List[str]],
                      svn_http_user: Optional[str], svn_http_pass: Optional[str],
                      dry_run: bool):
    repo_url = f"{svn_base_url.rstrip('/')}/{project}"
    auth = []
    if svn_http_user:
        auth += ["--username", svn_http_user]
    if svn_http_pass is not None and svn_http_pass != "":
        auth += ["--non-interactive", "--password", svn_http_pass]

    def svn_mkdir(urls: List[str], msg: str):
        cmd = ["svn", "mkdir"] + auth + ["-m", msg] + urls
        if dry_run:
            print("[DRY] " + " ".join(cmd))
            return
        subprocess.run(cmd, check=False)

    if not blocks_map:
        print("==> No blocks found in JSON (per-user). Skipping SVN blocks creation.")
        return

    print("==> Creating /trunk/blocks container...")
    svn_mkdir([f"{repo_url}/trunk/blocks"], "Create blocks container (trunk/blocks)")

    print(f"==> Creating {len(blocks_map)} blocks under trunk/blocks ...")
    for blk in sorted(blocks_map.keys()):
        svn_mkdir([f"{repo_url}/trunk/blocks/{blk}"], f"Create block {blk}")

def authz_group_name(project: str, block: str) -> str:
    p = re.sub(r"[^A-Za-z0-9_\-]", "_", project.strip().lower())
    b = re.sub(r"[^A-Za-z0-9_\-]", "_", block.strip())
    return f"{p}__{b}"

def parse_authz(content: str) -> Tuple[List[str], Dict[str, List[str]], Dict[str, List[str]]]:
    lines = content.splitlines(True)
    groups: Dict[str, List[str]] = {}
    sections: Dict[str, List[str]] = {}

    cur_section = None
    header: List[str] = []
    buf: List[str] = []

    def commit_section(sec: str, body_lines: List[str]):
        if sec == "[groups]":
            for ln in body_lines:
                s = ln.strip()
                if not s or s.startswith("#") or s.startswith(";"):
                    continue
                if "=" not in s:
                    continue
                k, v = s.split("=", 1)
                k = k.strip()
                members = [m.strip() for m in v.split(",") if m.strip()]
                groups[k] = members
        else:
            sections[sec] = body_lines[:]

    for ln in lines:
        m = re.match(r"^\s*\[[^\]]+\]\s*$", ln)
        if m:
            if cur_section is None:
                header = buf[:]
            else:
                commit_section(cur_section, buf)
            cur_section = ln.strip()
            buf = []
        else:
            buf.append(ln)

    if cur_section is None:
        header = lines[:]
    else:
        commit_section(cur_section, buf)

    return header, groups, sections

def render_authz(header: List[str], groups: Dict[str, List[str]], sections: Dict[str, List[str]]) -> str:
    out: List[str] = []
    out.extend(header)

    out.append("[groups]\n")
    keys = sorted(groups.keys(), key=lambda k: (k != "admins", k))
    for k in keys:
        out.append(f"{k} = {', '.join(groups[k])}\n")
    out.append("\n")

    def sec_sort(s: str):
        if s == "[/]":
            return (0, s)
        return (1, s)

    for sec in sorted(sections.keys(), key=sec_sort):
        out.append(f"{sec}\n")
        out.extend(sections[sec])
        if not (len(sections[sec]) > 0 and sections[sec][-1].endswith("\n")):
            out.append("\n")
        out.append("\n")

    return "".join(out)

def update_authz_for_blocks(authz_path: Path, project: str,
                            blocks_map: Dict[str, List[str]],
                            dry_run: bool,
                            default_other_access: str = "r"):
    if not blocks_map:
        print("==> No blocks to update in authz.")
        return

    if not authz_path.exists():
        die(f"authz file not found: {authz_path}", 2)

    content = authz_path.read_text(encoding="utf-8", errors="replace")
    header, groups, sections = parse_authz(content)

    if "admins" not in groups:
        groups["admins"] = []

    proj_key = project.strip().lower()

    for blk, members in blocks_map.items():
        gname = authz_group_name(proj_key, blk)
        existing = groups.get(gname, [])
        merged = []
        seen = set()
        for m in existing + members:
            m = (m or "").strip()
            if m and m not in seen:
                merged.append(m)
                seen.add(m)
        groups[gname] = merged

        sec = f"[{proj_key}:/trunk/blocks/{blk}]"
        body = [
            "@admins = rw\n",
            f"@{gname} = rw\n",
            f"* = {default_other_access}\n",
        ]
        sections[sec] = body

    new_content = render_authz(header, groups, sections)

    if dry_run:
        print(f"[DRY] Would update authz: {authz_path}")
        print(f"[DRY] Blocks groups added/updated: {', '.join([authz_group_name(proj_key, b) for b in sorted(blocks_map.keys())])}")
        return

    bak = authz_path.with_suffix(authz_path.suffix + ".bak")
    shutil.copy2(str(authz_path), str(bak))
    authz_path.write_text(new_content, encoding="utf-8")
    print(f"==> Updated authz: {authz_path} (backup: {bak})")

# -------------------------
# NEW: env_scripts/projects project creation (Option A)
#   URL: <svn_base_url>/env_scripts/projects/<projectname>
#   Template: /proj5/REL/env_scripts/projects/ref_cad/latest
#   Replace: ref_pj -> <projectname> (content + file/dir names)
#   Commit, then env_release
# -------------------------

def svn_auth_args(svn_http_user: Optional[str], svn_http_pass: Optional[str]) -> List[str]:
    auth = []
    if svn_http_user:
        auth += ["--username", svn_http_user]
    if svn_http_pass is not None and svn_http_pass != "":
        auth += ["--non-interactive", "--password", svn_http_pass]
    return auth

def svn_url_exists(url: str, auth: List[str], dry_run: bool) -> bool:
    # best-effort existence check
    cmd = ["svn", "ls"] + auth + [url]
    if dry_run:
        print("[DRY] " + " ".join(cmd))
        return True
    p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    return p.returncode == 0

def copy_tree_skip_svn(src: Path, dst: Path, dry_run: bool):
    """
    Copy directory tree from src -> dst, skipping any .svn folders/files.
    Python 3.6 compatible (no dirs_exist_ok).
    """
    if dry_run:
        print(f"[DRY] Copy template: {src} -> {dst} (skip .svn)")
        return

    if not src.exists() or not src.is_dir():
        die(f"Template path not found or not a directory: {src}", 2)

    # ensure dst exists
    dst.mkdir(parents=True, exist_ok=True)

    for root, dirs, files in os.walk(str(src)):
        # skip .svn directories
        dirs[:] = [d for d in dirs if d != ".svn"]
        rel = os.path.relpath(root, str(src))
        dst_root = dst if rel == "." else (dst / rel)
        dst_root.mkdir(parents=True, exist_ok=True)

        # copy files
        for fn in files:
            if fn == ".svn":
                continue
            s = Path(root) / fn
            if ".svn" in s.parts:
                continue
            d = dst_root / fn
            # ensure parent exists
            d.parent.mkdir(parents=True, exist_ok=True)
            try:
                shutil.copy2(str(s), str(d))
            except Exception as e:
                warn(f"Failed to copy {s} -> {d}: {e}")

def replace_in_file(filepath: str, old_name: str, new_name: str,
                    dry_run: bool = False, ignore_case: bool = False):
    # protect svn admin area
    if "/.svn/" in filepath or filepath.endswith("/.svn"):
        return
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        flags = re.IGNORECASE if ignore_case else 0
        pattern = re.compile(re.escape(old_name), flags)

        if pattern.search(content):
            new_content = pattern.sub(new_name, content)

            if not dry_run:
                with open(filepath, "w", encoding="utf-8") as f:
                    f.write(new_content)

            print(f"[UPDATED CONTENT] {filepath}")

    except Exception:
        # Skip binary/unreadable files
        return

def rename_path(path: str, old_name: str, new_name: str,
                dry_run: bool = False, ignore_case: bool = False) -> str:
    # protect svn admin area
    if "/.svn/" in path or path.endswith("/.svn"):
        return path

    dirname, basename = os.path.split(path)

    flags = re.IGNORECASE if ignore_case else 0
    pattern = re.compile(re.escape(old_name), flags)

    if pattern.search(basename):
        new_basename = pattern.sub(new_name, basename)
        new_path = os.path.join(dirname, new_basename)

        if not dry_run:
            try:
                os.rename(path, new_path)
            except Exception as e:
                warn(f"rename failed {path} -> {new_path}: {e}")
                return path

        print(f"[RENAMED] {path}  ->  {new_path}")
        return new_path

    return path

def process_directory_rename(root_dir: str, old_name: str, new_name: str,
                            dry_run: bool = False, ignore_case: bool = False):
    # Walk bottom-up to safely rename directories
    for root, dirs, files in os.walk(root_dir, topdown=False):
        # never touch .svn
        if "/.svn" in root or root.endswith("/.svn"):
            continue
        dirs[:] = [d for d in dirs if d != ".svn"]

        # Replace inside file contents
        for file in files:
            full_path = os.path.join(root, file)
            if "/.svn/" in full_path:
                continue
            replace_in_file(full_path, old_name, new_name, dry_run, ignore_case)

        # Rename files
        for file in files:
            old_path = os.path.join(root, file)
            if "/.svn/" in old_path:
                continue
            rename_path(old_path, old_name, new_name, dry_run, ignore_case)

        # Rename directories
        for d in dirs:
            old_dir = os.path.join(root, d)
            if "/.svn/" in old_dir:
                continue
            rename_path(old_dir, old_name, new_name, dry_run, ignore_case)

def create_env_scripts_project(svn_base_url: str, projectname: str,
                               svn_http_user: Optional[str], svn_http_pass: Optional[str],
                               template_path: Path,
                               old_word: str,
                               dry_run: bool,
                               ignore_case: bool,
                               do_release: bool):
    base = svn_base_url.rstrip("/")
    env_projects_url = f"{base}/env_scripts/projects"
    target_url = f"{env_projects_url}/{projectname}"

    auth = svn_auth_args(svn_http_user, svn_http_pass)

    print(f"\n=== ENV_SCRIPTS PROJECT CREATE ===")
    print(f"==> Target SVN URL   : {target_url}")
    print(f"==> Template path    : {template_path}")
    print(f"==> Replace word     : {old_word} -> {projectname}")
    print(f"==> Dry run          : {dry_run}")

    # 1) ensure parent exists (best-effort)
    if not svn_url_exists(env_projects_url, auth, dry_run):
        warn(f"Parent URL not accessible: {env_projects_url}. Make sure repo/path exists.")
        # continue anyway; mkdir may fail with clearer message

    # 2) create folder if missing
    if svn_url_exists(target_url, auth, dry_run):
        print("==> Target URL already exists. Will checkout and update contents.")
    else:
        cmd_mkdir = ["svn", "mkdir"] + auth + ["-m", f"Create env_scripts project {projectname}", target_url]
        if dry_run:
            print("[DRY] " + " ".join(cmd_mkdir))
        else:
            p = subprocess.run(cmd_mkdir, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
            if p.returncode != 0:
                warn(f"svn mkdir failed rc={p.returncode}: {(p.stderr or '').strip()}")
                # If it failed due to existing, continue; otherwise die
                if "already exists" not in (p.stderr or "").lower():
                    die("Cannot create env_scripts project folder in SVN.", 2)

    # 3) checkout to temp
    ts = time.strftime("%Y%m%d_%H%M%S")
    workdir = Path(tempfile.mkdtemp(prefix=f"envproj_{projectname}_{ts}_"))
    wc = workdir / projectname

    cmd_co = ["svn", "checkout"] + auth + [target_url, str(wc)]
    if dry_run:
        print("[DRY] " + " ".join(cmd_co))
    else:
        p = subprocess.run(cmd_co, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        if p.returncode != 0:
            die(f"svn checkout failed: {(p.stderr or '').strip()}", 2)

    # 4) copy template into WC
    # copy into wc root; do NOT overwrite .svn
    if dry_run:
        print(f"[DRY] Populate working copy from template into: {wc}")
    else:
        if not wc.exists():
            die(f"Working copy path missing after checkout: {wc}", 2)
        copy_tree_skip_svn(template_path, wc, dry_run=False)

    # 5) rename within working copy
    process_directory_rename(str(wc), old_word, projectname, dry_run=dry_run, ignore_case=ignore_case)

    # 6) svn add + commit
    cmd_add = ["svn", "add", "--force", "."] + auth
    cmd_status = ["svn", "status"] + auth
    cmd_commit = ["svn", "commit"] + auth + ["-m", f"Add env_scripts project {projectname} from template"]

    if dry_run:
        print("[DRY] (cwd) " + str(wc))
        print("[DRY] " + " ".join(cmd_add))
        print("[DRY] " + " ".join(cmd_status))
        print("[DRY] " + " ".join(cmd_commit))
    else:
        subprocess.run(cmd_add, cwd=str(wc), check=False)
        st = subprocess.run(cmd_status, cwd=str(wc), stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        if st.stdout:
            print("==> svn status:\n" + st.stdout.strip())
        p = subprocess.run(cmd_commit, cwd=str(wc), stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        if p.returncode != 0:
            warn(f"svn commit failed rc={p.returncode}: {(p.stderr or '').strip()}")
            # don't die; sometimes no changes to commit
        else:
            out = (p.stdout or "").strip()
            if out:
                print(out)

    # 7) release
    if do_release:
        cmd_rel = ["python", "/proj5/REL/bin/env_release.py", "--category", "projects", "--proj", projectname]
        if dry_run:
            print("[DRY] " + " ".join(cmd_rel))
        else:
            print(f"==> Releasing env project via env_release.py ...")
            r = subprocess.run(cmd_rel, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
            if r.stdout:
                print(r.stdout.strip())
            if r.returncode != 0:
                warn(f"env_release.py failed rc={r.returncode}: {(r.stderr or '').strip()}")

    print(f"==> Working copy location: {wc}")
    print("=== ENV_SCRIPTS PROJECT CREATE DONE ===")

# -------------------------
# CLI
# -------------------------
def parse_args():
    ap = argparse.ArgumentParser(
        description="Create EDA project trees (BASE+optional SCRATCH), optional Samba provisioning, "
                    "create SVN repo and domains, and create blocks under trunk/blocks from JSON per-user "
                    "and update /svn/authz for block-specific RW.\n"
                    "NEW: create env_scripts/projects/<project> from template ref_cad/latest, rename ref_pj -> project, commit, release."
    )
    ap.add_argument("--base-path", "-b", required=True, help="BASE path (e.g. /CX_PROJ)")
    ap.add_argument("--proj", "-p", required=True, help="Project name (e.g. SEMICON3)")
    ap.add_argument("--dom", "-d", help="Comma-separated domain list. Default: all domains.")
    ap.add_argument("--project-group", "-g", help="Linux group for project root (default: project name lowercased)")
    ap.add_argument("--scratch-base-path", "-s", help="SCRATCH_BASE path (e.g. /CX_RUN_NEW)")
    ap.add_argument("--dry-run", action="store_true", help="Show actions without changing anything.")
    ap.add_argument("--create-user-dirs", action="store_true",
                    help="Create per-user directories under <domain>/users/<uid> from JSON mapping.")

    ap.add_argument("--users-json", help="Path to users_config_*.json")
    ap.add_argument("--users-json-dir", help="Directory containing users_config_<proj>_*.json; picks latest by mtime")

    ap.add_argument("--provision-samba-group", action="store_true",
                    help="Create Samba project group and add users from JSON via ssh + sudo samba-tool.")
    ap.add_argument("--samba-host", default="192.168.92.30", help="Samba/AD host (default: 192.168.92.30)")
    ap.add_argument("--samba-ssh-user", default="user1", help="SSH user on samba host (default: user1)")
    ap.add_argument("--ssh-key", default="/home/cad/.ssh/id/id_ed25519",
                    help="SSH private key to reach samba host (default: /home/cad/.ssh/id/id_ed25519)")

    ap.add_argument("--create-svn-repo", action="store_true",
                    help="Create SVN repo and create trunk/branches/tags + domain folders under trunk.")
    ap.add_argument("--svn-repo-root", default="/proj5/projects/svn/repos",
                    help="Filesystem path where repositories live")
    ap.add_argument("--svn-base-url", default="http://localhost/svn",
                    help="SVN base URL (default: http://localhost/svn)")
    ap.add_argument("--svn-http-user", default=os.environ.get("SVN_AUTH_USER", ""),
                    help="SVN HTTP username (or env SVN_AUTH_USER)")
    ap.add_argument("--svn-http-pass", default=os.environ.get("SVN_AUTH_PASS", None),
                    help="SVN HTTP password (or env SVN_AUTH_PASS). If omitted, SVN prompts interactively.")

    ap.add_argument("--create-svn-blocks", action="store_true",
                    help="Create /trunk/blocks/<block> from JSON per-user blocks.")
    ap.add_argument("--authz-path", default="/svn/authz",
                    help="Authz file path to update (default: /svn/authz)")
    ap.add_argument("--authz-other-access", default="r",
                    help="Access for others at block path: 'r' (read) or '' (no access). Default: r")
    ap.add_argument("--reload-httpd", action="store_true",
                    help="Reload httpd after updating authz.")

    ap.add_argument("--no-user-exists-check", action="store_true",
                    help="Create workspace dirs even if uid not found on the system (NOT recommended).")

    # NEW
    ap.add_argument("--create-env-project", action="store_true",
                    help="Create/update SVN path <svn-base-url>/env_scripts/projects/<proj> by copying template "
                         "/proj5/REL/env_scripts/projects/ref_cad/latest, rename ref_pj-><proj>, commit, then release.")
    ap.add_argument("--env-template-path", default="/proj5/REL/env_scripts/projects/ref_cad/latest",
                    help="Template source path (default: /proj5/REL/env_scripts/projects/ref_cad/latest)")
    ap.add_argument("--env-old-name", default="ref_pj",
                    help="Word to replace inside template (default: ref_pj)")
    ap.add_argument("--env-ignore-case", action="store_true",
                    help="Case-insensitive replace during env project rename (default: off)")
    ap.add_argument("--no-env-release", action="store_true",
                    help="Do NOT run env_release.py after committing env project")

    return ap.parse_args()

def main():
    args = parse_args()

    base = Path(args.base_path).resolve()
    proj = args.proj.strip()
    if not proj:
        die("Project name is empty", 2)

    project_group = args.project_group if args.project_group else proj.lower()
    domains = normalize_domains(args.dom)

    users_by_domain: Dict[str, List[str]] = {d: [] for d in domains}
    all_users: List[str] = []
    blocks_map: Dict[str, List[str]] = {}

    # -----------------------------------------------------------------
    # resolve JSON  (auto pick latest from /home/cad if not given)
    # -----------------------------------------------------------------
    json_path: Optional[Path] = None
    if args.users_json:
        json_path = Path(args.users_json).expanduser().resolve()
    elif args.users_json_dir:
        import glob
        d = Path(args.users_json_dir).expanduser().resolve()
        pattern = str(d / f"users_config_{proj.lower()}_*.json")
        matches = [Path(p) for p in glob.glob(pattern)]
        if not matches:
            die(f"No JSON files match {pattern}", 2)
        matches.sort(key=lambda p: p.stat().st_mtime, reverse=True)
        json_path = matches[0]
    else:
        search_dir = Path("/home/cad")
        pattern = f"users_config_{proj.lower()}_*.json"
        matches = list(search_dir.glob(pattern))
        if not matches:
            die(f"No JSON files found for project '{proj.lower()}' in {search_dir}", 2)
        matches.sort(key=lambda p: p.stat().st_mtime, reverse=True)
        json_path = matches[0]
    # -----------------------------------------------------------------

    data = None
    if json_path:
        if not json_path.exists():
            die(f"JSON not found: {json_path}", 2)
        print(f"==> Using users JSON: {json_path}")
        data = load_users_json(json_path)

        for u in data.get("users", []):
            uid = (u.get("uid") or "").strip()
            dom = json_domain_to_folder(u.get("domain", ""))
            if not uid:
                continue
            all_users.append(uid)
            if dom and dom in users_by_domain:
                users_by_domain[dom].append(uid)

        blocks_map = extract_blocks_per_user(data)

    require_user_exists = (not args.no_user_exists_check)

    print("=== Creating BASE tree ===")
    create_project_tree(base, proj, project_group, domains, args.dry_run,
                        label="BASE",
                        create_user_dirs=args.create_user_dirs,
                        users_by_domain=users_by_domain,
                        require_user_exists=require_user_exists)

    if args.scratch_base_path:
        scratch_base = Path(args.scratch_base_path).resolve()
        if not scratch_base.exists():
            actions = [f"mkdir -p {scratch_base}",
                       f"chmod {mode_str(DIR_MODE)} {scratch_base}",
                       f"chgrp {project_group} {scratch_base}"]
            print(" ; ".join(actions))
            if not args.dry_run:
                scratch_base.mkdir(parents=True, exist_ok=True)
                os.chmod(scratch_base, DIR_MODE)
                try:
                    shutil.chown(scratch_base, group=project_group)
                except LookupError:
                    warn(f"Group '{project_group}' not found for {scratch_base}.")

        print("\n=== Creating SCRATCH tree ===")
        create_project_tree(scratch_base, proj, project_group, domains, args.dry_run,
                            label="SCRATCH",
                            create_user_dirs=args.create_user_dirs,
                            users_by_domain=users_by_domain,
                            require_user_exists=require_user_exists)

    if args.provision_samba_group:
        if data is None:
            die("--provision-samba-group requires users JSON (auto-picked from /home/cad).", 2)

        ssh_key = str(Path(args.ssh_key).expanduser().resolve())
        if not Path(ssh_key).exists():
            die(f"SSH key not found: {ssh_key}", 2)

        print(f"\n=== Provisioning Samba group '{project_group}' on {args.samba_host} ===")
        try:
            ensure_samba_group_and_members(
                host=args.samba_host,
                ssh_user=args.samba_ssh_user,
                group=project_group,
                members=all_users,
                dry_run=args.dry_run,
                ssh_key=ssh_key
            )
        except Exception as e:
            warn(f"Samba provisioning encountered errors: {e}")

    if args.create_svn_repo:
        print(f"\n=== Creating SVN repository '{proj.lower()}' ===")
        create_svn_repo(
            repo_root=Path(args.svn_repo_root).resolve(),
            svn_base_url=args.svn_base_url,
            project=proj.lower(),
            domains=domains,
            svn_http_user=args.svn_http_user.strip() if args.svn_http_user else None,
            svn_http_pass=args.svn_http_pass,
            dry_run=args.dry_run
        )

    if args.create_svn_blocks:
        if data is None:
            die("--create-svn-blocks requires users JSON (auto-picked from /home/cad).", 2)

        print(f"\n=== Creating SVN blocks for '{proj.lower()}' under trunk/blocks ===")
        create_svn_blocks(
            svn_base_url=args.svn_base_url,
            project=proj.lower(),
            blocks_map=blocks_map,
            svn_http_user=args.svn_http_user.strip() if args.svn_http_user else None,
            svn_http_pass=args.svn_http_pass,
            dry_run=args.dry_run
        )

        other_access = (args.authz_other_access or "").strip()
        if other_access not in ("r", ""):
            die("--authz-other-access must be 'r' or ''", 2)

        print(f"\n=== Updating authz for block permissions ({Path(args.authz_path)}) ===")
        update_authz_for_blocks(
            authz_path=Path(args.authz_path),
            project=proj.lower(),
            blocks_map=blocks_map,
            dry_run=args.dry_run,
            default_other_access=("r" if other_access == "r" else "")
        )

        if args.reload_httpd:
            cmd = ["sudo", "systemctl", "reload", "httpd"]
            if args.dry_run:
                print("[DRY] " + " ".join(cmd))
            else:
                subprocess.run(cmd, check=False)

    # NEW: env_scripts projects creation + commit + release
    if args.create_env_project:
        create_env_scripts_project(
            svn_base_url=args.svn_base_url,
            projectname=proj.lower(),
            svn_http_user=args.svn_http_user.strip() if args.svn_http_user else None,
            svn_http_pass=args.svn_http_pass,
            template_path=Path(args.env_template_path).resolve(),
            old_word=args.env_old_name,
            dry_run=args.dry_run,
            ignore_case=args.env_ignore_case,
            do_release=(not args.no_env_release),
        )

    print("\nDone.")

if __name__ == "__main__":
    main()

