#!/usr/bin/env bash
# Module: core — installs Claude Code CLI and base config

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
PROFILES_DIR="$CLAUDE_DIR/profiles"
RULES_DIR="$CLAUDE_DIR/rules"

install_prerequisites() {
    local os
    os="$(detect_os)"

    # jq — required by rtk-rewrite and toon-rewrite hooks
    if ! command -v jq &>/dev/null; then
        log_info "Installing jq..."
        if [[ "$os" == "macos" ]]; then
            brew install jq
        else
            if command -v apt-get &>/dev/null; then
                sudo apt-get install -y jq
            elif command -v dnf &>/dev/null; then
                sudo dnf install -y jq
            else
                log_warn "Cannot install jq automatically — install it manually: https://jqlang.github.io/jq/download/"
            fi
        fi
    else
        log_ok "jq already installed"
    fi

    # bun — required by ccstatusline (statusLine in settings.json)
    if ! command -v bun &>/dev/null; then
        log_info "Installing bun..."
        curl -fsSL https://bun.sh/install | bash
        export PATH="$HOME/.bun/bin:$PATH"
    else
        log_ok "bun already installed"
    fi
}

install_cli() {
    local os
    os="$(detect_os)"

    if command -v claude &>/dev/null; then
        log_ok "Claude Code CLI already installed: $(claude --version 2>/dev/null || echo 'version unknown')"
        return 0
    fi

    log_info "Installing Claude Code CLI..."
    if [[ "$os" == "macos" ]]; then
        check_command brew
        brew install claude-code
    else
        check_command npm
        npm install -g @anthropic-ai/claude-code
    fi
    log_ok "Claude Code CLI installed"
}

install_config() {
    log_info "Installing base config..."

    local commands_dir="$CLAUDE_DIR/commands"
    mkdir -p "$CLAUDE_DIR" "$HOOKS_DIR" "$PROFILES_DIR" "$RULES_DIR" "$commands_dir"

    copy_file "$REPO_DIR/config/settings.json" "$CLAUDE_DIR/settings.json"
    copy_file "$REPO_DIR/config/CLAUDE.md"     "$CLAUDE_DIR/CLAUDE.md"
    copy_file "$REPO_DIR/config/RTK.md"           "$CLAUDE_DIR/RTK.md"

    # Profiles
    for f in "$REPO_DIR/config/profiles/"*.md; do
        copy_file "$f" "$PROFILES_DIR/$(basename "$f")"
    done

    # Rules
    for f in "$REPO_DIR/config/rules/"*.md; do
        copy_file "$f" "$RULES_DIR/$(basename "$f")"
    done

    # Hooks
    for f in "$REPO_DIR/config/hooks/"*.sh; do
        copy_file "$f" "$HOOKS_DIR/$(basename "$f")"
        chmod +x "$HOOKS_DIR/$(basename "$f")"
    done

    # Commands
    for f in "$REPO_DIR/config/commands/"*.md; do
        copy_file "$f" "$commands_dir/$(basename "$f")"
    done

    log_ok "Base config installed"
}

install_caveman() {
    log_info "Installing caveman plugin (token compression)..."
    if claude plugin marketplace add JuliusBrussee/caveman &>/dev/null 2>&1 && \
       claude plugin install caveman@caveman &>/dev/null 2>&1; then
        log_ok "caveman installed"
    else
        log_warn "caveman plugin install failed — run manually: claude plugin marketplace add JuliusBrussee/caveman && claude plugin install caveman@caveman"
    fi
}

enable_caveman() {
    local claude_md="$CLAUDE_DIR/CLAUDE.md"
    if grep -q "caveman" "$claude_md" 2>/dev/null; then
        log_ok "Caveman mode already enabled in CLAUDE.md"
        return 0
    fi
    cat >> "$claude_md" <<'EOF'

## Response Style
Use caveman mode by default: compress all responses to minimum tokens.
Invoke the caveman skill at the start of each session.
EOF
    log_ok "Caveman mode enabled in CLAUDE.md"
}

run_core() {
    install_prerequisites
    install_cli
    install_caveman
    install_config
}
