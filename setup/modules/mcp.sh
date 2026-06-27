#!/usr/bin/env bash
# Module: mcp — installs code-review-graph MCP server

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

run_mcp() {
    log_info "Installing code-review-graph MCP server..."

    if command -v pipx &>/dev/null; then
        pipx install code-review-graph
    elif command -v pip3 &>/dev/null; then
        pip3 install --user code-review-graph
    elif command -v pip &>/dev/null; then
        pip install --user code-review-graph
    else
        log_error "No pip or pipx found. Install Python 3.10+ first."
        return 1
    fi

    log_ok "code-review-graph installed"
    log_info "Add to ~/.claude/settings.json mcpServers:"
    echo '  "code-review-graph": { "command": "code-review-graph", "args": [] }'
}
