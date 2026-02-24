#!/usr/bin/env python3
"""
manage.py — Full-stack project management tool
Supports CLI mode (argparse) and GUI mode (tkinter).

Usage:
    python manage.py <command> [options]        # CLI
    python manage.py gui                        # GUI launcher

Commands:
    setup      Install all dependencies
    dev        Start development servers
    build      Build frontend for production
    test       Run test suites
    lint       Lint & type-check code
    deploy     Deploy via Docker Compose
    docker     Docker Compose operations
    clean      Remove build artefacts
    status     Show running service status
    logs       Tail service logs
    gui        Open the graphical management interface
"""

from __future__ import annotations

import argparse
import os
import platform
import shutil
import subprocess
import sys
import threading
from pathlib import Path
from typing import Optional

# ─── Constants ────────────────────────────────────────────────────────────────

ROOT = Path(__file__).resolve().parent.parent          # javascript/
FRONTEND_DIR = ROOT / "roadmap"                        # adjust to your frontend path
BACKEND_DIR = ROOT.parent / "python" / "samples"      # adjust to your backend path
COMPOSE_FILE = ROOT / "docker-compose.yml"

IS_WINDOWS = platform.system() == "Windows"
NPM = "npm.cmd" if IS_WINDOWS else "npm"
PYTHON = sys.executable

SERVICES = {
    "frontend": {"port": 5173, "dir": FRONTEND_DIR, "start": [NPM, "run", "dev"]},
    "backend":  {"port": 8000, "dir": BACKEND_DIR,  "start": [PYTHON, "-m", "uvicorn", "app.main:app", "--reload"]},
}

# ─── Helpers ──────────────────────────────────────────────────────────────────

def _run(cmd: list[str], cwd: Optional[Path] = None, capture: bool = False) -> subprocess.CompletedProcess:
    """Run a command, streaming output to stdout unless capture=True."""
    kwargs: dict = {"cwd": str(cwd) if cwd else None}
    if capture:
        kwargs.update(capture_output=True, text=True)
    return subprocess.run(cmd, **kwargs)  # noqa: S603


def _header(text: str) -> None:
    width = 60
    print("\n" + "─" * width)
    print(f"  {text}")
    print("─" * width)


def _success(msg: str) -> None:
    print(f"\033[32m✔  {msg}\033[0m")


def _error(msg: str) -> None:
    print(f"\033[31m✖  {msg}\033[0m", file=sys.stderr)


def _warn(msg: str) -> None:
    print(f"\033[33m⚠  {msg}\033[0m")


def _check_tool(name: str) -> bool:
    found = shutil.which(name) is not None
    if not found:
        _warn(f"'{name}' not found on PATH — some commands may fail.")
    return found

# ─── Commands ─────────────────────────────────────────────────────────────────

def cmd_setup(args: argparse.Namespace) -> int:
    """Install all project dependencies."""
    _header("Setup — Installing Dependencies")
    errors = 0

    # Node / frontend
    if FRONTEND_DIR.exists():
        _header("Frontend — npm install")
        result = _run([NPM, "install"], cwd=FRONTEND_DIR)
        if result.returncode == 0:
            _success("Frontend dependencies installed")
        else:
            _error("Frontend npm install failed")
            errors += 1
    else:
        _warn(f"Frontend directory not found: {FRONTEND_DIR}")

    # Python / backend
    req_files = list(BACKEND_DIR.rglob("requirements*.txt")) if BACKEND_DIR.exists() else []
    if req_files:
        for req in req_files:
            _header(f"Backend — pip install -r {req.name}")
            result = _run([PYTHON, "-m", "pip", "install", "-r", str(req)])
            if result.returncode == 0:
                _success(f"Installed {req.name}")
            else:
                _error(f"pip install failed for {req.name}")
                errors += 1
    else:
        _warn(f"No requirements*.txt found under {BACKEND_DIR}")

    return errors


