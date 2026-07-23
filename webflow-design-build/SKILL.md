---
name: webflow-design-build
description: |
  Baut und ueberarbeitet Webflow-Sektionen/-Seiten ueber den Webflow-MCP diszipliniert und
  slop-frei. Erzwingt ein hartes Design-System-Gate (kein Bau ohne fixierte Tokens/DESIGN.md),
  einen Abnahme-Gate ueber klickbaren Artifact-Prototyp VOR dem Live-Bau, und ein
  Webflow-MCP-Playbook mit den bewaehrten Bau- und CMS-Mustern. Verhindert den generischen
  KI-Look durch Disziplin, nicht durch "mach es schoen". Fuer wiederkehrende Website-Arbeit
  (eigene Marken und Kunden).
  Verwenden wenn der Nutzer eine Webflow-Seite/-Sektion bauen, redesignen, an CMS binden,
  ein Custom-Embed/eine Visualisierung einbauen oder eine bestehende Sektion in eine
  Design-Formensprache ueberfuehren moechte.
  Ausloeser: "baue die Sektion in Webflow", "ueberarbeite die ... auf owlist.ch",
  "Webflow-Redesign", "an die Collection binden", "Partner-/Team-Kacheln umbauen",
  "webflow-design-build", "/webflow-design-build", "verhindere den KI-Look".
version: 1.0.0
---

# Webflow Design Build

Diszipliniertes Bauen und Redesignen von Webflow-Sektionen ueber den Webflow-MCP — so, dass das
Ergebnis nach einem **fixierten Design-System** aussieht und nicht nach generischem KI-Default.

## Kernidee (ehrlich)

Dieser Skill macht Ergebnisse **nicht durch guten KI-Geschmack** slop-frei, sondern durch drei
Zwaenge:

1. **Design-System-Gate (hart):** Ohne fixierte Tokens/Formensprache fuer diese Site wird nicht
   gebaut. Der Skill blockt und schickt dich zuerst durch die System-Definition.
2. **Abnahme-Gate:** Neues Design wird IMMER zuerst als klickbarer Artifact-Prototyp gezeigt und
   freigegeben, bevor irgendetwas live gebaut wird (kein Browser-Tool → blindes Live-Bauen ist
   riskant).
3. **Verify statt "sieht gut aus":** Render-/E2E-Check und ehrliches Verdikt vor jedem Publish.

Die **Richtung** (welches Design) kommt vom Menschen/Designer. Der Skill kapselt Handwerk +
Disziplin + Webflow-Wissen — keine Design-Entscheidung.

## Wann NICHT dieser Skill

- Reines Content-Einpflegen (bestehende CMS-Items befuellen) → direkt, kein Skill noetig.
- Nicht-Webflow-Sites (Next.js/Astro/Code) → dieser Skill ist Webflow-spezifisch; nutze das
  Design-System-Gate + Anti-Slop-Denken sinngemaess, aber das MCP-Playbook gilt nicht.
- Reiner Slop-Check einer fertigen Seite → `anti-slop` Skill + `references/anti-slop-gate.md`.

## Ablauf (Pflicht-Reihenfolge)

### Phase 0 — Design-System-Gate (HART, blockt)

Vor jeder Bauarbeit muss ein **fixiertes Design-System** fuer diese Site vorliegen:
Farb-Tokens (4-6 benannte Hex), Schrift-Rollen (Display + Body, echte Faces), Formensprache
(Radius, Divider-Muster, Spacing-Rhythmus, Foto-Behandlung), Motion-Regeln.

- **Liegt es vor?** (DESIGN.md der Site, `00 Kontext/Branding.md`, ein bestehender Style-Guide,
  oder eine vom Nutzer gelieferte Referenz wie "Richtung C") → weiter zu Phase 1.
- **Liegt es nicht vor?** → **STOPP.** Zuerst pinnen:
  - Bestehende Site/Referenz vorhanden → Skill **`design-md-generator`** (DESIGN.md extrahieren).
  - Kunde mit CI-Dokumenten → Skill **`ci-extraktor`** (Farben/Schriften aus Kundendokumenten).
  - Nichts vorhanden → 4-6 Tokens + 2 Schriften + Formensprache mit dem Nutzer explizit
    festlegen und schriftlich fixieren, BEVOR gebaut wird.
  - Niemals mit dem generischen Default starten (siehe `references/anti-slop-gate.md`, Cluster-Liste).

