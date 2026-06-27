#!/usr/bin/env bash
# Module: agents — copies specialized agents to ~/.claude/agents/

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

AGENTS_DIR="$HOME/.claude/agents"

run_agents() {
    log_info "Installing agents..."
    mkdir -p "$AGENTS_DIR"

    for f in "$REPO_DIR/agents/"*.md; do
        [[ "$(basename "$f")" == "AGENT.md" ]] && continue
        copy_file "$f" "$AGENTS_DIR/$(basename "$f")"
    done

    log_ok "Agents installed to $AGENTS_DIR"
}
