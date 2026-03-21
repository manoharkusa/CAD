#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Semicon Web Orchestrator (FastAPI)
----------------------------------
Receives API request JSON, writes users_json to a file, then triggers createDir.py
as a subprocess. Returns job_id and provides endpoints to check status and logs.

Designed to run behind nginx reverse proxy at /semicon/
(e.g., nginx: location /semicon/ { proxy_pass http://127.0.0.1:8000/; })

Endpoints:
  GET  /              -> simple UI
  GET  /health        -> health check
  POST /api/run       -> start job
  GET  /api/job/{id}  -> job metadata/status
  GET  /api/job/{id}/log?tail=200 -> log tail
"""

import os
import json
import time
import uuid
import shlex
import pathlib
import logging
import subprocess
from datetime import datetime
from typing import Any, Dict, Optional, List

from fastapi import FastAPI, HTTPException, Query
from fastapi.responses import HTMLResponse, JSONResponse, PlainTextResponse
from pydantic import BaseModel, Field


# -----------------------------
# CONFIG (adjust if needed)
# -----------------------------
BASE_DIR = pathlib.Path(__file__).resolve().parent
CREATE_DIR_PY = os.environ.get("SEMICON_CREATEDIR_PY", str(BASE_DIR / "createDir.py"))
SETUP_SCRIPT = os.environ.get("SEMICON_SETUP_SCRIPT", "/proj5/REL/env_scripts/infra/latest/setup")
JOBS_DIR = pathlib.Path(os.environ.get("SEMICON_JOBS_DIR", str(BASE_DIR / "jobs"))).resolve()
USERS_JSON_DIR = pathlib.Path(os.environ.get("SEMICON_USERS_JSON_DIR", str(JOBS_DIR / "users_json"))).resolve()
LOG_DIR = pathlib.Path(os.environ.get("SEMICON_LOG_DIR", "/var/lib/semicon/logs")).resolve()

# Limit how many lines we keep in log tail response (UI safety)
MAX_TAIL_LINES = 2000

# -----------------------------
# Centralized Logging Setup
# -----------------------------
LOG_DIR.mkdir(parents=True, exist_ok=True)
API_LOG_FILE = LOG_DIR / "api.log"

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s | %(levelname)s | %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger("semicon-api")

# Add file handler for centralized logging
file_handler = logging.FileHandler(API_LOG_FILE)
file_handler.setFormatter(logging.Formatter('%(asctime)s | %(levelname)s | %(message)s', '%Y-%m-%d %H:%M:%S'))
logger.addHandler(file_handler)


def log_job(job_id: str, job_type: str, action: str, details: dict):
    """Log job activity to centralized log file"""
    msg = f"JOB:{job_id} | TYPE:{job_type} | ACTION:{action}"
    for k, v in details.items():
        msg += f" | {k.upper()}:{v}"
    logger.info(msg)


import re

def parse_env_from_log(log_content: str, var_name: str) -> Optional[str]:
    """Parse environment variable value from log output (e.g., 'setenv EXP_DIR /path/to/dir')"""
    # Match patterns like: setenv EXP_DIR  /path/to/dir
    pattern = rf'setenv\s+{var_name}\s+(\S+)'
    match = re.search(pattern, log_content)
    if match:
        return match.group(1)
    return None


def parse_dirs_from_log(log_content: str) -> dict:
    """Parse important directory paths from log output"""
    dirs = {}

    # Parse EXP_DIR
    exp_dir = parse_env_from_log(log_content, "EXP_DIR")
    if exp_dir:
        dirs["exp_dir"] = exp_dir

    # Parse WA_ROOT
    wa_root = parse_env_from_log(log_content, "WA_ROOT")
    if wa_root:
        dirs["wa_root"] = wa_root

    # Parse SCRATCH_ROOT
    scratch_root = parse_env_from_log(log_content, "SCRATCH_ROOT")
    if scratch_root:
        dirs["scratch_root"] = scratch_root

    # Parse PROJ_ROOT
    proj_root = parse_env_from_log(log_content, "PROJ_ROOT")
    if proj_root:
        dirs["proj_root"] = proj_root

    return dirs


# -----------------------------
# In-memory job state
# -----------------------------
# NOTE: This is fine for a single-node service. If you later need HA, store state in files/DB.
JOBS: Dict[str, Dict[str, Any]] = {}


# -----------------------------
# Request models
# -----------------------------
class SetupArgs(BaseModel):
    """Arguments for the setup command (user workspace setup)"""
    user: str = Field(..., description="Username to run setup as")
    proj: str = Field(..., description="Project name e.g. ProjectVLSI")
    domain: str = Field(..., description="Domain: ades|design|pd|alayout|verification|dft")
    rev: Optional[str] = Field(None, description="Project revision/version")
    block: Optional[str] = Field(None, description="Block name")
    exp: Optional[str] = Field(None, description="Experiment name")
    rtltag: Optional[str] = Field(None, description="RTL tag")


class SetupRequest(BaseModel):
    args: SetupArgs


class RunArgs(BaseModel):
    # mirrors createDir.py args, but in JSON-friendly form
    base_path: str = Field(..., description="e.g. /CX_PROJ")
    proj: str = Field(..., description="e.g. GANGA")
    dom: Optional[str] = Field(None, description="Comma list: pd,verification")
    project_group: Optional[str] = None
    scratch_base_path: Optional[str] = None

    dry_run: bool = False
    create_user_dirs: bool = False
    provision_samba_group: bool = False
    samba_host: str = "192.168.92.30"
    samba_ssh_user: str = "user1"
    ssh_key: str = "/home/cad/.ssh/id/id_ed25519"

    create_svn_repo: bool = False
    svn_repo_root: str = "/proj5/projects/svn/repos"
    svn_base_url: str = "http://localhost/svn"
    svn_http_user: Optional[str] = None
    svn_http_pass: Optional[str] = None

    create_svn_blocks: bool = False
    authz_path: str = "/svn/authz"
    authz_other_access: str = "r"
    reload_httpd: bool = False

    no_user_exists_check: bool = False

    create_env_project: bool = False
    env_template_path: str = "/proj5/REL/env_scripts/projects/ref_cad/latest"
    env_old_name: str = "ref_pj"
    env_ignore_case: bool = False
    no_env_release: bool = False


class RunRequest(BaseModel):
    args: RunArgs
    # This is the content of users JSON (your users_config_*.json structure)
    users_json: Dict[str, Any]


# -----------------------------
# Helpers
# -----------------------------
def ensure_dirs():
    JOBS_DIR.mkdir(parents=True, exist_ok=True)
    USERS_JSON_DIR.mkdir(parents=True, exist_ok=True)


def safe_proj_name(proj: str) -> str:
    # keep filenames safe
    out = "".join(ch if ch.isalnum() or ch in ("_", "-", ".") else "_" for ch in proj.strip().lower())
    return out or "project"


def build_setup_cmd(args: SetupArgs) -> List[str]:
    """
    Build the setup command to run as a specific user.
    The setup script is a tcsh script that sets up user workspace.
    """
    # Build the setup command arguments
    setup_args = f"source {SETUP_SCRIPT} -proj {shlex.quote(args.proj)} -domain {shlex.quote(args.domain)}"

    if args.rev:
        setup_args += f" -rev {shlex.quote(args.rev)}"
    if args.block:
        setup_args += f" -block {shlex.quote(args.block)}"
    if args.exp:
        setup_args += f" -exp {shlex.quote(args.exp)}"
    if args.rtltag:
        setup_args += f" -rtltag {shlex.quote(args.rtltag)}"

    # Run as the specified user using sudo -u
    cmd = ["sudo", "-u", args.user, "/usr/bin/tcsh", "-c", setup_args]
    return cmd


def build_createdir_cmd(args: RunArgs, users_json_path: str) -> List[str]:
    """
    Convert API args -> createDir.py CLI list
    No shell=True, so injection is avoided.
    """
    cmd = ["sudo", "python3", CREATE_DIR_PY]

    # required
    cmd += ["--base-path", args.base_path]
    cmd += ["--proj", args.proj]

    # optional
    if args.dom:
        cmd += ["--dom", args.dom]
    if args.project_group:
        cmd += ["--project-group", args.project_group]
    if args.scratch_base_path:
        cmd += ["--scratch-base-path", args.scratch_base_path]

    # flags
    if args.dry_run:
        cmd += ["--dry-run"]
    if args.create_user_dirs:
        cmd += ["--create-user-dirs"]

    # JSON input (explicit path)
    cmd += ["--users-json", users_json_path]

    # samba
    if args.provision_samba_group:
        cmd += ["--provision-samba-group"]
        cmd += ["--samba-host", args.samba_host]
        cmd += ["--samba-ssh-user", args.samba_ssh_user]
        cmd += ["--ssh-key", args.ssh_key]

    # svn repo
    if args.create_svn_repo:
        cmd += ["--create-svn-repo"]
        cmd += ["--svn-repo-root", args.svn_repo_root]
        cmd += ["--svn-base-url", args.svn_base_url]
        if args.svn_http_user:
            cmd += ["--svn-http-user", args.svn_http_user]
        if args.svn_http_pass is not None:
            cmd += ["--svn-http-pass", args.svn_http_pass]

    # svn blocks + authz
    if args.create_svn_blocks:
        cmd += ["--create-svn-blocks"]
        cmd += ["--authz-path", args.authz_path]
        cmd += ["--authz-other-access", args.authz_other_access]
        if args.reload_httpd:
            cmd += ["--reload-httpd"]

    if args.no_user_exists_check:
        cmd += ["--no-user-exists-check"]

    # env project
    if args.create_env_project:
        cmd += ["--create-env-project"]
        cmd += ["--env-template-path", args.env_template_path]
        cmd += ["--env-old-name", args.env_old_name]
        if args.env_ignore_case:
            cmd += ["--env-ignore-case"]
        if args.no_env_release:
            cmd += ["--no-env-release"]

    return cmd


def spawn_job(cmd: List[str], job_dir: pathlib.Path, check_createdir: bool = True) -> subprocess.Popen:
    """
    Start subprocess and redirect output to log file.
    """
    log_path = job_dir / "run.log"
    # line-buffered-ish for python: we also add env PYTHONUNBUFFERED=1
    env = os.environ.copy()
    env["PYTHONUNBUFFERED"] = "1"

    # Ensure createDir.py path exists (only for createDir jobs)
    if check_createdir and not os.path.exists(CREATE_DIR_PY):
        raise RuntimeError(f"createDir.py not found at: {CREATE_DIR_PY}")

    # Start process
    log_f = open(log_path, "a", encoding="utf-8", errors="replace")
    p = subprocess.Popen(
        cmd,
        stdout=log_f,
        stderr=subprocess.STDOUT,
        cwd=str(BASE_DIR),
        env=env,
        universal_newlines=True
    )
    return p


def job_status(job_id: str) -> Dict[str, Any]:
    j = JOBS.get(job_id)
    if not j:
        raise HTTPException(status_code=404, detail="job not found")

    p: Optional[subprocess.Popen] = j.get("proc")
    if p is None:
        return {**j, "state": "unknown"}

    rc = p.poll()
    if rc is None:
        state = "running"
    elif rc == 0:
        state = "success"
    else:
        state = "failed"

    out = dict(j)
    out.pop("proc", None)
    out["returncode"] = rc
    out["state"] = state
    return out


def read_tail(path: pathlib.Path, tail_lines: int) -> str:
    if not path.exists():
        return ""
    tail_lines = max(1, min(int(tail_lines), MAX_TAIL_LINES))

    # Efficient tail: read last ~64KB chunks until enough lines
    data = b""
    with open(path, "rb") as f:
        f.seek(0, os.SEEK_END)
        size = f.tell()
        chunk = 65536
        pos = size
        while pos > 0 and data.count(b"\n") < tail_lines + 1:
            pos = max(0, pos - chunk)
            f.seek(pos)
            data = f.read(size - pos) + data
            size = pos
            if pos == 0:
                break

    text = data.decode("utf-8", errors="replace")
    lines = text.splitlines()
    return "\n".join(lines[-tail_lines:]) + ("\n" if lines else "")


# -----------------------------
# FastAPI app
# -----------------------------
app = FastAPI(title="Semicon Tool Orchestrator", version="1.0")


@app.get("/health")
def health():
    return {"ok": True, "host": os.uname().nodename, "jobs": len(JOBS)}


@app.get("/", response_class=HTMLResponse)
def index():
    # Enhanced UI with job monitoring dashboard
    return """
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Semicon API - Dashboard</title>
  <style>
    * { box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background: #f5f7fa; }
    h2 { color: #333; margin-bottom: 20px; }
    .container { max-width: 1400px; margin: 0 auto; }
    .stats { display: flex; gap: 16px; margin-bottom: 20px; }
    .stat-card { background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); flex: 1; }
    .stat-card h3 { margin: 0 0 8px 0; color: #666; font-size: 14px; }
    .stat-card .value { font-size: 32px; font-weight: bold; color: #333; }
    .stat-card.success .value { color: #22c55e; }
    .stat-card.failed .value { color: #ef4444; }
    .stat-card.running .value { color: #3b82f6; }
    .box { background: white; border-radius: 10px; padding: 20px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .box h3 { margin-top: 0; color: #333; border-bottom: 1px solid #eee; padding-bottom: 10px; }
    table { width: 100%; border-collapse: collapse; font-size: 14px; }
    th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
    th { background: #f8f9fa; font-weight: 600; color: #555; }
    tr:hover { background: #f8f9fa; }
    .status { padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 500; }
    .status.success { background: #dcfce7; color: #166534; }
    .status.failed { background: #fee2e2; color: #991b1b; }
    .status.running { background: #dbeafe; color: #1e40af; }
    .status.unknown { background: #f3f4f6; color: #6b7280; }
    .btn { padding: 6px 12px; border: none; border-radius: 6px; cursor: pointer; font-size: 12px; }
    .btn-primary { background: #3b82f6; color: white; }
    .btn-primary:hover { background: #2563eb; }
    .log-viewer { background: #1e1e1e; color: #d4d4d4; padding: 16px; border-radius: 8px; font-family: 'Consolas', monospace; font-size: 12px; max-height: 400px; overflow-y: auto; white-space: pre-wrap; word-break: break-all; }
    .filters { display: flex; gap: 12px; margin-bottom: 16px; }
    .filters select, .filters input { padding: 8px 12px; border: 1px solid #ddd; border-radius: 6px; }
    code { background: #f1f5f9; padding: 2px 6px; border-radius: 4px; font-size: 13px; }
    .refresh-btn { float: right; }
    .endpoints { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 12px; }
    .endpoint { background: #f8f9fa; padding: 12px; border-radius: 8px; }
    .endpoint code { background: #e2e8f0; }
    .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; }
    .modal-content { background: white; margin: 5% auto; padding: 20px; border-radius: 10px; max-width: 900px; max-height: 80vh; overflow-y: auto; }
    .modal-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #eee; padding-bottom: 10px; margin-bottom: 16px; }
    .close { font-size: 28px; cursor: pointer; color: #999; }
    .close:hover { color: #333; }
  </style>
</head>
<body>
  <div class="container">
    <h2>Semicon API Dashboard</h2>

    <div class="stats">
      <div class="stat-card"><h3>Total Jobs</h3><div class="value" id="total-jobs">-</div></div>
      <div class="stat-card success"><h3>Successful</h3><div class="value" id="success-jobs">-</div></div>
      <div class="stat-card failed"><h3>Failed</h3><div class="value" id="failed-jobs">-</div></div>
      <div class="stat-card running"><h3>Running</h3><div class="value" id="running-jobs">-</div></div>
    </div>

    <div class="box">
      <h3>Jobs <button class="btn btn-primary refresh-btn" onclick="loadJobs()">Refresh</button></h3>
      <div class="filters">
        <select id="filter-status" onchange="loadJobs()">
          <option value="">All Status</option>
          <option value="success">Success</option>
          <option value="failed">Failed</option>
          <option value="running">Running</option>
        </select>
        <select id="filter-type" onchange="loadJobs()">
          <option value="">All Types</option>
          <option value="createdir">Project Setup</option>
          <option value="setup">Workspace Setup</option>
        </select>
      </div>
      <table>
        <thead>
          <tr>
            <th>Job ID</th>
            <th>Type</th>
            <th>Project</th>
            <th>User</th>
            <th>Domain</th>
            <th>Status</th>
            <th>Created</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody id="jobs-table"></tbody>
      </table>
    </div>

    <div class="box">
      <h3>API Endpoints</h3>
      <div class="endpoints">
        <div class="endpoint"><code>POST /api/run</code> - Create project (createDir)</div>
        <div class="endpoint"><code>POST /api/setup</code> - Setup user workspace</div>
        <div class="endpoint"><code>GET /api/jobs</code> - List all jobs</div>
        <div class="endpoint"><code>GET /api/job/{id}</code> - Job status</div>
        <div class="endpoint"><code>GET /api/job/{id}/log</code> - Job log</div>
        <div class="endpoint"><code>GET /api/logs</code> - API activity log</div>
        <div class="endpoint"><code>GET /health</code> - Health check</div>
      </div>
    </div>

    <div class="box">
      <h3>API Activity Log <button class="btn btn-primary refresh-btn" onclick="loadApiLog()">Refresh</button></h3>
      <div class="log-viewer" id="api-log">Loading...</div>
    </div>
  </div>

  <!-- Log Modal -->
  <div id="log-modal" class="modal">
    <div class="modal-content">
      <div class="modal-header">
        <h3 id="modal-title">Job Log</h3>
        <span class="close" onclick="closeModal()">&times;</span>
      </div>
      <div class="log-viewer" id="modal-log"></div>
    </div>
  </div>

  <script>
    function loadJobs() {
      const status = document.getElementById('filter-status').value;
      const type = document.getElementById('filter-type').value;
      let url = '/api/jobs?limit=100';
      if (status) url += '&status=' + status;
      if (type) url += '&job_type=' + type;

      fetch(url)
        .then(r => r.json())
        .then(data => {
          document.getElementById('total-jobs').textContent = data.total;

          // Count by status
          let success = 0, failed = 0, running = 0;
          data.jobs.forEach(j => {
            if (j.state === 'success') success++;
            else if (j.state === 'failed') failed++;
            else if (j.state === 'running') running++;
          });
          document.getElementById('success-jobs').textContent = success;
          document.getElementById('failed-jobs').textContent = failed;
          document.getElementById('running-jobs').textContent = running;

          const tbody = document.getElementById('jobs-table');
          tbody.innerHTML = data.jobs.map(j => `
            <tr>
              <td><code>${j.job_id}</code></td>
              <td>${j.job_type === 'setup' ? 'Workspace' : 'Project'}</td>
              <td>${j.proj || '-'}</td>
              <td>${j.user || '-'}</td>
              <td>${j.domain || '-'}</td>
              <td><span class="status ${j.state}">${j.state}</span></td>
              <td>${formatDate(j.created_at)}</td>
              <td><button class="btn btn-primary" onclick="viewLog('${j.job_id}')">Log</button></td>
            </tr>
          `).join('');
        });
    }

    function loadApiLog() {
      fetch('/api/logs?tail=50')
        .then(r => r.text())
        .then(log => {
          document.getElementById('api-log').textContent = log || 'No logs yet';
        });
    }

    function viewLog(jobId) {
      document.getElementById('modal-title').textContent = 'Job Log: ' + jobId;
      document.getElementById('log-modal').style.display = 'block';
      fetch('/api/job/' + jobId + '/log?tail=500')
        .then(r => r.text())
        .then(log => {
          document.getElementById('modal-log').textContent = log || 'No log available';
        });
    }

    function closeModal() {
      document.getElementById('log-modal').style.display = 'none';
    }

    function formatDate(ts) {
      if (!ts) return '-';
      // Format: 20260305_174805 -> 2026-03-05 17:48:05
      const y = ts.slice(0,4), m = ts.slice(4,6), d = ts.slice(6,8);
      const h = ts.slice(9,11), mi = ts.slice(11,13), s = ts.slice(13,15);
      return `${y}-${m}-${d} ${h}:${mi}:${s}`;
    }

    // Close modal on outside click
    window.onclick = function(e) {
      if (e.target.id === 'log-modal') closeModal();
    }

    // Initial load
    loadJobs();
    loadApiLog();

    // Auto-refresh every 10 seconds
    setInterval(loadJobs, 10000);
    setInterval(loadApiLog, 10000);
  </script>
</body>
</html>
"""


@app.post("/api/run")
def api_run(req: RunRequest):
    ensure_dirs()

    # job id + dirs
    job_id = time.strftime("%Y%m%d_%H%M%S") + "_" + uuid.uuid4().hex[:8]
    job_dir = JOBS_DIR / job_id
    job_dir.mkdir(parents=True, exist_ok=True)

    proj_safe = safe_proj_name(req.args.proj)
    ts = time.strftime("%Y%m%d_%H%M%S")
    users_json_path = USERS_JSON_DIR / f"users_config_{proj_safe}_{ts}.json"

    # write users json
    try:
        with open(users_json_path, "w", encoding="utf-8") as f:
            json.dump(req.users_json, f, indent=2, sort_keys=False)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"failed to write users_json: {e}")

    # build command
    try:
        cmd = build_createdir_cmd(req.args, str(users_json_path))
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"invalid args: {e}")

    # store job metadata
    JOBS[job_id] = {
        "job_id": job_id,
        "job_type": "createdir",
        "created_at": ts,
        "proj": req.args.proj,
        "cmd": cmd,
        "cmd_pretty": " ".join(shlex.quote(x) for x in cmd),
        "users_json_path": str(users_json_path),
        "job_dir": str(job_dir),
        "log_path": str(job_dir / "run.log"),
    }

    # Log job start
    log_job(job_id, "createdir", "STARTED", {"proj": req.args.proj})

    # spawn and wait for completion
    try:
        p = spawn_job(cmd, job_dir)
        JOBS[job_id]["proc"] = p
        JOBS[job_id]["pid"] = p.pid
    except Exception as e:
        log_job(job_id, "createdir", "ERROR", {"error": str(e)})
        raise HTTPException(status_code=500, detail=f"failed to start job: {e}")

    # Wait for job to complete
    returncode = p.wait()

    # Determine final state
    if returncode == 0:
        state = "success"
        success = True
    else:
        state = "failed"
        success = False

    JOBS[job_id]["returncode"] = returncode
    JOBS[job_id]["state"] = state

    # Log job completion
    log_job(job_id, "createdir", state.upper(), {"proj": req.args.proj, "returncode": returncode})

    # Read log tail for response
    log_path = pathlib.Path(JOBS[job_id]["log_path"])
    log_tail = read_tail(log_path, tail_lines=50)

    # Parse directories from log
    full_log = read_tail(log_path, tail_lines=500)
    parsed_dirs = parse_dirs_from_log(full_log)

    # Calculate project directory
    project_dir = f"{req.args.base_path}/{req.args.proj}"
    scratch_dir = f"{req.args.scratch_base_path}/{req.args.proj}" if req.args.scratch_base_path else None

    return {
        "success": success,
        "job_id": job_id,
        "pid": JOBS[job_id].get("pid"),
        "state": state,
        "returncode": returncode,
        "project_dir": project_dir,
        "scratch_dir": scratch_dir,
        "proj_root": parsed_dirs.get("proj_root"),
        "cmd": JOBS[job_id]["cmd_pretty"],
        "log_tail": log_tail,
        "log_url": f"/api/job/{job_id}/log?tail=200",
        "status_url": f"/api/job/{job_id}",
    }


@app.get("/api/job/{job_id}")
def api_job(job_id: str):
    return JSONResponse(job_status(job_id))


@app.get("/api/job/{job_id}/log", response_class=PlainTextResponse)
def api_job_log(job_id: str, tail: int = 200):
    j = JOBS.get(job_id)
    if not j:
        raise HTTPException(status_code=404, detail="job not found")
    log_path = pathlib.Path(j["log_path"])
    return read_tail(log_path, tail_lines=tail)


@app.get("/api/jobs")
def api_jobs(
    limit: int = Query(50, description="Max jobs to return"),
    status: Optional[str] = Query(None, description="Filter by status: success|failed|running"),
    job_type: Optional[str] = Query(None, description="Filter by type: setup|createdir")
):
    """List all jobs with optional filters"""
    jobs_list = []
    for job_id, job in sorted(JOBS.items(), key=lambda x: x[1].get("created_at", ""), reverse=True):
        # Get current state
        j = dict(job)
        p = j.pop("proc", None)
        if p:
            rc = p.poll()
            if rc is None:
                j["state"] = "running"
            elif rc == 0:
                j["state"] = "success"
            else:
                j["state"] = "failed"
            j["returncode"] = rc

        # Apply filters
        if status and j.get("state") != status:
            continue
        if job_type:
            jt = j.get("job_type", "createdir")
            if jt != job_type:
                continue

        jobs_list.append({
            "job_id": j.get("job_id"),
            "job_type": j.get("job_type", "createdir"),
            "created_at": j.get("created_at"),
            "state": j.get("state", "unknown"),
            "returncode": j.get("returncode"),
            "proj": j.get("proj"),
            "user": j.get("user"),
            "domain": j.get("domain"),
            "block": j.get("block"),
            "exp": j.get("exp"),
        })

        if len(jobs_list) >= limit:
            break

    return {
        "total": len(JOBS),
        "returned": len(jobs_list),
        "jobs": jobs_list
    }


@app.get("/api/logs", response_class=PlainTextResponse)
def api_logs(tail: int = Query(100, description="Number of lines to return")):
    """Get centralized API log"""
    return read_tail(API_LOG_FILE, tail_lines=tail)


@app.post("/api/setup")
def api_setup(req: SetupRequest):
    """
    Run the setup command to create user workspace.
    This runs the setup script as the specified user.
    """
    ensure_dirs()

    # Validate domain
    valid_domains = ["ades", "design", "pd", "alayout", "verification", "dft"]
    if req.args.domain.lower() not in valid_domains:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid domain '{req.args.domain}'. Must be one of: {', '.join(valid_domains)}"
        )

    # job id + dirs
    job_id = time.strftime("%Y%m%d_%H%M%S") + "_" + uuid.uuid4().hex[:8]
    job_dir = JOBS_DIR / job_id
    job_dir.mkdir(parents=True, exist_ok=True)

    ts = time.strftime("%Y%m%d_%H%M%S")

    # build command
    try:
        cmd = build_setup_cmd(req.args)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"invalid args: {e}")

    # store job metadata
    JOBS[job_id] = {
        "job_id": job_id,
        "job_type": "setup",
        "created_at": ts,
        "user": req.args.user,
        "proj": req.args.proj,
        "domain": req.args.domain,
        "block": req.args.block,
        "exp": req.args.exp,
        "rtltag": req.args.rtltag,
        "cmd": cmd,
        "cmd_pretty": " ".join(shlex.quote(x) for x in cmd),
        "job_dir": str(job_dir),
        "log_path": str(job_dir / "run.log"),
    }

    # Log job start
    log_job(job_id, "setup", "STARTED", {
        "user": req.args.user, "proj": req.args.proj,
        "domain": req.args.domain, "block": req.args.block or "", "exp": req.args.exp or ""
    })

    # spawn and wait for completion
    try:
        p = spawn_job(cmd, job_dir, check_createdir=False)
        JOBS[job_id]["proc"] = p
        JOBS[job_id]["pid"] = p.pid
    except Exception as e:
        log_job(job_id, "setup", "ERROR", {"error": str(e)})
        raise HTTPException(status_code=500, detail=f"failed to start setup job: {e}")

    # Wait for job to complete
    returncode = p.wait()

    # Determine final state
    if returncode == 0:
        state = "success"
        success = True
    else:
        state = "failed"
        success = False

    JOBS[job_id]["returncode"] = returncode
    JOBS[job_id]["state"] = state

    # Log job completion
    log_job(job_id, "setup", state.upper(), {
        "user": req.args.user, "proj": req.args.proj, "returncode": returncode
    })

    # Read log tail for response
    log_path = pathlib.Path(JOBS[job_id]["log_path"])
    log_tail = read_tail(log_path, tail_lines=50)

    # Parse directories from log (EXP_DIR, WA_ROOT, SCRATCH_ROOT, etc.)
    full_log = read_tail(log_path, tail_lines=500)
    parsed_dirs = parse_dirs_from_log(full_log)

    return {
        "success": success,
        "job_id": job_id,
        "pid": JOBS[job_id].get("pid"),
        "state": state,
        "returncode": returncode,
        "user": req.args.user,
        "proj": req.args.proj,
        "domain": req.args.domain,
        "exp_dir": parsed_dirs.get("exp_dir"),
        "wa_root": parsed_dirs.get("wa_root"),
        "scratch_root": parsed_dirs.get("scratch_root"),
        "cmd": JOBS[job_id]["cmd_pretty"],
        "log_tail": log_tail,
        "log_url": f"/api/job/{job_id}/log?tail=200",
        "status_url": f"/api/job/{job_id}",
    }