def cmd_dev(args: argparse.Namespace) -> int:
    """Start frontend and/or backend development servers."""
    service = getattr(args, "service", "all")
    _header(f"Dev Servers — starting: {service}")

    targets = (
        {k: v for k, v in SERVICES.items() if k == service}
        if service != "all"
        else SERVICES
    )

    if not targets:
        _error(f"Unknown service '{service}'. Choose: {list(SERVICES.keys())} or 'all'")
        return 1

    procs: list[subprocess.Popen] = []
    for name, cfg in targets.items():
        cwd = cfg["dir"]
        if not cwd.exists():
            _warn(f"Directory not found for {name}: {cwd} — skipping")
            continue
        print(f"  Starting {name} on port {cfg['port']} …")
        proc = subprocess.Popen(cfg["start"], cwd=str(cwd))  # noqa: S603
        procs.append(proc)

    if not procs:
        _error("No services started.")
        return 1

    print("\n  Press Ctrl+C to stop all servers.\n")
    try:
        for p in procs:
            p.wait()
    except KeyboardInterrupt:
        _warn("Stopping servers…")
        for p in procs:
            p.terminate()
    return 0


def cmd_build(args: argparse.Namespace) -> int:
    """Build frontend for production."""
    _header("Build — Frontend Production Build")

    if not FRONTEND_DIR.exists():
        _error(f"Frontend directory not found: {FRONTEND_DIR}")
        return 1

    result = _run([NPM, "run", "build"], cwd=FRONTEND_DIR)
    if result.returncode == 0:
        _success("Frontend build complete → dist/")
    else:
        _error("Frontend build failed")
    return result.returncode


def cmd_test(args: argparse.Namespace) -> int:
    """Run frontend and backend test suites."""
    _header("Test Suites")
    errors = 0

    # Frontend tests
    if FRONTEND_DIR.exists():
        _header("Frontend — npm test")
        result = _run([NPM, "test", "--", "--run"], cwd=FRONTEND_DIR)
        if result.returncode == 0:
            _success("Frontend tests passed")
        else:
            _error("Frontend tests failed")
            errors += 1

    # Backend tests
    if BACKEND_DIR.exists():
        _header("Backend — pytest")
        result = _run([PYTHON, "-m", "pytest", "-v"], cwd=BACKEND_DIR)
        if result.returncode == 0:
            _success("Backend tests passed")
        else:
            _error("Backend tests failed")
            errors += 1

    return errors


def cmd_lint(args: argparse.Namespace) -> int:
    """Lint and type-check the codebase."""
    _header("Lint & Type-check")
    errors = 0

    if FRONTEND_DIR.exists():
        for script in (["npm", "run", "lint"], ["npm", "run", "type-check"]):
            result = _run(script, cwd=FRONTEND_DIR)
            errors += result.returncode

    if BACKEND_DIR.exists():
        for tool in (["ruff", "check", "."], ["mypy", "."]):
            if shutil.which(tool[0]):
                result = _run(tool, cwd=BACKEND_DIR)
                errors += result.returncode
            else:
                _warn(f"'{tool[0]}' not found — skipping")

    if errors == 0:
        _success("All lint checks passed")
    else:
        _error(f"{errors} lint check(s) failed")
    return errors


def cmd_deploy(args: argparse.Namespace) -> int:
    """Deploy using Docker Compose."""
    env = getattr(args, "env", "production")
    _header(f"Deploy — environment: {env}")

    compose = ["docker", "compose"]
    if COMPOSE_FILE.exists():
        compose += ["-f", str(COMPOSE_FILE)]

    cmds = [
        compose + ["pull"],
        compose + ["up", "-d", "--build", "--remove-orphans"],
    ]
    for cmd in cmds:
        result = _run(cmd, cwd=ROOT.parent)
        if result.returncode != 0:
            _error(f"Command failed: {' '.join(cmd)}")
            return result.returncode

    _success("Deployment complete")
    return 0


def cmd_docker(args: argparse.Namespace) -> int:
    """Docker Compose wrapper: up, down, ps, logs, pull, build."""
    action = getattr(args, "action", "ps")
    _header(f"Docker — {action}")

    compose = ["docker", "compose"]
    if COMPOSE_FILE.exists():
        compose += ["-f", str(COMPOSE_FILE)]

    action_map: dict[str, list[str]] = {
        "up":    compose + ["up", "-d"],
        "down":  compose + ["down"],
        "ps":    compose + ["ps"],
        "logs":  compose + ["logs", "--tail=50", "-f"],
        "pull":  compose + ["pull"],
        "build": compose + ["build"],
    }

    if action not in action_map:
        _error(f"Unknown docker action: {action}. Choose: {list(action_map)}")
        return 1

    return _run(action_map[action], cwd=ROOT.parent).returncode


