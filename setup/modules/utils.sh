#!/usr/bin/env bash
# Shared utilities for install modules

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_ok()      { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *)      echo "unknown" ;;
    esac
}

check_command() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        log_error "Required command not found: $cmd"
        return 1
    fi
}

backup_existing() {
    local claude_dir="$HOME/.claude"
    if [[ ! -d "$claude_dir" ]] || [[ -z "$(ls -A "$claude_dir" 2>/dev/null)" ]]; then
        return 0
    fi
    local backup_dir="${claude_dir}.bak.$(date +%Y%m%d-%H%M%S)"
    mv "$claude_dir" "$backup_dir"
    log_ok "Existing config moved to: $backup_dir"
}

copy_file() {
    local src="$1"
    local dst="$2"
    local dst_dir
    dst_dir="$(dirname "$dst")"
    mkdir -p "$dst_dir"
    cp "$src" "$dst"
    log_ok "Copied: $dst"
}

copy_dir() {
    local src="$1"
    local dst="$2"
    mkdir -p "$dst"
    cp -r "$src/." "$dst/"
    log_ok "Copied dir: $dst"
}
