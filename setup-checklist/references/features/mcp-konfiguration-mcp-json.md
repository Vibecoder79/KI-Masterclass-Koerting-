# MCP-Konfiguration (.mcp.json)

> **Modus:** projekt+global · **Prioritaet:** kritisch · **Status:** include-with-fixes
> Verifiziert 2026-06-02 gegen die offizielle Anthropic-Doku (code.claude.com/docs).

## MCP-Server konfigurieren (.mcp.json)

MCP-Server geben Claude Code direkten Zugriff auf externe Tools, Datenbanken und APIs (z. B. GitHub, Sentry, eine Postgres-DB) — statt staendig Daten von Hand in den Chat zu kopieren. Fuer ein pragmatisches Setup reichen drei Entscheidungen: Scope, Transport, Secrets.

**1. Scope waehlen — wo lebt der Server?** Es gibt drei Scopes. `local` (Standard) ist privat und nur fuer dich im aktuellen Projekt, gespeichert in `~/.claude.json`. `user` ist ebenfalls privat, aber ueber alle deine Projekte hinweg (ebenfalls in `~/.claude.json`). `project` ist der Team-Scope: Die Konfiguration landet in einer `.mcp.json` im Projekt-Root und wird in die Versionskontrolle eingecheckt — so haben alle im Team dieselben Tools. WARUM das wichtig ist: Team-relevante Server gehoeren nach `project` (geteilt, reproduzierbar), experimentelle oder credential-behaftete Server nach `local` (privat, nicht im Repo). Bei Namenskonflikten gewinnt `local` vor `project` vor `user` — und der gesamte Eintrag der hoechsten Quelle wird genutzt, es wird nicht ueber Scopes hinweg gemerged.

**2. Server anlegen — CLI statt Handarbeit.** Am schnellsten geht es ueber `claude mcp add`. Fuer Cloud-Dienste den HTTP-Transport nehmen (`claude mcp add --transport http <name> <url>`), fuer lokale Tools mit Systemzugriff stdio (`claude mcp add [options] <name> -- <command> [args...]`). Den Scope steuerst du mit `--scope project|local|user`. Wichtig: Alle Optionen muessen VOR dem Servernamen stehen, und `--` trennt den Namen vom eigentlichen Befehl. Die `.mcp.json` hat immer den Top-Level-Key `mcpServers`; stdio-Eintraege nutzen `command`/`args`/`env`, HTTP-Eintraege `type`/`url`/`headers` (`type` akzeptiert `http` bzw. den Alias `streamable-http`; `sse` ist deprecated).

**3. Secrets niemals hartkodieren.** In `.mcp.json` unterstuetzt Claude Code Env-Variablen-Expansion: `${API_KEY}` oder mit Fallback `${API_BASE_URL:-https://api.example.com}` — erlaubt in `command`, `args`, `env`, `url` und `headers`. So kannst du die Config bedenkenlos ins Repo committen, waehrend echte Tokens als Umgebungsvariablen bleiben (fehlt eine Variable ohne Default, schlaegt das Parsen der Config fehl). Fuer remote Server mit OAuth gehoert gar kein Token in die Config: Beim ersten 401/403 markiert Claude Code den Server, der Login laeuft ueber `/mcp` im Browser, Tokens werden sicher gespeichert (System-Keychain auf macOS bzw. Credentials-Datei) und automatisch erneuert. OAuth funktioniert mit HTTP-Servern; bei stdio-Servern gibt es keinen OAuth-Flow.

**4. Approval bewusst setzen.** Aus Sicherheitsgruenden fragt Claude Code vor der Nutzung von Projekt-Servern aus einer `.mcp.json` nach Bestaetigung — denn ein geteiltes Repo koennte einen boesartigen Server enthalten. Wenn du das fuer ein vertrauenswuerdiges Projekt steuern willst, nutze in `.claude/settings.json` (NICHT in `.mcp.json`) entweder `enabledMcpjsonServers` als Allowlist (z. B. `["github"]`) oder, wenn du wirklich alle pauschal freigibst, `enableAllProjectMcpServers: true`. Bereits getroffene Approval-Entscheidungen setzt du mit `claude mcp reset-project-choices` zurueck. WARUM lieber die Allowlist: Sie ist die leichtgewichtige, sichere Mitte — du genehmigst gezielt, was du kennst, statt blind alles.

## Referenz (maschinenlesbar)

