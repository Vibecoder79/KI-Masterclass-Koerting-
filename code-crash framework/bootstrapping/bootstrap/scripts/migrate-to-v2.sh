#!/usr/bin/env bash
# migrate-to-v2.sh
#
# DE: Idempotentes Skelett-Skript fuer die Migration von Bestands-Projekten
#     auf Bootstrapping-Governance v2. Fuehrt nur deterministische Auto-Schritte
#     aus. Manuelle Operator-Schritte werden mit `[MANUAL]` markiert und
#     loggen die noetige Aktion ohne sie auszufuehren. Mehrfaches Ausfuehren
#     ist sicher: bestehende Dateien werden nicht ueberschrieben, idempotente
#     Append-Operationen pruefen vor dem Schreiben.
#
# EN: Idempotent skeleton script for migrating existing projects to
#     Bootstrapping governance v2. Runs deterministic auto steps only.
#     Manual operator steps are tagged `[MANUAL]` and logged without being
#     executed. Safe to run multiple times: existing files are kept,
#     idempotent appends check before writing.

set -euo pipefail

# -----------------------------------------------------------------------------
# Globale Variablen / Globals
# -----------------------------------------------------------------------------

DRY_RUN="${DRY_RUN:-false}"
FORCE="${FORCE:-false}"
SCRIPT_NAME="$(basename "$0")"

# -----------------------------------------------------------------------------
# Logging-Helfer / Logging Helpers
# -----------------------------------------------------------------------------

log_info()   { printf '[INFO]   %s\n' "$*"; }
log_warn()   { printf '[WARN]   %s\n' "$*" >&2; }
log_skip()   { printf '[SKIP]   %s\n' "$*"; }
log_manual() { printf '[MANUAL] %s\n' "$*"; }
log_dry()    { printf '[DRY]    %s\n' "$*"; }

# -----------------------------------------------------------------------------
# Datei-/Verzeichnis-Helfer / File and directory helpers (idempotent)
# -----------------------------------------------------------------------------

ensure_dir() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        log_skip "dir exists: $dir"
        return 0
    fi
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "mkdir -p $dir"
        return 0
    fi
    mkdir -p "$dir"
    log_info "created dir: $dir"
}

ensure_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        log_skip "file exists: $file"
        return 0
    fi
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "touch $file"
        return 0
    fi
    ensure_dir "$(dirname "$file")"
    : > "$file"
    log_info "created file: $file"
}

append_if_missing() {
    # append_if_missing <file> <line>
    local file="$1"
    local line="$2"
    ensure_file "$file"
    if grep -Fxq "$line" "$file" 2>/dev/null; then
        log_skip "line already in $file"
        return 0
    fi
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "append to $file: $line"
        return 0
    fi
    printf '%s\n' "$line" >> "$file"
    log_info "appended to $file: $line"
}

# -----------------------------------------------------------------------------
# Pro BOO-Issue eine Funktion / One function per BOO issue
# -----------------------------------------------------------------------------

# ---------------- Phase 1 — Fundament / Foundation ----------------

