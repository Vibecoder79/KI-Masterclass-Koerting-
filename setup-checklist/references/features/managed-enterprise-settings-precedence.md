# Managed/Enterprise-Settings & Precedence

> **Modus:** global (admin) · **Prioritaet:** wichtig · **Status:** include-with-fixes
> Verifiziert 2026-06-02 gegen die offizielle Anthropic-Doku (code.claude.com/docs).

## Managed/Enterprise-Settings absichern (Admin-Schritt, optional)

Dieser Schritt ist nur relevant, wenn du Claude Code organisationsweit ausrollst oder fuer mehrere Geraete/Personen verbindliche Leitplanken brauchst. Fuer ein reines Einzel-Setup kannst du ihn ueberspringen.

WARUM: Managed-Settings stehen an der Spitze der Settings-Precedence. Sie koennen von keiner anderen Ebene ueberschrieben werden, auch nicht von Command-line-Argumenten. Das ist der einzige Ort, an dem du Richtlinien wirklich erzwingen kannst, statt sie nur zu empfehlen. Wer Sicherheitsregeln in user- oder project-Settings legt, kann sie damit nicht durchsetzen, weil Endnutzer sie aufweichen koennen.

Die Precedence-Reihenfolge (hoch nach niedrig): managed -> command-line -> local project (.claude/settings.local.json) -> shared project (.claude/settings.json) -> user (~/.claude/settings.json). Merke: Permission-Regeln mergen ueber alle Ebenen und deny gewinnt immer (deny -> ask -> allow, erste Treffer-Regel gewinnt); alle anderen Settings folgen der Ueberschreib-Reihenfolge.

So gehst du vor:

1. Lege die Managed-Settings-Datei am OS-Pfad ab (geschuetzt vor Nutzer-Aenderung, idealerweise per MDM):
   - macOS: /Library/Application Support/ClaudeCode/managed-settings.json (MDM-Domain: com.anthropic.claudecode via Jamf/Kandji)
   - Linux/WSL: /etc/claude-code/managed-settings.json
   - Windows: C:\Program Files\ClaudeCode\managed-settings.json (alternativ Group Policy / Intune: HKLM\SOFTWARE\Policies\ClaudeCode). Der Legacy-Pfad C:\ProgramData\ClaudeCode\managed-settings.json wird seit v2.1.75 NICHT mehr unterstuetzt - migrieren.
   Mehrere Teildateien kannst du in das Verzeichnis managed-settings.d/ legen; managed-settings.json wird als Basis zuerst gemerged, dann alle *.json alphabetisch darueber (systemd-Konvention: Skalare ueberschreiben, Arrays werden konkateniert/dedupliziert, Objekte deep-merged). Numerische Praefixe wie 10-, 20- steuern die Reihenfolge.

2. Setze die Lock-Down-Keys, die du wirklich brauchst, leichtgewichtig. Bewaehrt: permissions.deny fuer Secrets (.env, secrets/) und permissions.disableBypassPermissionsMode: "disable" (optional auch disableAutoMode: "disable"). Diese funktionieren aus jeder Ebene, gehoeren zur Erzwingung aber in managed.

3. Nutze Managed-ONLY-Keys nur dort, wo Erzwingung Pflicht ist. Diese Keys wirken ausschliesslich aus Managed-Settings: allowManagedPermissionRulesOnly (sperrt user/project-Permission-Regeln), allowManagedHooksOnly (nur managed/SDK/force-enabled-Plugin-Hooks), allowManagedMcpServersOnly (nur erlaubte MCP-Server; deniedMcpServers merged weiter), strictKnownMarketplaces und strictPluginOnlyCustomization (Plugin-/Customization-Quellen einschraenken). Jeder Key kostet Flexibilitaet - setze nur, was ein konkretes Compliance-Argument hat.

4. Optional fuer hohe Anforderungen: forceRemoteSettingsRefresh: true erzwingt fail-closed-Start (CLI startet nur mit frisch geladener Policy, sonst Exit). Vorher Netzzugriff auf api.anthropic.com sicherstellen, sonst koennen Nutzer Claude Code nicht starten (Ausnahme ab v2.1.139: claude-auth-Subcommands sind vom Check ausgenommen).

