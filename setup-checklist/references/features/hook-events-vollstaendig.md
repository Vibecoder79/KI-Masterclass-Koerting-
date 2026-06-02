# Hook-Events (vollstaendig)

> **Modus:** projekt+global · **Prioritaet:** kritisch · **Status:** include-with-fixes
> Verifiziert 2026-06-02 gegen die offizielle Anthropic-Doku (code.claude.com/docs).

## Hook-Events kennen und gezielt setzen

Hooks sind benutzerdefinierte Handler (Typ `command`, `http`, `mcp_tool`, `prompt` oder `agent`), die Claude Code an festen Punkten im Lebenszyklus automatisch ausfuehrt. Sie werden unter dem Key `"hooks"` in `settings.json` konfiguriert — global unter `~/.claude/settings.json` (alle Projekte, nur lokal auf deiner Maschine), projektlokal teilbar unter `.claude/settings.json` (committbar) oder privat unter `.claude/settings.local.json` (gitignored). Daneben kennt die Doku weitere Quellen: Managed-Policy-Settings (org-weit), Plugin-`hooks.json` und Skill-/Agent-Frontmatter. WARUM das wichtig ist: Hooks sind der Mechanismus fuer deterministisches, erzwungenes Verhalten — der Harness fuehrt sie aus, nicht das Modell. Eine Regel in CLAUDE.md ist eine Bitte; ein Hook ist eine Garantie.

