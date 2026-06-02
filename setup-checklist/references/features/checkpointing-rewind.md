# Checkpointing & Rewind

> **Modus:** operator · **Prioritaet:** nice-to-have · **Status:** include-with-fixes
> Verifiziert 2026-06-02 gegen die offizielle Anthropic-Doku (code.claude.com/docs).

## Checkpointing & Rewind nutzen

Claude Code legt automatisch Checkpoints an: Vor jedem Edit wird der Code-Zustand gesichert, und jeder neue Prompt erzeugt einen Checkpoint. Das WARUM: Damit kannst du ambitionierte, grossflaechige Aufgaben angehen, ohne Angst vor kaputtem Code, weil du jederzeit zu einem frueheren Stand zurueckspringst. Es ist keine Einrichtung noetig — das laeuft out of the box.

Oeffne das Rewind-Menue mit dem Befehl `/rewind` oder durch zweimaliges Druecken von `Esc` (nur bei leerer Prompt-Eingabe; ist Text im Feld, loescht doppeltes Esc stattdessen diesen Text — der wird in die Input-History gespeichert und ist mit `Up` wieder abrufbar). Das Menue listet alle Prompts der Session. Waehle den Punkt aus und entscheide bewusst, WAS zurueckgesetzt werden soll:

- **Restore code and conversation** — Code und Konversation gemeinsam zuruecksetzen.
- **Restore conversation** — nur die Konversation zuruecksetzen, der aktuelle Code bleibt.
- **Restore code** — nur die Datei-Aenderungen zuruecknehmen, die Konversation bleibt.

Zusaetzlich gibt es `Summarize from here` / `Summarize up to here`, um Teile der Konversation zu Summaries zu verdichten und Context-Window-Platz freizugeben — diese aendern keine Dateien auf der Platte.

Kenne die Grenzen (sonst falsches Sicherheitsgefuehl): Checkpoints erfassen NUR direkte Datei-Edits von Claudes Editier-Tools. Dateiaenderungen durch Bash-Befehle (`rm`, `mv`, `cp`) lassen sich NICHT per Rewind rueckgaengig machen. Ebenso wenig manuelle oder externe Aenderungen ausserhalb der Session bzw. aus parallelen Sessions (ausser sie betreffen dieselben Dateien der aktuellen Session). Checkpoints sind als schnelles "local undo" gedacht und ersetzen Git nicht — fuer permanente Historie und Zusammenarbeit weiter committen.

Zur Aufbewahrung: Die Checkpointing-Doku sagt, das automatische Cleanup nach 30 Tagen sei "configurable", nennt dafuer aber KEINEN dedizierten Checkpoint-Key. Der allgemeine settings.json-Key `cleanupPeriodDays` (Default 30, Minimum 1; `0` wird mit Validierungsfehler abgelehnt) steuert laut settings-Doku das Loeschen alter Session-Dateien beim Start — ein direkter, dokumentierter Bezug zum Checkpoint-Cleanup wird dort nicht hergestellt.

## Referenz (maschinenlesbar)

