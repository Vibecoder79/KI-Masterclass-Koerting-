# Hook-Typen (command/http/mcp_tool/prompt/agent) und Matcher-Syntax

> **Modus:** projekt+global · **Prioritaet:** nice-to-have · **Status:** include-with-fixes
> Verifiziert 2026-06-02 gegen die offizielle Anthropic-Doku (code.claude.com/docs).

## Hook-Typen waehlen (command / http / mcp_tool / prompt / agent)

Bevor du einen Hook anlegst, entscheide bewusst ueber das Feld `type` — es bestimmt, WIE der Hook laeuft, und jeder Typ hat eigene Pflichtfelder. Die offizielle Doku (https://code.claude.com/docs/en/hooks) kennt fuenf Typen:

- `command`: fuehrt eine Shell-Zeile aus. Das Event-JSON kommt auf stdin, die Antwort gibst du ueber Exit-Code und stdout zurueck. Pflichtfeld: `command`. Das ist der Standard fuer lokale Scripts (Linting, Formatierung, Validierung).
- `http`: postet das Event-JSON (Content-Type: application/json) an eine URL. Pflichtfeld: `url`. Sinnvoll, wenn ein externer Service entscheiden soll.
- `mcp_tool`: ruft ein Tool eines bereits verbundenen MCP-Servers auf. Pflichtfelder: `server` und `tool` (optional `input`, das `${path}`-Substitution aus dem Hook-Input unterstuetzt). Nutzt du, wenn die Logik schon als MCP-Tool existiert.
- `prompt`: schickt einen Prompt an ein Claude-Modell fuer eine Single-Turn-Evaluation und bekommt eine Ja/Nein-Entscheidung als JSON zurueck. Pflichtfeld: `prompt` (optional `model`, Default ist ein schnelles Modell). Mit `$ARGUMENTS` beziehst du das Hook-Input-JSON in den Prompt ein.
- `agent`: spawnt einen Subagent, der vor der Entscheidung Tools wie Read, Grep, Glob verwenden darf. Pflichtfeld: `prompt` (optional `model`). WICHTIG: Die Doku markiert Agent-Hooks ausdruecklich als experimentell ("Agent hooks are experimental and may change") — sie koennen sich aendern. Setze sie nur ein, wenn du diese Instabilitaet in Kauf nimmst.

WARUM das wichtig ist: Der falsche Typ verfehlt das Ziel oder kostet unnoetig Tokens. Fuer deterministische, schnelle Pruefungen nimm `command` (kein Modellaufruf). Greife nur zu `prompt`/`agent`, wenn wirklich eine modellgestuetzte Einschaetzung noetig ist — und bevorzuge das leichtere `prompt` vor dem experimentellen `agent`.

WANN ein Hook feuert, steuert der `matcher`. Die Tool-Events `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest` und `PermissionDenied` matchen auf den Tool-Namen. Events wie `UserPromptSubmit`, `Stop` oder `PostToolBatch` haben keinen Matcher und feuern immer (ein gesetzter Matcher wird stillschweigend ignoriert). Matcher-Regel: `"*"`/leer/weggelassen matcht alles; bestehen sie nur aus Buchstaben, Ziffern, `_` und `|`, sind es exakte Namen bzw. `|`-Listen (`"Edit|Write"`); sobald ein anderes Zeichen vorkommt, wird der Matcher als JavaScript-Regex ausgewertet (`"mcp__memory__.*"`). MCP-Tools heissen `mcp__<server>__<tool>`; um alle Tools eines Servers zu treffen, muss das `.*` angehaengt werden (`mcp__memory__.*`) — `mcp__memory` allein enthaelt nur Buchstaben/`_` und wird als exakter String verglichen, matcht also kein Tool. Hooks funktionieren sowohl in der globalen (`~/.claude/settings.json`) als auch in der Projekt-Settings (`.claude/settings.json`) — leg sie dort an, wo der Geltungsbereich passt.

## Referenz (maschinenlesbar)

```yaml
# Hook-Typen — der "type"-Wert in einem Hook-Eintrag bestimmt, WIE der Hook ausgefuehrt wird.
# Quelle: https://code.claude.com/docs/en/hooks (verifiziert)
# Platzierung: projekt (.claude/settings.json) ODER global (~/.claude/settings.json) — beide unterstuetzen Hooks.
hooks:
  # 1) command — fuehrt ein Shell-Kommando aus; Event-JSON kommt auf stdin, Ergebnis ueber Exit-Code/stdout.
  #    Pflichtfeld: command
  type_command:
    type: command
    command: "deine-shell-zeile"

  # 2) http — schickt das Event-JSON als HTTP-POST (Content-Type: application/json) an eine URL.
  #    Pflichtfeld: url
  type_http:
    type: http
    url: "https://example.com/endpoint"

  # 3) mcp_tool — ruft ein Tool eines bereits verbundenen MCP-Servers auf.
  #    Pflichtfelder: server, tool  (optional: input mit ${path}-Substitution)
  type_mcp_tool:
    type: mcp_tool
    server: "my_server"
    tool: "security_scan"
    input: { file_path: "${tool_input.file_path}" }

  # 4) prompt — schickt einen Prompt an ein Claude-Modell fuer Single-Turn-Evaluation; Modell gibt Ja/Nein als JSON zurueck.
  #    Pflichtfeld: prompt  (optional: model, Default = schnelles Modell). Platzhalter $ARGUMENTS = Hook-Input-JSON.
  type_prompt:
    type: prompt
    prompt: "Pruefe ... Nutze $ARGUMENTS als Platzhalter fuer das Hook-Input-JSON"
    model: "optional-model-name"   # optional, Default = schnelles Modell

  # 5) agent — spawnt einen Subagent, der Tools (Read/Grep/Glob) nutzen darf, bevor er entscheidet.
  #    Pflichtfeld: prompt  (optional: model). ACHTUNG: laut Doku EXPERIMENTELL ("experimental and may change").
  type_agent:
    type: agent
    prompt: "... $ARGUMENTS ..."
    model: "optional-model-name"   # optional

# --- Matcher-Syntax (steuert, WANN ein Hook feuert) ---
# Tool-Events matchen auf den Tool-Namen:
#   PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, PermissionDenied
# KEIN Matcher-Support (feuern immer, Matcher wird stillschweigend ignoriert):
#   UserPromptSubmit, PostToolBatch, Stop, CwdChanged, WorktreeCreate, WorktreeRemove
matcher_regeln:
  alle: '"*"  /  ""  /  weglassen  -> matcht alles'
  exakt_oder_liste: 'nur Buchstaben/Ziffern/_/| -> exakter Name oder |-Liste, z.B. "Bash" oder "Edit|Write"'
  regex: 'sobald ein anderes Zeichen vorkommt -> JavaScript-Regex, z.B. "^Notebook" oder "mcp__memory__.*"'
  mcp_naming: 'MCP-Tools heissen mcp__<server>__<tool>; "mcp__memory__.*" matcht alle Tools des Servers. WICHTIG: das ".*" ist Pflicht — "mcp__memory" allein enthaelt nur Buchstaben/_ und wird als exakter String verglichen, matcht also KEIN Tool.'
```

## Audit-Kriterien

- Jeder Hook-Eintrag hat ein gueltiges type-Feld aus {command, http, mcp_tool, prompt, agent}
- command-Hooks haben das Pflichtfeld command; http-Hooks das Pflichtfeld url
- mcp_tool-Hooks haben beide Pflichtfelder server UND tool
- prompt- und agent-Hooks haben das Pflichtfeld prompt
- agent-Hooks werden bewusst eingesetzt (Doku: experimentell, kann sich aendern) und nicht fuer triviale Checks verwendet
- Matcher werden nur auf Tool-Events (PreToolUse/PostToolUse/PostToolUseFailure/PermissionRequest/PermissionDenied) gesetzt, nicht auf matcher-lose Events (dort wird der Matcher stillschweigend ignoriert)
- MCP-Tool-Matcher folgen dem Schema mcp__<server>__<tool> und nutzen .* um alle Tools eines Servers zu treffen (mcp__memory__.*); ein Matcher ohne .* (z.B. mcp__memory) matcht kein Tool