def cmd_clean(args: argparse.Namespace) -> int:
    """Remove build artefacts and caches."""
    _header("Clean — Removing Build Artefacts")
    targets = [
        FRONTEND_DIR / "dist",
        FRONTEND_DIR / ".vite",
        FRONTEND_DIR / "coverage",
        BACKEND_DIR / "__pycache__",
        BACKEND_DIR / ".pytest_cache",
        BACKEND_DIR / ".mypy_cache",
        BACKEND_DIR / ".ruff_cache",
    ]
    for path in targets:
        if path.exists():
            shutil.rmtree(path, ignore_errors=True)
            print(f"  Removed: {path}")
    _success("Clean complete")
    return 0


def cmd_status(args: argparse.Namespace) -> int:
    """Show running service status."""
    _header("Service Status")

    # Docker Compose services
    _run(["docker", "compose", "ps"])

    # Local processes on known ports
    print("\nLocal ports:")
    for name, cfg in SERVICES.items():
        port = cfg["port"]
        if IS_WINDOWS:
            result = _run(
                ["netstat", "-ano", "-p", "TCP"],
                capture=True,
            )
            running = f":{port}" in (result.stdout or "")
        else:
            result = _run(["lsof", "-i", f"TCP:{port}", "-sTCP:LISTEN"], capture=True)
            running = bool(result.stdout)
        status = "\033[32mRUNNING\033[0m" if running else "\033[90mSTOPPED\033[0m"
        print(f"  {name:<12} port {port}  {status}")

    return 0


def cmd_logs(args: argparse.Namespace) -> int:
    """Tail Docker Compose service logs."""
    service = getattr(args, "service", "")
    _header(f"Logs — {service or 'all services'}")
    cmd = ["docker", "compose", "logs", "--tail=100", "-f"]
    if service:
        cmd.append(service)
    return _run(cmd, cwd=ROOT.parent).returncode

# ─── CLI ──────────────────────────────────────────────────────────────────────

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="manage.py",
        description="Full-stack project management (CLI + GUI)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    sub = parser.add_subparsers(dest="command", metavar="command")

    sub.add_parser("setup",  help="Install all dependencies")

    dev_p = sub.add_parser("dev", help="Start development servers")
    dev_p.add_argument("service", nargs="?", default="all",
                       choices=["all", "frontend", "backend"],
                       help="Which service to start (default: all)")

    sub.add_parser("build",  help="Build frontend for production")
    sub.add_parser("test",   help="Run all test suites")
    sub.add_parser("lint",   help="Lint and type-check code")

    deploy_p = sub.add_parser("deploy", help="Deploy with Docker Compose")
    deploy_p.add_argument("--env", default="production", choices=["staging", "production"])

    docker_p = sub.add_parser("docker", help="Docker Compose operations")
    docker_p.add_argument("action", nargs="?", default="ps",
                          choices=["up", "down", "ps", "logs", "pull", "build"])

    sub.add_parser("clean",  help="Remove build artefacts and caches")
    sub.add_parser("status", help="Show running service status")

    logs_p = sub.add_parser("logs", help="Tail service logs (Docker)")
    logs_p.add_argument("service", nargs="?", default="", help="Service name (blank = all)")

    sub.add_parser("gui",  help="Open graphical management interface")
    sub.add_parser("help", help="Show this help message")

    return parser

# ─── GUI ──────────────────────────────────────────────────────────────────────