Schritt 1 — Verstehe, welche Events es gibt. Die Doku listet (Stand Abruf 2026-06-02) genau 30 Events. Gruppen: Session-Lebenszyklus (`SessionStart`, `Setup`, `SessionEnd`), Prompt-Verarbeitung (`UserPromptSubmit`, `UserPromptExpansion`), Tool-Aufrufe (`PreToolUse`, `PermissionRequest`, `PermissionDenied`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`), Stop (`Stop`, `StopFailure`), Subagents/Tasks/Teams (`SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `TeammateIdle`), Kontext/Config/Dateien (`InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `FileChanged`), Worktrees (`WorktreeCreate`, `WorktreeRemove`), Kompaktierung (`PreCompact`, `PostCompact`), MCP-Elicitation (`Elicitation`, `ElicitationResult`), Anzeige/Benachrichtigung (`Notification`, `MessageDisplay`).

Schritt 2 — Waehle blockende vs. nur beobachtende Events bewusst. Die Doku fuehrt eine eigene Spalte "Can block?". Blockieren KOENNEN: `UserPromptSubmit`, `UserPromptExpansion`, `PreToolUse`, `PermissionRequest`, `PostToolBatch`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `Stop`, `TeammateIdle`, `ConfigChange`, `WorktreeCreate`, `PreCompact`, `Elicitation`, `ElicitationResult`. Rein informativ (ideal fuer Logging/Automatik ohne Blockierrisiko): u.a. `SessionStart`, `Setup`, `SessionEnd`, `PostToolUse`, `PostToolUseFailure`, `Notification`, `MessageDisplay`, `SubagentStart`, `StopFailure`, `InstructionsLoaded`, `CwdChanged`, `FileChanged`, `WorktreeRemove`, `PostCompact`, `PermissionDenied`. Haeufigste Guardrails in der Praxis: `PreToolUse` (verhindert riskante Tool-Aufrufe wie `rm -rf` oder Schreibzugriff auf geschuetzte Pfade), `UserPromptSubmit` (validiert/blockt Prompts vor Verarbeitung), `Stop` (haelt Claude an, bevor die Antwort als fertig gilt).

Schritt 3 — Verstehe den Block-Mechanismus. Exit-Code 0 = Erfolg (Claude parst stdout auf JSON-Output-Felder; nur bei Exit 0 wird JSON verarbeitet). Exit-Code 2 = blockierender Fehler (stdout und JSON werden ignoriert, stderr geht als Fehlermeldung an Claude zurueck; die genaue Wirkung haengt vom Event ab). Jeder andere Non-Zero-Exit = nicht-blockierender Fehler (nur geloggt, Ausfuehrung laeuft weiter). ACHTUNG laut Doku-Warnung: Fuer die meisten Events blockiert NUR Exit-Code 2 — Exit-Code 1 ist NICHT blockierend, obwohl 1 der uebliche Unix-Fehlercode ist. Fuer Policy-Enforcement also zwingend `exit 2` verwenden (oder bei Exit 0 das passende Entscheidungs-JSON ausgeben). Fuer reine Seiteneffekte (Notify, Log, Format) Exit 0 ohne Entscheidung.

Schritt 4 — Setze den `matcher` korrekt. `"*"`, leer oder weggelassen = alle. Nur Buchstaben/Ziffern/`_`/`|` werden als exakter String bzw. `|`-getrennte Liste verstanden (z.B. `"Edit|Write"`); jedes andere Zeichen macht den Matcher zu einer JavaScript-Regex (z.B. `"mcp__.*"`). Bei Tool-Events filtert der matcher auf den Tool-Namen. Wichtig fuer MCP: `mcp__<server>__.*` braucht das abschliessende `.*` — `mcp__memory` allein gilt als exakter String und matcht kein Tool. Nicht jedes Event unterstuetzt einen matcher (z.B. `UserPromptSubmit`, `Stop`, `CwdChanged`); `FileChanged` nutzt eine eigene Watch-Logik mit literalen Dateinamen.

## Referenz (maschinenlesbar)

```yaml
# ============================================================
# Hook-Events (Claude Code) — Referenz
# Quelle: https://code.claude.com/docs/en/hooks (Abruf 2026-06-02, vollstaendig)
# Platzierung: projekt (.claude/settings.json) + global (~/.claude/settings.json)
# Konfiguriert unter dem Key "hooks" in settings.json
# Blocken: Fuer die meisten Events blockiert NUR Exit-Code 2 (Exit 1 = nicht-blockierend!).
#          Alternativ JSON-Output bei Exit 0 (event-spezifische Felder).
# ============================================================

hooks:
  # ---- Session-Lebenszyklus ----
  SessionStart:        # feuert wenn Session beginnt/wiederaufnimmt — KEIN Block (stdout wird Kontext)
  Setup:               # feuert bei --init-only / --init / --maintenance (-p-Modus, CI) — KEIN Block
  SessionEnd:          # feuert wenn Session terminiert — KEIN Block

  # ---- Prompt-Verarbeitung ----
  UserPromptSubmit:    # feuert wenn Nutzer Prompt absendet, vor Verarbeitung — KANN blocken (Exit 2 loescht Prompt)
  UserPromptExpansion: # feuert wenn getipptes Command zu Prompt expandiert — KANN blocken (Exit 2 blockt Expansion)

  # ---- Tool-Aufrufe ----
  PreToolUse:          # feuert vor Tool-Ausfuehrung — KANN blocken (Exit 2 blockt Tool-Call)
  PermissionRequest:   # feuert wenn Permission-Dialog erscheint — KANN blocken (Exit 2 verweigert Permission)
  PermissionDenied:    # feuert wenn Auto-Mode-Klassifier Tool ablehnt — KEIN Block; JSON hookSpecificOutput.retry:true moeglich
  PostToolUse:         # feuert nach erfolgreichem Tool-Call — KEIN Block (zeigt stderr an Claude)
  PostToolUseFailure:  # feuert nach fehlgeschlagenem Tool-Call — KEIN Block (zeigt stderr an Claude)
  PostToolBatch:       # feuert nach Abschluss eines parallelen Tool-Batches, vor naechstem Model-Call — KANN blocken (Exit 2 stoppt Loop)

  # ---- Anzeige / Benachrichtigung ----
  Notification:        # feuert wenn Claude Code eine Notification sendet — KEIN Block
  MessageDisplay:      # feuert waehrend Assistant-Text angezeigt wird — KEIN Block (Originaltext wird gezeigt)

  # ---- Subagents / Tasks / Teams ----
  SubagentStart:       # feuert wenn ein Subagent gespawnt wird — KEIN Block
  SubagentStop:        # feuert wenn ein Subagent fertig ist — KANN blocken (Exit 2 verhindert Subagent-Stop)
  TaskCreated:         # feuert wenn ein Task via TaskCreate erstellt wird — KANN blocken (Exit 2 rollt Erstellung zurueck)
  TaskCompleted:       # feuert wenn ein Task als erledigt markiert wird — KANN blocken (Exit 2 verhindert Completion)
  TeammateIdle:        # feuert wenn ein Agent-Team-Teammate gleich idle geht — KANN blocken (Exit 2 verhindert Idle)

  # ---- Stop ----
  Stop:                # feuert wenn Claude mit der Antwort fertig ist — KANN blocken (Exit 2 setzt Konversation fort)
  StopFailure:         # feuert wenn der Turn wegen API-Fehler endet — KEIN Block (Output/Exit-Code ignoriert)

  # ---- Kontext / Config / Dateien ----
  InstructionsLoaded:  # feuert wenn CLAUDE.md oder .claude/rules/*.md in Kontext geladen wird — KEIN Block (Exit-Code ignoriert)
  ConfigChange:        # feuert wenn sich eine Config-Datei waehrend der Session aendert — KANN blocken (Exit 2, ausser policy_settings)
  CwdChanged:          # feuert wenn sich das Arbeitsverzeichnis aendert — KEIN Block (kein matcher)
  FileChanged:         # feuert wenn beobachtete Datei sich auf Platte aendert — KEIN Block (matcher = literale Dateinamen)

  # ---- Worktrees ----
  WorktreeCreate:      # feuert wenn Worktree via --worktree / isolation:"worktree" erstellt wird — KANN blocken (jeder Non-Zero-Exit)
  WorktreeRemove:      # feuert wenn Worktree entfernt wird — KEIN Block (Fehler nur im Debug geloggt)

  # ---- Kompaktierung ----
  PreCompact:          # feuert vor Kontext-Kompaktierung — KANN blocken (Exit 2 blockt Kompaktierung)
  PostCompact:         # feuert nach abgeschlossener Kompaktierung — KEIN Block

  # ---- MCP Elicitation ----
  Elicitation:         # feuert wenn MCP-Server waehrend Tool-Call Nutzer-Input anfordert — KANN blocken (Exit 2 verweigert)
  ElicitationResult:   # feuert nachdem Nutzer auf MCP-Elicitation geantwortet hat, vor Ruecksendung — KANN blocken (Exit 2 = decline)

# ------------------------------------------------------------
# Struktur eines Hook-Eintrags (settings.json):
#   "hooks": { "<EventName>": [ { "matcher": "<pattern>",
#              "hooks": [ { "type": "command|http|mcp_tool|prompt|agent", ... } ] } ] }
# matcher: "*"/""/weggelassen = alle; nur Buchstaben/Ziffern/_/| = exakt oder |-Liste; sonst JavaScript-Regex
# Bei Tool-Events (PreToolUse/PostToolUse/PostToolUseFailure/PermissionRequest/PermissionDenied)
#   filtert matcher auf den Tool-Namen (z.B. Bash, Edit|Write, mcp__<server>__.* — '.*' ist Pflicht fuer MCP-Wildcards)
# Manche Events haben keinen matcher (z.B. UserPromptSubmit, Stop, CwdChanged); FileChanged folgt eigener Watch-Logik.
# Weitere Scopes laut Doku: Managed Policy (org-weit), Plugin (hooks.json), Skill-/Agent-Frontmatter.
# ------------------------------------------------------------
```

## Audit-Kriterien

- settings.json: Existiert ueberhaupt ein 'hooks'-Key (global ODER projekt)? Falls produktive Guardrails erwartet werden, aber keiner existiert -> Hinweis.
- Jeder konfigurierte Event-Name ist ein in der offiziellen Doku belegter Event (kein Tippfehler/erfundener Name wie 'PreTool' statt 'PreToolUse'). Referenz: die 30 dokumentierten Events.
- Blockierende Guardrail-Hooks (z.B. PreToolUse fuer rm -rf / geschuetzte Pfade) nutzen Exit-Code 2 (oder das event-spezifische Entscheidungs-JSON bei Exit 0) — KEIN Exit 1: laut Doku blockiert Exit 1 NICHT. Ein reiner Log-Befehl ohne Exit 2 ist wirkungslos als Guardrail.
- Tool-Events (PreToolUse/PostToolUse/PostToolUseFailure/PermissionRequest/PermissionDenied) haben einen sinnvollen matcher auf den Tool-Namen statt blind '*' wenn nur bestimmte Tools gemeint sind; MCP-Wildcards enden auf '.*'.
- Hook-Scope passt zur Absicht: maschinenweite Regeln in ~/.claude/settings.json, projektspezifische teilbare Regeln in .claude/settings.json, Geheimnis-/Maschinen-spezifisches in .claude/settings.local.json (gitignored).
- Ein Guardrail-Event mit Can-block=No (z.B. PostToolUse, PermissionDenied, Notification) wird NICHT als Blocker missverstanden — diese koennen die Aktion nicht verhindern, nur reagieren/loggen.

## Vom Verifizierer entfernt / abgeschwaecht (nicht belegbar)

- Keine erfundenen Event-Namen gefunden — alle 30 Events stehen woertlich in der offiziellen Doku. Korrekturen betreffen nur unvollstaendige/irrefuehrende Block-Annotationen im Entwurf, nicht erfundene Inhalte:
- ENTWURF-FEHLER (korrigiert, nicht entfernt): YAML-Kommentar 'SubagentStop: feuert wenn ein Subagent fertig ist' ohne Block-Hinweis — Doku: KANN blocken (Exit 2 verhindert Subagent-Stop).
- ENTWURF-FEHLER (korrigiert): 'TaskCreated' und 'TaskCompleted' ohne Block-Hinweis gelistet — Doku: beide KOENNEN blocken (Exit 2 rollt Task-Erstellung zurueck bzw. verhindert Completion).
- ENTWURF-FEHLER (korrigiert): 'TeammateIdle' ohne Block-Hinweis — Doku: KANN blocken (Exit 2 verhindert Idle-Gehen).
- ENTWURF-FEHLER (korrigiert): 'ConfigChange' ohne Block-Hinweis — Doku: KANN blocken (Exit 2 blockt Config-Aenderung, ausser policy_settings).
- ENTWURF-FEHLER (korrigiert): 'PreCompact' ohne Block-Hinweis — Doku: KANN blocken.
- ENTWURF-FEHLER (korrigiert): 'Elicitation'/'ElicitationResult' ohne Block-Hinweis — Doku: beide KOENNEN blocken.
- ENTWURF-FEHLER (korrigiert): 'PostToolBatch' ohne Block-Hinweis — Doku: KANN blocken (Exit 2 stoppt den agentischen Loop vor naechstem Model-Call).
- ENTWURF-FEHLER (korrigiert): 'WorktreeCreate' ohne Block-Hinweis — Doku: KANN blocken (jeder Non-Zero-Exit laesst Worktree-Erstellung fehlschlagen).
- ENTWURF-SCHWAECHE (korrigiert): skill_section Schritt 2 nannte nur PreToolUse/UserPromptSubmit/Stop als blockierend — die Doku-Spalte 'Can block?' weist deutlich mehr blockierende Events aus (s.o.); Beschreibung erweitert.
- NICHT VERBATIM BELEGT (abgeschwaecht): Der exakte JSON-Feldname 'permissionDecision: deny' fuer PreToolUse war im abgerufenen Doku-Inhalt nicht woertlich sichtbar (nur Exit-2-Mechanik und 'hookSpecificOutput' generisch). Audit-Check entsprechend auf die belegte Exit-2-Mechanik umformuliert.
