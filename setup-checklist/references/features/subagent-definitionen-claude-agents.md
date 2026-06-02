# Subagent-Definitionen (.claude/agents/)

> **Modus:** projekt · **Prioritaet:** kritisch · **Status:** include-with-fixes
> Verifiziert 2026-06-02 gegen die offizielle Anthropic-Doku (code.claude.com/docs).

## Subagent-Definitionen (.claude/agents/)

Wiederkehrende Spezial-Aufgaben — Code-Review, Recherche, Test-Laeufe — lagerst du in eigene Sub-Agent-Definitionen aus. Lege diese als Markdown-Dateien unter `.claude/agents/` im Projekt ab und checke sie in die Versionskontrolle ein, damit das ganze Team denselben Reviewer oder Researcher nutzt. User-weite Sub-Agents, die in allen Projekten verfuegbar sein sollen, gehoeren stattdessen nach `~/.claude/agents/`. Am bequemsten erstellst du sie mit dem Befehl `/agents`; manuell angelegte Dateien werden erst nach einem Session-Neustart geladen.

WARUM: Jeder Sub-Agent laeuft in einem eigenen Kontext-Fenster mit eigenem System-Prompt und eigenen Tool-Rechten. Das haelt verbose Output (Suchergebnisse, Logs, Datei-Inhalte) aus deiner Hauptkonversation heraus — nur die Zusammenfassung kommt zurueck. Gleichzeitig kannst du Rechte einschraenken (z.B. Reviewer ohne `Write`/`Edit`) und Kosten senken, indem du Routine-Aufgaben auf schnellere Modelle wie Haiku leitest.

Aufbau einer Datei: YAML-Frontmatter oben, der Body darunter ist der System-Prompt. Pflicht sind nur zwei Felder — `name` (eindeutig, lowercase, Bindestriche; der Dateiname muss nicht passen) und `description` (steuert, wann Claude automatisch delegiert; schreibe sie praezise). Optional steuerst du Verhalten ueber `tools` (Allowlist; ohne Angabe werden alle Tools geerbt), `model` (`sonnet`/`opus`/`haiku`, volle Model-ID oder `inherit` — Default ist `inherit`), `effort` (`low`/`medium`/`high`/`xhigh`/`max`, je nach Modell), `mcpServers` (eigene MCP-Server nur fuer diesen Agent), sowie `skills`, `memory`, `permissionMode`, `disallowedTools`, `hooks`, `maxTurns`, `color`, `background`, `isolation` und `initialPrompt`. Bei aus Plugins geladenen Sub-Agents werden `hooks`, `mcpServers` und `permissionMode` ignoriert.

Die Ordner `.claude/agents/` und `~/.claude/agents/` werden rekursiv gescannt — du kannst Definitionen also in Unterordner wie `agents/review/` legen. Der Unterordner-Pfad beeinflusst Identitaet und Aufruf nicht, weil die Identitaet allein aus dem `name`-Feld kommt. Halte `name`-Werte ueber den ganzen Baum eindeutig: zwei Dateien mit gleichem Namen in einem Scope fuehren dazu, dass eine ohne Warnung verworfen wird.

