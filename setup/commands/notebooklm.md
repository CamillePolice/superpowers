# NotebookLM — Vault to Multimedia Deliverables

Orchestrates the vault → NotebookLM → deliverable pipeline (podcast, mindmap, study-guide, infographic).
Uses the Python lib notebooklm-py (github.com/teng-lin/notebooklm-py).

## Prerequisites

- Python 3.8+
- pip install notebooklm-py
- Google account with NotebookLM access

## Steps

1. **Selection** — identify wiki notes to use as sources (via pattern or explicit list)
2. **Notebook** — create or retrieve the corresponding NotebookLM notebook
3. **Sources** — inject each .md note as a source into the notebook
4. **Generation** — ask NotebookLM for the desired deliverable (audio_overview | mindmap | study_guide | ...)
5. **Download** — retrieve the file and save it in `wiki/Resources/`

## Expected Output

Deliverable file (MP3 / PDF / JSON / MD depending on type) placed in `wiki/Resources/`
with a corresponding index note.

## Rules

- Never overwrite an existing deliverable without explicit confirmation
- Always log the operation in `wiki/Daily/{date}.md`
- Sources passed to NotebookLM must be validated wiki notes (not raw/)
