#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  audit-trace.sh — Prompt-Audit-Trail Rekonstruktion (BOO-19)
#
#  Liest ein Spec-File, extrahiert Session-ID + Commit-SHA,
#  und zeigt Git-Commit-Diff + Session-Log-Turns zusammen.
#
#  Verwendung: bash .claude/scripts/audit-trace.sh {SPEC_ID}
#  Beispiel:   bash .claude/scripts/audit-trace.sh PROJ-42
#
#  Voraussetzungen: jq (fuer Session-Log-Rendering), git
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

SPEC_ID="${1:-}"
SPEC_DIR="${SPEC_DIR:-specs}"

if [[ -z "$SPEC_ID" ]]; then
    echo "Verwendung: bash .claude/scripts/audit-trace.sh {SPEC_ID}"
    echo "Beispiel:   bash .claude/scripts/audit-trace.sh PROJ-42"
    exit 1
fi

SPEC_FILE="${SPEC_DIR}/${SPEC_ID}.md"

if [[ ! -f "$SPEC_FILE" ]]; then
    echo "[audit-trace] Spec-File nicht gefunden: $SPEC_FILE"
    exit 1
fi

# ─── Werte aus Spec-File extrahieren ────────────────────────────────────────

COMMIT_SHA=$(grep -oP '(?<=\*\*Commit-SHA:\*\* `)[^`]+' "$SPEC_FILE" 2>/dev/null || echo "")
SESSION_ID=$(grep -oP '(?<=\*\*Session-ID:\*\* `)[^`]+' "$SPEC_FILE" 2>/dev/null || echo "")
SESSION_TS=$(grep -oP '(?<=\*\*Session-Timestamp:\*\* )\S+' "$SPEC_FILE" 2>/dev/null || echo "")

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Audit Trace — ${SPEC_ID}"
echo "════════════════════════════════════════════════════════════"
echo "  Spec-File:         $SPEC_FILE"
echo "  Session-Timestamp: ${SESSION_TS:-unbekannt}"
echo "  Session-ID:        ${SESSION_ID:-unbekannt}"
echo "  Commit-SHA:        ${COMMIT_SHA:-unbekannt}"
echo "════════════════════════════════════════════════════════════"

# ─── Git Commit Diff ────────────────────────────────────────────────────────

if [[ -n "$COMMIT_SHA" && "$COMMIT_SHA" != "unbekannt" ]]; then
    echo ""
    echo "── Git Commit Diff ──────────────────────────────────────────"
    git show "$COMMIT_SHA" --stat --no-patch 2>/dev/null || echo "  [Commit nicht gefunden: $COMMIT_SHA]"
    echo ""
    echo "  Vollständiger Diff: git show $COMMIT_SHA"
else
    echo ""
    echo "  [Kein Commit-SHA im Spec-File — Diff nicht verfügbar]"
fi

# ─── Session-Log Rendering ──────────────────────────────────────────────────

if [[ -n "$SESSION_ID" && "$SESSION_ID" != "unbekannt" ]]; then
    SESSION_FILE=$(find ~/.claude/projects -name "${SESSION_ID}.jsonl" 2>/dev/null | head -1)

    if [[ -n "$SESSION_FILE" ]]; then
        echo "── Session-Log Turns ────────────────────────────────────────"
        echo "  Log-Datei: $SESSION_FILE"
        echo ""

        if command -v jq &>/dev/null; then
            jq -r '
              select(.type == "message") |
              "[\(.role | ascii_upcase)] " +
              (if .content | type == "array"
               then (.content[] | select(.type == "text") | .text // "") | split("\n")[0:3] | join(" | ")
               else (.content // "" | split("\n")[0:3] | join(" | "))
               end) | .[0:200]
            ' "$SESSION_FILE" 2>/dev/null | head -40 || echo "  [jq Parse-Fehler — Datei manuell prüfen]"
        else
            echo "  [jq nicht installiert — Session-Log nicht renderbar]"
            echo "  Installieren: brew install jq (Mac) oder apt install jq (Linux)"
            echo "  Datei manuell öffnen: $SESSION_FILE"
        fi
    else
        echo "── Session-Log ──────────────────────────────────────────────"
        echo "  [Session-Log nicht gefunden: ${SESSION_ID}.jsonl]"
        echo "  Mögliche Ursachen:"
        echo "    - Session-Logs älter als Retention-Policy (Standard: 90 Tage)"
        echo "    - Session-ID war 'unbekannt' beim Commit (kein laufendes Claude Code)"
        echo "    - Anderer Rechner / anderes Profil"
    fi
else
    echo ""
    echo "  [Keine Session-ID im Spec-File — Session-Log nicht verfügbar]"
fi

# ─── Retention-Policy-Hinweis ───────────────────────────────────────────────

echo ""
echo "── Retention-Policy ─────────────────────────────────────────"
echo "  Empfehlung: Session-Logs 90 Tage aufbewahren, dann manuell"
echo "  archivieren oder löschen. Details: docs/domain/adrs/ (ADR anlegen)."
echo ""
echo "  Weitere Infos in GOVERNANCE.md §Audit-Trail."
echo "════════════════════════════════════════════════════════════"