Hinweis zur Alternative: Ohne MDM gibt es server-managed Settings (Admin-Konsole auf claude.ai, Teams ab v2.1.38 / Enterprise ab v2.1.30). Server-managed und endpoint-managed belegen beide die hoechste Tier; liefert eine Quelle eine nicht-leere Config, gewinnt sie komplett - server-managed wird zuerst geprueft, dann endpoint-managed; sie mergen nicht. Wichtig: managed-mcp.json (allowedMcpServers/deniedMcpServers) kann NICHT ueber server-managed verteilt werden - dafuer den managed-mcp.json-Pfad nutzen. Ebenso werden OS-Policy-only-Keys wie policyHelper und wslInheritsWindowsSettings ueber server-managed NICHT honoriert.

## Referenz (maschinenlesbar)

```yaml
# ============================================================
# ADMIN-SEKTION: Managed/Enterprise-Settings & Precedence
# Nur fuer IT-Admins / Org-Owner relevant. Endnutzer koennen
# diese Werte NICHT ueberschreiben (hoechste Precedence-Stufe).
# Quelle: code.claude.com/docs/en/settings, /server-managed-settings, /permissions
# ============================================================
managed_settings:

  # ---- Settings-Precedence (hoch -> niedrig) ----
  # 1. Managed settings (kann durch NICHTS ueberschrieben werden, auch nicht CLI-Args)
  # 2. Command-line arguments
  # 3. Local project settings  (.claude/settings.local.json)
  # 4. Shared project settings (.claude/settings.json)
  # 5. User settings           (~/.claude/settings.json)
  # Hinweis: Permission-Regeln MERGEN ueber alle Ebenen (deny gewinnt immer),
  # die uebrigen Settings ueberschreiben sich gemaess Reihenfolge.
  precedence_order:
    - managed
    - command_line
    - local_project
    - shared_project
    - user

  # ---- Datei-/Policy-Pfade fuer Endpoint-Managed (MDM) ----
  # macOS
  macos_managed_settings: "/Library/Application Support/ClaudeCode/managed-settings.json"
  macos_dropin_dir:       "/Library/Application Support/ClaudeCode/managed-settings.d/"
  macos_managed_mcp:      "/Library/Application Support/ClaudeCode/managed-mcp.json"
  macos_mdm_domain:       "com.anthropic.claudecode"   # macOS managed-preferences (Jamf/Kandji etc.)
  # Linux / WSL
  linux_managed_settings: "/etc/claude-code/managed-settings.json"
  linux_dropin_dir:       "/etc/claude-code/managed-settings.d/"
  linux_managed_mcp:      "/etc/claude-code/managed-mcp.json"
  # Windows
  windows_managed_settings: "C:\\Program Files\\ClaudeCode\\managed-settings.json"
  windows_dropin_dir:       "C:\\Program Files\\ClaudeCode\\managed-settings.d\\"
  windows_managed_mcp:      "C:\\Program Files\\ClaudeCode\\managed-mcp.json"
  windows_registry_admin:   "HKLM\\SOFTWARE\\Policies\\ClaudeCode"  # JSON-Wert, Group Policy / Intune
  windows_registry_user:    "HKCU\\SOFTWARE\\Policies\\ClaudeCode"  # niedrigste Policy-Prioritaet
  # Legacy: C:\Program Files war frueher C:\ProgramData\ClaudeCode\managed-settings.json
  #         -> seit v2.1.75 NICHT mehr unterstuetzt, migrieren.

  # ---- Managed-ONLY Keys ----
  # Wirken NUR aus Managed-Settings. In user/project gesetzt = ignoriert.
  # (Belegte Liste aus /permissions#managed-only-settings)
  managed_only_keys:
    allowAllClaudeAiMcps: false             # claude.ai-Connectors zusaetzlich zu managed-mcp.json laden
    allowManagedHooksOnly: false            # nur managed/SDK/force-enabled-Plugin-Hooks; user/project-Hooks blockiert
    allowManagedMcpServersOnly: false       # nur allowedMcpServers aus managed; deniedMcpServers merged weiter
    allowManagedPermissionRulesOnly: false  # user/project duerfen keine allow/ask/deny-Regeln definieren
    blockedMarketplaces: []                 # Blocklist Marketplace-Quellen (vor Download geprueft)
    strictKnownMarketplaces: false          # steuert, welche Plugin-Marketplaces hinzugefuegt/installiert werden duerfen
    strictPluginOnlyCustomization: false    # blockt skills/agents/hooks/mcp aus user/project (true ODER Array z.B. ["skills","hooks"])
    channelsEnabled: false                  # Channels org-weit erlauben
    allowedChannelPlugins: []               # Allowlist Channel-Plugins (braucht channelsEnabled: true)
    pluginTrustMessage: ""                  # Custom-Text im Plugin-Trust-Warnhinweis
    forceRemoteSettingsRefresh: false       # Startup blockt bis Remote-Settings frisch geladen; sonst Exit (fail-closed)
    wslInheritsWindowsSettings: false       # WSL liest Windows-Policy-Chain mit (nur Windows managed/HKLM)
    sandbox.filesystem.allowManagedReadPathsOnly: false  # nur managed allowRead-Pfade; denyRead merged
    sandbox.network.allowManagedDomainsOnly: false       # nur managed allowedDomains; denyDomains merged
    # Weitere belegte managed-only Keys (laut /settings#available-settings-Tabelle):
    # allowAllClaudeAiMcps, allowedHttpHookUrls, allowedMcpServers, claudeMd,
    # forceLoginMethod, forceLoginOrgUUID, pluginSuggestionMarketplaces,
    # policyHelper (v2.1.136+, nur OS-Policy/managed-settings.json, NICHT server-managed)

  # ---- Wichtige Lock-Down-Keys (funktionieren aus jeder Ebene, gehoeren aber in managed) ----
  permissions:
    deny:
      - "Read(./.env)"
      - "Read(./.env.*)"
      - "Read(./secrets/**)"
    disableBypassPermissionsMode: "disable" # verhindert bypassPermissions-Mode (nicht managed-only)
    disableAutoMode: "disable"              # verhindert auto-Mode (nicht managed-only)
```

