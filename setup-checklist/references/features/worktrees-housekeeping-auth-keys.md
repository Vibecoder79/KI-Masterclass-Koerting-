# Worktrees & Housekeeping/Auth-Keys

> **Modus:** projekt+global · **Prioritaet:** nice-to-have · **Status:** include-with-fixes
> Verifiziert 2026-06-02 gegen die offizielle Anthropic-Doku (code.claude.com/docs).

## Worktrees, Housekeeping und Auth-Keys

Wenn du mit isolierten Arbeitskopien (Git-Worktrees) arbeitest oder Subagents im Hintergrund laufen laesst, lohnt sich ein Blick auf den `worktree`-Block in der projektbezogenen `.claude/settings.json`. Mit `worktree.baseRef` legst du fest, woraus neue Worktrees abzweigen: Default `"fresh"` startet von `origin/<default-branch>` und gibt dir einen sauberen Stand passend zum Remote; `"head"` zweigt vom lokalen HEAD ab und nimmt ungepushte Commits sowie deinen Feature-Branch-Zustand mit. Das gilt fuer `--worktree`, das `EnterWorktree`-Tool und die Subagent-Isolation. WARUM: In grossen Monorepos kosten Worktrees Plattenplatz und Checkout-Zeit. `worktree.symlinkDirectories` (z. B. `["node_modules", ".cache"]`) verlinkt grosse Verzeichnisse statt sie zu kopieren, und `worktree.sparsePaths` checkt per `git sparse-checkout` nur die wirklich benoetigten Pfade (plus Root-Dateien) aus. Wer mit Background-Sessions arbeitet, sollte `worktree.bgIsolation` kennen — dieser Key ist allerdings NUR in Managed Settings verfuegbar: Default `"worktree"` blockt Edit/Write im Haupt-Checkout, bis `EnterWorktree` aufgerufen wurde; `"none"` laesst Background-Jobs die Working Copy direkt editieren (ab Claude Code v2.1.143).

Beim Housekeeping (global in `~/.claude/settings.json`) sind drei Keys relevant. `cleanupPeriodDays` (Default 30, Minimum 1) bestimmt, ab wann alte Session-Dateien und verwaiste Subagent-Worktrees beim Start aufgeraeumt werden; `0` wird mit Validierungsfehler abgelehnt. `autoUpdatesChannel` waehlt den Release-Kanal: `"latest"` (Default) fuer die neueste Version oder `"stable"` fuer einen rund eine Woche alten Stand, der Versionen mit groesseren Regressionen ueberspringt. WARUM stable: weniger Ueberraschungen in einem produktiven Setup. `minimumVersion` pinnt eine Untergrenze (verhindert Background-Auto-Updates und `claude update` unter diese Version) und ist vor allem in Managed Settings nuetzlich, um org-weit eine Mindestversion zu erzwingen.

Die Auth-Helper-Keys brauchst du nur, wenn du nicht ueber den Standard-Login gehst. `apiKeyHelper` verweist auf ein Shell-Script (ausgefuehrt in `/bin/sh`), das einen Auth-Wert erzeugt (wird als `X-Api-Key` und `Authorization: Bearer` gesendet; Refresh-Intervall via `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`). Fuer Cloud-Provider gibt es `awsCredentialExport` (Script gibt JSON mit AWS-Credentials aus, Bedrock), `awsAuthRefresh` (Script aktualisiert das `.aws`-Verzeichnis, z. B. `aws sso login --profile myprofile`) und `gcpAuthRefresh` (erneuert GCP Application Default Credentials, z. B. `gcloud auth application-default login`, Vertex AI). WARUM Helper statt statischer Keys: rotierende/temporaere Credentials landen so nie fest in der Konfiguration.

## Referenz (maschinenlesbar)

