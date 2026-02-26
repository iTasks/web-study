#!/usr/bin/env bash
# manage.sh — Full-stack project management (Bash CLI)
#
# Usage:
#   ./scripts/manage.sh <command> [options]
#
# Commands:
#   setup             Install all dependencies
#   dev [all|frontend|backend]   Start dev servers (default: all)
#   build             Build frontend for production
#   test              Run all test suites
#   lint              Lint and type-check code
#   deploy [env]      Deploy with Docker Compose (default: production)
#   docker <action>   Docker Compose: up | down | ps | logs | pull | build
#   clean             Remove build artefacts and caches
#   status            Show running service status
#   logs [service]    Tail Docker Compose service logs
#   help              Show this message

set -euo pipefail

# ─── Paths ────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FRONTEND_DIR="$ROOT/roadmap"          # adjust to your frontend path
BACKEND_DIR="$ROOT/../python/samples" # adjust to your backend path
COMPOSE_FILE="$ROOT/docker-compose.yml"

# ─── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ─── Helpers ──────────────────────────────────────────────────────────────────
header()  { echo -e "\n${CYAN}${BOLD}──────────────────────────────────────────${RESET}"; \
            echo -e "${CYAN}${BOLD}  $*${RESET}"; \
            echo -e "${CYAN}${BOLD}──────────────────────────────────────────${RESET}"; }
success() { echo -e "${GREEN}✔  $*${RESET}"; }
error()   { echo -e "${RED}✖  $*${RESET}" >&2; }
warn()    { echo -e "${YELLOW}⚠  $*${RESET}"; }

require_tool() {
    if ! command -v "$1" &>/dev/null; then
        warn "'$1' not found on PATH — some commands may fail."
    fi
}

compose_cmd() {
    if [[ -f "$COMPOSE_FILE" ]]; then
        docker compose -f "$COMPOSE_FILE" "$@"
    else
        docker compose "$@"
    fi
}

# ─── Commands ─────────────────────────────────────────────────────────────────
cmd_setup() {
    header "Setup — Installing Dependencies"
    local errors=0

    if [[ -d "$FRONTEND_DIR" ]]; then
        header "Frontend — npm install"
        npm install --prefix "$FRONTEND_DIR" || { error "npm install failed"; ((errors++)); }
        success "Frontend dependencies installed"
    else
        warn "Frontend dir not found: $FRONTEND_DIR"
    fi

    if [[ -d "$BACKEND_DIR" ]]; then
        while IFS= read -r req; do
            header "Backend — pip install -r $(basename "$req")"
            python3 -m pip install -r "$req" || { error "pip install failed for $req"; ((errors++)); }
            success "Installed $(basename "$req")"
        done < <(find "$BACKEND_DIR" -name "requirements*.txt" -maxdepth 3)
    else
        warn "Backend dir not found: $BACKEND_DIR"
    fi

    return $errors
}

cmd_dev() {
    local service="${1:-all}"
    header "Dev Servers — $service"
    local pids=()

    start_frontend() {
        if [[ -d "$FRONTEND_DIR" ]]; then
            echo "  Starting frontend on port 5173 …"
            npm --prefix "$FRONTEND_DIR" run dev &
            pids+=($!)
        else
            warn "Frontend dir not found: $FRONTEND_DIR"
        fi
    }

    start_backend() {
        if [[ -d "$BACKEND_DIR" ]]; then
            echo "  Starting backend on port 8000 …"
            (cd "$BACKEND_DIR" && python3 -m uvicorn app.main:app --reload --port 8000) &
            pids+=($!)
        else
            warn "Backend dir not found: $BACKEND_DIR"
        fi
    }

    case "$service" in
        frontend) start_frontend ;;
        backend)  start_backend  ;;
        all|*)    start_frontend; start_backend ;;
    esac

    if [[ ${#pids[@]} -eq 0 ]]; then
        error "No services started."
        return 1
    fi

    echo -e "\n  Press Ctrl+C to stop all servers.\n"
    trap 'kill "${pids[@]}" 2>/dev/null; echo ""; warn "Stopped."' INT TERM
    wait "${pids[@]}"
}

cmd_build() {
    header "Build — Frontend Production Build"
    require_tool npm
    if [[ ! -d "$FRONTEND_DIR" ]]; then
        error "Frontend dir not found: $FRONTEND_DIR"; return 1
    fi
    npm --prefix "$FRONTEND_DIR" run build
    success "Frontend build complete → dist/"
}

cmd_test() {
    header "Test Suites"
    local errors=0

    if [[ -d "$FRONTEND_DIR" ]]; then
        header "Frontend — npm test"
        npm --prefix "$FRONTEND_DIR" test -- --run || { error "Frontend tests failed"; ((errors++)); }
        success "Frontend tests passed"
    fi

    if [[ -d "$BACKEND_DIR" ]]; then
        header "Backend — pytest"
        (cd "$BACKEND_DIR" && python3 -m pytest -v) || { error "Backend tests failed"; ((errors++)); }
        success "Backend tests passed"
    fi

    return $errors
}

cmd_lint() {
    header "Lint & Type-check"
    local errors=0

    if [[ -d "$FRONTEND_DIR" ]]; then
        npm --prefix "$FRONTEND_DIR" run lint       2>/dev/null || ((errors++))
        npm --prefix "$FRONTEND_DIR" run type-check 2>/dev/null || ((errors++))
    fi

    if [[ -d "$BACKEND_DIR" ]]; then
        if command -v ruff &>/dev/null; then
            (cd "$BACKEND_DIR" && ruff check .) || ((errors++))
        else
            warn "ruff not found — skipping"
        fi
        if command -v mypy &>/dev/null; then
            (cd "$BACKEND_DIR" && mypy .) || ((errors++))
        else
            warn "mypy not found — skipping"
        fi
    fi

    if [[ $errors -eq 0 ]]; then success "All lint checks passed"
    else error "$errors lint check(s) failed"; fi
    return $errors
}

cmd_deploy() {
    local env="${1:-production}"
    header "Deploy — $env"
    require_tool docker

    compose_cmd pull
    compose_cmd up -d --build --remove-orphans
    success "Deployment complete"
}

cmd_docker() {
    local action="${1:-ps}"
    header "Docker — $action"
    require_tool docker

    case "$action" in
        up)    compose_cmd up -d ;;
        down)  compose_cmd down ;;
        ps)    compose_cmd ps ;;
        logs)  compose_cmd logs --tail=50 -f ;;
        pull)  compose_cmd pull ;;
        build) compose_cmd build ;;
        *)
            error "Unknown docker action: $action. Choose: up | down | ps | logs | pull | build"
            return 1
            ;;
    esac
}

