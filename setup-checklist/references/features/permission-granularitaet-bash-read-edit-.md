# Permission-Granularitaet (Bash/Read/Edit/WebFetch/MCP/Agent)

> **Modus:** global+projekt · **Prioritaet:** nice-to-have · **Status:** include
> Verifiziert 2026-06-02 gegen die offizielle Anthropic-Doku (code.claude.com/docs).

## Permission-Granularitaet einrichten (Bash / Read / Edit / WebFetch / MCP / Agent)

Claude Code entscheidet ueber jeden Tool-Aufruf anhand von feingranularen Permission-Regeln im Format `Tool` oder `Tool(specifier)`. Diese Regeln liegen in drei Listen -- `allow`, `ask`, `deny` -- in deinen settings-Dateien. **Warum das wichtig ist:** Die Regeln werden von Claude Code selbst durchgesetzt, nicht vom Modell. Anweisungen in der CLAUDE.md beeinflussen nur, was Claude *versucht*, nicht was tatsaechlich erlaubt ist. Eine saubere Permission-Konfiguration ist also deine echte Sicherheitsgrenze, nicht nur eine Bitte.

Merke dir die Auswertungsreihenfolge: **deny -> ask -> allow**, der erste Treffer gewinnt. deny schlaegt also immer alles. Ein blosser Tool-Name als deny (z.B. `Bash`) entfernt das Tool komplett aus Claudes Kontext; ein gescopter deny (z.B. `Bash(rm *)`) laesst das Tool verfuegbar und blockt nur passende Aufrufe.

**Schritt 1 -- Global das Gefaehrliche sperren (`~/.claude/settings.json`).** Trag rechnerweite deny-Regeln ein, die in keinem Projekt gelten sollen: Secret-Dateien (`Read(.env)`, `Read(//**/.env)`, `Read(~/.ssh/**)`) und destruktive Pushes (`Bash(git push *)` falls gewuenscht). Da deny aus jedem Scope ein allow ueberstimmt, sind diese Grenzen projektuebergreifend dicht.

**Schritt 2 -- Bash bewusst freigeben.** Bash-Regeln nutzen `*`-Wildcards an jeder Position; ein einzelnes `*` matcht auch Leerzeichen und spannt damit mehrere Argumente. Das Leerzeichen ist entscheidend: `Bash(ls *)` matcht `ls -la`, aber nicht `lsof`; `Bash(ls*)` matcht beide. Das `:*`-Suffix ist nur am Pattern-Ende aequivalent zu ` *`. **Warum vorsichtig:** Claude Code kennt Shell-Operatoren (`&&`, `||`, `;`, `|`, `|&`, `&` und Newlines) -- jeder Teilbefehl muss einzeln matchen, deshalb gibt `Bash(safe-cmd *)` keine Freigabe fuer `safe-cmd && other-cmd`. Vorsicht bei Env-Runnern wie `npx`, `docker exec`, `devbox run`: die werden nicht gestrippt, also schreib die volle Regel (`Bash(devbox run npm test)`) statt nur den Runner. Argument-Constraints (etwa curl auf eine Domain begrenzen) sind fragil und leicht zu umgehen -- fuer URL-Filter besser `curl`/`wget` per deny sperren und `WebFetch(domain:...)` erlauben.

**Schritt 3 -- Read/Edit per Pfad-Anker steuern.** Read- und Edit-Regeln folgen der gitignore-Syntax mit vier Ankern: `//path` (absolut ab Root), `~/path` (Home), `/path` (Projekt-Root), `path`/`./path` (aktuelles Verzeichnis). **Haeufige Falle:** `/Users/alice/file` ist NICHT absolut, sondern projekt-relativ -- fuer echte absolute Pfade brauchst du das doppelte `//`. `*` matcht eine Ebene, `**` rekursiv; ein blosser Dateiname matcht in jeder Tiefe (`Read(.env)` == `Read(**/.env)`).

