# Checkpointing & Rewind

> **Mode:** operator · **Priority:** nice-to-have · **Status:** include-with-fixes
> Verified 2026-06-02 against the official Anthropic docs (code.claude.com/docs).

## Using Checkpointing & Rewind

Claude Code creates checkpoints automatically: before every edit the code state is saved, and every new prompt creates a checkpoint. The WHY: this lets you take on ambitious, large-scale tasks without fear of broken code, because you can jump back to an earlier state at any time. No setup is needed — it works out of the box.

Open the rewind menu with the `/rewind` command or by pressing `Esc` twice (only when the prompt input is empty; if there is text in the field, double Esc clears that text instead — it is saved to the input history and can be recalled with `Up`). The menu lists all prompts of the session. Select the entry and deliberately decide WHAT should be reset:

- **Restore code and conversation** — reset code and conversation together.
- **Restore conversation** — reset only the conversation, the current code stays.
- **Restore code** — undo only the file changes, the conversation stays.

In addition there is `Summarize from here` / `Summarize up to here` to condense parts of the conversation into summaries and free up context-window space — these do not change any files on disk.

Know the limits (otherwise you get a false sense of safety): checkpoints capture ONLY direct file edits made by Claude's editing tools. File changes made by Bash commands (`rm`, `mv`, `cp`) CANNOT be undone via rewind. The same goes for manual or external changes made outside the session or from parallel sessions (unless they affect the same files of the current session). Checkpoints are meant as a quick "local undo" and do not replace Git — for permanent history and collaboration keep committing.

On retention: the checkpointing docs say the automatic cleanup after 30 days is "configurable", but name NO dedicated checkpoint key for it. The general settings.json key `cleanupPeriodDays` (default 30, minimum 1; `0` is rejected with a validation error) controls, according to the settings docs, the deletion of old session files on startup — a direct, documented link to checkpoint cleanup is not established there.

## Reference (machine-readable)

```yaml
# Checkpointing & Rewind (operator knowledge, no setup key needed)
# Claude Code tracks file edits automatically and allows jumping back.
checkpointing:
  # How to open the rewind menu
  oeffnen:
    befehl: "/rewind"
    shortcut: "Esc zweimal druecken (nur wenn Prompt-Eingabe leer ist)"
    # Note: if there is text in the prompt, double Esc clears the text instead
    #          (the text is saved in the input history, recallable with Up)
  # What happens automatically
  automatik:
    - "Jeder User-Prompt erzeugt einen neuen Checkpoint (Zustand VOR jedem Edit)"
    - "Checkpoints bleiben sessionuebergreifend erhalten (auch in resumed Conversations)"
    - "Auto-Cleanup zusammen mit Sessions nach 30 Tagen (laut Doku 'configurable')"
  # Rewind actions (selectable per prompt in the menu)
  restore_aktionen:
    - "Restore code and conversation: Code UND Konversation zuruecksetzen"
    - "Restore conversation: nur Konversation zuruecksetzen, aktueller Code bleibt"
    - "Restore code: nur Datei-Aenderungen zuruecksetzen, Konversation bleibt"
  summarize_aktionen:
    - "Summarize from here: ausgewaehlte Nachricht + alles danach zu Summary verdichten (aendert keine Dateien)"
    - "Summarize up to here: alles vor der Nachricht verdichten, Rest bleibt intakt"
  # Related settings.json key (controls session-file retention;
  # the checkpointing docs name NO dedicated checkpoint key,
  # they only describe the cleanup as 'configurable')
  setting:
    cleanupPeriodDays: 30   # Default 30, minimum 1; 0 is rejected with a validation error. Deletes old session files on startup.
# WHAT CHECKPOINTS DO NOT COVER (important for the operator):
#   - File changes made by Bash commands (rm/mv/cp) -> NOT undoable
#   - External/manual changes outside Claude Code or from parallel sessions
#     (unless they affect the same files of the current session)
#   - No substitute for version control: Git = permanent history, checkpoints = "local undo"
```

## Audit criteria

- Operator knows /rewind and the Esc-Esc shortcut (when the input is empty) to open the rewind menu
- Operator can distinguish the three restore modes (code+conversation / conversation only / code only)
- Operator knows that Bash-command changes (rm/mv/cp) are NOT covered by checkpoints
- Operator treats checkpoints as local undo and keeps using Git for permanent history
- Operator knows that cleanupPeriodDays (default 30, minimum 1) controls the retention of old session files; a dedicated checkpoint key is not documented

## Removed / softened by the verifier (not documented)

- LINKAGE cleanupPeriodDays controls checkpoint cleanup: the checkpointing docs only say the 30-day cleanup is 'configurable', but name NO settings.json key. The settings docs describe cleanupPeriodDays exclusively as the deletion of 'session files' (default 30, minimum 1, 0 is rejected with a validation error) and do not mention checkpointing at all. The claim 'the only related settings.json option (controls the 30-day cleanup)' or 'the only related settings.json dial ... that determines when ... the checkpoints ... are deleted' is an inference, not documented. The key and its mechanics stay (verified), but ONLY phrased as session-file retention, not as checkpoint control.
- WORDING 'External/manual changes ... are normally not captured (unless they affect the same files of the current session)': the docs say verbatim that checkpointing only tracks files that were edited within the current session; manual/external changes and edits from parallel sessions are 'normally not captured, unless they happen to modify the same files as the current session'. The claim is therefore documented — the parenthetical qualifier in the draft is correct and stays. (Not a reason for removal, listed here only for clarification.)