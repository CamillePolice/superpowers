#!/usr/bin/env bash
# Module: obsidian — copies skills to ~/.claude/commands/ and vault to $VAULT_PATH

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# Fork root: one level above setup/ — contains all skills (upstream + custom)
FORK_ROOT="$(cd "$REPO_DIR/.." && pwd)"
source "$SCRIPT_DIR/utils.sh"

COMMANDS_DIR="$HOME/.claude/commands"
SKILLS_DIR="$HOME/.claude/skills"

run_obsidian() {
    local vault_path="${1:-$HOME/vault}"

    log_info "Installing commands to $COMMANDS_DIR..."
    mkdir -p "$COMMANDS_DIR"
    for f in "$REPO_DIR/commands/"*.md; do
        local dst="$COMMANDS_DIR/$(basename "$f")"
        copy_file "$f" "$dst"
        if grep -q "~/vault" "$dst" 2>/dev/null; then
            sed -i.bak "s|~/vault|$vault_path|g" "$dst" && rm -f "${dst}.bak"
        fi
    done
    log_ok "Commands installed"

    log_info "Installing skills to $SKILLS_DIR..."
    for skill_dir in "$FORK_ROOT/skills"/*/; do
        local skill_name
        skill_name="$(basename "$skill_dir")"
        [[ "$skill_name" == "commands" ]] && continue
        mkdir -p "$SKILLS_DIR/$skill_name"
        cp -r "$skill_dir/." "$SKILLS_DIR/$skill_name/"
        if grep -rq "~/vault" "$SKILLS_DIR/$skill_name/" 2>/dev/null; then
            grep -rl "~/vault" "$SKILLS_DIR/$skill_name/" | while read -r f; do
                sed -i.bak "s|~/vault|$vault_path|g" "$f" && rm -f "${f}.bak"
            done
        fi
        log_ok "Skill installed: $skill_name"
    done
    log_ok "Skills installed"

    log_info "Installing Obsidian vault to $vault_path..."

    if [[ -d "$vault_path" && -n "$(ls -A "$vault_path" 2>/dev/null)" ]]; then
        echo ""
        log_warn "Vault directory already exists and is not empty: $vault_path"
        read -r -p "Overwrite? This will delete existing vault content. [y/N] " answer
        if [[ ! "$answer" =~ ^[Yy]$ ]]; then
            log_info "Vault installation skipped"
            return 0
        fi
        rm -rf "$vault_path"
    fi

    copy_dir "$REPO_DIR/obsidian-vault" "$vault_path"
    log_ok "Vault installed to $vault_path"
}
