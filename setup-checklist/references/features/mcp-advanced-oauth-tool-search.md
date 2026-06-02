# MCP Advanced (OAuth, Tool Search)

> **Modus:** global+projekt · **Prioritaet:** nice-to-have · **Status:** include-with-fixes
> Verifiziert 2026-06-02 gegen die offizielle Anthropic-Doku (code.claude.com/docs).

## MCP Advanced: OAuth, Tool Search und Limits

Remote-MCP-Server (Sentry, GitHub, Notion etc.) verlangen meist eine Anmeldung. Claude Code unterstuetzt OAuth 2.0: nach dem `claude mcp add` einmal `/mcp` in Claude Code ausfuehren und den Browser-Login abschliessen. Die Tokens werden danach sicher abgelegt und automatisch erneuert. Ueber das `/mcp`-Menue laesst sich die Anmeldung mit "Clear authentication" auch widerrufen. WARUM: So landen keine langlebigen Bearer-Tokens in `.mcp.json` oder der Versionskontrolle. Verlangt ein Server eine fest registrierte Redirect-URI, fixiere den Port mit `--callback-port 8080` (Form `http://localhost:PORT/callback`); dieses Flag laesst sich allein (mit Dynamic Client Registration) oder zusammen mit `--client-id` nutzen. Server ohne Dynamic Client Registration brauchen vorkonfigurierte Credentials via `--client-id` und `--client-secret` (das Secret wird maskiert abgefragt und im System-Keychain bzw. einem Credentials-File abgelegt, nicht in der Config; alternativ via `MCP_CLIENT_SECRET` fuer CI). Diese Flags gelten nur fuer HTTP- und SSE-Transporte und haben keine Wirkung auf stdio-Server. Sicherheits-Teams koennen die angeforderten Rechte ueber `oauth.scopes` im `.mcp.json` auf eine freigegebene Teilmenge einschraenken (space-separierter String, hat Vorrang vor `authServerMetadataUrl` und der `/.well-known`-Discovery).

Tool Search ist standardmaessig aktiv und sollte aktiv bleiben. Statt alle MCP-Tool-Definitionen beim Sessionstart in den Context zu laden, werden sie verzoegert und erst bei Bedarf ueber ein Suchwerkzeug gefunden. WARUM: Jeder zusaetzliche MCP-Server kostet so kaum noch Context-Fenster, und nur die tatsaechlich genutzten Tools belegen Platz. Steuerung ueber die Umgebungsvariable `ENABLE_TOOL_SEARCH` (im `env`-Block der `settings.json` oder als Shell-Variable): unset/`true` = alles deferred, `auto` bzw. `auto:N` = Schwellenwert-Modus (Tools upfront laden nur wenn sie in N Prozent des Context passen, Default 10%, Rest deferred), `false` = alles vorab laden. Hinweis: `ENABLE_TOOL_SEARCH=true` sendet den Beta-Header auch auf Vertex/Proxy, Requests schlagen dann aber auf Vertex-Modellen vor Sonnet 4.5/Opus 4.5 oder auf Proxies ohne `tool_reference`-Support fehl. Tool Search braucht generell ein Modell mit `tool_reference`-Unterstuetzung (Sonnet 4+ / Opus 4+, kein Haiku). Einzelne Server, deren Tools auf jeder Runde gebraucht werden, kann man mit `alwaysLoad: true` im Server-Eintrag von der Verzoegerung ausnehmen (ab v2.1.121) — sparsam einsetzen, da das wieder Context kostet und den Start bis zum Connect blockiert (max. 5-Sekunden-Connect-Timeout).

