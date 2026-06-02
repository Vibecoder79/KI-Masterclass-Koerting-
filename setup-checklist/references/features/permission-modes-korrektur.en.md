# Permission Modes (Correction)

> **Mode:** global · **Priority:** critical · **Status:** include
> Verified 2026-06-02 against the official Anthropic documentation (code.claude.com/docs).

## Setting permission modes correctly

Claude Code uses what are called permission modes to control how strictly it asks before tool calls. The default mode is set in the settings files (User, Project, or Managed) via the key `permissions.defaultMode`.

IMPORTANT (correction): There are no modes `manual` or `custom`. The officially valid values are exactly these six:

- `default` — asks on first use of each tool. Safe default for daily use.
- `acceptEdits` — automatically accepts file edits and common filesystem commands (mkdir, touch, mv, cp ...) in the working directory or `additionalDirectories`. Handy for focused implementation sessions.
- `plan` — plan mode: Claude may only read and execute read-only shell commands, but may not change source files. Ideal for exploring and planning before anything is touched.
- `auto` — auto-approve with background safety checks (Research Preview). Use with caution.
- `dontAsk` — automatically denies tools unless they have been granted in advance via `/permissions` or `permissions.allow`. Restrictive allowlist operation.
- `bypassPermissions` — skips ALL prompts. Use only in isolated environments (container/VM). `rm -rf /` and `rm -rf ~` still trigger a prompt as a circuit breaker.

WHY: The mode determines the balance between speed and safety. `default` protects against accidental write access, `plan` separates thinking from acting, `bypassPermissions` is deliberately intended only for throwaway environments. In shared or Managed settings you should actively block `bypassPermissions` and `auto`: `permissions.disableBypassPermissionsMode: "disable"` or `permissions.disableAutoMode: "disable"` respectively.

Additionally, the lists `permissions.allow`, `permissions.ask`, and `permissions.deny` govern which tools/commands are allowed, prompted for, or forbidden. Evaluation happens in the order deny -> ask -> allow; the first matching rule wins, deny always takes precedence. Rule syntax: `Tool` or `Tool(specifier)`, e.g. `Bash(git push *)` or `Read(.env)`.

## Reference (machine-readable)

```yaml
# Permission modes & permission rules (Claude Code)
# Source: https://code.claude.com/docs/en/permissions (as of 2026-06-02)
permission_modes:
  # CORRECTION: The real defaultMode values are NOT manual/auto/custom.
  # The default mode is set via the settings key "permissions.defaultMode".
  setting_key: permissions.defaultMode   # in settings.json (User/Project/Managed)
  werte:
    default: "Standardverhalten: fragt bei Erstnutzung jedes Tools nach Erlaubnis"
    acceptEdits: "Akzeptiert Datei-Edits + gaengige FS-Befehle (mkdir, touch, mv, cp ...) automatisch fuer Pfade im Arbeitsverzeichnis / additionalDirectories"
    plan: "Plan-Modus: Claude liest Dateien und fuehrt nur lesende Shell-Befehle aus, aendert KEINE Quelldateien"
    auto: "Auto-Approve mit Hintergrund-Safety-Checks (prueft ob Aktion zur Anfrage passt). Derzeit Research Preview"
    dontAsk: "Auto-Deny: lehnt Tools ab, ausser sie sind via /permissions oder permissions.allow vorab freigegeben"
    bypassPermissions: "Ueberspringt ALLE Permission-Prompts. rm -rf / bzw. ~ loesen weiterhin einen Prompt aus (Circuit Breaker). Nur in isolierten Umgebungen (Container/VM) nutzen"
  # Block modes (preferably in Managed Settings):
  sperren:
    permissions.disableBypassPermissionsMode: "disable"   # forbids bypassPermissions
    permissions.disableAutoMode: "disable"                 # forbids auto mode

permissions_regeln:
  # Evaluation order: deny -> ask -> allow (first matching rule wins, deny takes precedence)
  allow: "Tool ohne manuelle Bestaetigung erlauben"
  ask:   "Bei jeder Nutzung des Tools nachfragen"
  deny:  "Tool-Nutzung verbieten (gewinnt immer)"
  syntax: "Tool  ODER  Tool(specifier)"   # e.g. Bash, Bash(npm run *), Read(./.env), WebFetch(domain:example.com)
  beispiel:
    permissions:
      allow:
        - "Bash(npm run *)"
        - "Bash(git commit *)"
      deny:
        - "Bash(git push *)"
        - "Read(.env)"
```

## Audit criteria

- permissions.defaultMode (if set) has one of the valid values: default, acceptEdits, plan, auto, dontAsk, bypassPermissions (NOT manual/custom)
- Checklist/docs no longer mention invented modes (manual, custom)
- In shared/Managed settings, permissions.disableBypassPermissionsMode is set to 'disable'
- In shared/Managed settings, permissions.disableAutoMode is set to 'disable' (auto is only Research Preview)
- The permissions block uses only the keys allow/ask/deny with syntax Tool or Tool(specifier)
- Sensitive paths (e.g. .env) protected via a Read deny rule

## Removed / softened by the verifier (not documented)