**Schritt 4 -- WebFetch, MCP und Agent eng ziehen.** WebFetch per Domain freigeben: `WebFetch(domain:example.com)`. MCP-Tools ueber `mcp__server__tool`: `mcp__puppeteer` (oder `mcp__puppeteer__*`) erlaubt alle Tools des Servers, `mcp__puppeteer__puppeteer_navigate` nur eins -- gib lieber Einzeltools frei statt ganze Server. Subagents steuerst du mit `Agent(Name)` in der deny-Liste, z.B. `Agent(Explore)`.

**Pruefen:** Mit `/permissions` siehst du alle aktiven Regeln und aus welcher settings-Datei sie stammen. Nutze das, um Drift zwischen global und projekt aufzudecken.

## Referenz (maschinenlesbar)

```yaml
# --- Permission-Granularitaet ---------------------------------------------
# Quelle: https://code.claude.com/docs/en/permissions (live geprueft 2026-06-02)
# Platzierung: global (~/.claude/settings.json) + projekt (.claude/settings.json
#   bzw. .claude/settings.local.json). Regelformat: "Tool" oder "Tool(specifier)".
# Drei Listen: allow / ask / deny. Auswertung: deny -> ask -> allow; erster
#   Treffer gewinnt, deny gewinnt immer.
permission_granularitaet:

  grundsatz:
    # Ganzes Tool freigeben/sperren: nur Tool-Name ohne Klammern.
    # "Bash" als deny entfernt das Tool komplett aus Claudes Kontext;
    # "Bash(rm *)" laesst das Tool da und blockt nur passende Aufrufe.
    bare_tool: 'Bash | Read | Edit | WebFetch  # matcht ALLE Nutzungen'
    bash_star_equiv: 'Bash(*) ist identisch zu Bash (auch als deny: entfernt Tool aus Kontext)'

  bash:
    # Wildcard * an JEDER Position erlaubt (Anfang/Mitte/Ende).
    # Ein einzelnes * matcht auch Leerzeichen, spannt also mehrere Argumente.
    # Leerzeichen vor * erzwingt Wortgrenze: "Bash(ls *)" matcht "ls -la",
    #   aber NICHT "lsof". "Bash(ls*)" (ohne Space) matcht beide.
    # ":*"-Suffix = aequivalent zu " *", aber nur am Pattern-ENDE gueltig
    #   (in der Mitte, z.B. "git:* push", ist ":" ein literales Zeichen).
    allow_beispiel:
      - 'Bash(npm run *)'        # alle npm-run-Befehle
      - 'Bash(git commit *)'     # git commit ...
      - 'Bash(git * main)'       # z.B. git checkout main, git push origin main
      - 'Bash(* --version)'      # alles was auf --version endet
    deny_beispiel:
      - 'Bash(git push *)'       # Push blockieren
    exakt: 'Bash(npm run build)  # exakter Match, kein Wildcard'
    # Compound-Befehle: Separatoren && || ; | |& & und Newline werden erkannt.
    #   Jeder Teilbefehl muss EINZELN matchen -> "Bash(safe-cmd *)" erlaubt
    #   NICHT "safe-cmd && other-cmd".
    # Process-Wrapper werden vorab gestrippt: timeout, time, nice, nohup, stdbuf
    #   (und bare xargs ohne Flags). Env-Runner wie npx, docker exec, devbox run
    #   werden NICHT gestrippt -> volle Regel schreiben: Bash(devbox run npm test).
    # WARNUNG: Argument-Constraints sind fragil (z.B. curl-URL-Filter umgehbar).
    #   Fuer URL-Filter besser: curl/wget per deny sperren + WebFetch(domain:...).

  read_edit:
    # Folgen gitignore-Spezifikation. 4 Pfad-Typen je nach Anker:
    #   //path  = absolut ab Filesystem-Root   -> Read(//Users/alice/secrets/**)
    #   ~/path  = ab Home-Verzeichnis          -> Read(~/Documents/*.pdf)
    #   /path   = relativ zum PROJEKT-Root      -> Edit(/src/**/*.ts)
    #   path / ./path = relativ zum CWD         -> Read(*.env)
    # ACHTUNG: /Users/alice/file ist NICHT absolut, sondern projekt-relativ!
    #   Fuer absolut zwingend // verwenden.
    # *  = eine Ebene, ** = rekursiv. Bare-Filename matcht in jeder Tiefe:
    #   Read(.env) == Read(**/.env).
    deny_beispiel:
      - 'Read(.env)'             # jede .env ab CWD abwaerts
      - 'Read(//**/.env)'        # jede .env irgendwo im Filesystem
      - 'Read(~/.ssh/**)'        # SSH-Keys sperren
    allow_beispiel:
      - 'Edit(/src/**/*.ts)'     # nur TS-Edits im Projekt-src
      - 'Read(src/**)'           # Lesen ab <cwd>/src/
    # Edit-Regeln gelten fuer alle eingebauten Datei-Edit-Tools.
    #   Read-Regeln werden best-effort auch auf Grep/Glob/@file angewandt.
    # Read/Edit-deny gilt auch fuer cat/head/tail/sed in Bash, ABER NICHT
    #   fuer fremde Subprozesse (Python/Node-Script) -> dafuer Sandbox noetig.

  webfetch:
    allow_beispiel:
      - 'WebFetch(domain:example.com)'  # nur Fetches an example.com
    # Hinweis: WebFetch allein verhindert keinen Netzzugriff -- bei erlaubtem
    #   Bash kann Claude weiter via curl/wget jede URL erreichen.

  mcp:
    # Syntax mcp__server__tool. Wildcard funktioniert.
    server_alle: 'mcp__puppeteer        # jedes Tool des puppeteer-Servers'
    server_wildcard: 'mcp__puppeteer__* # ebenfalls alle Tools des Servers'
    einzeltool: 'mcp__puppeteer__puppeteer_navigate  # nur dieses Tool'

  agent:
    # Subagents steuern via Agent(AgentName), typ. in deny.
    deny_beispiel:
      - 'Agent(Explore)'         # Explore-Subagent deaktivieren
    weitere: 'Agent(Plan) | Agent(my-custom-agent)'

  precedence:
    # Settings-Reihenfolge (hoechste zuerst); deny aus JEDEM Scope schlaegt allow:
    #   1) Managed settings  2) CLI-Argumente  3) .claude/settings.local.json
    #   4) .claude/settings.json  5) ~/.claude/settings.json
    # Einmal denied auf irgendeiner Ebene -> keine andere Ebene kann erlauben.
    hinweis: 'deny -> ask -> allow; erster Treffer gewinnt'
    pruefen: '/permissions zeigt alle Regeln + Quell-settings.json-Datei'
```

## Audit-Kriterien

- deny-Liste enthaelt Secret-Schutz: Read(.env) bzw. Read(//**/.env) und Read(~/.ssh/**)
- Bash-allow-Regeln nutzen korrekte Wortgrenze (Leerzeichen vor * oder :*-Suffix nur am Ende)
- Keine Argument-Constraint-Regeln fuer Netz-Tools (curl/wget) als allow -- stattdessen WebFetch(domain:...)
- Read/Edit-Pfade nutzen den richtigen Anker (// fuer absolut, nicht /Users/...)
- MCP-Freigaben so eng wie moeglich (Einzeltool mcp__server__tool statt ganzer Server, wo sinnvoll)
- Env-Runner-Befehle (npx/docker exec/devbox run) haben volle Regeln inkl. Inner-Command, nicht nur den Runner
- deny-first-Logik verstanden: kein versehentliches allow, das ein noetiges deny ueberschreiben soll (deny gewinnt ohnehin)
