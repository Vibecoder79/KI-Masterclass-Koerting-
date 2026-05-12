#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  setup-branch-protection.sh — Branch-Protection fuer main aktivieren (BOO-29)
#
#  Setzt via `gh api` die Branch-Protection fuer den main-Branch auf GitHub.
#  Required Status Checks werden dynamisch aus den vorhandenen Workflow-Files
#  unter .github/workflows/*.yml gelesen (erstes `name:`-Feld pro Workflow).
#
#  Verwendung:
#    bash setup-branch-protection.sh           # main schuetzen
#    bash setup-branch-protection.sh --dry-run # nur loggen, kein Aufruf
#
#  Voraussetzungen:
#    - gh CLI installiert (`gh --version`)
#    - eingeloggt (`gh auth status`) mit repo-admin Permissions
#    - Remote 'origin' zeigt auf GitHub-Repo
#    - main-Branch existiert remote (mind. ein `git push origin main` gelaufen)
#
#  Idempotenz: der PUT-Call ist Replace, also re-run-safe. Mehrfaches
#  Ausfuehren ueberschreibt die Protection identisch — keine Akkumulation.
#
#  Referenz: BOO-29, file-templates §branch-protection,
#  migration-checklist-v1-to-v2.md §BOO-29.
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

DRY_RUN="${DRY_RUN:-false}"
SCRIPT_NAME="$(basename "$0")"

# ─── Logging-Helfer ─────────────────────────────────────────────────────────

log_info()   { printf '[INFO]   %s\n' "$*"; }
log_warn()   { printf '[WARN]   %s\n' "$*" >&2; }
log_skip()   { printf '[SKIP]   %s\n' "$*"; }
log_dry()    { printf '[DRY]    %s\n' "$*"; }
log_error()  { printf '[ERROR]  %s\n' "$*" >&2; }

# ─── Argument-Parsing ───────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN="true"
            log_info "DRY-RUN aktiv — gh api wird NICHT aufgerufen, nur geloggt."
            shift
            ;;
        -h|--help)
            cat <<EOF
$SCRIPT_NAME — Branch-Protection fuer main aktivieren (BOO-29)

Verwendung:
  $SCRIPT_NAME            Branch-Protection fuer main schreiben
  $SCRIPT_NAME --dry-run  Nur loggen welcher gh api-Aufruf erfolgen wuerde
  $SCRIPT_NAME -h         Diese Hilfe

Lies vor dem Lauf: bootstrap/references/migration-checklist-v1-to-v2.md §BOO-29
EOF
            exit 0
            ;;
        *)
            log_warn "Unbekanntes Argument: $1 (siehe --help)"
            exit 1
            ;;
    esac
done

# ─── Voraussetzungen-Check ──────────────────────────────────────────────────

# 1. gh CLI installiert?
if ! command -v gh >/dev/null 2>&1; then
    log_error "gh CLI nicht gefunden."
    log_error "Fix: 'brew install gh' (Mac) oder https://cli.github.com/ — danach erneut laufen lassen."
    exit 1
fi

# 2. gh auth status — eingeloggt mit ausreichenden Permissions?
if ! gh auth status >/dev/null 2>&1; then
    log_error "gh CLI nicht eingeloggt."
    log_error "Fix: 'gh auth login' ausfuehren (Browser-Flow oder Token mit 'repo'-Scope), danach erneut laufen lassen."
    exit 1
fi

# 3. Remote 'origin' vorhanden?
if ! git remote get-url origin >/dev/null 2>&1; then
    log_error "Kein git remote 'origin' im aktuellen Repo."
    log_error "Fix: 'git remote add origin git@github.com:<owner>/<repo>.git' und 'git push -u origin main' laufen lassen."
    exit 1
fi

REMOTE_URL=$(git remote get-url origin)

# 4. Owner/Repo aus Remote-URL extrahieren (https + ssh Form)
#    https://github.com/<owner>/<repo>(.git)
#    git@github.com:<owner>/<repo>(.git)
OWNER_REPO=$(printf '%s' "$REMOTE_URL" \
    | sed -E 's#^(https://[^/]+/|git@[^:]+:)##' \
    | sed -E 's#\.git$##')

OWNER="${OWNER_REPO%%/*}"
REPO="${OWNER_REPO##*/}"

if [[ -z "$OWNER" || -z "$REPO" || "$OWNER" == "$REPO" ]]; then
    log_error "Owner/Repo konnte nicht aus origin URL geparst werden: $REMOTE_URL"
    log_error "Fix: pruefen ob origin auf 'github.com:<owner>/<repo>' oder 'github.com/<owner>/<repo>' zeigt."
    exit 1
fi

log_info "Repo erkannt: ${OWNER}/${REPO}"

# 5. main-Branch existiert remote?
if ! gh api "repos/${OWNER}/${REPO}/branches/main" >/dev/null 2>&1; then
    log_error "main-Branch existiert NICHT remote auf ${OWNER}/${REPO}."
    log_error "Fix: erst 'git push -u origin main' ausfuehren — Branch-Protection braucht den remote Branch."
    exit 1