## Audit-Kriterien

- Existiert eine Managed-Settings-Datei am korrekten OS-Pfad (macOS: /Library/Application Support/ClaudeCode/managed-settings.json, Linux: /etc/claude-code/managed-settings.json, Windows: C:\Program Files\ClaudeCode\managed-settings.json)?
- Falls Windows: liegt KEINE Datei mehr am Legacy-Pfad C:\ProgramData\ClaudeCode\managed-settings.json (seit v2.1.75 nicht mehr unterstuetzt, muss migriert sein)?
- Ist die Managed-Settings-Datei vor Endnutzer-Schreibzugriff geschuetzt (Datei-Permissions / MDM / Registry-Policy)?
- Enthaelt managed permissions.deny mindestens Secrets-Pfade (.env, .env.*, secrets/**)?
- Ist disableBypassPermissionsMode in managed auf 'disable' gesetzt, falls bypassPermissions verboten sein soll (analog disableAutoMode fuer auto-Mode)?
- Werden Managed-ONLY-Keys (allowManagedPermissionRulesOnly, allowManagedHooksOnly, allowManagedMcpServersOnly, strictKnownMarketplaces, strictPluginOnlyCustomization) NUR in Managed-Settings verwendet und nicht faelschlich in user/project (dort wirkungslos)?
- Falls forceRemoteSettingsRefresh: true gesetzt ist: ist Netzzugriff auf api.anthropic.com fuer alle Nutzer sichergestellt?
- Falls server-managed Settings genutzt werden: werden MCP-Allow/Deny-Listen ueber managed-mcp.json (nicht ueber server-managed) verteilt, da server-managed managed-mcp.json nicht ausliefern kann?
- Wurde geprueft, dass keine sicherheitskritischen Regeln nur in user/project-Settings liegen (dort durch hoehere Ebenen ueberschreibbar)?

## Vom Verifizierer entfernt / abgeschwaecht (nicht belegbar)

- disableAgentView als managed-only Key — taucht in KEINER der massgeblichen Tabellen (/permissions#managed-only-settings, /settings) auf. NICHT aufnehmen.
- parentSettingsBehavior als managed-only Key — ist laut /permissions eine SDK-Option (managedSettings/parentSettingsBehavior='merge' fuer Embedding-Hosts), KEIN managed-only-Settings-Key im klassischen Sinn. Nicht als managed-only listen.
- Behauptung im uncertain_notes, dass HKLM/HKCU\SOFTWARE\Policies\ClaudeCode und com.anthropic.claudecode 'nicht woertlich verifiziert' seien — diese Annahme war FALSCH: beide stehen woertlich auf /settings. Die Vorsichts-Markierung verified=false war unbegruendet.