Minimal-Beispiel `.claude/agents/code-reviewer.md`:

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. When invoked, analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```

Tipp zur Modell-Wahl: Willst du das Modell aller Sub-Agents temporaer ueberstimmen (z.B. fuer einen guenstigen CI-Lauf), setze die Umgebungsvariable `CLAUDE_CODE_SUBAGENT_MODEL` — sie hat Vorrang vor dem `model`-Frontmatter (Reihenfolge: env > per-Invocation `model` > `model`-Frontmatter > Modell der Hauptkonversation). Best Practices laut Doku: fokussierte Sub-Agents (eine Aufgabe pro Agent), detaillierte Beschreibungen, minimale Tool-Rechte, und ab in die Versionskontrolle.

## Referenz (maschinenlesbar)

```yaml
# Subagent-Definitionen — projektspezifische Sub-Agents als Markdown-Dateien
# Quelle: https://code.claude.com/docs/en/sub-agents (Stand 2026-06-02)
subagents:
  # Speicherort: Projekt-Sub-Agents in .claude/agents/ ablegen (in Versionskontrolle einchecken).
  # User-weite Sub-Agents kommen nach ~/.claude/agents/. Ordner werden rekursiv gescannt
  # (Unterordner wie agents/review/ erlaubt; Identitaet kommt NUR aus dem name-Feld).
  speicherort_projekt: ".claude/agents/"
  speicherort_user: "~/.claude/agents/"
  # Dateiformat: Markdown mit YAML-Frontmatter. Body = System-Prompt des Sub-Agents.
  format: "Markdown (.md) mit YAML-Frontmatter, Body = System-Prompt"

  # Frontmatter-Felder. NUR name und description sind Pflicht; alle anderen optional.
  frontmatter:
    name:        "PFLICHT. Eindeutiger Bezeichner, lowercase + Bindestriche. Dateiname muss NICHT passen."
    description: "PFLICHT. Wann Claude an diesen Sub-Agent delegieren soll (steuert Auto-Delegation)."
    tools:       "Optional. Erlaubte Tools (Allowlist). Ohne Angabe: erbt alle Tools der Hauptkonversation."
    disallowedTools: "Optional. Tools-Denylist (wird vor tools angewendet; ein in beiden gelistetes Tool wird entfernt)."
    # model-Werte: sonnet | opus | haiku | volle Model-ID (z.B. claude-opus-4-8) | inherit
    model:       "Optional. Default: inherit (gleiches Modell wie Hauptkonversation)."
    # effort-Werte: low | medium | high | xhigh | max (verfuegbare Stufen modellabhaengig)
    effort:      "Optional. Effort-Level wenn Sub-Agent aktiv; ueberschreibt Session-Effort. Default: erbt von Session."
    # mcpServers: pro Eintrag entweder Server-Name (Referenz) oder Inline-Definition (.mcp.json-Schema)
    mcpServers:  "Optional. MCP-Server nur fuer diesen Sub-Agent. Bei Plugin-Sub-Agents ignoriert."
    permissionMode: "Optional. default | acceptEdits | auto | dontAsk | bypassPermissions | plan. Bei Plugin-Sub-Agents ignoriert."
    skills:      "Optional. Skills, die beim Start in den Kontext vorgeladen werden (voller Inhalt)."
    memory:      "Optional. Persistenter Speicher: user | project | local."
    maxTurns:    "Optional. Max. agentische Turns bis Stopp."
    hooks:       "Optional. Lifecycle-Hooks nur fuer diesen Sub-Agent. Bei Plugin-Sub-Agents ignoriert."
    color:       "Optional. red|blue|green|yellow|purple|orange|pink|cyan."
    background:  "Optional. true = immer als Background-Task. Default: false."
    isolation:   "Optional. worktree = isolierter Repo-Klon in temporaerem git worktree."
    initialPrompt: "Optional. Wird als erster User-Turn auto-submitted, wenn der Agent als Haupt-Session laeuft (--agent / agent-Setting)."

# Modell-Aufloesung (Reihenfolge): CLAUDE_CODE_SUBAGENT_MODEL (env) > per-Invocation model
# > model-Frontmatter > Modell der Hauptkonversation.
env:
  CLAUDE_CODE_SUBAGENT_MODEL: "Env-Var. Hat hoechste Prioritaet bei der Modell-Wahl fuer Sub-Agents."

# Minimal-Beispiel .claude/agents/code-reviewer.md:
# ---
# name: code-reviewer
# description: Reviews code for quality and best practices
# tools: Read, Glob, Grep
# model: sonnet
# ---
# You are a code reviewer. ...
```

## Audit-Kriterien

- Liegen Projekt-Sub-Agents unter .claude/agents/ (nicht woanders) und sind sie in der Versionskontrolle eingecheckt?
- Hat jede Sub-Agent-Datei YAML-Frontmatter mit den Pflichtfeldern name und description?
- Sind die name-Werte ueber den gesamten Ordnerbaum eindeutig (lowercase + Bindestriche)? Doppelte Namen in einem Scope werden ohne Warnung verworfen.
- Ist tools (Allowlist) oder disallowedTools gesetzt, um Rechte auf das Noetige zu beschraenken (z.B. Reviewer ohne Write/Edit)?
- Falls model gesetzt: nutzt es einen gueltigen Wert (sonnet/opus/haiku, volle Model-ID oder inherit)?
- Falls effort gesetzt: nutzt es eine gueltige Stufe (low/medium/high/xhigh/max)?