fi

# ─── Dynamische Check-Liste aus .github/workflows/*.yml ─────────────────────

WORKFLOWS_DIR=".github/workflows"
CONTEXTS=()

if [[ ! -d "$WORKFLOWS_DIR" ]]; then
    log_warn "$WORKFLOWS_DIR fehlt — keine CI-Workflows gefunden, Branch-Protection wird OHNE Required Status Checks gesetzt."
    log_warn "Empfehlung: erst CI-Workflows anlegen (BOO-4, BOO-5, BOO-15, BOO-16, BOO-28), dann erneut laufen lassen."
else
    # Glob auf *.yml und *.yaml — beide Endungen tolerieren
    shopt -s nullglob
    workflow_files=("$WORKFLOWS_DIR"/*.yml "$WORKFLOWS_DIR"/*.yaml)
    shopt -u nullglob

    if [[ ${#workflow_files[@]} -eq 0 ]]; then
        log_warn "$WORKFLOWS_DIR ist leer — keine CI-Workflows gefunden."
    else
        for wf in "${workflow_files[@]}"; do
            # Erste Top-Level `name:`-Zeile lesen (nicht innerhalb von `jobs:`/`steps:`)
            # Wir nehmen schlicht die erste Zeile die mit 'name:' beginnt (Top-Level YAML)
            name_line=$(grep -m1 '^name:' "$wf" 2>/dev/null || true)
            if [[ -z "$name_line" ]]; then
                log_warn "$(basename "$wf"): kein Top-Level 'name:'-Feld gefunden — uebersprungen"
                continue
            fi
            # Wert nach 'name:' extrahieren, Quotes/Whitespace strippen
            ctx="${name_line#name:}"
            # Fuehrenden Whitespace entfernen
            ctx="${ctx#"${ctx%%[![:space:]]*}"}"
            # Folgenden Whitespace entfernen
            ctx="${ctx%"${ctx##*[![:space:]]}"}"
            # Umschliessende Double-Quotes entfernen
            if [[ "$ctx" == \"*\" ]]; then
                ctx="${ctx#\"}"
                ctx="${ctx%\"}"
            fi
            # Umschliessende Single-Quotes entfernen
            if [[ "$ctx" == \'*\' ]]; then
                ctx="${ctx#\'}"
                ctx="${ctx%\'}"
            fi
            if [[ -n "$ctx" ]]; then
                CONTEXTS+=("$ctx")
                log_info "Detected workflow '$(basename "$wf")' -> Required Status Check '$ctx'"
            fi
        done
    fi
fi

# ─── gh api Aufruf zusammenbauen ────────────────────────────────────────────

# Args fuer gh api — 1:1 aus BOO-29 Issue-Body. Contexts dynamisch.
GH_ARGS=(
    -X PUT "repos/${OWNER}/${REPO}/branches/main/protection"
    -F "required_status_checks[strict]=true"
)

for ctx in "${CONTEXTS[@]}"; do
    GH_ARGS+=(-F "required_status_checks[contexts][]=${ctx}")
done

GH_ARGS+=(
    -F "enforce_admins=false"
    -F "required_pull_request_reviews[dismiss_stale_reviews]=true"
    -F "required_pull_request_reviews[required_approving_review_count]=1"
    -F "restrictions=null"
    -F "allow_force_pushes=false"
)

# ─── Ausfuehrung ────────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Branch-Protection — ${OWNER}/${REPO} main"
echo "════════════════════════════════════════════════════════════"
echo "  Strict:                       true"
echo "  Required Status Checks:       ${#CONTEXTS[@]} (${CONTEXTS[*]:-keine})"
echo "  Enforce admins:               false"
echo "  Dismiss stale reviews:        true"
echo "  Approving reviews required:   1"
echo "  Allow force pushes:           false"
echo "════════════════════════════════════════════════════════════"
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
    log_dry "gh api ${GH_ARGS[*]}"
    log_info "Dry-Run beendet — Aufruf NICHT durchgefuehrt."
    exit 0
fi

log_info "Sende PUT an repos/${OWNER}/${REPO}/branches/main/protection ..."
if gh api "${GH_ARGS[@]}" >/dev/null; then
    log_info "Branch-Protection gesetzt — verifizieren in GitHub UI: https://github.com/${OWNER}/${REPO}/settings/branches"
else
    log_error "gh api Aufruf fehlgeschlagen."
    log_error "Moegliche Ursachen:"
    log_error "  - fehlende Repo-Admin-Permissions (kein Owner/Admin auf ${OWNER}/${REPO})"
    log_error "  - Branch 'main' existiert nicht remote (erst 'git push -u origin main')"
    log_error "  - Free-Plan-Limit fuer Private Repos (Branch-Protection nur in Pro/Team)"
    log_error "Test manuell: gh api repos/${OWNER}/${REPO}/branches/main/protection"
    exit 1
fi
