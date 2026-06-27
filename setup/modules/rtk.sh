#!/usr/bin/env bash
# Module: rtk — installs RTK (token optimizer) and TOON (JSON compactor)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

install_rtk() {
    local os
    os="$(detect_os)"

    export PATH="$HOME/.local/bin:$PATH"
    mkdir -p "$HOME/.local/bin"

    if command -v rtk &>/dev/null && rtk gain &>/dev/null 2>&1; then
        log_ok "RTK already installed and verified"
        return 0
    fi

    # Remove wrong rtk (reachingforthejack/rtk — Type Kit) if present
    if command -v rtk &>/dev/null && ! rtk gain &>/dev/null 2>&1; then
        log_warn "Wrong rtk binary detected (Type Kit). Removing..."
        rm -f "$HOME/.local/bin/rtk" 2>/dev/null || true
        if [[ "$os" == "macos" ]] && command -v brew &>/dev/null; then
            brew uninstall rtk 2>/dev/null || true
        fi
    fi

    log_info "Installing RTK (Rust Token Killer)..."
    if [[ "$os" == "macos" ]] && command -v brew &>/dev/null; then
        brew install rtk 2>/dev/null || \
            curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
    else
        curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
    fi

    export PATH="$HOME/.local/bin:$PATH"

    if ! command -v rtk &>/dev/null; then
        log_warn "rtk not in PATH. Add to your shell profile: export PATH=\"\$HOME/.local/bin:\$PATH\""
        return 0
    fi

    if ! rtk gain &>/dev/null 2>&1; then
        log_warn "rtk gain failed — wrong package may still be installed"
        return 0
    fi

    log_ok "RTK installed"
}

install_toon() {
    log_info "Installing TOON (JSON compactor)..."
    if command -v bun &>/dev/null; then
        bun install -g @toon-format/cli &>/dev/null && log_ok "TOON installed (bun)" && return 0
    fi
    if command -v npm &>/dev/null; then
        npm install -g @toon-format/cli &>/dev/null && log_ok "TOON installed (npm)" && return 0
    fi
    log_warn "TOON not installed — bun/npm required"
}

run_rtk() {
    install_rtk
    install_toon
    log_ok "RTK + TOON ready"
}
