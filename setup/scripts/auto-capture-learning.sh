#!/usr/bin/env bash
# Auto-capture learning notes from /tmp/learning-notes-*.md to vault
# Run daily via cron to persist discoveries automatically

set -euo pipefail

VAULT="${CLAUDE_VAULT_PATH:-$HOME/vault}"
LEARNINGS_DIR="$VAULT/raw/learnings"
LOG_FILE="$HOME/.claude/logs/auto-capture.log"

mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$LEARNINGS_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Find all learning notes files
notes_files=(/tmp/learning-notes-*.md)

if [[ ! -e "${notes_files[0]}" ]]; then
    log "No learning notes found - nothing to capture"
    exit 0
fi

total_captured=0

for notes_file in "${notes_files[@]}"; do
    [[ ! -f "$notes_file" ]] && continue
    [[ ! -s "$notes_file" ]] && continue  # skip empty files

    # Extract project name from filename: /tmp/learning-notes-PROJECT.md
    filename=$(basename "$notes_file")
    project="${filename#learning-notes-}"
    project="${project%.md}"

    log "Processing: $notes_file (project: $project)"

    # Read notes
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue

        # Filter invalid notes (placeholders, too short, generic)
        if [[ "$line" =~ \<.*\> ]] || \
           [[ "$line" == *"Build error encountered"* ]] || \
           [[ "$line" == *"edge case found"* ]] || \
           [[ ${#line} -lt 50 ]]; then
            log "  Skipped (invalid): $line"
            continue
        fi

        # Extract tag and create slug
        if [[ "$line" =~ ^\[([a-z]+)\]\ (.+) ]]; then
            tag="${BASH_REMATCH[1]}"
            content="${BASH_REMATCH[2]}"

            # Extract technology from content (first word after tag)
            tech=$(echo "$content" | awk '{print tolower($1)}' | sed 's/[^a-z0-9-]//g')
            slug=$(echo "$content" | head -c 30 | sed 's/[^a-z0-9 -]//g' | tr ' ' '-' | tr -s '-')

            # Determine scope: project-specific or general
            scope="general"
            dest="$LEARNINGS_DIR/global"
            mkdir -p "$dest"

            if [[ "$project" != "default" ]]; then
                # Check if content is project-specific
                if [[ "$content" =~ (business|legacy|specific|this\ project|workaround) ]]; then
                    scope="project"
                    dest="$LEARNINGS_DIR/$project"
                    mkdir -p "$dest"
                fi
            fi

            # Generate filename
            timestamp=$(date +%Y%m%d)
            filename="$dest/${tech}-${slug}-${timestamp}.md"

            # Check if similar file exists
            similar=$(find "$dest" -name "${tech}-*.md" 2>/dev/null | head -1)

            if [[ -n "$similar" && -f "$similar" ]]; then
                log "  Appending to existing: $similar"
                echo "" >> "$similar"
                echo "---" >> "$similar"
                echo "" >> "$similar"
                echo "$line" >> "$similar"
                echo "" >> "$similar"
                echo "Added: $(date '+%Y-%m-%d')" >> "$similar"
            else
                log "  Creating new: $filename"
                cat > "$filename" <<EOF
---
date: $(date +%Y-%m-%d)
tags: [$tag, $tech]
scope: $scope
$([ "$scope" = "project" ] && echo "project: $project")
---

# ${tech^} - ${content%% —*}

$line

## Context

Auto-captured from session notes.

## Solution

See description above.

## Example

\`\`\`
# Add example if needed
\`\`\`
EOF
            fi

            ((total_captured++))
        else
            log "  Skipped (format): $line"
        fi
    done < "$notes_file" || true  # while loop may return 1 if last iteration was continue

    # Clear the notes file after processing
    : > "$notes_file"
    log "  Cleared: $notes_file"
done

log "Auto-capture complete: $total_captured notes processed"

# Suggest /ingest if notes were captured
if [[ $total_captured -gt 0 ]]; then
    log "Run '/ingest' in Claude Code to compile raw/ → wiki/"
fi