cmd_clean() {
    header "Clean — Removing Build Artefacts"
    local dirs=(
        "$FRONTEND_DIR/dist"
        "$FRONTEND_DIR/.vite"
        "$FRONTEND_DIR/coverage"
        "$BACKEND_DIR/__pycache__"
        "$BACKEND_DIR/.pytest_cache"
        "$BACKEND_DIR/.mypy_cache"
        "$BACKEND_DIR/.ruff_cache"
    )
    for d in "${dirs[@]}"; do
        if [[ -d "$d" ]]; then
            rm -rf "$d"
            echo "  Removed: $d"
        fi
    done
    # Remove __pycache__ recursively
    if [[ -d "$BACKEND_DIR" ]]; then
        find "$BACKEND_DIR" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    fi
    success "Clean complete"
}

cmd_status() {
    header "Service Status"

    if command -v docker &>/dev/null; then
        echo -e "\nDocker Compose services:"
        compose_cmd ps 2>/dev/null || warn "Docker not available or no compose file"
    fi

    echo -e "\nLocal ports:"
    declare -A PORTS=([frontend]=5173 [backend]=8000)
    for name in "${!PORTS[@]}"; do
        port="${PORTS[$name]}"
        if lsof -i "TCP:$port" -sTCP:LISTEN &>/dev/null 2>&1; then
            echo -e "  ${name/<12/}  port $port  ${GREEN}RUNNING${RESET}"
        elif ss -tlnp "sport = :$port" 2>/dev/null | grep -q ":$port"; then
            echo -e "  $name  port $port  ${GREEN}RUNNING${RESET}"
        else
            echo -e "  $name  port $port  ${RED}STOPPED${RESET}"
        fi
    done
}

cmd_logs() {
    local service="${1:-}"
    header "Logs — ${service:-all services}"
    require_tool docker
    if [[ -n "$service" ]]; then
        compose_cmd logs --tail=100 -f "$service"
    else
        compose_cmd logs --tail=100 -f
    fi
}

cmd_help() {
    echo ""
    echo " manage.sh -- Full-stack project management (Bash CLI)"
    echo ""
    echo " Usage:  ./scripts/manage.sh <command> [options]"
    echo ""
    echo " Commands:"
    echo "   setup              Install all dependencies"
    echo "   dev [all|frontend|backend]  Start dev servers (default: all)"
    echo "   build              Build frontend for production"
    echo "   test               Run all test suites"
    echo "   lint               Lint and type-check code"
    echo "   deploy [env]       Deploy with Docker Compose (default: production)"
    echo "   docker <action>    Docker Compose: up | down | ps | logs | pull | build"
    echo "   clean              Remove build artefacts and caches"
    echo "   status             Show running service status"
    echo "   logs [service]     Tail Docker Compose service logs"
    echo "   help               Show this message"
    echo ""
}

# ─── Entry Point ──────────────────────────────────────────────────────────────
main() {
    local command="${1:-help}"
    shift || true

    case "$command" in
        setup)   cmd_setup ;;
        dev)     cmd_dev "${1:-all}" ;;
        build)   cmd_build ;;
        test)    cmd_test ;;
        lint)    cmd_lint ;;
        deploy)  cmd_deploy "${1:-production}" ;;
        docker)  cmd_docker "${1:-ps}" ;;
        clean)   cmd_clean ;;
        status)  cmd_status ;;
        logs)    cmd_logs "${1:-}" ;;
        help|-h|--help) cmd_help ;;
        *)
            error "Unknown command: $command"
            cmd_help
            exit 1
            ;;
    esac
}

main "$@"
