# Project Management Scripts

[← Back to JavaScript](../README.md) | [Roadmap](../roadmap/README.md) | [Main README](../../README.md)

Three equivalent management tools — pick the one that fits your OS and workflow:

| Script | Platform | Mode |
|--------|----------|------|
| [`manage.py`](manage.py) | Any (Python 3.8+) | **CLI** + **GUI** (tkinter) |
| [`manage.sh`](manage.sh) | Linux / macOS / WSL | CLI |
| [`manage.bat`](manage.bat) | Windows (cmd.exe) | CLI |
| [`manage.ps1`](manage.ps1) | Windows / macOS / Linux (PowerShell 5.1+) | CLI |

---

## Commands

All four scripts share the same command surface:

| Command | Description |
|---------|-------------|
| `setup` | Install all dependencies (npm + pip) |
| `dev [all\|frontend\|backend]` | Start development servers (default: all) |
| `build` | Build frontend for production |
| `test` | Run all test suites (Vitest + pytest) |
| `lint` | Lint and type-check code (ESLint, mypy, ruff) |
| `deploy [env]` | Deploy via Docker Compose (default: production) |
| `docker <action>` | Docker Compose: `up`, `down`, `ps`, `logs`, `pull`, `build` |
| `clean` | Remove build artefacts (dist/, .pytest_cache, etc.) |
| `status` | Show running service status (Docker + local ports) |
| `logs [service]` | Tail Docker Compose service logs |
| `gui` | *(Python only)* Open the graphical management interface |
| `help` | Show usage information |

---

## Usage

### Python CLI

```bash
python scripts/manage.py setup
python scripts/manage.py dev all
python scripts/manage.py dev frontend
python scripts/manage.py build
python scripts/manage.py test
python scripts/manage.py lint
python scripts/manage.py deploy production
python scripts/manage.py docker up
python scripts/manage.py docker down
python scripts/manage.py docker logs
python scripts/manage.py clean
python scripts/manage.py status
python scripts/manage.py logs backend
```

### Python GUI

```bash
python scripts/manage.py gui
# or just
python scripts/manage.py
```

Opens a dark-themed desktop window with one-click buttons for every command. Output streams in real time to the built-in console pane.

### Bash (Linux / macOS / WSL)

```bash
# Make executable once
chmod +x scripts/manage.sh

./scripts/manage.sh setup
./scripts/manage.sh dev
./scripts/manage.sh dev backend
./scripts/manage.sh build
./scripts/manage.sh test
./scripts/manage.sh lint
./scripts/manage.sh deploy production
./scripts/manage.sh docker up
./scripts/manage.sh docker logs
./scripts/manage.sh clean
./scripts/manage.sh status
```

### Windows Batch (cmd.exe)

```bat
scripts\manage.bat setup
scripts\manage.bat dev all
scripts\manage.bat build
scripts\manage.bat test
scripts\manage.bat lint
scripts\manage.bat deploy production
scripts\manage.bat docker up
scripts\manage.bat docker down
scripts\manage.bat clean
scripts\manage.bat status
```

### PowerShell

```powershell
# Allow local scripts (run once, as admin)
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

# Then run
.\scripts\manage.ps1 setup
.\scripts\manage.ps1 dev all
.\scripts\manage.ps1 dev frontend
.\scripts\manage.ps1 build
.\scripts\manage.ps1 test
.\scripts\manage.ps1 lint
.\scripts\manage.ps1 deploy production
.\scripts\manage.ps1 docker up
.\scripts\manage.ps1 docker down
.\scripts\manage.ps1 docker logs
.\scripts\manage.ps1 clean
.\scripts\manage.ps1 status
.\scripts\manage.ps1 logs backend
.\scripts\manage.ps1 help
```

---

## Prerequisites

| Tool | Version | Required for |
|------|---------|-------------|
| Python | 3.8+ | `manage.py` + backend tests/lint |
| Node.js | 18+ | Frontend (`npm`) |
| Docker + Docker Compose | Latest | `deploy`, `docker` commands |
| tkinter | (stdlib) | `manage.py gui` — pre-installed on most Python distributions |
| PowerShell | 5.1+ | `manage.ps1` |
| bash | 4.0+ | `manage.sh` |

### Install tkinter (if missing)

```bash
# Ubuntu / Debian
sudo apt-get install python3-tk

# macOS
brew install python-tk

# Windows — included with the python.org installer (tick "tcl/tk")
```

---

## Configuration

The scripts auto-detect paths relative to their location. If your project layout differs, edit the path constants at the top of each script:

```python
# manage.py
FRONTEND_DIR = ROOT / "roadmap"              # path to your React app
BACKEND_DIR  = ROOT.parent / "python" / "samples"  # path to your Python app
COMPOSE_FILE = ROOT / "docker-compose.yml"
```

```bash
# manage.sh
FRONTEND_DIR="$ROOT/roadmap"
BACKEND_DIR="$ROOT/../python/samples"
COMPOSE_FILE="$ROOT/docker-compose.yml"
```

Identical pattern in `manage.bat` and `manage.ps1`.

---

## GUI Screenshot Reference

The Python GUI (`manage.py gui`) provides:

- **Left sidebar** — one-click buttons grouped by category (Setup, Dev, Build, Test, Deploy, Docker, Tools)
- **Right pane** — scrollable output console with real-time streaming
- **Clear** button — clears the output pane
- Colour-coded buttons (blue = dev, green = build/deploy, purple = docker, red = clean)
- Dark theme (Catppuccin Mocha palette)
- Runs commands in background threads — UI stays responsive
