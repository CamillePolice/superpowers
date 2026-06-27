#!/usr/bin/env bash
# Module: cron — installs daily auto-capture cronjob

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

SCRIPTS_DIR="$HOME/.claude/scripts"
LOGS_DIR="$HOME/.claude/logs"

run_cron() {
    log_info "Installing auto-capture cronjob..."

    # Copy script
    mkdir -p "$SCRIPTS_DIR"
    mkdir -p "$LOGS_DIR"

    local script_src="$REPO_DIR/scripts/auto-capture-learning.sh"
    local script_dst="$SCRIPTS_DIR/auto-capture-learning.sh"

    copy_file "$script_src" "$script_dst"
    chmod +x "$script_dst"

    # Add to crontab (daily at 16:00)
    local cron_cmd="0 16 * * * $script_dst >> $LOGS_DIR/auto-capture.log 2>&1"

    # Check if cronjob already exists
    if crontab -l 2>/dev/null | grep -q "auto-capture-learning.sh"; then
        log_warn "Cronjob already exists, skipping"
    else
        # Add new cronjob
        (crontab -l 2>/dev/null; echo "$cron_cmd") | crontab -
        log_ok "Cronjob installed: daily at 16:00"
    fi

    log_info "Manual test: $script_dst"
}