migrate_boo_1() {
    # BOO-1 — /intent-Skill bauen (Schrader Kap. 4) — Skill v1.0.0 seit 2026-05-01
    # https://linear.app/owlist/issue/BOO-1
    log_info "BOO-1: /intent-Skill — intents/-Verzeichnis im Bestands-Projekt anlegen"
    ensure_dir "intents"
    ensure_file "intents/.gitkeep"
    if [[ ! -f "intents/README.md" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write intents/README.md"
        else
            cat > "intents/README.md" <<'EOF'
# Intents

Pro Initiative eine Intent-Datei nach Schrader-Template (Code Crash Kap. 4):

- `intents/INTENT-XX.md` — Intent-Statement + 5-Schritte-Session-Output (XX = lfd. Nummer mit fuehrenden Nullen)
- `intents/INTENT-XX.validation.md` — Self-Check-Report mit Status gruen / gelb / rot

Workflow + Templates siehe Skill `/intent` (`bootstrapping/intent/`).
Pipeline-Verortung: `/intent` -> `/ideation` -> `/backlog` -> `/implement`.
EOF
            log_info "created intents/README.md"
        fi
    else
        log_skip "intents/README.md exists"
    fi
    log_manual "Operator: pruefen ob bestehende docs/intent.md oder vergleichbare Notizen existieren — falls ja, in intents/legacy.md migrieren"
    log_manual "Operator: /intent-Skill verfuegbar machen (via /bootstrap-Update oder durch Kopieren von bootstrapping/intent/ nach ~/.claude/skills/intent/)"
    return 0
}

migrate_boo_2() {
    # BOO-2 — ESLint-Regelsatz haerten (Airbnb + security + sonarjs) — v3.2.2 seit 2026-05-01
    # https://linear.app/owlist/issue/BOO-2
    log_info "BOO-2: ESLint-/Ruff-Regelsatz haerten"

    # --- Node.js: npm install nur wenn package.json vorhanden ---
    if [[ -f "package.json" ]]; then
        local pkgs="eslint @eslint/js eslint-config-airbnb-base eslint-plugin-security eslint-plugin-sonarjs @eslint/compat"
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "npm install --save-dev $pkgs"
        else
            log_info "Node-Projekt erkannt — npm install der ESLint-Layer"
            if command -v npm >/dev/null 2>&1; then
                # shellcheck disable=SC2086
                npm install --save-dev $pkgs && log_info "npm install erfolgreich" || log_warn "npm install fehlgeschlagen — Operator pruefen"
            else
                log_warn "npm nicht gefunden — Operator: '$pkgs' manuell installieren"
            fi
        fi
        log_manual "Operator (Node): eslint.config.mjs aus bootstrap/references/file-templates.md §eslint.config.mjs uebernehmen (4-Layer-Stack)"
        log_manual "Operator (Node, mit React): 'eslint-config-airbnb' statt '-base' nachinstallieren"
    else
        log_skip "kein package.json im aktuellen Verzeichnis — Node-Schritte uebersprungen"
    fi

    # --- Python: Hinweise fuer pyproject.toml ---
    if [[ -f "pyproject.toml" ]]; then
        log_info "Python-Projekt erkannt — Ruff-Konfiguration anpassen"
        log_manual "Operator (Python): [tool.ruff.lint]-Block aus bootstrap/references/file-templates.md §pyproject.toml uebernehmen"
        log_manual "Operator (Python): select sollte E, W, F, I, B, C4, S enthalten; per-file-ignores fuer tests/ und migrations/ pruefen"
    else
        log_skip "kein pyproject.toml im aktuellen Verzeichnis — Python-Schritte uebersprungen"
    fi

    log_manual "Operator: Erstlauf 'npx eslint . --max-warnings 0' bzw. 'ruff check .' — Findings erwartbar; via /implement deklarativ iterieren oder Lint-Cleanup-Story einplanen"
    return 0
}

# ---------------- Phase 2 — Production-Readiness ----------------

migrate_boo_3() {
    # BOO-3 — /bootstrap: .semgrep.yml Auto-Setup (sprach-aware) — v3.2.3 seit 2026-05-06
    # https://linear.app/owlist/issue/BOO-3
    log_info "BOO-3: .semgrep.yml + .semgrepignore anlegen (sprach-aware)"

    # Sprach-Erkennung — Layer 2 wird basierend auf vorhandenen Manifest-Dateien aktiviert
    local has_node="false"
    local has_python="false"
    [[ -f "package.json" ]] && has_node="true"
    [[ -f "pyproject.toml" ]] && has_python="true"

    if [[ ! -f ".semgrep.yml" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write .semgrep.yml (Node:$has_node Python:$has_python)"
        else
            {
                printf '%s\n' "# .semgrep.yml — SAST-Default fuer Governance v2 (BOO-3, v3.2.3)"
                printf '%s\n' "# DE: Konsumiert von Pre-Commit-Hook (BOO-4) und CI (geplant)."
                printf '%s\n' "# EN: Consumed by pre-commit hook (BOO-4) and CI (planned)."
                printf '%s\n' "rules: []"
                printf '%s\n' "include:"
                printf '%s\n' "  # Layer 1 — Pflicht (alle Stacks) / mandatory (all stacks)"
                printf '%s\n' "  - p/security-audit"
                printf '%s\n' "  - p/secrets"
                printf '\n'
                printf '%s\n' "  # Layer 2 — sprach-spezifisch (auto-erkannt) / language-specific (auto-detected)"
                if [[ "$has_node" == "true" ]]; then
                    printf '%s\n' "  - p/javascript"
                else
                    printf '%s\n' "  # - p/javascript        # bei package.json einkommentieren"
                fi
                if [[ "$has_python" == "true" ]]; then
                    printf '%s\n' "  - p/python"
                else
                    printf '%s\n' "  # - p/python            # bei pyproject.toml einkommentieren"
                fi
                printf '\n'
                printf '%s\n' "  # Layer 3 — Optional fuer Web-Projekte (manuell einkommentieren)"
                printf '%s\n' "  # - p/owasp-top-ten     # bei Web-Frontend, REST-APIs, GraphQL"
            } > ".semgrep.yml"
            log_info "created .semgrep.yml (Node:$has_node Python:$has_python)"
        fi
    else
        log_skip ".semgrep.yml exists"
    fi

    if [[ ! -f ".semgrepignore" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write .semgrepignore default excludes"
        else
            cat > ".semgrepignore" <<'EOF'
# .semgrepignore — Default-Excludes fuer Governance v2 (BOO-3)
node_modules/
dist/
build/
journal/reports/
.venv/
__pycache__/
EOF
            log_info "created .semgrepignore"
        fi
    else
        log_skip ".semgrepignore exists"
    fi

    log_manual "Operator: bei Web-Projekt 'p/owasp-top-ten' in .semgrep.yml einkommentieren (Layer 3)"
    log_manual "Operator: Semgrep CLI installieren falls nicht vorhanden ('brew install semgrep' oder 'pip install semgrep')"
    return 0
}

migrate_boo_4() {
    # BOO-4 — /implement Schritt 6a-bis: Semgrep als Pre-Commit + CI Gate — v3.2.4 seit 2026-05-06
    # https://linear.app/owlist/issue/BOO-4
    log_info "BOO-4: Pre-Commit-Hook + GitHub Action mit Manifest-Reader anlegen"

    # --- Pre-Commit-Hook ---
    local hook_path=".git/hooks/pre-commit"
    if [[ ! -d ".git" ]]; then
        log_skip "kein .git/-Verzeichnis — Pre-Commit-Hook uebersprungen (Operator: 'git init' zuerst)"
    elif [[ -f "$hook_path" ]]; then
        log_skip "$hook_path existiert — manuelle Inspektion noetig"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "write $hook_path (Manifest-Reader fuer ESLint + Semgrep)"
    else
        # Hook-Inhalt aus file-templates.md §.git/hooks/pre-commit
        cat > "$hook_path" <<'HOOK_EOF'
#!/usr/bin/env bash
# .git/hooks/pre-commit — Quality-Gate Layer 2 (lokal, blockierend)
# DE: Konsumiert eslint.config.mjs (BOO-2) und .semgrep.yml (BOO-3 Manifest).
set -euo pipefail
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
cd "$PROJECT_ROOT"

# --- ESLint-Gate (BOO-2) ---
if [[ -f "eslint.config.mjs" ]]; then
    CHANGED_JS=$(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.(js|mjs|jsx|ts|tsx)$' || true)
    if [[ -n "$CHANGED_JS" ]]; then
        echo "[PRE-COMMIT] ESLint auf $(echo "$CHANGED_JS" | wc -l | tr -d ' ') Datei(en)"
        echo "$CHANGED_JS" | xargs npx eslint --max-warnings=0 || {
            echo "[PRE-COMMIT] ESLint-Gate BLOCKIERT."
            exit 1
        }
    fi
fi

# --- Semgrep-Gate (BOO-4, Manifest-Reader) ---
if [[ -f ".semgrep.yml" ]]; then
    PACKS=$(grep -E '^[[:space:]]*-[[:space:]]+p/' .semgrep.yml | sed -E 's/^[[:space:]]*-[[:space:]]+//' || true)
    if [[ -n "$PACKS" ]]; then
        ARGS=""
        for pack in $PACKS; do
            ARGS="$ARGS --config $pack"
        done
        echo "[PRE-COMMIT] Semgrep mit Packs: $(echo "$PACKS" | tr '\n' ' ')"
        if ! command -v semgrep >/dev/null 2>&1; then
            echo "[PRE-COMMIT] Semgrep CLI nicht installiert — 'brew install semgrep' oder 'pip install semgrep'"
            exit 1
        fi
        # shellcheck disable=SC2086
        if ! semgrep $ARGS --error --quiet 2>&1; then
            echo "[PRE-COMMIT] Semgrep-Gate BLOCKIERT."
            exit 1
        fi
    else
        echo "[PRE-COMMIT] .semgrep.yml hat keine aktiven Packs — Gate uebersprungen"
    fi
fi

exit 0
HOOK_EOF
        chmod +x "$hook_path"
        log_info "created $hook_path (executable)"
    fi

    # --- GitHub Action Workflow ---
    local workflow_dir=".github/workflows"
    local workflow_path="$workflow_dir/semgrep.yml"
    ensure_dir "$workflow_dir"
    if [[ -f "$workflow_path" ]]; then
        log_skip "$workflow_path existiert"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "write $workflow_path (Manifest-Reader-CI)"
    else
        cat > "$workflow_path" <<'WORKFLOW_EOF'
# .github/workflows/semgrep.yml — Quality-Gate Layer 3 (CI, blockiert Merge)
name: Semgrep
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  semgrep:
    runs-on: ubuntu-latest
    container: returntocorp/semgrep
    steps:
      - uses: actions/checkout@v4

      - name: Read manifest and run Semgrep
        run: |
          mkdir -p .ci-reports
          ARGS=""
          while IFS= read -r line; do
              pack=$(echo "$line" | sed -E 's/^[[:space:]]*-[[:space:]]+//')
              ARGS="$ARGS --config $pack"
          done < <(grep -E '^[[:space:]]*-[[:space:]]+p/' .semgrep.yml)
          if [[ -z "$ARGS" ]]; then
              echo "::error::No active packs in .semgrep.yml"
              exit 1
          fi
          semgrep $ARGS --error --sarif --output=.ci-reports/semgrep.sarif

      - uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: .ci-reports/semgrep.sarif
        if: always()

      - uses: actions/upload-artifact@v4
        with:
          name: semgrep-report
          path: .ci-reports/semgrep.sarif
WORKFLOW_EOF
        log_info "created $workflow_path"
    fi

    log_manual "Operator: Branch-Protection in GitHub aktivieren — Required Status Check 'Semgrep' (siehe BOO-29)"
    log_manual "Operator: Bei Husky-Setup .husky/pre-commit anpassen statt .git/hooks/pre-commit"
    return 0
}

migrate_boo_5() {
    # BOO-5 — /bootstrap: SonarQube Cloud Auto-Setup
    # https://linear.app/owlist/issue/BOO-5
    log_info "BOO-5: SonarQube Cloud — Auto + Manual"
    log_manual "Operator: SonarCloud-Account verifizieren, Org 'owlist' bestaetigen"
    log_manual "Operator: Projekt in SonarCloud anlegen, SONAR_TOKEN in GitHub-Secrets eintragen"
    # TODO: implementiert beim Done von BOO-5 — sonar-project.properties + Workflow-File aus file-templates.md
    log_manual "Operator: sonar-project.properties + .github/workflows/sonarcloud.yml aus file-templates.md kopieren (Auto-Schritt folgt beim Done von BOO-5)"
    return 0
}

migrate_boo_12() {
    # BOO-12 — Dependency + Halluzinations-Check Pre-Commit (Slopsquatting-Schutz) — v3.2.5 seit 2026-05-06
    # https://linear.app/owlist/issue/BOO-12
    log_info "BOO-12: Slopsquatting-Schutz — dependency-check.sh anlegen + Pre-Commit-Hook erweitern"

    # --- Hook-Skript anlegen ---
    local hooks_dir=".claude/hooks"
    local hook_script="$hooks_dir/dependency-check.sh"
    ensure_dir "$hooks_dir"
    if [[ -f "$hook_script" ]]; then
        log_skip "$hook_script existiert"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "write $hook_script (drei Checks: Existenz/Age/CVE)"
    else
        cat > "$hook_script" <<'DEPCHECK_EOF'
#!/usr/bin/env bash
# .claude/hooks/dependency-check.sh — Slopsquatting-Schutz (BOO-12)
# Inhalt aus bootstrap/references/file-templates.md §hooks/dependency-check.sh
# (komplettes Bash-Skript hier eingebettet)
set -euo pipefail

CHANGED=$(git diff --cached --name-only --diff-filter=ACMR)
TRIGGERS_NPM=$(echo "$CHANGED" | grep -E '^package\.json$' || true)
TRIGGERS_PIP=$(echo "$CHANGED" | grep -E '^(requirements\.txt|pyproject\.toml)$' || true)
TRIGGERS_CARGO=$(echo "$CHANGED" | grep -E '^Cargo\.toml$' || true)

if [[ -z "$TRIGGERS_NPM" && -z "$TRIGGERS_PIP" && -z "$TRIGGERS_CARGO" ]]; then
    exit 0
fi

AGE_THRESHOLD_DAYS=30
BLOCKED=0

extract_new_npm_deps() {
    # POSIX-konform (BSD-grep/sed-kompatibel): match nur "+"-Zeilen mit
    # "key": "version-wert" — Wert muss mit Versionsnummer beginnen
    # (optional ^, ~, >=, <= prefix). Filtert Top-Level-"version".
    git diff --cached package.json 2>/dev/null \
        | grep -E '^\+[[:space:]]+"[^"]+":[[:space:]]*"[~^>=<]?[0-9]' \
        | sed -E 's/^\+[[:space:]]+"([^"]+)":.*/\1/' \
        | grep -vE '^(version)$' \
        || true
}

extract_new_pypi_deps() {
    if [[ -n "$TRIGGERS_PIP" ]] && echo "$TRIGGERS_PIP" | grep -q "requirements.txt"; then
        git diff --cached requirements.txt 2>/dev/null \
            | grep -E '^\+[a-zA-Z]' \
            | sed -E 's/^\+([a-zA-Z0-9_-]+).*/\1/' \
            || true
    fi
    if [[ -n "$TRIGGERS_PIP" ]] && echo "$TRIGGERS_PIP" | grep -q "pyproject.toml"; then
        git diff --cached pyproject.toml 2>/dev/null \
            | grep -E '^\+[[:space:]]+"[a-zA-Z]' \
            | sed -E 's/^\+[[:space:]]+"([a-zA-Z0-9_-]+).*/\1/' \
            || true
    fi
}

check_npm_existence() {
    local pkg="$1"
    if command -v npm >/dev/null 2>&1; then
        npm view "$pkg" name >/dev/null 2>&1 && return 0 || return 1
    else
        curl -fsSL --max-time 5 "https://registry.npmjs.org/$pkg" >/dev/null 2>&1 && return 0 || return 1
    fi
}

check_pypi_existence() {
    local pkg="$1"
    curl -fsSL --max-time 5 "https://pypi.org/pypi/$pkg/json" >/dev/null 2>&1 && return 0 || return 1
}

check_npm_age() {
    local pkg="$1"
    local created
    if command -v npm >/dev/null 2>&1; then
        created=$(npm view "$pkg" time.created 2>/dev/null || echo "")
    else
        created=$(curl -fsSL --max-time 5 "https://registry.npmjs.org/$pkg" 2>/dev/null \
            | grep -oE '"created":"[^"]+"' | head -1 | sed -E 's/"created":"([^"]+)"/\1/' || echo "")
    fi
    [[ -z "$created" ]] && return 0
    local pkg_epoch
    pkg_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${created%.*}" +"%s" 2>/dev/null || \
                date -d "$created" +"%s" 2>/dev/null || echo "0")
    [[ "$pkg_epoch" == "0" ]] && return 0
    local now_epoch days
    now_epoch=$(date +"%s")
    days=$(( (now_epoch - pkg_epoch) / 86400 ))
    if (( days < AGE_THRESHOLD_DAYS )); then
        echo "[DEP-CHECK] WARNUNG: Paket '$pkg' ist nur $days Tage alt — Typosquatter-Risiko, manuell verifizieren"
    fi
    return 0
}

check_npm_cve() {
    if command -v npm >/dev/null 2>&1 && [[ -f "package-lock.json" ]]; then
        local audit_output
        audit_output=$(npm audit --audit-level=high 2>&1 || true)
        if echo "$audit_output" | grep -qE 'high|critical'; then
            echo "[DEP-CHECK] BLOCK: npm audit meldet High/Critical Vulnerabilities. Lauf 'npm audit' fuer Details."
            return 1
        fi
    fi
    return 0
}

check_pypi_cve() {
    if command -v pip-audit >/dev/null 2>&1; then
        local audit_output
        audit_output=$(pip-audit --strict 2>&1 || true)
        if echo "$audit_output" | grep -qiE 'vulnerability|cve'; then
            echo "[DEP-CHECK] BLOCK: pip-audit meldet Vulnerabilities. Lauf 'pip-audit' fuer Details."
            return 1
        fi
    fi
    return 0
}

echo "[DEP-CHECK] Slopsquatting-Schutz aktiv"

if [[ -n "$TRIGGERS_NPM" ]]; then
    NEW_NPM=$(extract_new_npm_deps)
    for pkg in $NEW_NPM; do
        if ! check_npm_existence "$pkg"; then
            echo "[DEP-CHECK] BLOCK: npm-Paket '$pkg' existiert nicht in der Registry — Halluzination?"
            BLOCKED=1
        else
            check_npm_age "$pkg"
        fi
    done
    check_npm_cve || BLOCKED=1
fi

if [[ -n "$TRIGGERS_PIP" ]]; then
    NEW_PYPI=$(extract_new_pypi_deps)
    for pkg in $NEW_PYPI; do
        if ! check_pypi_existence "$pkg"; then
            echo "[DEP-CHECK] BLOCK: PyPI-Paket '$pkg' existiert nicht — Halluzination?"
            BLOCKED=1
        fi
    done
    check_pypi_cve || BLOCKED=1
fi

if [[ -n "$TRIGGERS_CARGO" ]]; then
    echo "[DEP-CHECK] HINWEIS: Cargo-Diff erkannt — Cargo-Check wird in zukuenftiger Iteration ergaenzt. Operator: 'cargo audit' manuell laufen lassen."
fi

if (( BLOCKED == 1 )); then
    echo "[DEP-CHECK] Gate BLOCKIERT. Slopsquatting-Risiko vermeiden — Pakete verifizieren, dann erneut committen."
    exit 1
fi

echo "[DEP-CHECK] Gate bestanden"
exit 0
DEPCHECK_EOF
        chmod +x "$hook_script"
        log_info "created $hook_script (executable)"
    fi

    # --- Pre-Commit-Hook erweitern: Aufruf von dependency-check.sh nach Semgrep ergaenzen ---
    local pre_commit_hook=".git/hooks/pre-commit"
    if [[ ! -f "$pre_commit_hook" ]]; then
        log_manual "Pre-Commit-Hook fehlt — erst BOO-4 ('--issue BOO-4') laufen lassen"
    elif grep -q "dependency-check.sh" "$pre_commit_hook" 2>/dev/null; then
        log_skip "Pre-Commit-Hook ruft dependency-check.sh bereits auf"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "append dependency-check.sh-Aufruf an $pre_commit_hook (vor 'exit 0')"
    else
        # Aufruf vor das letzte 'exit 0' einfuegen
        # Idempotent: zweite Lauf-Erkennung via grep oben
        local tmp
        tmp=$(mktemp)
        awk '
            /^exit 0$/ && !done {
                print "# --- Dependency-Gate (BOO-12) ---"
                print "if [[ -x \".claude/hooks/dependency-check.sh\" ]]; then"
                print "    bash .claude/hooks/dependency-check.sh || exit 1"
                print "fi"
                print ""
                done = 1
            }
            { print }
        ' "$pre_commit_hook" > "$tmp"
        mv "$tmp" "$pre_commit_hook"
        chmod +x "$pre_commit_hook"
        log_info "Pre-Commit-Hook um dependency-check.sh-Aufruf erweitert"
    fi

    log_manual "Operator (Node): 'npm audit' verfuegbar — fuer CVE-Pruefung"
    log_manual "Operator (Python): 'pip install pip-audit' fuer CVE-Pruefung"
    return 0
}

migrate_boo_15() {
    # BOO-15 — /implement Coverage-Gate (>=80% fuer neuen Code) — v3.2.6 seit 2026-05-06
    # https://linear.app/owlist/issue/BOO-15
    log_info "BOO-15: coverage-check.sh anlegen (Diff-Coverage-Gate)"

    local hooks_dir=".claude/hooks"
    local hook_script="$hooks_dir/coverage-check.sh"
    ensure_dir "$hooks_dir"
    if [[ -f "$hook_script" ]]; then
        log_skip "$hook_script existiert"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "write $hook_script (Diff-Coverage-Gate, COVERAGE_PASS=80, COVERAGE_WARN=60)"
    else
        cat > "$hook_script" <<'COVCHECK_EOF'
#!/usr/bin/env bash
# .claude/hooks/coverage-check.sh — Diff-Coverage-Gate (BOO-15)
# Inhalt aus bootstrap/references/file-templates.md §hooks/coverage-check.sh
set -euo pipefail

COVERAGE_PASS="${COVERAGE_PASS:-80}"
COVERAGE_WARN="${COVERAGE_WARN:-60}"

COVERAGE_FILE=""
COVERAGE_TOOL=""

if [[ -f "coverage/coverage-final.json" ]]; then
    COVERAGE_FILE="coverage/coverage-final.json"
    COVERAGE_TOOL="c8"
elif [[ -f "coverage.json" ]]; then
    COVERAGE_FILE="coverage.json"
    COVERAGE_TOOL="pytest-cov"
elif [[ -f ".coverage" || -f "coverage/.coverage" ]]; then
    echo "[COVERAGE] HINWEIS: pytest-cov-SQLite gefunden, aber kein JSON-Export. Lauf 'pytest --cov --cov-report=json' fuer Diff-Coverage."
    exit 0
else
    echo "[COVERAGE] Keine Coverage-Daten gefunden — Gate uebersprungen."
    echo "[COVERAGE] Hinweis: Test-Setup fehlt — ggf. /bootstrap nachziehen oder 'npx c8 npm test' / 'pytest --cov --cov-report=json' laufen lassen."
    exit 0
fi

echo "[COVERAGE] Tool: $COVERAGE_TOOL, Datei: $COVERAGE_FILE, Schwellwerte: pass=$COVERAGE_PASS%, warn=$COVERAGE_WARN%"

extract_added_lines() {
    # POSIX-awk-kompatibel (BSD + gawk): kein match(... , arr) mit drittem
    # Argument. Statt dessen split() auf @@-Zeile, "+"-Token-Suche, dann
    # split bei Komma in [start, count].
    git diff --cached -U0 --no-color 2>/dev/null \
        | awk '
            /^\+\+\+ b\// { file = substr($0, 7); next }
            /^@@ / {
                n = split($0, parts, " ")
                for (i = 1; i <= n; i++) {
                    if (parts[i] ~ /^\+[0-9]+/) {
                        sub(/^\+/, "", parts[i])
                        split(parts[i], nums, ",")
                        start = nums[1] + 0
                        count = (nums[2] == "") ? 1 : (nums[2] + 0)
                        for (j = 0; j < count; j++) print file ":" (start + j)
                        break
                    }
                }
                next
            }
        '
}

parse_covered_lines_c8() {
    local file="$1"
    python3 - "$COVERAGE_FILE" "$file" <<'PYEOF'
import json, sys
cov_file, target = sys.argv[1], sys.argv[2]
try:
    data = json.load(open(cov_file))
except Exception:
    sys.exit(0)
target_abs = target.lstrip("./")
for k, v in data.items():
    if k.endswith(target_abs) or k.endswith(target):
        stmts = v.get("statementMap", {})
        counts = v.get("s", {})
        for stmt_id, loc in stmts.items():
            line = loc.get("start", {}).get("line")
            if line and counts.get(stmt_id, 0) > 0:
                print(line)
        break
PYEOF
}

parse_covered_lines_pytest() {
    local file="$1"
    python3 - "$COVERAGE_FILE" "$file" <<'PYEOF'
import json, sys
cov_file, target = sys.argv[1], sys.argv[2]
try:
    data = json.load(open(cov_file))
except Exception:
    sys.exit(0)
files = data.get("files", {})
target_norm = target.lstrip("./")
for k, v in files.items():
    if k.endswith(target_norm) or k.endswith(target):
        for line in v.get("executed_lines", []):
            print(line)
        break
PYEOF
}

ADDED=$(extract_added_lines)

if [[ -z "$ADDED" ]]; then
    echo "[COVERAGE] Keine neu hinzugefuegten Zeilen im Diff — Gate uebersprungen."
    exit 0
fi

TOTAL_ADDED=0
COVERED_ADDED=0
declare -A FILES_SEEN

while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    file="${entry%:*}"
    line="${entry##*:}"

    if ! echo "$file" | grep -qE '\.(js|mjs|ts|tsx|jsx|py)$'; then
        continue
    fi
    if echo "$file" | grep -qE '(^test|/test|_test\.|\.test\.|\.spec\.|tests/|__tests__|conftest\.py)'; then
        continue
    fi

    if [[ -z "${FILES_SEEN[$file]:-}" ]]; then
        if [[ "$COVERAGE_TOOL" == "c8" ]]; then
            FILES_SEEN[$file]="$(parse_covered_lines_c8 "$file" | tr '\n' ' ')"
        else
            FILES_SEEN[$file]="$(parse_covered_lines_pytest "$file" | tr '\n' ' ')"
        fi
    fi

    TOTAL_ADDED=$(( TOTAL_ADDED + 1 ))
    if echo " ${FILES_SEEN[$file]} " | grep -qw "$line"; then
        COVERED_ADDED=$(( COVERED_ADDED + 1 ))
    fi
done <<< "$ADDED"

if (( TOTAL_ADDED == 0 )); then
    echo "[COVERAGE] Keine bewertbaren neuen Zeilen (alles Tests/Configs) — Gate uebersprungen."
    exit 0
fi

PCT=$(( (COVERED_ADDED * 100) / TOTAL_ADDED ))
echo "[COVERAGE] Diff-Coverage: $COVERED_ADDED / $TOTAL_ADDED added lines = ${PCT}%"

if (( PCT >= COVERAGE_PASS )); then
    echo "[COVERAGE] Gate bestanden (>=${COVERAGE_PASS}%)"
    exit 0
elif (( PCT >= COVERAGE_WARN )); then
    echo "[COVERAGE] WARNUNG: Diff-Coverage ${PCT}% liegt unter ${COVERAGE_PASS}% (Pass-Schwelle), aber ueber ${COVERAGE_WARN}% (Warn-Schwelle)."
    echo "[COVERAGE] Operator-Freigabe moeglich mit Begruendung im Linear-Kommentar."
    exit 0
else
    echo "[COVERAGE] Gate BLOCKIERT: Diff-Coverage ${PCT}% liegt unter ${COVERAGE_WARN}% (Warn-Schwelle)."
    echo "[COVERAGE] Tests hinzufuegen oder Story splitten."
    exit 1
fi
COVCHECK_EOF
        chmod +x "$hook_script"
        log_info "created $hook_script (executable)"
    fi

    log_manual "Operator (Node): 'npm install --save-dev c8' falls nicht installiert"
    log_manual "Operator (Python): pytest-cov in pyproject.toml ergaenzen"
    log_manual "Operator: /implement-Skill ruft den Hook automatisch in Schritt 6a-quart auf — Test-Lauf vorher mit Coverage-Output noetig"
    return 0
}

migrate_boo_27() {
    # BOO-27 — Issue-Template: 4 Schrader-Prompt-Bestandteile als Pflichtfelder (Governance v2)
    # https://linear.app/owlist/issue/BOO-27
    log_info "BOO-27: Schrader-Prompt-Bestandteile als Pflichtfelder + HARD GATE in /implement"
    ensure_dir ".github/ISSUE_TEMPLATE"
    if [[ ! -f ".github/ISSUE_TEMPLATE/story.yml" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write .github/ISSUE_TEMPLATE/story.yml"
        else
            cat > ".github/ISSUE_TEMPLATE/story.yml" <<'EOF'
name: Story / Feature
description: "Code Crash Governance v2 — Schrader Prompt Components (Pflichtfelder)"
title: "[STORY] "
body:
  - type: dropdown
    id: execution_mode
    attributes:
      label: "Ausführungsmodus"
      description: "agentic = Lead + parallele Sub-Agents | sub-agents = sequentiell | linear = direkt (<50 Zeilen, 1-2 SP)"
      options:
        - linear
        - sub-agents
        - agentic
    validations:
      required: true
  - type: textarea
    id: insight
    attributes:
      label: "Insight — Warum jetzt?"
      description: "Welches Problem oder welche Beobachtung steckt hinter dieser Story? Min. 1 Satz."
      placeholder: "Bsp: Der aktuelle Prozess X ist fehleranfällig weil ..."
    validations:
      required: true
  - type: textarea
    id: constraints
    attributes:
      label: "Constraints — Rahmenbedingungen"
      description: "Technische, zeitliche oder fachliche Grenzen für die Lösung."
      placeholder: "Bsp: Muss rückwärtskompatibel bleiben, kein Breaking Change in API v1"
    validations:
      required: true
  - type: textarea
    id: success_criteria
    attributes:
      label: "Erfolgskriterien"
      description: "Woran erkennt man den Erfolg? Konkret und messbar."
      placeholder: "Bsp: CI grün, alle bestehenden Tests bestehen, neue Tests für Pfad X"
    validations:
      required: true
  - type: textarea
    id: desired_outcome
    attributes:
      label: "Gewünschtes Ergebnis"
      description: "Welcher Zustand herrscht nach der Umsetzung?"
      placeholder: "Bsp: Operator kann /implement BOO-XX ohne manuelle Vorbereitung aufrufen"
    validations:
      required: true
  - type: textarea
    id: dod
    attributes:
      label: "Definition of Done"
      value: "- [ ] Tests grün\n- [ ] Kein Lint-Fehler\n- [ ] SecondBrain / HANDBUCH aktualisiert\n- [ ] Commit-Message-Convention eingehalten\n- [ ] Keine offenen TODOs im diff"
    validations:
      required: false
EOF
            log_info "created .github/ISSUE_TEMPLATE/story.yml"
        fi
    else
        log_skip ".github/ISSUE_TEMPLATE/story.yml exists"
    fi
    log_manual "Operator: /implement hat seit BOO-27 einen HARD GATE in Schritt 1b — bestehende Linear-Issues brauchen alle 4 Schrader-Bestandteile (Insight / Constraints / Erfolgskriterien / Gewuenschtes Ergebnis, je min. 20 Zeichen) bevor /implement aufgerufen werden kann"
    log_manual "Operator: Optional CLAUDE.md ergaenzen: 'Jedes Linear-Issue muss die 4 Schrader-Prompt-Bestandteile enthalten. /implement blockt sonst in Schritt 1b.'"
    return 0
}

migrate_boo_28() {
    # BOO-28 — /bootstrap: ESLint als GitHub Action (CI-Gate) — v3.17.0 seit 2026-05-12
    # https://linear.app/owlist/issue/BOO-28
    #
    # Legt Stack-abhaengig einen oder zwei CI-Workflow-Files an:
    #   1. .github/workflows/eslint.yml   — wenn package.json vorhanden (Node/JS/TS)
    #   2. .github/workflows/ruff.yml     — wenn pyproject.toml ODER requirements.txt vorhanden (Python)
    #   Mixed-Stack (beide Manifest-Files vorhanden) -> beide Workflows parallel.
    #
    # SARIF-Output ist Pflicht (BOO-32-Vorbereitung) — beide Workflows schreiben nach
    # .ci-reports/<tool>.sarif und uploaden via github/codeql-action/upload-sarif@v3.
    #
    # Stack-Detection: identisches Pattern zu migrate_boo_16/migrate_boo_25.
    #   - package.json                                 -> Node
    #   - pyproject.toml ODER requirements.txt         -> Python
    #   - beide                                        -> Mixed (beide Workflows)
    #   - keines                                       -> Unknown (log_warn, kein Workflow)
    #
    # Idempotenz: bestehende Workflow-Files werden ge[SKIP]ped; --force ueberschreibt.
    log_info "BOO-28: ESLint/Ruff als GitHub Action (CI-Lint-Gate mit SARIF)"

    # --- Stack-Detection ---
    local has_node="false"
    local has_python="false"
    [[ -f "package.json" ]] && has_node="true"
    [[ -f "pyproject.toml" || -f "requirements.txt" ]] && has_python="true"

    if [[ "$has_node" != "true" && "$has_python" != "true" ]]; then
        log_warn "BOO-28: weder package.json noch pyproject.toml/requirements.txt gefunden — Stack unbekannt"
        log_manual "Operator: Stack manuell festlegen oder Manifest-File ergaenzen, dann erneut '--issue BOO-28' laufen lassen"
        return 0
    fi

    ensure_dir ".github/workflows"

    # --- Node-Stack: .github/workflows/eslint.yml ---
    if [[ "$has_node" == "true" ]]; then
        local eslint_yml=".github/workflows/eslint.yml"
        if [[ -f "$eslint_yml" && "$FORCE" != "true" ]]; then
            log_skip "$eslint_yml existiert (use --force to overwrite)"
        elif [[ "$DRY_RUN" == "true" ]]; then
            if [[ -f "$eslint_yml" ]]; then
                log_dry "overwrite $eslint_yml (--force) — Inhalt aus file-templates.md §.github/workflows/eslint.yml (BOO-28)"
            else
                log_dry "write $eslint_yml (Inhalt aus file-templates.md §.github/workflows/eslint.yml (BOO-28))"
            fi
        else
            # Heredoc 1:1 aus bootstrap/references/file-templates.md §.github/workflows/eslint.yml (BOO-28)
            cat > "$eslint_yml" <<'ESLINT_YML_EOF'
name: ESLint
on: [push, pull_request]
jobs:
  eslint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci
      - run: npx eslint . --format=@microsoft/eslint-formatter-sarif --output-file=.ci-reports/eslint.sarif
      - uses: github/codeql-action/upload-sarif@v3
        with: { sarif_file: .ci-reports/eslint.sarif }
        if: always()
ESLINT_YML_EOF
            log_info "created $eslint_yml (SARIF-Output nach .ci-reports/eslint.sarif)"
        fi

        # SARIF-Formatter als devDependency ergaenzen (idempotent via jq)
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "ergaenze package.json devDependencies um '@microsoft/eslint-formatter-sarif' (via jq oder Operator)"
        elif command -v jq >/dev/null 2>&1; then
            if jq -e '.devDependencies["@microsoft/eslint-formatter-sarif"] // empty' package.json >/dev/null 2>&1; then
                log_skip "package.json devDependencies enthaelt bereits '@microsoft/eslint-formatter-sarif'"
            else
                jq '.devDependencies = (.devDependencies // {}) + {"@microsoft/eslint-formatter-sarif": "^3.1.0"}' package.json > package.json.tmp \
                    && mv package.json.tmp package.json
                log_info "package.json devDependencies um '@microsoft/eslint-formatter-sarif' ergaenzt — 'npm install' im Anschluss noetig"
            fi
        else
            log_warn "jq nicht gefunden — Operator: 'npm install --save-dev @microsoft/eslint-formatter-sarif' manuell ausfuehren"
        fi
    fi

    # --- Python-Stack: .github/workflows/ruff.yml ---
    if [[ "$has_python" == "true" ]]; then
        local ruff_yml=".github/workflows/ruff.yml"
        if [[ -f "$ruff_yml" && "$FORCE" != "true" ]]; then
            log_skip "$ruff_yml existiert (use --force to overwrite)"
        elif [[ "$DRY_RUN" == "true" ]]; then
            if [[ -f "$ruff_yml" ]]; then
                log_dry "overwrite $ruff_yml (--force) — Inhalt aus file-templates.md §.github/workflows/ruff.yml (BOO-28)"
            else
                log_dry "write $ruff_yml (Inhalt aus file-templates.md §.github/workflows/ruff.yml (BOO-28))"
            fi
        else
            # Heredoc aus bootstrap/references/file-templates.md §.github/workflows/ruff.yml (BOO-28)
            cat > "$ruff_yml" <<'RUFF_YML_EOF'
name: Ruff
on: [push, pull_request]
jobs:
  ruff:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.12' }
      - run: pip install ruff
      - run: |
          mkdir -p .ci-reports
          ruff check . --output-format=sarif --output-file=.ci-reports/ruff.sarif
      - uses: github/codeql-action/upload-sarif@v3
        with: { sarif_file: .ci-reports/ruff.sarif }
        if: always()
RUFF_YML_EOF
            log_info "created $ruff_yml (SARIF-Output nach .ci-reports/ruff.sarif)"
        fi
    fi

    # --- .ci-reports/ aus dem Repo-Index halten (Konvention analog journal/reports/perf/) ---
    append_if_missing ".gitignore" ".ci-reports/"

    # --- Operator-Schritte ---
    log_manual "Operator-Schritte: siehe migration-checklist-v1-to-v2.md §BOO-28"
    if [[ "$has_node" == "true" ]]; then
        log_manual "Operator (Node): 'npm install' nach package.json-Update — verifiziert '@microsoft/eslint-formatter-sarif' im node_modules vorhanden"
    fi
    log_manual "Operator: ersten CI-Lauf abwarten (Push oder PR auf main) — gruener 'ESLint'-Check (bzw. 'Ruff') sollte erscheinen"
    log_manual "Operator: SARIF-Upload im GitHub Security-Tab pruefen (Settings -> Security -> Code scanning alerts)"
    log_manual "Operator: nach BOO-28-Done in BOO-29 Branch-Protection aktivieren mit Required Status Check 'ESLint' (bzw. 'Ruff')"
    return 0
}

migrate_boo_29() {
    # BOO-29 — /bootstrap: Branch-Protection mit Required Status Checks — v3.18.0 seit 2026-05-12
    # https://linear.app/owlist/issue/BOO-29
    #
    # Setzt via `gh api` Branch-Protection auf main:
    #   - required_status_checks.strict = true
    #   - required_status_checks.contexts[] — dynamisch aus .github/workflows/*.yml
    #     (erstes Top-Level `name:`-Feld pro Workflow-Datei)
    #   - enforce_admins = false
    #   - required_pull_request_reviews.dismiss_stale_reviews = true
    #   - required_pull_request_reviews.required_approving_review_count = 1
    #   - restrictions = null
    #   - allow_force_pushes = false
    #
    # Eigentliche Logik in scripts/setup-branch-protection.sh — diese Funktion
    # ist Wrapper, der Voraussetzungen prueft, das Skript aufruft (oder bei
    # DRY_RUN/FORCE die richtige Flag-Kombination logged) und auf Fehler klar
    # an den Operator zurueckspielt.
    #
    # Idempotenz: PUT-Call ist Replace — re-run-safe.
    log_info "BOO-29: Branch-Protection mit Required Status Checks"

    # --- Voraussetzungs-Check 1: gh CLI installiert? ---
    if ! command -v gh >/dev/null 2>&1; then
        log_warn "gh CLI nicht gefunden — BOO-29 uebersprungen"
        log_manual "Operator: 'brew install gh' (Mac) oder https://cli.github.com/ — danach erneut '--issue BOO-29' laufen lassen"
        return 0
    fi

    # --- Voraussetzungs-Check 2: gh auth status — eingeloggt? ---
    if ! gh auth status >/dev/null 2>&1; then
        log_warn "gh CLI nicht eingeloggt — BOO-29 uebersprungen"
        log_manual "Operator: 'gh auth login' ausfuehren (Browser-Flow oder Token mit 'repo'-Scope), danach erneut '--issue BOO-29' laufen lassen"
        return 0
    fi

    # --- Voraussetzungs-Check 3: Remote 'origin' vorhanden? ---
    if ! git remote get-url origin >/dev/null 2>&1; then
        log_warn "Kein git remote 'origin' im aktuellen Repo — BOO-29 uebersprungen"
        log_manual "Operator: 'git remote add origin git@github.com:<owner>/<repo>.git' und 'git push -u origin main' laufen lassen, dann erneut '--issue BOO-29'"
        return 0
    fi

    # --- Skript-Pfad finden — neben migrate-to-v2.sh im selben Verzeichnis ---
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local bp_script="$script_dir/setup-branch-protection.sh"

    if [[ ! -f "$bp_script" ]]; then
        log_warn "setup-branch-protection.sh nicht gefunden unter $bp_script — BOO-29 uebersprungen"
        log_manual "Operator: scripts/setup-branch-protection.sh aus dem Bootstrap-Repo (bootstrapping/bootstrap/scripts/) ins Projekt kopieren und dann erneut laufen lassen"
        return 0
    fi

    # --- Dispatch: Dry-Run vs. echter Lauf ---
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry "bash $bp_script --dry-run (Branch-Protection setzen mit dynamischen Required Status Checks aus .github/workflows/*.yml)"
    else
        log_info "Rufe $bp_script auf — Branch-Protection wird gesetzt"
        if bash "$bp_script"; then
            log_info "Branch-Protection erfolgreich gesetzt"
        else
            log_warn "setup-branch-protection.sh fehlgeschlagen — Operator-Schritte unten beachten"
            log_manual "Operator: bash $bp_script manuell ausfuehren und Fehlerausgabe pruefen (Permissions? main remote? Free-Plan-Limit?)"
        fi
    fi

    log_manual "Operator: in GitHub-UI verifizieren (Settings -> Branches -> main) — Protection-Rule sollte aktiv sein mit den detected Checks"
    log_manual "Operator: Test-PR oeffnen ohne gruene Checks — Merge muss blockiert sein"
    return 0
}

migrate_boo_30() {
    # BOO-30 — Linear-Workflow-States + Definition-of-Done — v3.19.0 seit 2026-05-12
    # https://linear.app/owlist/issue/BOO-30
    #
    # Bestands-Projekte ziehen das Issue-Template-Update nach (DoD-Pflichtsektion).
    # Linear-Setup (6 Workflow-States + GitHub-Integration) bleibt bewusst manuell
    # — Operator-Hinweise via [MANUAL]-Logs.
    #
    # Idempotenz: prueft Marker-Zeile "Story darf erst auf Linear-Status \"Done\""
    # in jedem Ziel-File. Vorhandener Marker -> [SKIP]. Fehlender Marker:
    #   1) .github/ISSUE_TEMPLATE/story.yml: dod-Block patchen (value-Feld)
    #   2) .claude/ISSUE_WRITING_GUIDELINES.md: DoD-Pflicht-Sektion anhaengen
    log_info "BOO-30: Linear-Workflow-States + Definition-of-Done — Issue-Template-Erweiterung"

    # --- DoD-Marker (1:1 aus BOO-30) ---
    local dod_marker='Story darf erst auf Linear-Status "Done" wenn:'

    # ====== Teil 1: .github/ISSUE_TEMPLATE/story.yml DoD-Block patchen ======
    local story_yml=".github/ISSUE_TEMPLATE/story.yml"
    if [[ ! -f "$story_yml" ]]; then
        log_warn "$story_yml fehlt — BOO-27 zuerst laufen lassen (migrate-to-v2.sh --issue BOO-27)"
        log_manual "Operator: 'bash <pfad>/migrate-to-v2.sh --issue BOO-27' ausfuehren, dann BOO-30 wiederholen"
    else
        if grep -Fq "$dod_marker" "$story_yml" 2>/dev/null; then
            log_skip "$story_yml: DoD-Block schon auf BOO-30-Stand"
        elif [[ "$DRY_RUN" == "true" ]]; then
            log_dry "patch $story_yml: dod value-Feld auf BOO-30-Canonical (5er-Checkliste)"
        else
            # Idempotenter In-place-Patch via Python: liest YAML als Text, ersetzt den 'id: dod'-Block
            # bis zum naechsten Top-Level-Eintrag ('- type:' oder EOF). Python ist bei BOO-15/BOO-34
            # bereits Voraussetzung — keine neue Dependency.
            if ! command -v python3 >/dev/null 2>&1; then
                log_warn "python3 nicht gefunden — $story_yml unveraendert. Manuelles Update notwendig (Vorlage in HANDBUCH §8g)."
            else
                local tmp_yml
                tmp_yml="$(mktemp)"
                python3 - "$story_yml" "$tmp_yml" <<'PYEOF'
import sys
import re

src, dst = sys.argv[1], sys.argv[2]
with open(src, "r", encoding="utf-8") as fh:
    lines = fh.readlines()

# Canonical-Block (1:1 aus BOO-30). Indent matcht das Bestand-Schema von migrate_boo_27.
canonical = [
    "  - type: textarea\n",
    "    id: dod\n",
    "    attributes:\n",
    "      label: \"Definition of Done (Pflicht)\"\n",
    "      description: \"Story darf erst auf Linear-Status Done wenn alle Punkte abgehakt sind (1:1 aus BOO-30, nicht pro Story anpassen).\"\n",
    "      value: |\n",
    "        Story darf erst auf Linear-Status \"Done\" wenn:\n",
    "        - [ ] Alle lokalen Gates gruen (ESLint, Semgrep, Tests, Coverage)\n",
    "        - [ ] PR ist gemerged auf main\n",
    "        - [ ] Alle Required Status Checks gruen (siehe BOO-29)\n",
    "        - [ ] Kein offener \"QA Failed\"-Status\n",
    "        - [ ] Spec-File `specs/BOO-XX.md` aktualisiert mit Result-Summary (Implement-Skill Schritt 8)\n",
    "    validations:\n",
    "      required: true\n",
]

# Bestehenden dod-Block lokalisieren: 'id: dod' nach oben bis zum letzten '- type:' suchen.
out = []
i = 0
patched = False
n = len(lines)
while i < n:
    # dod-Textarea-Block beginnt typischerweise mit "  - type: textarea" + "    id: dod"
    if (re.match(r"^[ \t]*-[ \t]+type:[ \t]+textarea[ \t]*$", lines[i])
            and i + 1 < n
            and re.match(r"^[ \t]*id:[ \t]+dod[ \t]*$", lines[i + 1])):
        # Block-Ende suchen: naechstes Top-Level "- type:" oder Datei-Ende.
        j = i + 2
        while j < n and not re.match(r"^[ \t]*-[ \t]+type:", lines[j]):
            j += 1
        # Block i..j-1 ersetzen
        out.extend(canonical)
        patched = True
        i = j
        continue
    out.append(lines[i])
    i += 1

if not patched:
    # Kein dod-Block vorhanden — am Ende anhaengen.
    if out and not out[-1].endswith("\n"):
        out.append("\n")
    out.extend(canonical)

with open(dst, "w", encoding="utf-8") as fh:
    fh.writelines(out)
PYEOF
                if [[ -s "$tmp_yml" ]]; then
                    mv "$tmp_yml" "$story_yml"
                    log_info "patched $story_yml: dod-Block auf BOO-30-Canonical (5er-Checkliste)"
                else
                    rm -f "$tmp_yml"
                    log_warn "Python-Patch lieferte leeren Output — $story_yml unveraendert. Manuelles Update notwendig."
                fi
            fi
        fi
    fi

    # ====== Teil 2: .claude/ISSUE_WRITING_GUIDELINES.md DoD-Sektion ergaenzen ======
    local guidelines=".claude/ISSUE_WRITING_GUIDELINES.md"
    if [[ ! -f "$guidelines" ]]; then
        log_skip "$guidelines fehlt — kein gerendetes Bootstrap-Artefakt, BOO-30-Erweiterung nicht anwendbar"
    elif grep -Fq "$dod_marker" "$guidelines" 2>/dev/null; then
        log_skip "$guidelines: DoD-Sektion schon auf BOO-30-Stand"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_dry "append DoD-Pflicht-Sektion an $guidelines (5er-Checkliste 1:1 aus BOO-30)"
    else
        cat >> "$guidelines" <<'DOD_GUIDELINES_EOF'

---

## Definition of Done (Pflicht) — BOO-30

Story darf erst auf Linear-Status "Done" wenn:
* [ ] Alle lokalen Gates gruen (ESLint, Semgrep, Tests, Coverage)
* [ ] PR ist gemerged auf main
* [ ] Alle Required Status Checks gruen (siehe BOO-29)
* [ ] Kein offener "QA Failed"-Status
* [ ] Spec-File `specs/BOO-XX.md` aktualisiert mit Result-Summary (Implement-Skill Schritt 8)

**Regeln:**
- Checklisten-Punkte nicht pro Story anpassen oder weglassen.
- Wenn ein Gate nicht zutrifft (z.B. keine Tests bei einer reinen Doku-Story), explizit kennzeichnen: `* [N/A] Tests — reine Doku-Story`.
- Spec-File-Update ist unabhaengig von der Story-Groesse Pflicht.

Quelle: BOO-30 + HANDBUCH §8g Linear-Setup pro Projekt.
DOD_GUIDELINES_EOF
        log_info "appended DoD-Pflicht-Sektion an $guidelines"
    fi

    # ====== Teil 3: Manuelle Operator-Schritte fuer Linear-Setup ======
    log_manual "Operator: Linear-Workflow-States manuell anlegen — Linear -> Settings -> <Team> -> Workflow"
    log_manual "Operator: 6 States in dieser Reihenfolge anlegen — Backlog, In Progress, In Review, QA Failed, Done, Cancelled (Namen exakt, sie steuern Auto-Transitions)"
    log_manual "Operator: GitHub-Integration aktivieren — Linear -> Settings -> Integrations -> GitHub -> Connect Repository -> Projekt-Repo auswaehlen"
    log_manual "Operator: Auto-Recognition wirkt sofort fuer Branch-Names / PR-Titles / Commit-Messages / PR-Body mit '{ISSUE_PREFIX}-XX'-Prefix bzw. 'Closes {ISSUE_PREFIX}-XX'"
    log_manual "Operator: Test-Story mit Branch '{ISSUE_PREFIX}-XX-test' anlegen — PR-Open transitioniert Issue auf 'In Review'"
    log_manual "Operator: vollstaendige Anleitung in HANDBUCH §8g 'Linear-Setup pro Projekt' (DE) / §8g 'Linear setup per project' (EN)"
    return 0
}

migrate_boo_34() {
    # BOO-34 — /bootstrap: .claude/environment.json — Skill-Umgebungs-Awareness — v3.3.0 seit 2026-05-06
    # https://linear.app/owlist/issue/BOO-34
    log_info "BOO-34: .claude/generate-environment-json.sh + .claude/environment.json anlegen"

    ensure_dir ".claude"

    # --- Schritt 1: Generator-Skript anlegen ---
    local gen_script=".claude/generate-environment-json.sh"
    local write_gen=false
    if [[ -f "$gen_script" && "$FORCE" != "true" ]]; then
        log_skip "$gen_script existiert (use --force to overwrite)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        if [[ -f "$gen_script" ]]; then
            log_dry "overwrite $gen_script (--force) — Inhalt aus file-templates.md §.claude/generate-environment-json.sh"
        else
            log_dry "write $gen_script (Inhalt aus file-templates.md §.claude/generate-environment-json.sh)"
        fi
    else
        write_gen=true
    fi

    if [[ "$write_gen" == "true" ]]; then
        # Heredoc 1:1 aus bootstrap/references/file-templates.md §.claude/generate-environment-json.sh
        cat > "$gen_script" <<'GENENV_EOF'
#!/usr/bin/env bash
# .claude/generate-environment-json.sh — Environment-Awareness-Generator (BOO-34)
# DE: Erzeugt .claude/environment.json mit Detection von Mac/VPS/CI, verfuegbaren
#     Tools (eslint, semgrep, Test-Framework) und Standard-Pfaden. BSD- und
#     Linux-kompatibel, ohne Abhaengigkeiten ausser bash, uname, command, cat,
#     grep, sed, date.
# EN: Generates .claude/environment.json with Mac/VPS/CI detection, available
#     tools (eslint, semgrep, test framework) and default paths. BSD- and
#     Linux-compatible, no deps beyond bash, uname, command, cat, grep, sed, date.
set -euo pipefail

# --- CLI-Flags ---
FORCE=0
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=1 ;;
        --help|-h)
            cat <<'HLP'
Usage: bash .claude/generate-environment-json.sh [--force]
  --force   Overwrite existing .claude/environment.json
HLP
            exit 0 ;;
    esac
done

OUT=".claude/environment.json"
mkdir -p .claude

if [[ -f "$OUT" && $FORCE -eq 0 ]]; then
    echo "[ENV] $OUT existiert bereits — Skip (use --force to overwrite)."
    exit 0
fi

# --- environment: ci > mac > vps ---
# CI-Check ZUERST: ein CI-Runner kann Linux ODER Mac sein.
if [[ -n "${CI:-}" ]]; then
    ENVIRONMENT="ci"
elif [[ "$(uname -s)" = "Darwin" ]]; then
    ENVIRONMENT="mac"
else
    ENVIRONMENT="vps"
fi

# --- tools_available ---
# eslint: command -v ODER lokal in node_modules
HAS_ESLINT="false"
if command -v eslint >/dev/null 2>&1; then
    HAS_ESLINT="true"
elif [[ -f "package.json" ]] && command -v npm >/dev/null 2>&1; then
    if npm ls eslint --silent >/dev/null 2>&1; then
        HAS_ESLINT="true"
    fi
fi

# semgrep: nur via command -v (PATH)
HAS_SEMGREP="false"
if command -v semgrep >/dev/null 2>&1; then
    HAS_SEMGREP="true"
fi

# tests: erkennen aus package.json (vitest/jest/mocha) oder pyproject.toml (pytest)
TESTS="null"
if [[ -f "package.json" ]]; then
    if grep -q '"vitest"' package.json 2>/dev/null; then
        TESTS='"vitest"'
    elif grep -q '"jest"' package.json 2>/dev/null; then
        TESTS='"jest"'
    elif grep -q '"mocha"' package.json 2>/dev/null; then
        TESTS='"mocha"'
    fi
fi
if [[ "$TESTS" = "null" && -f "pyproject.toml" ]]; then
    if grep -qE '(pytest|^\[tool\.pytest)' pyproject.toml 2>/dev/null; then
        TESTS='"pytest"'
    fi
fi

# sonarqube_ide_plugin: nicht erkennbar via CLI — Default false, Operator ergaenzt manuell auf Mac.
SONAR_IDE="false"

# sonarqube_cloud: Cloud-API ist von ueberall erreichbar — hardcoded true.
SONAR_CLOUD="true"

# --- metadata.stack: analog BOO-3 Semgrep-Stack-Erkennung ---
HAS_PKG=0
HAS_PY=0
[[ -f "package.json" ]] && HAS_PKG=1
[[ -f "pyproject.toml" ]] && HAS_PY=1

if [[ $HAS_PKG -eq 1 && $HAS_PY -eq 1 ]]; then
    STACK="mixed"
elif [[ $HAS_PKG -eq 1 ]]; then
    # TS vs JS: tsconfig.json oder "typescript" als devDep
    if [[ -f "tsconfig.json" ]] || grep -q '"typescript"' package.json 2>/dev/null; then
        STACK="node-typescript"
    else
        STACK="node-javascript"
    fi
elif [[ $HAS_PY -eq 1 ]]; then
    STACK="python"
else
    STACK="unknown"
fi

# --- metadata.created_at: ISO-8601 UTC ---
CREATED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# --- metadata.bootstrap_version: aktuelle Bootstrap-Version ---
BOOTSTRAP_VERSION="3.3.0"

# --- JSON via Heredoc (kein jq noetig) ---
cat > "$OUT" <<EOF
{
  "environment": "${ENVIRONMENT}",
  "tools_available": {
    "eslint": ${HAS_ESLINT},
    "semgrep": ${HAS_SEMGREP},
    "tests": ${TESTS},
    "sonarqube_ide_plugin": ${SONAR_IDE},
    "sonarqube_cloud": ${SONAR_CLOUD}
  },
  "paths": {
    "journal": "journal/",
    "reports_local": "journal/reports/local/",
    "reports_ci": "journal/reports/ci/",
    "lessons_l1": "journal/learnings.md",
    "lessons_l2_dir": "journal/",
    "lessons_l3": "journal/learnings.db",
    "specs": "specs/",
    "architecture_design": "ARCHITECTURE_DESIGN.md",
    "intents": "intents/",
    "pitches": "pitch/"
  },
  "metadata": {
    "created_at": "${CREATED_AT}",
    "bootstrap_version": "${BOOTSTRAP_VERSION}",
    "stack": "${STACK}"
  }
}
EOF

echo "[ENV] $OUT geschrieben (environment=${ENVIRONMENT}, stack=${STACK})."
GENENV_EOF
        chmod +x "$gen_script"
        log_info "created $gen_script (executable)"
    fi

    # --- Schritt 2: Generator ausfuehren — schreibt .claude/environment.json ---
    local env_file=".claude/environment.json"
    if [[ -f "$env_file" && "$FORCE" != "true" ]]; then
        log_skip "$env_file existiert (use --force to overwrite)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        if [[ -f "$env_file" ]]; then
            log_dry "run bash $gen_script --force (overwrite $env_file)"
        else
            log_dry "run bash $gen_script (write $env_file)"
        fi
    elif [[ ! -x "$gen_script" ]]; then
        log_warn "$gen_script fehlt oder nicht ausfuehrbar — Schritt 1 zuerst laufen lassen"
        return 1
    else
        local gen_rc=0
        if [[ "$FORCE" == "true" ]]; then
            bash "$gen_script" --force || gen_rc=$?
        else
            bash "$gen_script" || gen_rc=$?
        fi
        if [[ "$gen_rc" -eq 0 ]]; then
            log_info "$env_file via Generator erzeugt"
        else
            log_warn "$gen_script schlug fehl (rc=$gen_rc) — manuell pruefen"
            return 1
        fi
    fi

    log_manual "Operator: nach Tool-Aenderung (z.B. 'brew install semgrep') 'bash .claude/generate-environment-json.sh --force' laufen lassen"
    log_manual "Operator (Mac): falls SonarLint VS-Code-Plugin aktiv, 'sonarqube_ide_plugin' in $env_file manuell auf true setzen"
    return 0
}

migrate_boo_36() {
    # BOO-36 — /implement: journal/reports/local/ Persistenz
    # https://linear.app/owlist/issue/BOO-36
    log_info "BOO-36: journal/reports/local/ + .gitignore-Eintrag"
    ensure_dir "journal/reports/local"
    ensure_file "journal/reports/local/.gitkeep"
    append_if_missing ".gitignore" "journal/reports/local/*"
    append_if_missing ".gitignore" "!journal/reports/local/.gitkeep"
    return 0
}

migrate_boo_38() {
    # BOO-38 — Sprint-Sizing-Konvention dokumentieren
    # https://linear.app/owlist/issue/BOO-38
    log_info "BOO-38: Sprint-Sizing-Konvention (Doku-only, kein Projekt-Schritt)"
    log_manual "Operator: Doku im Skill — keine Migration im Bestands-Projekt"
    return 0
}

migrate_boo_39() {
    # BOO-39 — /ideation: Token-Heuristik
    # https://linear.app/owlist/issue/BOO-39
    log_info "BOO-39: Token-Heuristik in /ideation"
    # TODO: implementiert beim Done von BOO-39
    log_manual "Operator: implementiert beim Done von BOO-39 — Skill-Update, ggf. README-Hinweis im Bestands-Projekt"
    return 0
}

migrate_boo_40() {
    # BOO-40 — /implement: Token-Window-Pre-Flight (Schritt 0b)
    # https://linear.app/owlist/issue/BOO-40
    log_info "BOO-40: Token-Window-Pre-Flight"
    # TODO: implementiert beim Done von BOO-40
    log_manual "Operator: implementiert beim Done von BOO-40 — Skill-Update"
    return 0
}

# ---------------- Phase 3 — Observability + Performance ----------------

migrate_boo_8() {
    # BOO-8 — Testability als 7. Standard-Dimension einfuehren (Re-Scope 2026-05-06)
    # https://linear.app/owlist/issue/BOO-8
    #
    # Re-Scope-Hinweis: Issue war 2026-04-23 als "Operations -> Testability + Observability"
    # formuliert. Status-Quo-Check ergab: keine "Operations"-Sammel-Dimension, Observability
    # bereits Standard #5. BOO-8 ist additiv — nur Testability dazu.
    #
    # Auto-Edit der ARCHITECTURE_DESIGN.md ist bewusst nicht implementiert: das File ist
    # projekt-spezifisch (eigene §-Nummerierung, eigene Add-ons, eigene Pruef-Fragen) und
    # ein automatisches Insert wuerde die Struktur brechen. Operator-getrieben, idempotent
    # ohne File-Operationen.
    log_info "BOO-8: Testability als 7. Standard-Dimension einfuehren"
    log_manual "Operator: ARCHITECTURE_DESIGN.md oeffnen, §3 Quality Attributes / Qualitaets-Dimensionen suchen"
    log_manual "Operator: Testability-Zeile zwischen Maintainability (#6) und Cost Efficiency / Domain Quality einfuegen"
    log_manual "Operator: Pruef-Frage uebernehmen: 'Coverage auf neuem Code? Test-Pyramide (Unit/Contract/Integration)? Pass-Rate stabil?'"
    log_manual "Operator: Detail-Inhalt aus bootstrapping/architecture-review/references/dimensions-detail.md §7 Testability ins Projekt-spezifische Dokument uebertragen"
    log_manual "Operator: pruefen ob Test-Aspekte heute unter Maintainability/Reliability vermischt sind — ggf. nach Testability migrieren (Operator-Entscheidung pro Projekt)"
    log_manual "Operator: Sanity-Test 'grep -E Testability ARCHITECTURE_DESIGN.md' → mindestens ein Treffer"
    log_manual "Operator (DoD, optional): /architecture-review auf Bestands-Projekt durchlaufen lassen — neue Dimension end-to-end validieren"
    log_manual "Operator: Details in bootstrapping/bootstrap/references/migration-checklist-v1-to-v2.md §BOO-8"
    return 0
}

migrate_boo_13() {
    # BOO-13 — Scalability als 8. Standard-Architektur-Dimension einfuehren (Re-Scope 2026-05-08)
    # https://linear.app/owlist/issue/BOO-13
    #
    # Re-Scope-Hinweis: Issue war urspruenglich als reine Sektions-Erweiterung in
    # ARCHITECTURE_DESIGN.md mit 4 Invarianten formuliert. Beim Re-Scope wurde der Zuschnitt
    # mit BOO-8 (Testability als 7. Standard-Dimension) harmonisiert: Scalability wird als
    # 8. Standard-Architektur-Dimension verankert, inklusive 4 Pro-Invarianten und 4
    # Anti-Patterns. Quelle: architecture-review/references/dimensions-detail.md §8.
    #
    # Auto-Edit der ARCHITECTURE_DESIGN.md ist bewusst nicht implementiert: das File ist
    # projekt-spezifisch (eigene §-Nummerierung, eigene Add-ons, eigene Pruef-Fragen) und
    # ein automatisches Insert wuerde die Struktur brechen. Operator-getrieben, idempotent
    # ohne File-Operationen — analog zu migrate_boo_8.
    #
    # Stack-unabhaengig: Scalability gilt fuer alle Stacks gleichermassen — keine
    # Stack-Detection (kein package.json/pyproject.toml-Check) noetig.
    log_info "BOO-13: Scalability als 8. Standard-Architektur-Dimension einfuehren"
    log_manual "Operator: docs/ARCHITECTURE_DESIGN.md oeffnen, §3 Quality Attributes / Qualitaets-Dimensionen suchen"
    log_manual "Operator: Scalability-Zeile zwischen Testability (#7) und Cost Efficiency / Domain Quality einfuegen"
    log_manual "Operator: 4 Pro-Invarianten dokumentieren — Stateless, Horizontal-Scaling-Faehigkeit, 12-Factor, Async-Entkopplung"
    log_manual "Operator: 4 Anti-Patterns als Anti-Bullets ergaenzen (siehe architecture-review/references/dimensions-detail.md §8)"
    log_manual "Operator: pro Pro-Invariante Status (erfuellt/nicht erfuellt/n/a) + Begruendung im Bestands-Projekt eintragen"
    log_manual "Operator: Anti-Pattern-Sweep — grep -RIn 'globalThis\\.sessions|\\.lock|setInterval|node-cron|node-schedule' src/ lib/ services/ — Funde als ADR oder Backlog-Issue dokumentieren"
    log_manual "Operator: ADR docs/domain/adrs/NNN-scalability-disabled.md anlegen, falls Scalability fuer dieses Projekt bewusst deaktiviert wird (z.B. Single-User-CLI, Local-Tool ohne Skalierungs-Pfad)"
    log_manual "Operator (DoD, optional): /architecture-review --system durchlaufen lassen — der Skill prueft jetzt 8 Standard-Dimensionen, Report archivieren in journal/reports/"
    log_manual "Operator: Skill-Check — grep -E '^## §?8\\.? Scalability' .claude/skills/architecture-review/references/dimensions-detail.md → falls leer: 'git pull' im Skill-Klon oder Phase 5 von /bootstrap erneut laufen lassen (Skill v1.6.0+)"
    log_manual "Operator: Details in bootstrapping/bootstrap/references/migration-checklist-v1-to-v2.md §BOO-13"
    return 0
}

migrate_boo_14() {
    # BOO-14 — Observability-Skelett (Logging + Metrics + Alerts) — v3.5.0 seit 2026-05-07
    # https://linear.app/owlist/issue/BOO-14
    #
    # Legt drei Files an:
    #   1. observability.md          — zentrales Skelett (Root)
    #   2. observability/alerts/.gitkeep — Verzeichnis-Marker fuer Pro-Service-Alert-Rules
    #   3. observability/.env.observability — Routing-Stub (gitignored)
    # Plus .gitignore-Eintrag fuer .env.observability (idempotent).
    #
    # Idempotenz: bestehende Files werden ge[SKIP]ped; --force ueberschreibt
    # observability.md und observability/.env.observability (NICHT die alerts/-Files
    # — die sind operator-spezifisch und stehen unter Schritt 5 der Migration-Checklist).
    log_info "BOO-14: Observability-Skelett (observability.md + alerts/ + .env.observability)"

    # Idempotenz-Quick-Check: alle drei Pfade vorhanden?
    if [[ -f "observability.md" && -d "observability/alerts" && -f "observability/.env.observability" ]]; then
        if [[ "$FORCE" != "true" ]]; then
            log_skip "BOO-14 already applied (observability.md + observability/alerts/ + .env.observability vorhanden) — use --force to overwrite"
            log_manual "Operator-Schritte: siehe migration-checklist-v1-to-v2.md §BOO-14"
            return 0
        fi
    fi

    # --- Schritt 1: observability.md (Root-Skelett) ---
    if [[ -f "observability.md" && "$FORCE" != "true" ]]; then
        log_skip "observability.md existiert (use --force to overwrite)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        if [[ -f "observability.md" ]]; then
            log_dry "overwrite observability.md (--force) — Inhalt aus file-templates.md §observability.md"
        else
            log_dry "write observability.md (Inhalt aus file-templates.md §observability.md)"
        fi
    else
        cat > "observability.md" <<'OBS_EOF'
# Observability

DE: Zentrales Observability-Skelett (BOO-14). Drei Pflicht-Sektionen — Operator
fuellt Service-spezifische Inhalte (Komponenten aus ARCHITECTURE_DESIGN.md §4)
manuell ein.

EN: Central observability skeleton (BOO-14). Three mandatory sections — operator
fills in service-specific content (components from ARCHITECTURE_DESIGN.md §4)
manually.

## 1. Logging-Schema / Logging schema

Strukturierte JSON-Logs mit folgenden Pflicht-Feldern pro Log-Eintrag:

| Feld         | Typ      | Pflicht | Beispiel                                  |
| ------------ | -------- | ------- | ----------------------------------------- |
| `timestamp`  | ISO-8601 | ja      | `2026-05-07T08:31:14.123Z`                |
| `level`      | string   | ja      | `info` \| `warn` \| `error` \| `debug`    |
| `service`    | string   | ja      | `auth-service`                            |
| `trace_id`   | string   | ja      | `7f9b2a1c-...` (UUID v4)                  |
| `event`      | string   | ja      | `user.login.success`                      |
| `message`    | string   | ja      | menschenlesbarer Kontext                  |

Stack-Defaults:
- Node.js → `pino` (https://github.com/pinojs/pino)
- Python → `structlog` (https://www.structlog.org)

## 2. Metrics-Endpoint / Metrics endpoint

Pro Service ein `/metrics`-Endpoint im Prometheus-Format.

**Port-Konvention:** `9090 + N` — Service-Index aus der Komponenten-Reihenfolge in
ARCHITECTURE_DESIGN.md §4. Beispiel:

| Service        | Port  |
| -------------- | ----- |
| (auth-service) | 9091  |
| (api-service)  | 9092  |
| (db-service)   | 9093  |
| ...            | 9090+N|

Stack-Defaults:
- Node.js → `prom-client`
- Python → `prometheus_client`

## 3. Alert-Rules / Alert rules

Pro Service ein File `observability/alerts/<service>.yml` mit den drei
**Pflicht-Alerts**:

| Alert         | Schwellwert                  | Auswertung |
| ------------- | ---------------------------- | ---------- |
| ErrorRate     | `>5%` HTTP-5xx               | 5 min      |
| LatencyP99    | `>1s` p99 Request-Latency    | 10 min     |
| ServiceDown   | `up == 0`                    | 1 min      |

Routing der Alerts ueber `observability/.env.observability` (Telegram / Slack /
Email — nicht im Repo committed, gitignored).

Validierung lokal:
```bash
promtool check rules observability/alerts/*.yml
```

---

## Service-Sektionen (Operator fuellt)

Pro Service aus ARCHITECTURE_DESIGN.md §4 Komponenten-Uebersicht eine eigene
Sektion. Vorlage:

### Service: <name>

- **Port (`9090+N`):** _z.B. 9091_
- **Logger:** _z.B. pino (Node) / structlog (Python)_
- **Metrics-Endpoint:** _http://localhost:9091/metrics_
- **Alert-File:** `observability/alerts/<name>.yml`
- **Runbook:** _Pfad zum Runbook fuer Pager-Alerts_

> Schrader Code Crash Kap. 3 §Production Readiness §Observability + Kap. 4
> §Run the System (Saeule 3 Observability): "Wer ohne Observability deployed,
> fliegt blind."
OBS_EOF
        log_info "created observability.md"
    fi

    # --- Schritt 2: observability/alerts/-Verzeichnis (mit .gitkeep) ---
    ensure_dir "observability/alerts"
    ensure_file "observability/alerts/.gitkeep"

    # --- Schritt 3: observability/.env.observability (Routing-Stub) ---
    if [[ -f "observability/.env.observability" && "$FORCE" != "true" ]]; then
        log_skip "observability/.env.observability existiert (use --force to overwrite)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        if [[ -f "observability/.env.observability" ]]; then
            log_dry "overwrite observability/.env.observability (--force)"
        else
            log_dry "write observability/.env.observability (Routing-Stub)"
        fi
    else
        cat > "observability/.env.observability" <<'ENV_EOF'
# observability/.env.observability — Routing-Konfiguration (BOO-14)
# DE: NICHT committen — diese Datei ist via .gitignore ausgeschlossen.
#     Echte Bot-Tokens / Webhook-URLs / SMTP-Credentials nur lokal.
#     Eine .env.observability.example (ohne Secrets) darf committed werden.
# EN: DO NOT commit — this file is excluded via .gitignore.
#     Real bot tokens / webhook URLs / SMTP credentials only locally.
#     A .env.observability.example (no secrets) may be committed.

# --- Telegram (Default-Channel laut OWLIST-Setup) ---
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=

# --- Slack ---
SLACK_WEBHOOK_URL=

# --- Email (SMTP fuer kritische Alerts) ---
SMTP_HOST=
SMTP_PORT=587
SMTP_USER=
SMTP_PASS=
SMTP_FROM=
SMTP_TO=
ENV_EOF
        log_info "created observability/.env.observability"
    fi

    # --- Schritt 4: .gitignore-Eintrag (idempotent) ---
    append_if_missing ".gitignore" "observability/.env.observability"

    # --- Operator-Schritte (Pflicht-Lese-Hinweis) ---
    log_manual "Operator-Schritte: siehe migration-checklist-v1-to-v2.md §BOO-14 (Schritte 2-6 + 8)"
    log_manual "Operator: Services aus ARCHITECTURE_DESIGN.md §4 in observability.md als '### Service: <name>' Sektionen anlegen"
    log_manual "Operator: Port-Konvention 9090+N pro Service vergeben (auth=9091, api=9092, ...)"
    log_manual "Operator: pro Service observability/alerts/<service>.yml mit ErrorRate/LatencyP99/ServiceDown anlegen (Vorlage in file-templates.md)"
    log_manual "Operator: Routing-Werte in observability/.env.observability eintragen (Telegram/Slack/Email)"
    log_manual "Operator (DoD): 'promtool check rules observability/alerts/*.yml' lokal validieren — falls promtool fehlt: 'brew install prometheus' (Mac) bzw. 'apt install prometheus' (VPS)"
    return 0
}

migrate_boo_16() {
    # BOO-16 — Performance-Baseline-Gate (Pre-Production-Gate) — v3.8.0 seit 2026-05-11
    # https://linear.app/owlist/issue/BOO-16
    #
    # Legt vier Artefakte an (Stack-abhaengig):
    #   1. journal/perf-baseline.json                — lebende Baseline (committed, services: [])
    #   2. bench/<service>.bench.js (Node) ODER
    #      bench/<service>_bench.py (Python)        — Pro Service Benchmark-Stub
    #   3. .github/workflows/perf.yml                — CI-Performance-Gate (Matrix aus Service-Liste)
    #   4. journal/reports/perf/.gitkeep + overrides.log (leer)
    # Plus stack-spezifische devDeps-Hinweise (autocannon / pytest-benchmark+httpx)
    # und .gitignore-Eintraege idempotent.
    #
    # Stack-Detection:
    #   - package.json vorhanden                      → Node
    #   - pyproject.toml ODER requirements.txt        → Python
    #   - beide                                       → Mixed (beide Varianten)
    #   - keines                                      → Unknown (log_warn, kein Bench-Stub)
    #
    # Service-Liste:
    #   - ENV BOO16_SERVICES="auth-service api-gateway" hat Vorrang
    #   - sonst: aus observability.md (Heading "### Service: <name>") parsen
    #   - falls beide nicht vorhanden: Default-Liste ["service"] + log_manual-Hinweis
    #
    # Idempotenz: bestehende Files werden ge[SKIP]ped; --force ueberschreibt
    # perf-baseline.json (NICHT die bench/-Files — operator-spezifisch).
    log_info "BOO-16: Performance-Baseline-Gate (perf-baseline.json + bench/ + perf.yml + overrides.log)"

    # Idempotenz-Quick-Check: Kernpfade vorhanden?
    if [[ -f "journal/perf-baseline.json" && -d "bench" && -f ".github/workflows/perf.yml" && -d "journal/reports/perf" ]]; then
        if [[ "$FORCE" != "true" ]]; then
            log_skip "BOO-16 already applied (perf-baseline.json + bench/ + perf.yml + reports/perf/ vorhanden) — use --force to overwrite"
            log_manual "Operator-Schritte: siehe migration-checklist-v1-to-v2.md §BOO-16"
            return 0
        fi
    fi

    # --- Stack-Detection ---
    local has_node="false"
    local has_python="false"
    [[ -f "package.json" ]] && has_node="true"
    [[ -f "pyproject.toml" || -f "requirements.txt" ]] && has_python="true"

    if [[ "$has_node" != "true" && "$has_python" != "true" ]]; then
        log_warn "BOO-16: weder package.json noch pyproject.toml/requirements.txt gefunden — Stack unbekannt"
        log_manual "Operator: Stack manuell festlegen oder Manifest-File ergaenzen, dann erneut '--issue BOO-16' laufen lassen"
    fi

    # --- Service-Liste ermitteln ---
    local services=()
    if [[ -n "${BOO16_SERVICES:-}" ]]; then
        # ENV-Variable schlaegt observability.md
        # shellcheck disable=SC2206
        services=( ${BOO16_SERVICES} )
        log_info "Service-Liste aus ENV BOO16_SERVICES uebernommen: ${services[*]}"
    elif [[ -f "observability.md" ]]; then
        # Parse "### Service: <name>" Headings aus observability.md (analog BOO-14)
        while IFS= read -r svc; do
            [[ -n "$svc" ]] && services+=( "$svc" )
        done < <(grep -E '^### Service:' observability.md 2>/dev/null | sed -E 's/^### Service:[[:space:]]*//; s/[[:space:]]+$//' || true)
        if [[ "${#services[@]}" -eq 0 ]]; then
            log_warn "observability.md gefunden, aber keine '### Service: <name>'-Headings — Default-Service-Liste verwenden"
            services=( "service" )
        else
            log_info "Service-Liste aus observability.md geparst: ${services[*]}"
        fi
    else
        log_warn "weder ENV BOO16_SERVICES noch observability.md gefunden — Default-Service-Liste ['service'] verwenden"
        services=( "service" )
    fi

    # --- Schritt 1: journal/perf-baseline.json (Initial leer mit services: []) ---
    if [[ -f "journal/perf-baseline.json" && "$FORCE" != "true" ]]; then
        log_skip "journal/perf-baseline.json existiert (use --force to overwrite)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        if [[ -f "journal/perf-baseline.json" ]]; then
            log_dry "overwrite journal/perf-baseline.json (--force) — Inhalt aus file-templates.md §journal/perf-baseline.json"
        else
            log_dry "write journal/perf-baseline.json (services: [])"
        fi
    else
        ensure_dir "journal"
        cat > "journal/perf-baseline.json" <<'PERF_BASELINE_EOF'
{
  "$schema_version": 1,
  "services": []
}
PERF_BASELINE_EOF
        log_info "created journal/perf-baseline.json (services: [])"
    fi

    # --- Schritt 2: bench/<service>.bench.js (Node) bzw. <service>_bench.py (Python) ---
    ensure_dir "bench"

    # Helper: schreibt einen Bench-Stub aus Template-Heredoc mit Service-Name-Substitution
    _boo16_write_node_bench() {
        local svc_kebab="$1"
        local target="bench/${svc_kebab}.bench.js"
        if [[ -f "$target" ]]; then
            log_skip "$target existiert (operator-spezifisch — manuell loeschen wenn neu rendern)"
            return 0
        fi
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write $target (Node-Bench-Stub aus file-templates.md §bench/<service>.bench.js)"
            return 0
        fi
        cat > "$target" <<'NODE_BENCH_EOF'
// bench/{{SERVICE_NAME_KEBAB}}.bench.js
// BOO-16 Service-Benchmark — laeuft in CI ueber .github/workflows/perf.yml.
// Voraussetzung: Service laeuft auf {{PORT}} unter {{PATH}} (siehe README).

const autocannon = require('autocannon');
const fs = require('node:fs');
const path = require('node:path');
const { execSync } = require('node:child_process');

const SERVICE_NAME = '{{SERVICE_NAME_KEBAB}}';
const TARGET_URL = process.env.BENCH_URL || 'http://localhost:{{PORT}}{{PATH}}';
const CONNECTIONS = Number(process.env.BENCH_CONNECTIONS || 10);
const DURATION = Number(process.env.BENCH_DURATION || 30); // Sekunden

async function main() {
  // Warmup: 5 Sekunden, Resultat verworfen — schuetzt vor JIT-/Cache-Effekten in der Messung.
  await autocannon({ url: TARGET_URL, connections: CONNECTIONS, duration: 5 });

  const result = await autocannon({
    url: TARGET_URL,
    connections: CONNECTIONS,
    duration: DURATION,
  });

  // autocannon hat kein natives p95 — p97_5 ist die naechste verfuegbare Percentile (>=95).
  // Konservative Approximation, dokumentiert in journal/perf-baseline.json -> bench_tool: "autocannon".
  const sha = execSync('git rev-parse HEAD').toString().trim();
  const shortSha = sha.slice(0, 7);

  const report = {
    service: SERVICE_NAME,
    p50_ms: result.latency.p50,
    p95_ms: result.latency.p97_5, // Approximation, siehe Kommentar oben
    p99_ms: result.latency.p99,
    req_per_sec: result.requests.average,
    recorded_at: new Date().toISOString(),
    commit_sha: sha,
    bench_tool: 'autocannon',
  };

  const outDir = path.join('journal', 'reports', 'perf');
  fs.mkdirSync(outDir, { recursive: true });
  const outPath = path.join(outDir, `${SERVICE_NAME}-bench-${shortSha}.json`);
  fs.writeFileSync(outPath, JSON.stringify(report, null, 2));

  console.log(`[BOO-16] Bench-Report: ${outPath}`);
  console.log(JSON.stringify(report, null, 2));
}

main().catch((err) => {
  console.error('[BOO-16] Bench failed:', err);
  process.exit(1);
});
NODE_BENCH_EOF
        # Service-Name-Substitution (Platzhalter -> echter Kebab-Case-Service-Name)
        # Plattform-unabhaengig (BSD/GNU sed) via Tempfile.
        sed -e "s/{{SERVICE_NAME_KEBAB}}/${svc_kebab}/g" "$target" > "${target}.tmp" && mv "${target}.tmp" "$target"
        log_info "created $target"
    }

    _boo16_write_python_bench() {
        local svc_kebab="$1"
        # snake-case = kebab-case mit _ statt -
        local svc_snake="${svc_kebab//-/_}"
        local target="bench/${svc_snake}_bench.py"
        if [[ -f "$target" ]]; then
            log_skip "$target existiert (operator-spezifisch — manuell loeschen wenn neu rendern)"
            return 0
        fi
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write $target (Python-Bench-Stub aus file-templates.md §bench/<service>_bench.py)"
            return 0
        fi
        cat > "$target" <<'PY_BENCH_EOF'
# bench/{{SERVICE_NAME_SNAKE}}_bench.py
# BOO-16 Service-Benchmark — laeuft in CI ueber .github/workflows/perf.yml.
# Aufruf: pytest bench/ --benchmark-json=journal/reports/perf/{{SERVICE_NAME_KEBAB}}-bench.json

import json
import os
import subprocess
from datetime import datetime, timezone
from pathlib import Path

import httpx
import pytest

SERVICE_NAME = "{{SERVICE_NAME_KEBAB}}"
TARGET_URL = os.environ.get("BENCH_URL", "http://localhost:{{PORT}}{{PATH}}")


@pytest.fixture(scope="module")
def client():
    with httpx.Client(timeout=10.0) as c:
        # Warmup: 50 Requests, Resultat verworfen.
        for _ in range(50):
            c.get(TARGET_URL).raise_for_status()
        yield c


def test_request_latency(benchmark, client):
    """Misst Latenz pro HTTP-Call. p50 = median, p95 ueber Approximation (siehe Header)."""
    result = benchmark(lambda: client.get(TARGET_URL).raise_for_status())
    # pytest-benchmark schreibt stats automatisch via --benchmark-json.
    # Der Comparator-Step in perf.yml konvertiert stats -> p50/p95/p99 (siehe perf.yml).
    return result


# Optional: Operator-Choice B — eigene Histogram-Aufzeichnung fuer echte Quantile.
# Aktivieren durch Auskommentieren und in perf.yml den Konvertierungs-Pfad anpassen.
#
# def test_request_latency_with_histogram(client):
#     import time
#     samples_ms: list[float] = []
#     for _ in range(1000):
#         t0 = time.perf_counter()
#         client.get(TARGET_URL).raise_for_status()
#         samples_ms.append((time.perf_counter() - t0) * 1000)
#     samples_ms.sort()
#     report = _build_report(
#         p50=samples_ms[len(samples_ms) // 2],
#         p95=samples_ms[int(len(samples_ms) * 0.95)],
#         p99=samples_ms[int(len(samples_ms) * 0.99)],
#         req_per_sec=1000.0 / (sum(samples_ms) / len(samples_ms) / 1000),
#     )
#     _write_report(report, bench_tool="pytest-benchmark+histogram")


def _build_report(p50: float, p95: float, p99: float, req_per_sec: float) -> dict:
    sha = subprocess.check_output(["git", "rev-parse", "HEAD"]).decode().strip()
    return {
        "service": SERVICE_NAME,
        "p50_ms": p50,
        "p95_ms": p95,
        "p99_ms": p99,
        "req_per_sec": req_per_sec,
        "recorded_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "commit_sha": sha,
        "bench_tool": "pytest-benchmark",
    }


def _write_report(report: dict, bench_tool: str = "pytest-benchmark") -> None:
    report["bench_tool"] = bench_tool
    out_dir = Path("journal/reports/perf")
    out_dir.mkdir(parents=True, exist_ok=True)
    short_sha = report["commit_sha"][:7]
    out_path = out_dir / f"{SERVICE_NAME}-bench-{short_sha}.json"
    out_path.write_text(json.dumps(report, indent=2))
PY_BENCH_EOF
        # Service-Name-Substitution (Snake + Kebab)
        sed -e "s/{{SERVICE_NAME_SNAKE}}/${svc_snake}/g" \
            -e "s/{{SERVICE_NAME_KEBAB}}/${svc_kebab}/g" "$target" > "${target}.tmp" && mv "${target}.tmp" "$target"
        log_info "created $target"
    }

    # Pro Service Bench-Stub anlegen
    local svc
    for svc in "${services[@]}"; do
        if [[ "$has_node" == "true" ]]; then
            _boo16_write_node_bench "$svc"
        fi
        if [[ "$has_python" == "true" ]]; then
            _boo16_write_python_bench "$svc"
        fi
    done

    # --- Schritt 3: Stack-spezifische devDeps idempotent ---
    if [[ "$has_node" == "true" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "ergaenze package.json devDependencies um 'autocannon' (via jq oder Operator)"
        elif command -v jq >/dev/null 2>&1; then
            # Idempotenz: nur wenn autocannon noch nicht in devDependencies
            if jq -e '.devDependencies.autocannon // empty' package.json >/dev/null 2>&1; then
                log_skip "package.json devDependencies enthaelt bereits 'autocannon'"
            else
                jq '.devDependencies = (.devDependencies // {}) + {"autocannon": "^7.15.0"}' package.json > package.json.tmp \
                    && mv package.json.tmp package.json
                log_info "package.json devDependencies um 'autocannon' ergaenzt — 'npm install' im Anschluss noetig"
            fi
        else
            log_warn "jq nicht gefunden — Operator: 'npm install --save-dev autocannon' manuell ausfuehren"
        fi
    fi

    if [[ "$has_python" == "true" ]]; then
        if [[ -f "pyproject.toml" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                log_dry "ergaenze pyproject.toml [project.optional-dependencies].test um pytest-benchmark + httpx (Operator)"
            elif grep -q 'pytest-benchmark' pyproject.toml 2>/dev/null && grep -q 'httpx' pyproject.toml 2>/dev/null; then
                log_skip "pyproject.toml enthaelt bereits pytest-benchmark + httpx"
            else
                log_manual "Operator (Python): pyproject.toml [project.optional-dependencies] um Block 'test = [\"pytest>=8\", \"pytest-benchmark>=5\", \"httpx>=0.27\"]' ergaenzen (siehe file-templates.md §bench/<service>_bench.py)"
            fi
        elif [[ -f "requirements.txt" ]]; then
            log_manual "Operator (Python, requirements.txt): 'pytest-benchmark>=5' und 'httpx>=0.27' in requirements-dev.txt (oder Test-Section) ergaenzen"
        fi
    fi

    # --- Schritt 4: .github/workflows/perf.yml mit Service-Matrix ---
    ensure_dir ".github/workflows"
    local perf_yml=".github/workflows/perf.yml"
    if [[ -f "$perf_yml" && "$FORCE" != "true" ]]; then
        log_skip "$perf_yml existiert (use --force to overwrite)"
    elif [[ "$DRY_RUN" == "true" ]]; then
        if [[ -f "$perf_yml" ]]; then
            log_dry "overwrite $perf_yml (--force) — Inhalt aus file-templates.md §.github/workflows/perf.yml"
        else
            log_dry "write $perf_yml (Service-Matrix: ${services[*]})"
        fi
    else
        # Service-Matrix als YAML-Liste rendern: [auth-service, api-gateway]
        local matrix_list=""
        local first="true"
        for svc in "${services[@]}"; do
            if [[ "$first" == "true" ]]; then
                matrix_list="${svc}"
                first="false"
            else
                matrix_list="${matrix_list}, ${svc}"
            fi
        done
        cat > "$perf_yml" <<'PERF_YML_EOF'
# .github/workflows/perf.yml
# BOO-16 Performance-Baseline-Gate — vergleicht aktuellen Bench-Lauf gegen
# journal/perf-baseline.json. Schwellen: <=5% PASS, 5-20% WARNING, >20% FAIL.

name: Performance

on:
  pull_request:
    branches: [main]
  workflow_dispatch:

jobs:
  bench:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        # Operator pflegt Service-Liste hier — synchron zu observability.md.
        service: [{{SERVICE_MATRIX}}]
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      # --- Stack-Setup: eines von beiden, je nach Stack-Choice (Block A) ---
      - name: Setup Node.js
        if: ${{ hashFiles('package.json') != '' }}
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Setup Python
        if: ${{ hashFiles('pyproject.toml') != '' }}
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install deps (Node)
        if: ${{ hashFiles('package.json') != '' }}
        run: npm ci

      - name: Install deps (Python)
        if: ${{ hashFiles('pyproject.toml') != '' }}
        run: pip install -e '.[test]'

      # --- Service starten — Operator passt Command pro Projekt an ---
      # Annahme: Service horcht auf Port 8080. Fuer Multi-Service-Projekte
      # pro Service einen eigenen Workflow-Job mit eigenem Port.
      - name: Start service (background)
        run: |
          # TODO Operator: hier den Start-Command fuer ${{ matrix.service }} eintragen.
          # Beispiele:
          #   Node:   npm run start:${{ matrix.service }} &
          #   Python: python -m {{MODULE}} &
          echo "Operator: Start-Command fuer ${{ matrix.service }} hier eintragen" && exit 1

      - name: Wait for service
        run: |
          for i in $(seq 1 30); do
            if curl -sf http://localhost:8080/health > /dev/null; then
              echo "Service ready"; exit 0
            fi
            sleep 1
          done
          echo "Service did not start within 30s"; exit 1

      # --- Bench laufen lassen (eines von beiden) ---
      - name: Run bench (Node)
        if: ${{ hashFiles('package.json') != '' }}
        env:
          BENCH_URL: http://localhost:8080/
          BENCH_DURATION: '30'
        run: node bench/${{ matrix.service }}.bench.js

      - name: Run bench (Python)
        if: ${{ hashFiles('pyproject.toml') != '' }}
        env:
          BENCH_URL: http://localhost:8080/
        run: |
          mkdir -p journal/reports/perf
          pytest bench/ \
            --benchmark-json=journal/reports/perf/${{ matrix.service }}-bench-raw.json

      # --- Comparator: Ratio current_p95 / baseline_p95 ---
      - name: Compare against baseline
        id: compare
        env:
          SERVICE: ${{ matrix.service }}
          PR_LABELS: ${{ toJson(github.event.pull_request.labels.*.name) }}
          COMMIT_MSG: ${{ github.event.pull_request.title }}
        run: |
          set -euo pipefail
          SHORT_SHA=$(git rev-parse --short HEAD)
          REPORT_PATH="journal/reports/perf/${SERVICE}-bench-${SHORT_SHA}.json"

          # Python-Stack: stats -> Baseline-Schema konvertieren (Operator-Choice A).
          if [ -f "journal/reports/perf/${SERVICE}-bench-raw.json" ] && [ ! -f "$REPORT_PATH" ]; then
            python3 - <<PY
          import json, subprocess
          from datetime import datetime, timezone
          raw = json.load(open("journal/reports/perf/${SERVICE}-bench-raw.json"))
          stats = raw["benchmarks"][0]["stats"]
          sha = subprocess.check_output(["git","rev-parse","HEAD"]).decode().strip()
          mean_ms = stats["mean"] * 1000
          stddev_ms = stats["stddev"] * 1000
          report = {
            "service": "${SERVICE}",
            "p50_ms": stats["median"] * 1000,
            "p95_ms": mean_ms + 1.645 * stddev_ms,
            "p99_ms": stats["max"] * 1000,
            "req_per_sec": 1000.0 / mean_ms if mean_ms > 0 else 0.0,
            "recorded_at": datetime.now(timezone.utc).isoformat().replace("+00:00","Z"),
            "commit_sha": sha,
            "bench_tool": "pytest-benchmark",
          }
          json.dump(report, open("${REPORT_PATH}","w"), indent=2)
          PY
          fi

          if [ ! -f "$REPORT_PATH" ]; then
            echo "FAIL: Bench-Report fehlt: $REPORT_PATH"; exit 1
          fi

          CURRENT=$(python3 -c "import json; print(json.load(open('$REPORT_PATH'))['p95_ms'])")
          BASELINE=$(python3 -c "
          import json, sys
          data = json.load(open('journal/perf-baseline.json'))
          for s in data.get('services', []):
              if s['service'] == '${SERVICE}':
                  print(s['p95_ms']); sys.exit(0)
          sys.exit(2)
          " || echo "MISSING")

          if [ "$BASELINE" = "MISSING" ]; then
            echo "FAIL: Baseline fuer ${SERVICE} fehlt in journal/perf-baseline.json."
            echo "Bench-Output: $REPORT_PATH — Werte manuell uebernehmen + Operator-Freigabe."
            exit 1
          fi

          RATIO=$(python3 -c "print(${CURRENT} / ${BASELINE})")
          echo "ratio=${RATIO}" >> "$GITHUB_OUTPUT"
          echo "current=${CURRENT}" >> "$GITHUB_OUTPUT"
          echo "baseline=${BASELINE}" >> "$GITHUB_OUTPUT"

          PASS=$(python3 -c "print('1' if ${RATIO} <= 1.05 else '0')")
          WARN=$(python3 -c "print('1' if ${RATIO} > 1.05 and ${RATIO} <= 1.20 else '0')")
          FAIL=$(python3 -c "print('1' if ${RATIO} > 1.20 else '0')")

          if [ "$PASS" = "1" ]; then
            echo "PASS: p95 ratio ${RATIO} (<= 1.05)"; exit 0
          fi
          if [ "$WARN" = "1" ]; then
            echo "WARNING: p95 ratio ${RATIO} (5-20% above baseline)"
            echo "outcome=warning" >> "$GITHUB_OUTPUT"
            exit 0
          fi
          # FAIL-Pfad — Override pruefen
          if echo "$PR_LABELS" | grep -q '"perf-override"' \
             || git log -1 --pretty=%B | grep -qi '^Perf-Override:'; then
            echo "FAIL overridden by operator. Logging to overrides.log."
            mkdir -p journal/reports/perf
            REASON=$(git log -1 --pretty=%B | grep -i '^Perf-Override:' | head -1 || echo "via PR label")
            echo "$(date -u +%FT%TZ) | ${SERVICE} | ratio=${RATIO} | sha=$(git rev-parse HEAD) | ${REASON}" \
              >> journal/reports/perf/overrides.log
            exit 0
          fi
          echo "FAIL: p95 ratio ${RATIO} > 1.20 (no override)"
          exit 1

      - name: Comment on PR (warning only)
        if: steps.compare.outputs.outcome == 'warning' && github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const ratio = '${{ steps.compare.outputs.ratio }}';
            const current = '${{ steps.compare.outputs.current }}';
            const baseline = '${{ steps.compare.outputs.baseline }}';
            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: `BOO-16 Perf-Warning: \`${{ matrix.service }}\` p95 ratio **${ratio}** ` +
                    `(current ${current} ms vs baseline ${baseline} ms). ` +
                    `Below 1.20 FAIL-Threshold but above 1.05 PASS-Threshold — review recommended.`
            });

      - name: Upload bench artifact
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: perf-bench-${{ matrix.service }}
          path: journal/reports/perf/
          retention-days: 30
PERF_YML_EOF
        # Service-Matrix substituieren
        sed -e "s/{{SERVICE_MATRIX}}/${matrix_list}/g" "$perf_yml" > "${perf_yml}.tmp" && mv "${perf_yml}.tmp" "$perf_yml"
        log_info "created $perf_yml (Service-Matrix: ${matrix_list})"
    fi

    # --- Schritt 5: journal/reports/perf/.gitkeep + overrides.log ---
    ensure_dir "journal/reports/perf"
    ensure_file "journal/reports/perf/.gitkeep"
    ensure_file "journal/reports/perf/overrides.log"

    # --- Schritt 6: .gitignore-Eintraege idempotent ---
    append_if_missing ".gitignore" "coverage/"
    append_if_missing ".gitignore" "journal/reports/perf/*.json"

    # --- Operator-Schritte (Pflicht-Lese-Hinweis) ---
    log_manual "Operator-Schritte: siehe migration-checklist-v1-to-v2.md §BOO-16"
    if [[ -f "observability.md" && -z "${BOO16_SERVICES:-}" ]]; then
        log_manual "Operator: Service-Liste manuell verifizieren — wurde aus observability.md geparst (${services[*]})"
    fi
    log_manual "Operator: ersten CI-Lauf abwarten, Artefakt 'perf-bench-<service>' herunterladen, perf-baseline.json mit p50/p95/p99/req_per_sec pro Service befuellen, committen ('BOO-16: initial baseline for <service>')"
    log_manual "Operator: Branch-Protection fuer 'Perf' Required Status Check aktivieren (oder ADR-Begruendung unter docs/domain/adrs/NNN-perf-gate-disabled.md)"
    log_manual "Operator (Node): falls jq fehlt oder devDeps nicht ergaenzt — 'npm install --save-dev autocannon' nachholen"
    log_manual "Operator (Python): 'pip install -e .[test]' nach pyproject.toml-Update — verifiziert pytest-benchmark + httpx verfuegbar"
    log_manual "Operator: Service-Start-Command in .github/workflows/perf.yml im Step 'Start service (background)' eintragen (Platzhalter exit 1 ersetzen)"
    return 0
}

migrate_boo_45() {
    # BOO-45 — Lighthouse-CI Setup-Integration (Frontend-Pendant zu BOO-16)
    # https://linear.app/owlist/issue/BOO-45
    # Aktiviert nur wenn Frontend-Anteil vorhanden — Operator-Frage statt Auto-Detect, weil
    # "package.json mit react-Eintrag" nicht zuverlaessig diskriminiert (z.B. Storybook in
    # einem reinen Backend-Repo). Operator entscheidet beim ersten Run.
    log_info "BOO-45: Lighthouse-CI fuer Frontend-Performance"

    # Idempotenz-Check
    if [[ -f "lighthouserc.json" && -f ".github/workflows/lighthouse.yml" ]]; then
        log_skip "Lighthouse-CI bereits aktiv (lighthouserc.json + lighthouse.yml existieren)"
        return 0
    fi

    # Frontend-Stack-Heuristik: package.json mit Frontend-Framework
    local has_frontend=false
    if [[ -f "package.json" ]]; then
        if grep -qE '"(react|vue|svelte|astro|next|nuxt|vite|webpack)"' package.json; then
            has_frontend=true
        fi
    fi

    if [[ "$has_frontend" != "true" ]]; then
        log_warn "BOO-45 ist Frontend-Pendant zu BOO-16 — Stack scheint Backend-only (kein React/Vue/Svelte/Astro/Next/Nuxt/Vite/Webpack in package.json)"
        log_manual "Operator: Wenn Frontend-Anteil vorhanden ist (z.B. via Drittanbieter-Hosting), 'FRONTEND_OVERRIDE=true bash migrate-to-v2.sh --issue BOO-45' setzen — sonst BOO-45 ueberspringen"
        if [[ "${FRONTEND_OVERRIDE:-false}" != "true" ]]; then
            return 0
        fi
        log_info "FRONTEND_OVERRIDE=true gesetzt — fahre mit Lighthouse-CI-Setup fort"
    fi

    # Lighthouserc anlegen
    if [[ ! -f "lighthouserc.json" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write lighthouserc.json (BOO-45 Performance-Budgets)"
        else
            cat > "lighthouserc.json" <<'LIGHTHOUSE_RC_EOF'
{
  "ci": {
    "collect": {
      "url": ["http://localhost:3000/"],
      "numberOfRuns": 3,
      "settings": {
        "preset": "desktop",
        "throttlingMethod": "simulate"
      }
    },
    "assert": {
      "preset": "lighthouse:recommended",
      "assertions": {
        "categories:performance": ["error", {"minScore": 0.9}],
        "categories:accessibility": ["error", {"minScore": 0.9}],
        "categories:best-practices": ["warn", {"minScore": 0.9}],
        "categories:seo": ["warn", {"minScore": 0.9}],
        "largest-contentful-paint": ["error", {"maxNumericValue": 2500}],
        "cumulative-layout-shift": ["error", {"maxNumericValue": 0.1}],
        "total-blocking-time": ["error", {"maxNumericValue": 300}]
      }
    },
    "upload": {
      "target": "filesystem",
      "outputDir": "journal/reports/ci/lighthouse-out"
    }
  }
}
LIGHTHOUSE_RC_EOF
            log_info "created lighthouserc.json"
        fi
    else
        log_skip "lighthouserc.json exists"
    fi

    # Workflow anlegen
    ensure_dir ".github/workflows"
    if [[ ! -f ".github/workflows/lighthouse.yml" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write .github/workflows/lighthouse.yml"
        else
            cat > ".github/workflows/lighthouse.yml" <<'LIGHTHOUSE_YML_EOF'
name: Lighthouse CI

on:
  push:
    branches:
      - main
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }

      - name: Install dependencies
        run: npm ci

      - name: Build frontend
        run: npm run build

      - name: Start preview server in background
        run: |
          npx serve -s dist -l 3000 &
          npx wait-on http://localhost:3000 --timeout 60000

      - name: Run Lighthouse CI
        run: |
          npm install -g @lhci/cli@0.14.x
          lhci autorun --config=./lighthouserc.json

      - name: Collect reports for Hermes (BOO-32)
        if: always()
        run: |
          mkdir -p journal/reports/ci/run-${{ github.run_id }}
          cp -rf journal/reports/ci/lighthouse-out/* journal/reports/ci/run-${{ github.run_id }}/ 2>/dev/null || true
          if [ -f "journal/reports/ci/lighthouse-out/manifest.json" ]; then
            cp -f journal/reports/ci/lighthouse-out/manifest.json journal/reports/ci/run-${{ github.run_id }}/lighthouse.json
          fi

      - name: Upload reports as artifact
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: ci-reports-${{ github.run_id }}
          path: journal/reports/ci/run-${{ github.run_id }}/
          retention-days: 30
LIGHTHOUSE_YML_EOF
            log_info "created .github/workflows/lighthouse.yml"
        fi
    else
        log_skip ".github/workflows/lighthouse.yml exists"
    fi

    log_manual "Operator: lighthouserc.json anpassen — Frontend-URL pro Environment (preview/staging/prod), Performance-Budgets justieren (LCP/CLS/TBT), Mobile-Throttling-Profil waehlen (desktop vs. mobile)"
    log_manual "Operator: .github/workflows/lighthouse.yml Build-Command an Stack anpassen (npm run build / next build / vite build) und Preview-Server-Command (npx serve / npm run start)"
    log_manual "Operator (optional): LHCI_GITHUB_APP_TOKEN als GitHub-Secret setzen fuer Lighthouse-CI-Server-Status-Checks — sonst Filesystem-Reports"
    log_manual "Operator: nach erstem CI-Lauf den Artifact 'ci-reports-{id}' im Actions-Tab pruefen — sollte lighthouse.json + lighthouse-out/*.json enthalten"
    return 0
}

migrate_boo_46() {
    # BOO-46 — Self-Hosted-Runner + 10%-Threshold-Schaerfung fuer Performance-Gate
    # https://linear.app/owlist/issue/BOO-46
    # Folgeschnitt zu BOO-16: reservierter Runner -> weniger Varianz -> schaerferer Threshold.
    # Idempotente perf.yml-Anpassung (runs-on + Threshold). Operator macht VPS-Setup selbst.
    log_info "BOO-46: Self-Hosted-Runner + 10%-Threshold-Schaerfung"

    local perf_yml=".github/workflows/perf.yml"
    if [[ ! -f "$perf_yml" ]]; then
        log_warn "$perf_yml fehlt — BOO-16 zuerst durchlaufen (migrate_boo_16) bevor BOO-46"
        return 0
    fi

    # Idempotenz: ist runs-on schon self-hosted?
    if grep -qE '^\s*runs-on:\s*self-hosted' "$perf_yml"; then
        log_skip "perf.yml hat bereits runs-on: self-hosted"
    else
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "sed: runs-on: ubuntu-latest -> runs-on: self-hosted in $perf_yml"
        else
            # Backup
            cp -f "$perf_yml" "${perf_yml}.boo46-backup"
            sed -i '' 's/runs-on: ubuntu-latest/runs-on: self-hosted/g' "$perf_yml"
            log_info "patched runs-on: ubuntu-latest -> self-hosted (Backup: ${perf_yml}.boo46-backup)"
        fi
    fi

    # Threshold-Schaerfung: 1.20 -> 1.10 (20% -> 10%)
    if grep -qE 'ratio.*1\.10' "$perf_yml"; then
        log_skip "perf.yml hat bereits 10%-Threshold (1.10)"
    else
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "sed: 1.20 -> 1.10 (Threshold-Schaerfung) in $perf_yml"
        else
            # 20% -> 10%: alle '1.20' und '> 1.20' Vorkommen ersetzen
            sed -i '' 's/1\.20/1.10/g' "$perf_yml"
            # Auch im Comment '20%-Threshold' -> '10%-Threshold'
            sed -i '' 's/20%-Threshold/10%-Threshold/g' "$perf_yml"
            sed -i '' 's/20 %/10 %/g' "$perf_yml"
            log_info "patched Threshold 20%% -> 10%% (Self-Hosted-Runner weniger Varianz)"
        fi
    fi

    log_manual "Operator: GitHub-Actions-Runner-Software auf VPS installieren — Settings -> Actions -> Runners -> New self-hosted runner, dann './config.sh --url ... --token ...' auf VPS ausfuehren"
    log_manual "Operator: systemd-Service-Unit anlegen ('sudo ./svc.sh install' im Runner-Verzeichnis) damit Runner als Daemon laeuft"
    log_manual "Operator: Runner-Health-Check via Cron alle 6h (e.g. 'gh api repos/{owner}/{repo}/actions/runners | jq .runners[].status') — Alert bei status != 'online' > 10min"
    log_manual "Operator: nach erstem self-hosted CI-Lauf den 20%->10% Threshold validieren — bei zuviel False-Positives auf 15% justieren"
    log_manual "Operator: ggf. zweiten Runner als Failover anlegen (matrix.runs-on: [self-hosted, fallback-hosted]) — out-of-scope von BOO-46"
    return 0
}

migrate_boo_25() {
    # BOO-25 — Reliability als eigene Architektur-Dimension (Schraders 6. Saeule) — v3.7.0 seit 2026-05-07
    # https://linear.app/owlist/issue/BOO-25
    #
    # Legt vier Skelett-Files an (Stack-abhaengig):
    #   1. lib/idempotency.{js,py}     — Idempotency-Key-Middleware-Stub
    #   2. lib/retry.{js,py}           — Retry-mit-Exponential-Backoff-Helper-Stub
    #   3. lib/circuit-breaker.{js,py} — Circuit-Breaker-Wrapper-Stub
    #   4. docs/SLO.md                 — Service-Level-Objectives-Skelett (Stack-unabhaengig)
    #
    # Stack-Detection:
    #   - package.json vorhanden  → .js-Variante anlegen
    #   - pyproject.toml ODER requirements.txt vorhanden → .py-Variante anlegen
    #   - beide vorhanden (Mixed-Stack) → beide Varianten parallel
    #   - keines vorhanden (Unknown)  → log_warn + Operator-Hinweis, nur docs/SLO.md anlegen
    #
    # Idempotenz: bestehende Files werden ge[SKIP]ped; --force ueberschreibt mit
    # `.bak`-Backup. Operator-Schritte (Middleware-Wiring, .env, Tests) werden
    # NICHT automatisch ausgefuehrt — siehe migration-checklist §BOO-25.
    log_info "BOO-25: Reliability-Skelett (idempotency + retry + circuit-breaker + SLO.md)"

    local has_node="false"
    local has_python="false"
    [[ -f "package.json" ]] && has_node="true"
    [[ -f "pyproject.toml" || -f "requirements.txt" ]] && has_python="true"

    if [[ "$has_node" != "true" && "$has_python" != "true" ]]; then
        log_warn "BOO-25: weder package.json noch pyproject.toml/requirements.txt gefunden — Stack unbekannt"
        log_manual "Operator: Stack manuell festlegen oder Manifest-File ergaenzen, dann erneut '--issue BOO-25' laufen lassen"
        log_manual "BOO-25: docs/SLO.md wird trotzdem angelegt (Stack-unabhaengig)"
    fi

    # Helper: schreibt eine Skelett-Datei mit --force-Backup-Logik
    _boo25_write_skeleton() {
        local target="$1"
        local content="$2"
        if [[ -f "$target" ]]; then
            if [[ "$FORCE" != "true" ]]; then
                log_skip "$target existiert (use --force to overwrite)"
                return 0
            fi
            if [[ "$DRY_RUN" == "true" ]]; then
                log_dry "backup $target -> $target.bak; overwrite $target"
                return 0
            fi
            cp "$target" "$target.bak"
            log_info "backup created: $target.bak"
        elif [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write $target (Skelett — Inhalt aus file-templates.md §$(basename "$target"))"
            return 0
        fi
        ensure_dir "$(dirname "$target")"
        printf '%s' "$content" > "$target"
        log_info "created $target"
    }

    # --- Schritt 1a: lib/idempotency.{js,py} ---
    if [[ "$has_node" == "true" ]]; then
        _boo25_write_skeleton "lib/idempotency.js" "$(cat <<'IDEMP_JS_EOF'
// lib/idempotency.js — Idempotency-Middleware-Skelett (BOO-25)
//
// DE: Skelett. Echte Implementierung aus file-templates.md §lib/idempotency uebernehmen.
//     Cache-Backend: Redis (REDIS_URL aus .env). Pflicht-Header: Idempotency-Key.
//     Verhalten:
//       - gleicher Key + gleicher Body  -> cached Response zurueckgeben
//       - gleicher Key + anderer Body   -> HTTP 422
//       - kein Key auf POST/PUT/PATCH/DELETE -> HTTP 400 (konfigurierbar)
//
// EN: Skeleton. Replace with the implementation from file-templates.en.md §lib/idempotency.
//     Cache backend: Redis (REDIS_URL from .env). Required header: Idempotency-Key.
//
// Schrader Code Crash chap. 4 §Run the System (pillar 6 reliability) — pillar 1 idempotency.

module.exports = function idempotencyMiddleware(/* { redisClient, ttlSeconds } */) {
  return async function (req, res, next) {
    // TODO(BOO-25): Operator implementiert — siehe file-templates.md §lib/idempotency
    return next();
  };
};
IDEMP_JS_EOF
)"
    fi
    if [[ "$has_python" == "true" ]]; then
        _boo25_write_skeleton "lib/idempotency.py" "$(cat <<'IDEMP_PY_EOF'
"""lib/idempotency.py — Idempotency-Middleware-Skelett (BOO-25).

DE: Skelett. Echte Implementierung aus file-templates.md §lib/idempotency uebernehmen.
    Cache-Backend: Redis (REDIS_URL aus .env). Pflicht-Header: Idempotency-Key.
    Verhalten:
      - gleicher Key + gleicher Body  -> cached Response zurueckgeben
      - gleicher Key + anderer Body   -> HTTP 422
      - kein Key auf POST/PUT/PATCH/DELETE -> HTTP 400 (konfigurierbar)

EN: Skeleton. Replace with the implementation from file-templates.en.md §lib/idempotency.
    Cache backend: Redis (REDIS_URL from .env). Required header: Idempotency-Key.

Schrader Code Crash chap. 4 §Run the System (pillar 6 reliability) — pillar 1 idempotency.
"""
from typing import Callable


def idempotency_dependency(*_args, **_kwargs) -> Callable:
    """FastAPI Depends() target — Operator implementiert (siehe file-templates.md §lib/idempotency)."""
    # TODO(BOO-25): Operator implementiert — siehe file-templates.md §lib/idempotency
    def _noop(*_a, **_kw):
        return None
    return _noop
IDEMP_PY_EOF
)"
    fi

    # --- Schritt 1b: lib/retry.{js,py} ---
    if [[ "$has_node" == "true" ]]; then
        _boo25_write_skeleton "lib/retry.js" "$(cat <<'RETRY_JS_EOF'
// lib/retry.js — Retry-mit-Exponential-Backoff-Skelett (BOO-25)
//
// DE: Skelett. Echte Implementierung aus file-templates.md §lib/retry uebernehmen.
//     Default-Config: maxRetries=3, baseDelayMs=200, factor=2, jitter=true.
//     Status-Code-Filter: KEIN Retry bei 4xx (Client-Fehler). 5xx und Netzwerk-Fehler
//     werden retried. Idempotency-Konflikte (422) werden NICHT retried.
//
// EN: Skeleton. Replace with the implementation from file-templates.en.md §lib/retry.
//     Default config: maxRetries=3, baseDelayMs=200, factor=2, jitter=true.
//
// Schrader Code Crash chap. 4 §Run the System (pillar 6 reliability) — pillar 2 retry+backoff.

module.exports = async function withRetry(fn, /* options */) {
  // TODO(BOO-25): Operator implementiert — siehe file-templates.md §lib/retry
  return fn();
};
RETRY_JS_EOF
)"
    fi
    if [[ "$has_python" == "true" ]]; then
        _boo25_write_skeleton "lib/retry.py" "$(cat <<'RETRY_PY_EOF'
"""lib/retry.py — Retry-mit-Exponential-Backoff-Skelett (BOO-25).

DE: Skelett. Echte Implementierung aus file-templates.md §lib/retry uebernehmen.
    Default-Config: max_retries=3, base_delay=0.2, factor=2, jitter=True.
    Status-Code-Filter: KEIN Retry bei 4xx (Client-Fehler). 5xx und Netzwerk-Fehler
    werden retried. Idempotency-Konflikte (422) werden NICHT retried.

EN: Skeleton. Replace with the implementation from file-templates.en.md §lib/retry.
    Default config: max_retries=3, base_delay=0.2, factor=2, jitter=True.

Schrader Code Crash chap. 4 §Run the System (pillar 6 reliability) — pillar 2 retry+backoff.
"""
from typing import Awaitable, Callable, TypeVar

T = TypeVar("T")


async def with_retry(fn: Callable[[], Awaitable[T]], *_args, **_kwargs) -> T:
    """Operator implementiert — siehe file-templates.md §lib/retry."""
    # TODO(BOO-25): Operator implementiert — siehe file-templates.md §lib/retry
    return await fn()
RETRY_PY_EOF
)"
    fi

    # --- Schritt 1c: lib/circuit-breaker.{js,py} ---
    if [[ "$has_node" == "true" ]]; then
        _boo25_write_skeleton "lib/circuit-breaker.js" "$(cat <<'CB_JS_EOF'
// lib/circuit-breaker.js — Circuit-Breaker-Wrapper-Skelett (BOO-25)
//
// DE: Skelett. Echte Implementierung aus file-templates.md §lib/circuit-breaker uebernehmen.
//     Default-Config: errorThresholdPercentage=50, resetTimeout=30000, volumeThreshold=10.
//     Pro externer Abhaengigkeit (DB, Auth-Service, externe API, Message Bus) eine
//     eigene Breaker-Instanz konfigurieren. Schwellen pro Abhaengigkeit anpassen.
//
// EN: Skeleton. Replace with the implementation from file-templates.en.md §lib/circuit-breaker.
//     Default config: errorThresholdPercentage=50, resetTimeout=30000, volumeThreshold=10.
//
// Schrader Code Crash chap. 4 §Run the System (pillar 6 reliability) — pillar 3 circuit breaker.

module.exports = function createBreaker(fn, /* options */) {
  // TODO(BOO-25): Operator implementiert — siehe file-templates.md §lib/circuit-breaker
  return { fire: (...args) => fn(...args), getStats: () => ({}) };
};
CB_JS_EOF
)"
    fi
    if [[ "$has_python" == "true" ]]; then
        _boo25_write_skeleton "lib/circuit-breaker.py" "$(cat <<'CB_PY_EOF'
"""lib/circuit_breaker.py — Circuit-Breaker-Wrapper-Skelett (BOO-25).

DE: Skelett. Echte Implementierung aus file-templates.md §lib/circuit-breaker uebernehmen.
    Default-Config: error_threshold_percent=50, reset_timeout=30.0, volume_threshold=10.
    Pro externer Abhaengigkeit (DB, Auth-Service, externe API, Message Bus) eine
    eigene Breaker-Instanz konfigurieren. Schwellen pro Abhaengigkeit anpassen.

EN: Skeleton. Replace with the implementation from file-templates.en.md §lib/circuit-breaker.
    Default config: error_threshold_percent=50, reset_timeout=30.0, volume_threshold=10.

Schrader Code Crash chap. 4 §Run the System (pillar 6 reliability) — pillar 3 circuit breaker.
"""
from typing import Awaitable, Callable, TypeVar

T = TypeVar("T")


def create_breaker(fn: Callable[..., Awaitable[T]], *_args, **_kwargs):
    """Operator implementiert — siehe file-templates.md §lib/circuit-breaker."""
    # TODO(BOO-25): Operator implementiert — siehe file-templates.md §lib/circuit-breaker
    async def _fire(*args, **kwargs) -> T:
        return await fn(*args, **kwargs)
    return _fire
CB_PY_EOF
)"
    fi

    # --- Schritt 1d: docs/SLO.md (Stack-unabhaengig) ---
    _boo25_write_skeleton "docs/SLO.md" "$(cat <<'SLO_EOF'
# Service-Level-Objectives (SLO) — BOO-25

DE: Skelett. Operator fuellt Availability-Ziel, Error-Budget-Tabelle und SLIs aus.
    Vorlage: `bootstrap/references/file-templates.md` §`docs/SLO.md`.
EN: Skeleton. Operator fills in availability target, error-budget table and SLIs.
    Template: `bootstrap/references/file-templates.en.md` §`docs/SLO.md`.

> Schrader Code Crash Kap. 4 §Run the System (Saeule 6 Reliability) — Saeule 5
> SLO + Error-Budget. "Wer kein Error-Budget hat, weiss nicht, wann er stoppen
> muss."

## 1. Availability-Ziel / Availability target

- **Ziel / Target:** _z.B. 99.9% (drei-Neuner) — Operator entscheidet pro Service_
- **Begruendung / Rationale:** _warum genau dieses Ziel? (Kosten, Markt, Risiko)_

## 2. Error-Budget pro Quartal / Quarterly error budget

| Quartal | Budget (Minuten) | Verbraucht (Minuten) | Rest |
| ------- | ---------------- | -------------------- | ---- |
| Q?-YYYY | _berechnen_      | _0_                  | _0_  |

Berechnung: Budget = (1 - SLO) * 90 Tage * 24 h * 60 min.

## 3. SLIs / Service-Level-Indicators

Mindestens drei SLIs mit Mess-Methode (Verweis auf BOO-14-Metrics-Endpoint):

| SLI | Definition | Quelle / Source |
| --- | ---------- | --------------- |
| `error_rate` | Anteil HTTP-5xx an Gesamt-Requests | BOO-14 `/metrics` (`http_requests_total{status=~"5.."}`) |
| `p95_latency` | 95.-Perzentil Request-Dauer | BOO-14 `/metrics` (`http_request_duration_seconds`) |
| `availability` | Anteil Zeit mit `up == 1` | BOO-14 Alert-Rule `{service}_down` |

## 4. Review-Cadence / Review cadence

- Pflicht: Error-Budget-Status pro `/sprint-review`-Run pruefen.
- Bei Budget-Exhaustion: Stop-Ship-Regel — neue Features pausiert bis Budget wieder gruen.

## 5. Operator-Notizen / Operator notes

_<Platz fuer Service-spezifische Anpassungen — aktivierte Reliability-Saeulen,
ADR-Verweis auf docs/domain/adrs/NNN-reliability-pillars.md, etc.>_
SLO_EOF
)"

    # --- Operator-Schritte (Pflicht-Lese-Hinweis) ---
    log_manual "Operator-Schritte: siehe migration-checklist-v1-to-v2.md §BOO-25 (Schritte 2-8)"
    log_manual "Operator: Skelette aus lib/idempotency.{js,py} / lib/retry.{js,py} / lib/circuit-breaker.{js,py} mit Inhalten aus file-templates.md fuellen"
    log_manual "Operator: Idempotency-Middleware in Service-Entry-Point einhaengen (app.use() pro POST/PUT/PATCH/DELETE — NICHT global)"
    log_manual "Operator: REDIS_URL in .env ergaenzen (Beispielwert in .env.example committen)"
    log_manual "Operator: pro externer Abhaengigkeit (DB, Auth, externe API, Message Bus) eigenen Circuit-Breaker konfigurieren"
    log_manual "Operator: Retry-Helper auf alle Downstream-Calls anwenden — KEIN Retry bei 4xx, kein Retry bei 422 (Idempotency-Konflikt)"
    log_manual "Operator: docs/SLO.md befuellen (Availability-Ziel, Error-Budget, mindestens 3 SLIs)"
    log_manual "Operator: Tests fuer Idempotenz + Retry-Pfad ergaenzen (BOO-15 Coverage-Gate >=80% greift)"
    log_manual "Operator: docs/ARCHITECTURE_DESIGN.md §3 Quality Attributes pruefen — aktive Saeulen dokumentieren oder ADR docs/domain/adrs/NNN-reliability-pillars.md anlegen"
    return 0
}

# ---------------- Phase 4 — Intent-Propagation + KI-taugliche Architektur ----------------

migrate_boo_7() {
    # BOO-7 — KI-Tauglichkeit-Checkliste
    # https://linear.app/owlist/issue/BOO-7
    log_info "BOO-7: KI-Tauglichkeit-Checkliste in /architecture-review"
    # TODO: implementiert beim Done von BOO-7
    log_manual "Operator: implementiert beim Done von BOO-7 — Skill-Update, im Projekt nur Verweis im README"
    return 0
}

migrate_boo_10() {
    # BOO-10 — Intent-Propagation
    # https://linear.app/owlist/issue/BOO-10
    log_info "BOO-10: Intent-Propagation in Issue-/PR-Templates"
    log_manual "Operator: Issue-Template um Feld 'Intent-Referenz' erweitern (Pfad zu intents/<key>.md)"
    log_manual "Operator: PR-Template um Block 'Intent erfuellt? (Beleg via Test/ADR)' erweitern"
    return 0
}

migrate_boo_21() {
    # BOO-21 — Domainwissen ins Projekt
    # https://linear.app/owlist/issue/BOO-21
    log_info "BOO-21: docs/domain/ Verzeichnisstruktur"
    ensure_dir "docs/domain"
    ensure_dir "docs/domain/research"
    ensure_dir "docs/domain/adrs"
    if [[ ! -f "docs/domain/README.md" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write docs/domain/README.md stub"
        else
            cat > "docs/domain/README.md" <<'EOF'
# Domain Knowledge

- `research/` — Recherche-Notizen (YYYY-MM-DD-thema.md)
- `adrs/` — Domain-spezifische Architecture Decision Records (NNN-titel.md)
EOF
            log_info "created docs/domain/README.md"
        fi
    else
        log_skip "docs/domain/README.md exists"
    fi
    log_manual "Operator: Domain-ADR-Template aus bootstrap/references/file-templates.md nach docs/domain/adrs/000-template.md kopieren"
    return 0
}

migrate_boo_24() {
    # BOO-24 — 4 KI-Architektur-Prinzipien Pflicht-Block
    # https://linear.app/owlist/issue/BOO-24
    log_info "BOO-24: 4 KI-Architektur-Prinzipien + 4 Anti-Patterns Pflichtblock"
    log_manual "Operator: in docs/ARCHITECTURE_DESIGN.md §1 Pflichtblock einfuegen (Inhalt aus file-templates.md)"
    return 0
}

migrate_boo_26() {
    # BOO-26 — Anti-Pattern-Katalog
    # https://linear.app/owlist/issue/BOO-26
    log_info "BOO-26: Anti-Pattern-Katalog (Schrader Kap. 7)"
    # TODO: implementiert beim Done von BOO-26
    log_manual "Operator: implementiert beim Done von BOO-26 — Reference-Datei im Skill, im Projekt nur Verweis"
    return 0
}

migrate_boo_35() {
    # BOO-35 — /ideation: Pre-Flight-Check ARCHITECTURE_DESIGN.md
    # https://linear.app/owlist/issue/BOO-35
    log_info "BOO-35: ARCHITECTURE_DESIGN-Aktualitaets-Pre-Flight"
    # TODO: implementiert beim Done von BOO-35
    log_manual "Operator: implementiert beim Done von BOO-35 — Skill-Update"
    return 0
}

# ---------------- Phase 5 — Enterprise Governance ----------------

migrate_boo_11() {
    # BOO-11 — Issue-Writing-Guidelines
    # https://linear.app/owlist/issue/BOO-11
    log_info "BOO-11: Issue-Writing-Guidelines + Ausfuehrungsmodus"
    log_manual "Operator: docs/issue-writing-guidelines.md aus bootstrap/references/issue-writing-guidelines-template.de.md kopieren"
    log_manual "Operator: Issue-Template um Felder 'Ausfuehrungsmodus' und 'Sub-Agent-Kontext' erweitern"
    return 0
}

migrate_boo_17() {
    # BOO-17 — Feature-Flag-Konvention
    # https://linear.app/owlist/issue/BOO-17
    log_info "BOO-17: Feature-Flag-Konvention fuer AI-Code"
    # TODO: implementiert beim Done von BOO-17
    log_manual "Operator: implementiert beim Done von BOO-17 — Spec-Template um 'Rollout-Stufen' erweitern"
    return 0
}

migrate_boo_18() {
    # BOO-18 — Mandatory Human Review fuer sensible Pfade
    # https://linear.app/owlist/issue/BOO-18
    log_info "BOO-18: .claude/sensitive-paths.json"
    ensure_dir ".claude"
    if [[ ! -f ".claude/sensitive-paths.json" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_dry "write .claude/sensitive-paths.json stub"
        else
            cat > ".claude/sensitive-paths.json" <<'EOF'
{
  "paths": [
    ".env",
    "secrets/",
    "infra/terraform/",
    "migrations/"
  ],
  "policy": "manual-review-required"
}
EOF
            log_info "created .claude/sensitive-paths.json"
        fi
    else
        log_skip ".claude/sensitive-paths.json exists"
    fi
    log_manual "Operator: Pre-Commit-Hook erweitern — Hard-Stop bei Aenderung in sensiblen Pfaden"
    return 0
}

migrate_boo_19() {
    # BOO-19 — Prompt-Audit-Trail
    # https://linear.app/owlist/issue/BOO-19
    log_info "BOO-19: Prompt-Audit-Trail (Session-Logs + Spec-Referenz)"
    # TODO: implementiert beim Done von BOO-19
    log_manual "Operator: implementiert beim Done von BOO-19 — journal/sessions/ + PR-Template-Erweiterung"
    return 0
}

# ---------------- Phase 6 — Dokumentation + Rollout ----------------

migrate_boo_20() {
    # BOO-20 — HANDBUCH.md Schrader-Appendix
    # https://linear.app/owlist/issue/BOO-20
    log_info "BOO-20: HANDBUCH Schrader-Appendix (skill-only, keine Migration)"
    log_manual "Operator: Skill-interne Doku — keine Projekt-Migration"
    return 0
}

migrate_boo_37() {
    # BOO-37 — /pitch-Skill: pitch/-Dir + paths.pitches in environment.json
    # https://linear.app/owlist/issue/BOO-37
    # Skill-Source ist im Bundle (git pull); diese Migration setzt nur die Projekt-
    # seitigen Voraussetzungen: pitch/-Verzeichnis anlegen und paths.pitches in
    # .claude/environment.json sicherstellen.
    log_info "BOO-37: /pitch — pitch/-Dir + paths.pitches in environment.json"

    # 1) pitch/-Verzeichnis anlegen (idempotent), mit .gitkeep damit der leere
    #    Ordner committed werden kann. pitch/ wird NICHT gitignored — Briefings
    #    sind Teil der Projekt-Geschichte.
    ensure_dir "pitch"
    ensure_file "pitch/.gitkeep"

    # 2) intents/-Verzeichnis ebenfalls (BOO-1 Voraussetzung — wird vom Pitch-Skill
    #    als Quelle gelesen). Idempotent.
    ensure_dir "intents"
    ensure_file "intents/.gitkeep"

    # 3) paths.pitches in .claude/environment.json sicherstellen. Wenn die Datei
    #    fehlt, ueberlassen wir das BOO-34 (eigener Migrations-Schritt). Wenn sie
    #    existiert, aber den Key noch nicht hat: --force-Regen ueber den Generator
    #    empfehlen, weil der Generator in v3.23.0 die neuen Keys schreibt.
    local env_file=".claude/environment.json"
    if [[ -f "$env_file" ]]; then
        if grep -q '"pitches"' "$env_file"; then
            log_skip "$env_file enthaelt bereits paths.pitches"
        else
            if [[ "$DRY_RUN" == "true" ]]; then
                log_dry "regenerate $env_file (paths.pitches fehlt)"
            else
                log_manual "Operator: 'bash .claude/generate-environment-json.sh --force' ausfuehren, damit paths.pitches + paths.intents in environment.json landen"
            fi
        fi
    else
        log_manual "Operator: erst migrate_boo_34 ausfuehren (legt .claude/environment.json an), dann diesen Schritt wiederholen — paths.pitches kommt dann automatisch"
    fi

    return 0
}

# ---------------- Phase 7 — Hermes-Integration ----------------

migrate_boo_31() {
    # BOO-31 — metadata.hermes-Block in alle Skill-Frontmatter
    # https://linear.app/owlist/issue/BOO-31
    log_info "BOO-31: Hermes-Frontmatter in SKILL.md"
    # TODO: implementiert beim Done von BOO-31
    log_manual "Operator: implementiert beim Done von BOO-31 — Frontmatter-Aenderung in Skills, Bestands-Projekte unbetroffen"
    return 0
}

migrate_boo_32() {
    # BOO-32 — CI-Output-Standardisierung fuer Hermes
    # https://linear.app/owlist/issue/BOO-32
    # Layout: journal/reports/ci/run-{github-action-id}/{tool}.{ext}
    # Siehe HANDBUCH Anhang E "Reports-Konvention" fuer Pfad-Hierarchie + Tool-Mapping
    log_info "BOO-32: journal/reports/ Layout (ci/ + local/)"

    # Zwei Sub-Trees: ci/ (BOO-32) + local/ (BOO-36)
    ensure_dir "journal/reports/ci"
    ensure_dir "journal/reports/local"
    ensure_file "journal/reports/ci/.gitkeep"
    ensure_file "journal/reports/local/.gitkeep"

    # .gitignore idempotent ergaenzen — Reports sind kurzlebiges Signal, nicht versionieren
    if [[ -f ".gitignore" ]]; then
        if ! grep -qE "^journal/reports/?$" .gitignore; then
            if [[ "$DRY_RUN" == "true" ]]; then
                log_dry "append 'journal/reports/' to .gitignore"
            else
                echo "" >> .gitignore
                echo "# BOO-32: CI + local tool reports (Hermes-konsumiert via GitHub Actions artifacts)" >> .gitignore
                echo "journal/reports/" >> .gitignore
                log_info "appended 'journal/reports/' to .gitignore"
            fi
        else
            log_skip ".gitignore already contains journal/reports/"
        fi
    else
        log_warn ".gitignore fehlt — bitte manuell anlegen mit 'journal/reports/'"
    fi

    log_manual "Operator: pro existierendem CI-Workflow (eslint.yml/ruff.yml/semgrep.yml/perf.yml/sonar.yml) Collect+Upload-Step am Job-Ende ergaenzen — Template-Snippet in HANDBUCH Anhang E §Aggregator-Step"
    log_manual "Operator: SonarCloud-Post-Step ergaenzen, der sonarqube.json via Web-API zieht (nicht Teil der SonarSource-Action)"
    log_manual "Operator: nach erstem CI-Lauf den Artifact 'ci-reports-{id}' im Actions-Tab pruefen — sollte eslint.sarif / tests.junit.xml etc. enthalten"
    return 0
}

migrate_boo_33() {
    # BOO-33 — Hermes-Setup-Anleitung im HANDBUCH
    # https://linear.app/owlist/issue/BOO-33
    log_info "BOO-33: Hermes-Setup-Anleitung (skill-only, keine Migration)"
    log_manual "Operator: Skill-interne Doku — keine Projekt-Migration"
    return 0
}

# -----------------------------------------------------------------------------
# Aggregator / All-in-one
# -----------------------------------------------------------------------------

migrate_all() {
    log_info "DE: Starte Gesamt-Migration v1 -> v2 (idempotent)"
    log_info "EN: Starting full v1 -> v2 migration (idempotent)"

    # Phase 1
    migrate_boo_1
    migrate_boo_2

    # Phase 2
    migrate_boo_3
    migrate_boo_4
    migrate_boo_5
    migrate_boo_12
    migrate_boo_15
    migrate_boo_27
    migrate_boo_28
    migrate_boo_29
    migrate_boo_30
    migrate_boo_34
    migrate_boo_36
    migrate_boo_38
    migrate_boo_39
    migrate_boo_40

    # Phase 3
    migrate_boo_8
    migrate_boo_13
    migrate_boo_14
    migrate_boo_16
    migrate_boo_25

    # Phase 4
    migrate_boo_7
    migrate_boo_10
    migrate_boo_21
    migrate_boo_24
    migrate_boo_26
    migrate_boo_35

    # Phase 5
    migrate_boo_11
    migrate_boo_17
    migrate_boo_18
    migrate_boo_19

    # Phase 6
    migrate_boo_20
    migrate_boo_37

    # Phase 7
    migrate_boo_31
    migrate_boo_32
    migrate_boo_33

    log_info "DE: Migration abgeschlossen. Status pro Projekt in migration-status.md eintragen."
    log_info "EN: Migration finished. Record per-project status in migration-status.md."
}

# -----------------------------------------------------------------------------
# CLI / Argument Parsing
# -----------------------------------------------------------------------------

# Liste aller verfuegbaren Issues (fuer --list und --issue Validierung)
ALL_ISSUES=(
    BOO-1 BOO-2
    BOO-3 BOO-4 BOO-5 BOO-12 BOO-15 BOO-27 BOO-28 BOO-29 BOO-30 BOO-34 BOO-36 BOO-38 BOO-39 BOO-40
    BOO-8 BOO-13 BOO-14 BOO-16 BOO-25
    BOO-7 BOO-10 BOO-21 BOO-24 BOO-26 BOO-35
    BOO-11 BOO-17 BOO-18 BOO-19
    BOO-20 BOO-37
    BOO-31 BOO-32 BOO-33
)

print_help() {
    cat <<EOF
$SCRIPT_NAME — Migrations-Skript fuer Bootstrapping-Governance v1 -> v2

DE:
  --all               Alle Auto-Schritte fuer alle BOO-Issues ausfuehren.
  --issue BOO-N       Nur die Funktion fuer ein einzelnes Issue ausfuehren.
  --list              Alle unterstuetzten BOO-Issues auflisten.
  --dry-run           Nur loggen, keine Datei-Operationen ausfuehren.
  --force             Bestehende Auto-Generate-Files ueberschreiben (z.B. BOO-34).
  -h, --help          Diese Hilfe anzeigen.

EN: same flags, same semantics. The script is idempotent and safe to re-run.

Beispiele / Examples:
  $SCRIPT_NAME --all
  $SCRIPT_NAME --issue BOO-21
  $SCRIPT_NAME --dry-run --all
  $SCRIPT_NAME --issue BOO-34 --force
  $SCRIPT_NAME --list
EOF
}

list_issues() {
    log_info "Verfuegbare / available BOO-Issues:"
    local issue
    for issue in "${ALL_ISSUES[@]}"; do
        printf '  %s\n' "$issue"
    done
}

run_single_issue() {
    local issue="$1"
    local found=false
    local known
    for known in "${ALL_ISSUES[@]}"; do
        if [[ "$known" == "$issue" ]]; then
            found=true
            break
        fi
    done
    if [[ "$found" != "true" ]]; then
        log_warn "Unbekannter Issue: $issue (siehe --list)"
        return 1
    fi
    local fn_name
    fn_name="migrate_boo_${issue#BOO-}"
    if declare -F "$fn_name" >/dev/null; then
        "$fn_name"
    else
        log_warn "Funktion $fn_name nicht implementiert"
        return 1
    fi
}

main() {
    if [[ $# -eq 0 ]]; then
        print_help
        exit 0
    fi

    local mode=""
    local single_issue=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --all)
                mode="all"
                shift
                ;;
            --issue)
                mode="single"
                single_issue="${2:-}"
                if [[ -z "$single_issue" ]]; then
                    log_warn "--issue benoetigt einen Wert (z.B. BOO-21)"
                    exit 1
                fi
                shift 2
                ;;
            --list)
                mode="list"
                shift
                ;;
            --dry-run)
                DRY_RUN="true"
                log_info "DRY-RUN aktiv — keine Datei-Operationen werden ausgefuehrt."
                shift
                ;;
            --force)
                FORCE="true"
                log_info "FORCE aktiv — bestehende Auto-Generate-Files werden ueberschrieben."
                shift
                ;;
            -h|--help)
                print_help
                exit 0
                ;;
            *)
                log_warn "Unbekanntes Argument: $1"
                print_help
                exit 1
                ;;
        esac
    done

    case "$mode" in
        all)    migrate_all ;;
        single) run_single_issue "$single_issue" ;;
        list)   list_issues ;;
        "")     print_help ;;
    esac
}

main "$@"

# DE: Dieses Skript ist ein Skelett. Konkrete Migration pro BOO-Issue wird beim Done des jeweiligen Issues nachgereicht.
# EN: This script is a skeleton. Concrete migration logic per BOO issue lands when each issue ships.
