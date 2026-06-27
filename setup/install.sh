#!/usr/bin/env bash
# Claude Code setup installer

set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$REPO_DIR/modules"

source "$MODULES_DIR/utils.sh"
source "$MODULES_DIR/claude-core.sh"
source "$MODULES_DIR/agents.sh"
source "$MODULES_DIR/obsidian.sh"
source "$MODULES_DIR/rtk.sh"
source "$MODULES_DIR/mcp.sh"
source "$MODULES_DIR/cron.sh"
source "$MODULES_DIR/superpowers-sync.sh"

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --core            Claude Code CLI + base config (settings, CLAUDE.md, profiles, rules, hooks)
  --agents          Specialized agents → ~/.claude/agents/
  --obsidian        Obsidian vault + all skills → ~/.claude/commands/
  --rtk             RTK + TOON token optimizers
  --mcp             code-review-graph MCP server
  --cron            Daily cronjob to auto-capture learning notes
  --sync            Sync fork with upstream obra/superpowers (ff-only)
  --sync-push       Same as --sync but also push origin/main after sync
  --all             Everything above (except --sync-push)
  --vault-path DIR  Custom vault location (default: ~/vault)
  --caveman         Enable caveman mode by default (75% token compression on responses)
  -h, --help        Show this help

Examples:
  $0 --all
  $0 --sync --all           # sync upstream then install
  $0 --all --caveman
  $0 --core --agents
  $0 --obsidian --vault-path ~/my-vault
EOF
}

# Defaults
DO_CORE=false
DO_AGENTS=false
DO_OBSIDIAN=false
DO_RTK=false
DO_MCP=false
DO_CRON=false
DO_SYNC=false
DO_SYNC_PUSH=false
DO_CAVEMAN=false
VAULT_PATH="$HOME/vault"

if [[ $# -eq 0 ]]; then
    usage
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --core)       DO_CORE=true ;;
        --agents)     DO_AGENTS=true ;;
        --obsidian)   DO_OBSIDIAN=true ;;
        --rtk)        DO_RTK=true ;;
        --mcp)        DO_MCP=true ;;
        --cron)       DO_CRON=true ;;
        --sync)       DO_SYNC=true ;;
        --sync-push)  DO_SYNC_PUSH=true ;;
        --all)        DO_CORE=true; DO_AGENTS=true; DO_OBSIDIAN=true; DO_RTK=true; DO_MCP=true; DO_CRON=true ;;
        --vault-path) shift; VAULT_PATH="$1" ;;
        --caveman)    DO_CAVEMAN=true ;;
        -h|--help)    usage; exit 0 ;;
        *)            log_error "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
done

echo ""
log_info "Claude Code setup — starting installation"
echo ""

$DO_SYNC      && run_sync "false"
$DO_SYNC_PUSH && run_sync "true"

backup_existing

$DO_CORE     && run_core
$DO_AGENTS   && run_agents
$DO_OBSIDIAN && run_obsidian "$VAULT_PATH"
$DO_RTK      && run_rtk
$DO_MCP      && run_mcp
$DO_CRON     && run_cron
$DO_CAVEMAN  && enable_caveman

echo ""
log_ok "Installation complete."