Bei grossen Tool-Outputs warnt Claude Code ab 10.000 Token; das Default-Maximum liegt bei 25.000 Token. Fuer Server, die grosse Datensaetze oder Reports liefern, das Limit ueber `MAX_MCP_OUTPUT_TOKENS` anheben (z.B. `MAX_MCP_OUTPUT_TOKENS=50000`). Der Server-Startup-Timeout laesst sich mit `MCP_TIMEOUT` setzen (z.B. `MCP_TIMEOUT=10000 claude` fuer 10 Sekunden). Das Tool-Ausfuehrungs-Timeout steuert `MCP_TOOL_TIMEOUT` global; pro Server hat ein `timeout`-Feld (in Millisekunden) im `.mcp.json`-Eintrag Vorrang, z.B. `"timeout": 600000` fuer zehn Minuten — Werte unter 1000 werden auf eine Sekunde gefloort. Diese drei Variablen sind auf der mcp-Seite dokumentiert (nicht auf der env-vars-Seite).

## Referenz (maschinenlesbar)

```yaml
# MCP Advanced — OAuth, Tool Search, Output- und Timeout-Limits
# Platzierung: global (Env-Vars via settings.json env) + projekt (.mcp.json)
# Quelle: https://code.claude.com/docs/en/mcp (live geprueft 2026-06-02)
mcp_advanced:

  # --- OAuth fuer Remote-Server (HTTP/SSE) ---
  oauth:
    # Authentifizierung bei OAuth-2.0-Servern: nach `claude mcp add` den
    # Befehl /mcp in Claude Code ausfuehren und Browser-Login abschliessen.
    # Tokens werden sicher gespeichert und automatisch refreshed.
    auth_command: "/mcp"                 # Login + "Clear authentication" zum Widerruf
    # Fester Callback-Port, falls Server eine vorab registrierte Redirect-URI
    # (http://localhost:PORT/callback) verlangt. Nutzbar allein (mit Dynamic
    # Client Registration) oder zusammen mit --client-id:
    callback_port_flag: "--callback-port 8080"
    # Server ohne Dynamic Client Registration: vorkonfigurierte Credentials.
    # --client-secret fragt maskiert nach dem Secret (oder MCP_CLIENT_SECRET als Env).
    preconfigured_creds: "claude mcp add --transport http --client-id <id> --client-secret --callback-port 8080 <name> <url>"
    # Hinweis: --client-id/--client-secret/--callback-port gelten nur fuer
    # HTTP- und SSE-Transporte; keine Wirkung auf stdio-Server.
    # Optionale oauth-Felder im .mcp.json (Server-Eintrag):
    json_oauth_fields:
      clientId: "your-client-id"
      callbackPort: 8080
      # Scopes auf vom Security-Team freigegebene Teilmenge pinnen
      # (space-separierter String, hat Vorrang vor authServerMetadataUrl
      # und vor Discovery via /.well-known):
      scopes: "channels:read chat:write search:read"
      # Discovery-Kette ueberschreiben (nur https://, ab v2.1.64):
      authServerMetadataUrl: "https://auth.example.com/.well-known/openid-configuration"

  # --- Tool Search (Default an) ---
  # Reduziert Context-Verbrauch: MCP-Tool-Definitionen werden verzoegert geladen
  # und erst bei Bedarf via ToolSearch entdeckt. Default = aktiv.
  # Benoetigt Modell mit tool_reference (Sonnet 4+/Opus 4+; kein Haiku).
  tool_search:
    env_var: "ENABLE_TOOL_SEARCH"        # in settings.json env oder als Shell-Env
    values:
      unset: "Alle MCP-Tools deferred, on demand (Default). Faellt auf Upfront-Laden zurueck auf Vertex AI oder bei nicht-first-party ANTHROPIC_BASE_URL"
      "true": "Alle deferred; Beta-Header wird auch auf Vertex/Proxy gesendet. Requests SCHLAGEN FEHL auf Vertex-Modellen vor Sonnet 4.5/Opus 4.5 oder auf Proxies ohne tool_reference-Support"
      "auto": "Schwellenwert: Tools upfront laden wenn sie in <10% Context passen, Rest deferred"
      "auto:N": "Schwellenwert mit eigenem Prozentsatz (N = 0-100), z.B. auto:5"
      "false": "Alle Tools upfront geladen, kein Deferral"
    # Einzelnen Server immer sichtbar halten (im .mcp.json-Server-Eintrag):
    always_load: "alwaysLoad: true"      # ab v2.1.121; blockiert Start bis Connect (max 5s)
    # ToolSearch-Tool komplett verbieten (settings.json):
    deny_tool: '{ "permissions": { "deny": ["ToolSearch"] } }'

  # --- Output- und Timeout-Limits (Env-Vars) ---
  # Hinweis: Diese drei Variablen sind auf der mcp-Seite belegt, erscheinen aber
  # NICHT auf der env-vars-Seite (Stand 2026-06-02).
  limits:
    # Warnung ab 10.000 Token Tool-Output; Default-Maximum 25.000 Token.
    MAX_MCP_OUTPUT_TOKENS: 50000         # erhoehen bei grossen Datenmengen/Reports
    # Startup-Timeout fuer MCP-Server in ms (nur Beispiel, kein dokumentierter Default):
    MCP_TIMEOUT: 10000                   # z.B. MCP_TIMEOUT=10000 claude (= 10s)
    # Globales Tool-Ausfuehrungs-Timeout; pro-Server via .mcp.json "timeout" (ms)
    # ueberschreibbar. Werte unter 1000 werden auf 1 Sekunde gefloort.
    MCP_TOOL_TIMEOUT: 600000             # nur Beispiel; pro-Server "timeout": 600000 hat Vorrang
```