### Phase 1 — Inspizieren (nie blind bauen)

Immer erst die bestehende Struktur lesen, echte IDs und Styles erfassen:
- `data_sites_tool > get_site` — Locales (inkl. `cmsLocaleId`), Custom-Domains fuers Publish.
- `data_pages_tool > list_pages` — pageId.
- `data_element_tool > query_elements` / `get_all_elements` — Ziel-Sektion, Element-IDs, Klassen.
- `data_style_tool > query_styles` (mit `include_properties`) — **wo lebt das CSS wirklich**
  (Webflow-Klassen vs. Head-Freeform). Nie annehmen, immer lesen.
- `data_cms_tool > get_collection_details` — echte Feld-Slugs, wenn CMS im Spiel ist.
- Footer/Head-Freeform (`data_scripts_tool > get_*_freeform_code`) auf abhaengige Scripts pruefen
  (z.B. Scroll-Pin, Slider-Logik), damit der Umbau sie nicht bricht.

### Phase 2 — Prototyp + Abnahme-Gate

- Neues Design als **klickbaren Artifact-Prototyp** bauen (echte Tokens/Fonts-Fallback, echte
  Inhalte/Platzhalter). Bei Interaktion (Slider/Tabs): interaktiv im Artifact.
- Vorbehalte offen nennen (Artifact-CSP blockt externe Fonts/CDN → Fallbacks; live rendern echte
  Fonts).
- **Freigabe abwarten.** Korrekturen im Prototyp, nicht live. Siehe `references/prototyp-gate.md`.

### Phase 3 — Live bauen (Webflow-MCP-Playbook)

Erst nach Freigabe. Reihenfolge + Muster strikt nach `references/webflow-mcp-playbook.md`:
- CMS zuerst (Collection/Felder/Items) wenn dynamisch, dann Struktur, dann Bindung, dann Styles.
- Bestehende Styles wiederverwenden statt neue erfinden; Klassen mit Prefix gegen Kollision.
- Abhaengige Scripts erhalten (die Klasse/Struktur, die das Script greift, muss bleiben).
- Custom-Visualisierungen: **selbst-enthalten** (kein Laufzeit-CDN), offline vorberechnen.

### Phase 4 — Verify + Publish

- Strukturell verifizieren (Bindung gesetzt? genau eine Ziel-Klasse? Code vollstaendig gespeichert?).
- Wo moeglich Render-/E2E-Check (SVG→PNG via rsvg-convert + Read; oder Live-HTML per curl auf
  erwartete Strings pruefen). Siehe `references/webflow-mcp-playbook.md` (Abschnitt Verify).
- **Publish pusht die GANZE gestagte Site** — vorher Freigabe, und darauf hinweisen.
- Ehrliche Grenze: ohne Browser-Tool kein Live-Klick-Test → finaler Augen-Check liegt beim Nutzer.

### Phase 5 — Anti-Slop-Pass (vor Abschluss)

Pflicht-Durchlauf gegen `references/anti-slop-gate.md` (das visuelle Pendant zur Text-`anti-slop`).
Bei Motion zusaetzlich `design-motion-principles` (Audit-Modus).

## Zusammenspiel mit bestehenden Skills (nicht duplizieren)

| Zweck | Skill |
|---|---|
| Design-System extrahieren/definieren | `design-md-generator`, `ci-extraktor` |
| Text-Slop | `anti-slop` + `00 Kontext/Anti-Slop.md` |
| Motion-Slop | `design-motion-principles` |
| Bild-Assets | `nanobanana2` |
| Session dokumentieren | `journal` / Daily Note |

Dieser Skill orchestriert diese als Sub-Schritte; er baut ihre Faehigkeiten NICHT nach.

## References

- `references/webflow-mcp-playbook.md` — Bau-/CMS-/Embed-Muster + die bewaehrten Stolpersteine.
- `references/anti-slop-gate.md` — visuelle Slop-Cluster + Pflicht-Checkliste vor Publish.
- `references/prototyp-gate.md` — wie der Abnahme-Prototyp gebaut/kommuniziert wird.

Marken-Kontext (OWLIST u.a.) NICHT hier duplizieren — auf SecondBrain verweisen:
`00 Kontext/Branding.md`, `00 Kontext/Anti-Slop.md`, projektspezifische DESIGN.md.