def launch_gui() -> None:
    """Launch the tkinter GUI."""
    try:
        import tkinter as tk
        from tkinter import messagebox, scrolledtext, ttk
    except ImportError:
        _error("tkinter is not available. Install it with your OS package manager.")
        _error("  Ubuntu/Debian: sudo apt-get install python3-tk")
        _error("  macOS:         brew install python-tk")
        sys.exit(1)

    COMMANDS = {
        "Setup (install deps)":  (cmd_setup,  argparse.Namespace()),
        "Dev — All Servers":     (cmd_dev,    argparse.Namespace(service="all")),
        "Dev — Frontend Only":   (cmd_dev,    argparse.Namespace(service="frontend")),
        "Dev — Backend Only":    (cmd_dev,    argparse.Namespace(service="backend")),
        "Build Frontend":        (cmd_build,  argparse.Namespace()),
        "Run Tests":             (cmd_test,   argparse.Namespace()),
        "Lint & Type-check":     (cmd_lint,   argparse.Namespace()),
        "Deploy (production)":   (cmd_deploy, argparse.Namespace(env="production")),
        "Docker — Up":           (cmd_docker, argparse.Namespace(action="up")),
        "Docker — Down":         (cmd_docker, argparse.Namespace(action="down")),
        "Docker — Status (ps)":  (cmd_docker, argparse.Namespace(action="ps")),
        "Clean Artefacts":       (cmd_clean,  argparse.Namespace()),
        "Service Status":        (cmd_status, argparse.Namespace()),
    }

    root = tk.Tk()
    root.title("Full-Stack Project Manager")
    root.resizable(True, True)
    root.minsize(760, 520)

    # ── Layout ────────────────────────────────────────
    left = tk.Frame(root, width=220, bg="#1e1e2e")
    left.pack(side=tk.LEFT, fill=tk.Y, padx=0, pady=0)
    left.pack_propagate(False)

    right = tk.Frame(root, bg="#13131f")
    right.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True)

    # Title
    tk.Label(
        left, text="🚀 Project Manager", font=("Helvetica", 13, "bold"),
        bg="#1e1e2e", fg="#cdd6f4", pady=16,
    ).pack(fill=tk.X)

    ttk.Separator(left, orient="horizontal").pack(fill=tk.X, padx=8, pady=4)

    # Output area
    output = scrolledtext.ScrolledText(
        right, bg="#1e1e2e", fg="#cdd6f4", font=("Courier", 10),
        borderwidth=0, highlightthickness=0, wrap=tk.WORD,
    )
    output.pack(fill=tk.BOTH, expand=True, padx=12, pady=12)
    output.configure(state="disabled")

    clear_btn = tk.Button(
        right, text="Clear Output", bg="#45475a", fg="#cdd6f4",
        relief=tk.FLAT, padx=10, pady=4,
        command=lambda: (output.configure(state="normal"),
                         output.delete("1.0", tk.END),
                         output.configure(state="disabled")),
    )
    clear_btn.pack(anchor=tk.E, padx=12, pady=(0, 8))

    def write_output(text: str) -> None:
        output.configure(state="normal")
        output.insert(tk.END, text + "\n")
        output.see(tk.END)
        output.configure(state="disabled")

    def redirect_stdout(func, ns: argparse.Namespace) -> None:
        """Run command in background thread, capturing stdout to the text widget."""
        import contextlib
        import io

        def target():
            buf = io.StringIO()
            with contextlib.redirect_stdout(buf), contextlib.redirect_stderr(buf):
                rc = func(ns)
            root.after(0, write_output, buf.getvalue())
            root.after(0, write_output, f"\n[Exit code: {rc}]")

        threading.Thread(target=target, daemon=True).start()

    # Buttons
    for label, (func, ns) in COMMANDS.items():
        color = "#89b4fa" if "Dev" in label else \
                "#a6e3a1" if "Build" in label or "Deploy" in label else \
                "#cba6f7" if "Docker" in label else \
                "#f38ba8" if "Clean" in label else "#cdd6f4"

        btn = tk.Button(
            left, text=label, anchor=tk.W, padx=12, pady=5,
            bg="#1e1e2e", fg=color, activebackground="#313244",
            activeforeground=color, relief=tk.FLAT, bd=0,
            font=("Helvetica", 10),
            command=lambda f=func, n=ns, lbl=label: (
                write_output(f"\n{'─'*50}\n▶  {lbl}\n{'─'*50}"),
                redirect_stdout(f, n),
            ),
        )
        btn.pack(fill=tk.X, padx=4, pady=1)

    root.mainloop()

# ─── Entry Point ──────────────────────────────────────────────────────────────

COMMAND_MAP = {
    "setup":  cmd_setup,
    "dev":    cmd_dev,
    "build":  cmd_build,
    "test":   cmd_test,
    "lint":   cmd_lint,
    "deploy": cmd_deploy,
    "docker": cmd_docker,
    "clean":  cmd_clean,
    "status": cmd_status,
    "logs":   cmd_logs,
}


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    if args.command is None or args.command == "gui":
        launch_gui()
        return 0

    handler = COMMAND_MAP.get(args.command)
    if handler is None or args.command == "help":
        parser.print_help()
        return 0

    return handler(args)


if __name__ == "__main__":
    sys.exit(main())
