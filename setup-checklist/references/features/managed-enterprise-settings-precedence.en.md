# Managed/Enterprise Settings & Precedence

> **Mode:** global (admin) · **Priority:** important · **Status:** include-with-fixes
> Verified 2026-06-02 against the official Anthropic docs (code.claude.com/docs).

## Secure managed/enterprise settings (admin step, optional)

This step is only relevant if you roll out Claude Code organization-wide or need binding guardrails for multiple devices/people. For a pure single-user setup you can skip it.

WHY: Managed settings sit at the top of the settings precedence. They cannot be overridden by any other level, not even by command-line arguments. This is the only place where you can truly enforce policies rather than merely recommend them. Anyone who puts security rules into user or project settings cannot enforce them, because end users can soften them.

The precedence order (high to low): managed -> command-line -> local project (.claude/settings.local.json) -> shared project (.claude/settings.json) -> user (~/.claude/settings.json). Note: permission rules merge across all levels and deny always wins (deny -> ask -> allow, first matching rule wins); all other settings follow the override order.

How to proceed:

1. Place the managed settings file at the OS path (protected from user modification, ideally via MDM):
   - macOS: /Library/Application Support/ClaudeCode/managed-settings.json (MDM domain: com.anthropic.claudecode via Jamf/Kandji)
   - Linux/WSL: /etc/claude-code/managed-settings.json
   - Windows: C:\Program Files\ClaudeCode\managed-settings.json (alternatively Group Policy / Intune: HKLM\SOFTWARE\Policies\ClaudeCode). The legacy path C:\ProgramData\ClaudeCode\managed-settings.json is NO LONGER supported since v2.1.75 - migrate.
   You can place multiple partial files into the directory managed-settings.d/; managed-settings.json is merged first as the base, then all *.json alphabetically on top (systemd convention: scalars override, arrays are concatenated/deduplicated, objects are deep-merged). Numeric prefixes like 10-, 20- control the order.

2. Set the lock-down keys you actually need, keep it lightweight. Proven: permissions.deny for secrets (.env, secrets/) and permissions.disableBypassPermissionsMode: "disable" (optionally also disableAutoMode: "disable"). These work from any level, but belong in managed for enforcement.

3. Use managed-ONLY keys only where enforcement is mandatory. These keys take effect exclusively from managed settings: allowManagedPermissionRulesOnly (locks out user/project permission rules), allowManagedHooksOnly (only managed/SDK/force-enabled plugin hooks), allowManagedMcpServersOnly (only allowed MCP servers; deniedMcpServers keeps merging), strictKnownMarketplaces and strictPluginOnlyCustomization (restrict plugin/customization sources). Each key costs flexibility - only set what has a concrete compliance argument.

4. Optional for high requirements: forceRemoteSettingsRefresh: true enforces a fail-closed start (the CLI only starts with freshly loaded policy, otherwise exit). First ensure network access to api.anthropic.com, otherwise users cannot start Claude Code (exception since v2.1.139: claude-auth subcommands are exempt from the check).

Note on the alternative: Without MDM there are server-managed settings (admin console on claude.ai, Teams since v2.1.38 / Enterprise since v2.1.30). Server-managed and endpoint-managed both occupy the highest tier; if one source delivers a non-empty config, it wins entirely - server-managed is checked first, then endpoint-managed; they do not merge. Important: managed-mcp.json (allowedMcpServers/deniedMcpServers) CANNOT be distributed via server-managed - use the managed-mcp.json path for that. Likewise, OS-policy-only keys such as policyHelper and wslInheritsWindowsSettings are NOT honored via server-managed.

## Reference (machine-readable)