```yaml
# === Worktrees (projekt-Ebene: .claude/settings.json) ===
# Steuert, wie isolierte Git-Worktrees fuer --worktree, EnterWorktree und Subagent-Isolation entstehen.
worktree:
  baseRef: "fresh"            # Branch-Basis neuer Worktrees: "fresh" (Default, von origin/<default-branch>, sauberer Stand passend zum Remote) | "head" (vom lokalen HEAD, inkl. ungepushter Commits und Feature-Branch-Zustand)
  symlinkDirectories: []      # Verzeichnisse aus dem Haupt-Repo per Symlink in jeden Worktree einbinden statt grosse Verzeichnisse zu duplizieren. Default: keine. Beispiel: ["node_modules", ".cache"]
  sparsePaths: []             # Nur diese Verzeichnisse (+ Root-Dateien) per git sparse-checkout auschecken. Schneller in grossen Monorepos. Beispiel: ["packages/my-app", "shared/utils"]
  bgIsolation: "worktree"     # NUR Managed Settings: Isolation fuer Background-Sessions: "worktree" (Default, blockt Edit/Write im Haupt-Checkout bis EnterWorktree aufgerufen wird) | "none" (Background-Jobs duerfen Working Copy direkt editieren). Braucht Claude Code >= 2.1.143

# === Housekeeping (global: ~/.claude/settings.json) ===
cleanupPeriodDays: 30         # Session-Dateien aelter als X Tage werden beim Start geloescht (Default 30, Minimum 1, 0 wird mit Validierungsfehler abgelehnt). Steuert auch das Aufraeumen verwaister Subagent-Worktrees beim Start.
autoUpdatesChannel: "latest"  # Release-Kanal: "latest" (Default, neueste Version) | "stable" (~1 Woche alt, ueberspringt Versionen mit grossen Regressionen). Auto-Update ganz aus: DISABLE_AUTOUPDATER in env.
minimumVersion: ""            # Untergrenze: verhindert Background-Auto-Updates und claude update unter diese Version. Sinnvoll in Managed Settings zum org-weiten Pinnen. Beispiel: "2.1.100"

# === Auth-Helpers (global: ~/.claude/settings.json) ===
apiKeyHelper: ""              # Script (in /bin/sh ausgefuehrt), das einen Auth-Wert erzeugt (gesendet als X-Api-Key + Authorization: Bearer Header). Refresh-Intervall via CLAUDE_CODE_API_KEY_HELPER_TTL_MS. Beispiel: /bin/generate_temp_api_key.sh
awsCredentialExport: ""      # Script, das JSON mit AWS-Credentials ausgibt (Bedrock advanced credential configuration). Beispiel: /bin/generate_aws_grant.sh
awsAuthRefresh: ""           # Script, das das .aws-Verzeichnis aktualisiert (Bedrock). Beispiel: aws sso login --profile myprofile
gcpAuthRefresh: ""           # Script, das GCP Application Default Credentials erneuert, wenn sie ablaufen oder nicht geladen werden koennen (Vertex AI). Beispiel: gcloud auth application-default login
```

## Audit-Kriterien

- worktree.bgIsolation ist NUR in Managed Settings verfuegbar; dort nur auf "none" setzen, wenn Background-Jobs den Haupt-Checkout bewusst direkt editieren duerfen, und Claude Code >= 2.1.143 installiert ist
- cleanupPeriodDays ist >= 1 (0 wird mit Validierungsfehler abgelehnt); Default 30 belassen, ausser es gibt einen Grund fuer kuerzere/laengere Aufbewahrung
- In produktiven/Team-Setups autoUpdatesChannel pruefen: "stable" reduziert Regressionsrisiko gegenueber "latest"
- minimumVersion in Managed Settings gesetzt, wenn eine org-weite Mindestversion erzwungen werden soll
- Auth-Helper-Scripts (apiKeyHelper, awsCredentialExport, awsAuthRefresh, gcpAuthRefresh) enthalten KEINE hartkodierten Secrets, sondern rufen rotierende/temporaere Credentials ab
- symlinkDirectories/sparsePaths in grossen Monorepos gesetzt, um Worktree-Platzbedarf und Checkout-Zeit zu reduzieren

## Vom Verifizierer entfernt / abgeschwaecht (nicht belegbar)

- gcpWorkloadIdentity als settings-Key — NICHT auf https://code.claude.com/docs/en/settings vorhanden. Korrekt bereits aus checklist_yaml/skill_section ausgeschlossen (war im Entwurf nur als verified:false-Claim gefuehrt, nicht im Output). Keine Aktion noetig ausser Bestaetigung.
