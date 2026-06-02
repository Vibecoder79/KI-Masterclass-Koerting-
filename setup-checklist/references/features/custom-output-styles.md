# Custom Output Styles

> **Modus:** projekt+global · **Prioritaet:** wichtig · **Status:** include
> Verifiziert 2026-06-02 gegen die offizielle Anthropic-Doku (code.claude.com/docs).

## Custom Output Styles einrichten

Output Styles aendern, WIE Claude antwortet (Rolle, Ton, Ausgabeformat), nicht WAS Claude weiss. Sie modifizieren direkt den System-Prompt. Nutze sie, wenn du dich beim selben Stil oder Format jede Runde neu wiederholst, oder wenn Claude etwas anderes als Software-Engineering machen soll (z.B. Schreibassistent, Datenanalyst). Fuer Projekt-Konventionen und Codebase-Wissen gehoert der Inhalt dagegen in CLAUDE.md, nicht in einen Output Style.

WARUM: Wer immer wieder denselben Stil nachprompten muss, verschwendet Tokens und Aufmerksamkeit. Ein Output Style verankert diesen Stil dauerhaft im System-Prompt und gilt damit fuer jede Antwort.

Schritt 1 — Built-in pruefen: Claude Code bringt vier Built-in Styles mit. Default ist der normale Engineering-Prompt; daneben gibt es Proactive (handelt sofort, trifft Annahmen, Aktion vor Planung), Explanatory (liefert lehrreiche Insights beim Coden) und Learning (learn-by-doing, setzt TODO(human)-Marker zum Selbst-Coden). Setze einen Style ueber `/config` -> "Output style"; die Auswahl landet in `.claude/settings.local.json` (lokale Projekt-Ebene). Alternativ direkt das Feld `outputStyle` in einer settings-Datei setzen, z.B. `"outputStyle": "Explanatory"`.

Schritt 2 — Eigenen Style anlegen (optional): Ein Custom Style ist eine Markdown-Datei mit Frontmatter plus Instruktionen. Lege sie je nach Reichweite ab unter `~/.claude/output-styles` (global, alle Projekte) oder `.claude/output-styles` (projektspezifisch); zusaetzlich gibt es die Managed-Policy-Ebene `.claude/output-styles` im Managed-Settings-Verzeichnis. Der Dateiname wird zum Style-Namen, sofern du im Frontmatter kein `name` setzt. Wichtigste Entscheidung: `keep-coding-instructions: true`, wenn Claude weiter normal coden, aber anders kommunizieren soll (Default ist false, dann fallen die eingebauten Engineering-Instruktionen weg). Weitere Felder: `description` (erscheint im /config-Picker) und `name`.

Schritt 3 — Aktivieren: Style ueber `/config` -> "Output style" waehlen. Da der Style Teil des System-Prompts ist und nur einmal beim Session-Start gelesen wird, greift die Aenderung erst nach `/clear` oder in einer neuen Session.

Hinweis: Den frueheren Standalone-Befehl `/output-style` gibt es nicht mehr (deprecated in v2.1.73, entfernt in v2.1.91) — nutze `/config` oder setze `outputStyle` direkt.

## Referenz (maschinenlesbar)

```yaml
# Custom Output Styles — passt System-Prompt an (Rolle/Ton/Format), nicht das Wissen
# Quelle: https://code.claude.com/docs/en/output-styles (Stand 2026-06-02)
output_styles:

  # outputStyle-Setting in einer settings-Datei. /config -> "Output style" speichert
  # nach .claude/settings.local.json (lokale Projekt-Ebene). Direkt setzbar:
  setting:
    key: outputStyle           # Wert = Name eines Built-in oder Custom Styles
    beispiel: |
      {
        "outputStyle": "Explanatory"
      }
    hinweis: "Teil des System-Prompts, einmal bei Session-Start gelesen -> greift erst nach /clear oder neuer Session"

  # Built-in Styles (Default = bestehender System-Prompt fuer Software-Engineering)
  builtin:
    - Proactive      # fuehrt sofort aus, trifft Annahmen, Aktion vor Planung
    - Explanatory    # liefert lehrreiche "Insights" beim Coden
    - Learning       # learn-by-doing, setzt TODO(human)-Marker zum Selbst-Coden

  # Custom Styles = Markdown-Datei: Frontmatter + Instruktionen fuer System-Prompt
  # Dateiname wird zum Style-Namen, sofern kein name im Frontmatter gesetzt ist
  custom:
    pfade:
      user:           ~/.claude/output-styles          # global, alle Projekte
      projekt:        .claude/output-styles            # projektspezifisch
      managed_policy: .claude/output-styles            # im Managed-Settings-Verzeichnis
    frontmatter:
      name:                     # optional, sonst Dateiname
      description:              # gezeigt im /config-Picker
      keep-coding-instructions: # true = Coding-Instruktionen behalten (Default: false)
      force-for-plugin:         # nur Plugin-Styles, Default: false
    beispiel: |
      ---
      name: Diagrams first
      description: Lead every explanation with a diagram
      keep-coding-instructions: true
      ---
      When explaining code, start with a Mermaid diagram, then explain in prose.

  # Verwaltung
  commands:
    - /config        # Menue "Output style" zum Auswaehlen
  hinweis_deprecated: "/output-style: in v2.1.73 deprecated, in v2.1.91 entfernt -> /config oder outputStyle direkt"

  # Plugins koennen Styles in einem output-styles/ Verzeichnis ausliefern
```

## Audit-Kriterien

- Pruefen ob outputStyle-Setting gesetzt ist (settings.json / settings.local.json) und auf einen gueltigen Built-in- oder Custom-Style-Namen zeigt
- Falls Custom Styles existieren: liegen sie unter ~/.claude/output-styles (global) oder .claude/output-styles (projekt)?
- Custom-Style-Frontmatter pruefen: bewusste Entscheidung zu keep-coding-instructions (true bei weiter codend, sonst weglassen) und vorhandene description fuer den /config-Picker
- Sicherstellen dass Projekt-Konventionen in CLAUDE.md stehen und nicht in einen Output Style abgewandert sind