## Audit-Kriterien

- OAuth-Server: Sind Tokens nur ueber /mcp authentifiziert und NICHT als statische Bearer-Header in .mcp.json/Versionskontrolle abgelegt?
- Tool Search: Ist ENABLE_TOOL_SEARCH nicht versehentlich auf false gesetzt (Default-Verhalten = deferred bleibt erhalten)?
- alwaysLoad: true nur fuer wenige, wirklich auf jeder Runde benoetigte Server gesetzt (kein Context-Verschwendung)?
- Verwendetes Modell unterstuetzt tool_reference (Sonnet 4+/Opus 4+, kein Haiku), falls ENABLE_TOOL_SEARCH=true erzwungen wird? (Auf Vertex zusaetzlich: Sonnet 4.5+/Opus 4.5+)
- oauth.scopes auf freigegebene Teilmenge gepinnt, wenn der Server mehr Scopes anbietet als noetig?
- MAX_MCP_OUTPUT_TOKENS bei Servern mit grossen Outputs bewusst gesetzt (Default 25.000, Warnung ab 10.000)?

## Vom Verifizierer entfernt / abgeschwaecht (nicht belegbar)

- env-vars-Seite-Frage geklaert: MAX_MCP_OUTPUT_TOKENS, MCP_TIMEOUT und MCP_TOOL_TIMEOUT erscheinen NICHT auf https://code.claude.com/docs/en/env-vars (per WebFetch bestaetigt). Sie sind aber alle drei woertlich auf der mcp-Seite belegt. Der Entwurfs-Claim #15 (verified:false) ist damit korrekt; kein Inhalt muss entfernt werden, nur die Quellenangabe praezisiert.
- Kein dokumentierter Default-Zahlenwert fuer MCP_TIMEOUT (Startup) und MCP_TOOL_TIMEOUT (global). Die Doku nennt nur Beispielwerte 10000 bzw. 600000. Die YAML-Werte sind daher als Beispiel und nicht als Default zu fuehren (im Entwurf bereits so gekennzeichnet, beibehalten).
- Praezisierung statt Entfernung: Die ENABLE_TOOL_SEARCH=true-Beschreibung 'Beta-Header auch auf Vertex/Proxy' war unvollstaendig. Die Doku ergaenzt, dass Requests auf Vertex-Modellen vor Sonnet 4.5 / Opus 4.5 bzw. auf Proxies ohne tool_reference-Unterstuetzung FEHLSCHLAGEN. Korrigiert.