```yaml
# ---------------------------------------------------------------
# MCP-Konfiguration (.mcp.json) — Best-Practice-Setup
# Quelle: https://code.claude.com/docs/en/mcp + /docs/en/settings
# ---------------------------------------------------------------
mcp_konfiguration:

  # Die drei Scopes bestimmen, WO ein Server gespeichert wird
  # und ob er mit dem Team geteilt wird.
  scopes:
    local:    # Standard. Nur du, nur dieses Projekt. Gespeichert in ~/.claude.json
    project:  # Team-geteilt via .mcp.json im Projekt-Root (in Versionskontrolle)
    user:     # Nur du, aber ueber ALLE Projekte. Gespeichert in ~/.claude.json
    # Praezedenz (hoechste zuerst): local > project > user > Plugins > claude.ai-Connectors
    # Ganzer Server-Eintrag der hoechsten Quelle wird genutzt; KEIN Merge ueber Scopes.

  # Server hinzufuegen via CLI (Optionen MUESSEN vor dem Namen stehen,
  # "--" trennt Servername von Befehl/Args).
  cli:
    # Remote HTTP-Server (empfohlen fuer Cloud-Dienste)
    http:  'claude mcp add --transport http <name> <url>'
    # Lokaler stdio-Server (lokaler Prozess, Systemzugriff)
    stdio: 'claude mcp add [options] <name> -- <command> [args...]'
    scope: 'claude mcp add --scope project|local|user ...'   # Standard: local
    env:   'claude mcp add --env KEY=value ...'              # Umgebungsvariablen
    json:  "claude mcp add-json <name> '<json>'"            # direkt aus JSON
    list:  'claude mcp list'                                 # alle Server zeigen
    get:   'claude mcp get <name>'                           # Details eines Servers

  # .mcp.json — Team-geteilt, Top-Level-Key ist IMMER "mcpServers".
  # Gehoert in den Projekt-Root und in die Versionskontrolle.
  mcp_json_struktur:
    # stdio-Transport (lokaler Prozess)
    stdio_beispiel: |
      {
        "mcpServers": {
          "shared-server": {
            "command": "/path/to/server",
            "args": [],
            "env": {}
          }
        }
      }
    # HTTP-Transport (remote). type akzeptiert "http"
    # (Alias "streamable-http"). SSE ("sse") ist deprecated.
    # WebSocket ist ein EIGENER Transport (type "ws"), nur via .mcp.json / add-json.
    http_beispiel: |
      {
        "mcpServers": {
          "api-server": {
            "type": "http",
            "url": "${API_BASE_URL:-https://api.example.com}/mcp",
            "headers": {
              "Authorization": "Bearer ${API_KEY}"
            }
          }
        }
      }

  # Env-Variablen-Expansion in .mcp.json: Secrets NICHT hartkodieren,
  # sondern referenzieren. Erlaubt in command, args, env, url, headers.
  env_expansion:
    syntax_var:     '${VAR}'            # Wert der Umgebungsvariable
    syntax_default: '${VAR:-default}'   # Fallback wenn VAR nicht gesetzt
    # Fehlende Variable ohne Default => Config-Parse schlaegt fehl

  # OAuth fuer remote Server: Token NICHT in Config.
  # Trigger automatisch bei 401/403; Login via /mcp im Interactive-Mode.
  # OAuth funktioniert mit HTTP-Servern (Flags gelten nur HTTP/SSE, nicht stdio).
  oauth:
    befehl: '/mcp'              # OAuth-Flow im Browser starten
    speicher: 'System-Keychain (macOS) bzw. Credentials-Datei, Auto-Refresh'
    scopes_pinnen: 'oauth.scopes (Leerzeichen-getrennter String) in .mcp.json begrenzt Berechtigungen'

  # Approval/Auto-Approve fuer Projekt-Server aus .mcp.json.
  # ACHTUNG: Diese Keys gehoeren in .claude/settings.json (NICHT in .mcp.json).
  # Standardverhalten: Claude Code fragt vor Nutzung von Projekt-Servern nach.
  approval_settings:
    enableAllProjectMcpServers: false   # boolean — ALLE Projekt-Server auto-genehmigen (pauschal)
    enabledMcpjsonServers: []           # string[] — Allowlist: nur diese Server genehmigen, z.B. ["memory","github"]
    disabledMcpjsonServers: []          # string[] — Blocklist: diese Server ablehnen, z.B. ["filesystem"]
    reset: 'claude mcp reset-project-choices'   # Approval-Entscheidungen zuruecksetzen
```

## Audit-Kriterien

- Falls eine .mcp.json existiert: Top-Level-Key heisst 'mcpServers' (kein anderer Key)
- Keine Klartext-Secrets (API-Keys/Tokens) in .mcp.json — stattdessen ${VAR}- oder ${VAR:-default}-Expansion (erlaubt in command, args, env, url, headers)
- HTTP-Server-Eintraege haben ein 'type'-Feld mit Wert 'http' oder Alias 'streamable-http'; 'sse' nur falls unvermeidbar (deprecated). Hinweis: WebSocket ist ein eigener Transport (type 'ws'), KEIN HTTP-type-Wert
- Approval-Keys (enableAllProjectMcpServers / enabledMcpjsonServers / disabledMcpjsonServers) stehen in .claude/settings.json, NICHT in .mcp.json
- Wenn enableAllProjectMcpServers=true gesetzt ist: bewusst entschieden? Sonst gezielte Allowlist via enabledMcpjsonServers bevorzugen
- Projekt-geteilte .mcp.json ist in der Versionskontrolle; lokale/experimentelle Server liegen im local-Scope (~/.claude.json), nicht im Repo

## Vom Verifizierer entfernt / abgeschwaecht (nicht belegbar)

- KEINE inhaltlich unbelegten Claims gefunden. Alle 16 gelisteten Claims sind durch die offizielle Doku belegt (mcp-Seite bzw. settings-Seite). Korrigiert wurden nur zwei Praezisierungsfehler, keine Erfindungen: (1) In einem audit_check wurde 'ws' faelschlich als gueltiger Wert des HTTP-'type'-Feldes gelistet. Laut Doku ist 'ws' ein EIGENER Transport (WebSocket), kein HTTP-type-Wert; das HTTP-'type'-Feld akzeptiert 'http' bzw. den Alias 'streamable-http'. (2) Die OAuth-Token-Speicherung wurde im skill_section auf 'Keychain' verkuerzt; die Doku sagt praeziser 'system keychain (macOS) or a credentials file' — im skill_section angeglichen (der YAML-Block war bereits korrekt).