```yaml
# Checkpointing & Rewind (Operator-Wissen, kein Setup-Key noetig)
# Claude Code trackt Datei-Edits automatisch und erlaubt Rueckspruenge.
checkpointing:
  # Wie man das Rewind-Menue oeffnet
  oeffnen:
    befehl: "/rewind"
    shortcut: "Esc zweimal druecken (nur wenn Prompt-Eingabe leer ist)"
    # Hinweis: bei Text im Prompt loescht doppeltes Esc stattdessen den Text
    #          (der Text wird in der Input-History gesichert, mit Up wieder abrufbar)
  # Was automatisch passiert
  automatik:
    - "Jeder User-Prompt erzeugt einen neuen Checkpoint (Zustand VOR jedem Edit)"
    - "Checkpoints bleiben sessionuebergreifend erhalten (auch in resumed Conversations)"
    - "Auto-Cleanup zusammen mit Sessions nach 30 Tagen (laut Doku 'configurable')"
  # Rewind-Aktionen (im Menue pro Prompt waehlbar)
  restore_aktionen:
    - "Restore code and conversation: Code UND Konversation zuruecksetzen"
    - "Restore conversation: nur Konversation zuruecksetzen, aktueller Code bleibt"
    - "Restore code: nur Datei-Aenderungen zuruecksetzen, Konversation bleibt"
  summarize_aktionen:
    - "Summarize from here: ausgewaehlte Nachricht + alles danach zu Summary verdichten (aendert keine Dateien)"
    - "Summarize up to here: alles vor der Nachricht verdichten, Rest bleibt intakt"
  # Verwandter settings.json-Key (steuert Session-Datei-Aufbewahrung;
  # die Checkpointing-Doku nennt KEINEN dedizierten Checkpoint-Key,
  # bezeichnet das Cleanup nur als 'configurable')
  setting:
    cleanupPeriodDays: 30   # Default 30, Minimum 1; 0 wird mit Validierungsfehler abgelehnt. Loescht alte Session-Dateien beim Start.
# WAS CHECKPOINTS NICHT ABDECKEN (wichtig fuer Operator):
#   - Dateiaenderungen durch Bash-Befehle (rm/mv/cp) -> NICHT rueckgaengig machbar
#   - Externe/manuelle Aenderungen ausserhalb von Claude Code oder aus parallelen Sessions
#     (ausser sie betreffen dieselben Dateien der aktuellen Session)
#   - Kein Ersatz fuer Versionskontrolle: Git = permanente Historie, Checkpoints = "local undo"
```

## Audit-Kriterien

- Operator kennt /rewind und den Esc-Esc-Shortcut (bei leerer Eingabe) zum Oeffnen des Rewind-Menues
- Operator kann die drei Restore-Modi unterscheiden (Code+Konversation / nur Konversation / nur Code)
- Operator weiss, dass Bash-Befehl-Aenderungen (rm/mv/cp) NICHT von Checkpoints abgedeckt sind
- Operator behandelt Checkpoints als local undo und nutzt weiter Git fuer permanente Historie
- Operator weiss, dass cleanupPeriodDays (Default 30, Minimum 1) die Aufbewahrung alter Session-Dateien steuert; ein dedizierter Checkpoint-Key ist nicht dokumentiert

## Vom Verifizierer entfernt / abgeschwaecht (nicht belegbar)

- LINKAGE cleanupPeriodDays steuert Checkpoint-Cleanup: Die Checkpointing-Doku sagt nur, dass das 30-Tage-Cleanup 'configurable' ist, nennt aber KEINEN settings.json-Key. Die settings-Doku beschreibt cleanupPeriodDays ausschliesslich als Loeschung von 'session files' (Default 30, Minimum 1, 0 wird mit Validierungsfehler abgelehnt) und erwaehnt Checkpointing mit keinem Wort. Die Behauptung 'Einzige verwandte settings.json-Option (steuert das 30-Tage-Cleanup)' bzw. 'das einzige verwandte settings.json-Stellrad ... das festlegt, wann ... die Checkpoints ... geloescht werden' ist eine Inferenz, nicht belegt. Der Key und seine Mechanik bleiben (verifiziert), aber NUR als Session-Datei-Aufbewahrung formuliert, nicht als Checkpoint-Steuerung.
- FORMULIERUNG 'Externe/manuelle Aenderungen ... werden normalerweise nicht erfasst (ausser sie betreffen dieselben Dateien der aktuellen Session)': Die Doku sagt woertlich, Checkpointing trackt nur Dateien, die innerhalb der aktuellen Session editiert wurden; manuelle/externe Aenderungen und Edits aus parallelen Sessions sind 'normally not captured, unless they happen to modify the same files as the current session'. Der Claim ist damit belegt — die Klammer-Einschraenkung im Entwurf ist korrekt und bleibt. (Kein Streichgrund, hier nur zur Klarstellung gelistet.)
