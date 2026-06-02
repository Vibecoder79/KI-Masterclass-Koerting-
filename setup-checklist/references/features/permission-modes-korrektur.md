# Permission-Modes (Korrektur)

> **Modus:** global · **Prioritaet:** kritisch · **Status:** include
> Verifiziert 2026-06-02 gegen die offizielle Anthropic-Doku (code.claude.com/docs).

## Permission-Modes korrekt setzen

Claude Code steuert ueber sogenannte Permission-Modes, wie streng vor Tool-Aufrufen nachgefragt wird. Der Standardmodus wird in den Settings-Dateien (User, Projekt oder Managed) ueber den Key `permissions.defaultMode` gesetzt.

WICHTIG (Korrektur): Es gibt keine Modi `manual` oder `custom`. Die offiziell gueltigen Werte sind genau diese sechs:

- `default` — fragt bei Erstnutzung jedes Tools nach. Sicherer Standard fuer den taeglichen Einsatz.
- `acceptEdits` — akzeptiert Datei-Edits und gaengige Filesystem-Befehle (mkdir, touch, mv, cp ...) im Arbeitsverzeichnis oder `additionalDirectories` automatisch. Praktisch fuer fokussierte Implementier-Sessions.
- `plan` — Plan-Modus: Claude darf nur lesen und read-only Shell-Befehle ausfuehren, aber keine Quelldateien aendern. Ideal zum Explorieren und Planen, bevor etwas angefasst wird.
- `auto` — Auto-Approve mit Hintergrund-Safety-Checks (Research Preview). Mit Vorsicht einsetzen.
- `dontAsk` — lehnt Tools automatisch ab, ausser sie sind vorab via `/permissions` oder `permissions.allow` freigegeben. Restriktiver Allowlist-Betrieb.
- `bypassPermissions` — ueberspringt ALLE Prompts. Nur in isolierten Umgebungen (Container/VM) nutzen. `rm -rf /` und `rm -rf ~` loesen als Circuit Breaker weiterhin einen Prompt aus.

WARUM: Der Modus entscheidet ueber die Balance aus Tempo und Sicherheit. `default` schuetzt vor versehentlichen Schreibzugriffen, `plan` trennt Denken von Handeln, `bypassPermissions` ist bewusst nur fuer Wegwerf-Umgebungen gedacht. In geteilten oder Managed-Settings sollte man `bypassPermissions` und `auto` aktiv sperren: `permissions.disableBypassPermissionsMode: "disable"` bzw. `permissions.disableAutoMode: "disable"`.

Ergaenzend regeln die Listen `permissions.allow`, `permissions.ask` und `permissions.deny`, welche Tools/Befehle erlaubt, nachgefragt oder verboten sind. Auswertung erfolgt in der Reihenfolge deny -> ask -> allow; die erste passende Regel gewinnt, deny hat immer Vorrang. Regel-Syntax: `Tool` oder `Tool(specifier)`, z.B. `Bash(git push *)` oder `Read(.env)`.

## Referenz (maschinenlesbar)

```yaml
# Permission-Modes & Berechtigungsregeln (Claude Code)
# Quelle: https://code.claude.com/docs/en/permissions (Stand 2026-06-02)
permission_modes:
  # KORREKTUR: Die echten defaultMode-Werte sind NICHT manual/auto/custom.
  # Gesetzt wird der Standardmodus ueber den Settings-Key "permissions.defaultMode".
  setting_key: permissions.defaultMode   # in settings.json (User/Projekt/Managed)
  werte:
    default: "Standardverhalten: fragt bei Erstnutzung jedes Tools nach Erlaubnis"
    acceptEdits: "Akzeptiert Datei-Edits + gaengige FS-Befehle (mkdir, touch, mv, cp ...) automatisch fuer Pfade im Arbeitsverzeichnis / additionalDirectories"
    plan: "Plan-Modus: Claude liest Dateien und fuehrt nur lesende Shell-Befehle aus, aendert KEINE Quelldateien"
    auto: "Auto-Approve mit Hintergrund-Safety-Checks (prueft ob Aktion zur Anfrage passt). Derzeit Research Preview"
    dontAsk: "Auto-Deny: lehnt Tools ab, ausser sie sind via /permissions oder permissions.allow vorab freigegeben"
    bypassPermissions: "Ueberspringt ALLE Permission-Prompts. rm -rf / bzw. ~ loesen weiterhin einen Prompt aus (Circuit Breaker). Nur in isolierten Umgebungen (Container/VM) nutzen"
  # Modi sperren (am besten in Managed Settings):
  sperren:
    permissions.disableBypassPermissionsMode: "disable"   # verbietet bypassPermissions
    permissions.disableAutoMode: "disable"                 # verbietet auto-Modus

permissions_regeln:
  # Auswertungsreihenfolge: deny -> ask -> allow (erste passende Regel gewinnt, deny hat Vorrang)
  allow: "Tool ohne manuelle Bestaetigung erlauben"
  ask:   "Bei jeder Nutzung des Tools nachfragen"
  deny:  "Tool-Nutzung verbieten (gewinnt immer)"
  syntax: "Tool  ODER  Tool(specifier)"   # z.B. Bash, Bash(npm run *), Read(./.env), WebFetch(domain:example.com)
  beispiel:
    permissions:
      allow:
        - "Bash(npm run *)"
        - "Bash(git commit *)"
      deny:
        - "Bash(git push *)"
        - "Read(.env)"
```

## Audit-Kriterien

- permissions.defaultMode (falls gesetzt) hat einen der gueltigen Werte: default, acceptEdits, plan, auto, dontAsk, bypassPermissions (NICHT manual/custom)
- Checkliste/Doku nennt keine erfundenen Modi mehr (manual, custom)
- In geteilten/Managed-Settings ist permissions.disableBypassPermissionsMode auf 'disable' gesetzt
- In geteilten/Managed-Settings ist permissions.disableAutoMode auf 'disable' gesetzt (auto ist nur Research Preview)
- permissions-Block nutzt nur die Schluessel allow/ask/deny mit Syntax Tool oder Tool(specifier)
- Sensible Pfade (z.B. .env) per Read-deny-Regel geschuetzt
