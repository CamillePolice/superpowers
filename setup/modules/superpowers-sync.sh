#!/usr/bin/env bash
# Module: superpowers-sync — sync fork with upstream obra/superpowers (ff-only)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORK_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

run_sync() {
    local push_origin="${1:-false}"

    if ! git -C "$FORK_ROOT" remote get-url upstream &>/dev/null; then
        log_info "Adding upstream remote..."
        git -C "$FORK_ROOT" remote add upstream https://github.com/obra/superpowers.git
        log_ok "upstream remote added"
    fi

    log_info "Fetching upstream..."
    git -C "$FORK_ROOT" fetch upstream

    local current_branch
    current_branch="$(git -C "$FORK_ROOT" branch --show-current)"
    if [[ "$current_branch" != "main" ]]; then
        log_warn "Not on main (currently on '$current_branch') — switching to main for sync"
        git -C "$FORK_ROOT" checkout main
    fi

    log_info "Merging upstream/main (ff-only)..."
    if git -C "$FORK_ROOT" merge --ff-only upstream/main; then
        log_ok "Sync complete — fork is up to date with upstream"
    else
        log_error "ff-only merge failed — main has diverged from upstream"
        log_error "Fix: never commit directly to main; use feature branches only"
        exit 1
    fi

    if [[ "$push_origin" == "true" ]]; then
        log_info "Pushing to origin/main..."
        git -C "$FORK_ROOT" push origin main
        log_ok "origin/main updated"
    fi

    if [[ "$current_branch" != "main" ]]; then
        git -C "$FORK_ROOT" checkout "$current_branch"
        log_ok "Switched back to '$current_branch'"
    fi
}