```yaml
# ============================================================
# ADMIN SECTION: Managed/Enterprise settings & precedence
# Relevant only for IT admins / org owners. End users CANNOT
# override these values (highest precedence tier).
# Source: code.claude.com/docs/en/settings, /server-managed-settings, /permissions
# ============================================================
managed_settings:

  # ---- Settings precedence (high -> low) ----
  # 1. Managed settings (cannot be overridden by ANYTHING, not even CLI args)
  # 2. Command-line arguments
  # 3. Local project settings  (.claude/settings.local.json)
  # 4. Shared project settings (.claude/settings.json)
  # 5. User settings           (~/.claude/settings.json)
  # Note: permission rules MERGE across all levels (deny always wins),
  # the remaining settings override each other according to the order.
  precedence_order:
    - managed
    - command_line
    - local_project
    - shared_project
    - user

  # ---- File/policy paths for endpoint-managed (MDM) ----
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
  windows_registry_admin:   "HKLM\\SOFTWARE\\Policies\\ClaudeCode"  # JSON value, Group Policy / Intune
  windows_registry_user:    "HKCU\\SOFTWARE\\Policies\\ClaudeCode"  # lowest policy priority
  # Legacy: C:\Program Files was formerly C:\ProgramData\ClaudeCode\managed-settings.json
  #         -> NO LONGER supported since v2.1.75, migrate.

  # ---- Managed-ONLY keys ----
  # Take effect ONLY from managed settings. Set in user/project = ignored.
  # (Documented list from /permissions#managed-only-settings)
  managed_only_keys:
    allowAllClaudeAiMcps: false             # load claude.ai connectors in addition to managed-mcp.json
    allowManagedHooksOnly: false            # only managed/SDK/force-enabled plugin hooks; user/project hooks blocked
    allowManagedMcpServersOnly: false       # only allowedMcpServers from managed; deniedMcpServers keeps merging
    allowManagedPermissionRulesOnly: false  # user/project may not define allow/ask/deny rules
    blockedMarketplaces: []                 # blocklist of marketplace sources (checked before download)
    strictKnownMarketplaces: false          # controls which plugin marketplaces may be added/installed
    strictPluginOnlyCustomization: false    # blocks skills/agents/hooks/mcp from user/project (true OR array e.g. ["skills","hooks"])
    channelsEnabled: false                  # allow channels org-wide
    allowedChannelPlugins: []               # allowlist of channel plugins (requires channelsEnabled: true)
    pluginTrustMessage: ""                  # custom text in the plugin trust warning
    forceRemoteSettingsRefresh: false       # startup blocks until remote settings are freshly loaded; otherwise exit (fail-closed)
    wslInheritsWindowsSettings: false       # WSL also reads the Windows policy chain (Windows managed/HKLM only)
    sandbox.filesystem.allowManagedReadPathsOnly: false  # only managed allowRead paths; denyRead keeps merging
    sandbox.network.allowManagedDomainsOnly: false       # only managed allowedDomains; denyDomains keeps merging
    # Further documented managed-only keys (per the /settings#available-settings table):
    # allowAllClaudeAiMcps, allowedHttpHookUrls, allowedMcpServers, claudeMd,
    # forceLoginMethod, forceLoginOrgUUID, pluginSuggestionMarketplaces,
    # policyHelper (v2.1.136+, OS policy/managed-settings.json only, NOT server-managed)

  # ---- Important lock-down keys (work from any level, but belong in managed) ----
  permissions:
    deny:
      - "Read(./.env)"
      - "Read(./.env.*)"
      - "Read(./secrets/**)"
    disableBypassPermissionsMode: "disable" # prevents bypassPermissions mode (not managed-only)
    disableAutoMode: "disable"              # prevents auto mode (not managed-only)
```

## Audit criteria

- Does a managed settings file exist at the correct OS path (macOS: /Library/Application Support/ClaudeCode/managed-settings.json, Linux: /etc/claude-code/managed-settings.json, Windows: C:\Program Files\ClaudeCode\managed-settings.json)?
- If Windows: is there NO longer a file at the legacy path C:\ProgramData\ClaudeCode\managed-settings.json (no longer supported since v2.1.75, must be migrated)?
- Is the managed settings file protected from end-user write access (file permissions / MDM / registry policy)?
- Does managed permissions.deny contain at least secrets paths (.env, .env.*, secrets/**)?
- Is disableBypassPermissionsMode set to 'disable' in managed, if bypassPermissions should be forbidden (analogous to disableAutoMode for auto mode)?
- Are managed-ONLY keys (allowManagedPermissionRulesOnly, allowManagedHooksOnly, allowManagedMcpServersOnly, strictKnownMarketplaces, strictPluginOnlyCustomization) used ONLY in managed settings and not mistakenly in user/project (where they have no effect)?
- If forceRemoteSettingsRefresh: true is set: is network access to api.anthropic.com ensured for all users?
- If server-managed settings are used: are MCP allow/deny lists distributed via managed-mcp.json (not via server-managed), since server-managed cannot deliver managed-mcp.json?
- Has it been checked that no security-critical rules reside only in user/project settings (where they are overridable by higher levels)?

## Removed / softened by the verifier (not documented)

- disableAgentView as a managed-only key — appears in NONE of the authoritative tables (/permissions#managed-only-settings, /settings). Do NOT include.
- parentSettingsBehavior as a managed-only key — per /permissions it is an SDK option (managedSettings/parentSettingsBehavior='merge' for embedding hosts), NOT a managed-only settings key in the classic sense. Do not list as managed-only.
- The claim in uncertain_notes that HKLM/HKCU\SOFTWARE\Policies\ClaudeCode and com.anthropic.claudecode were 'not verbatim verified' — this assumption was WRONG: both appear verbatim on /settings. The caution flag verified=false was unfounded.
