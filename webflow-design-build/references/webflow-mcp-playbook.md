# Webflow-MCP-Playbook

Konkrete Bau-, CMS- und Embed-Muster fuer den Webflow-MCP. Aus echter Bauarbeit destilliert
(owlist.ch /team: Core-Team-Kacheln, Standortkarte, Partner-Slider). Erst `webflow_guide_tool`
einmal aufrufen (Pflicht-Erststep), dann diese Muster anwenden.

## Grundregeln

- **Nie Site/Page-IDs raten.** Immer `data_sites_tool > list_sites`/`get_site`,
  `data_pages_tool > list_pages`.
- **Data-Tools = REST-Zustand, Designer-Tools = UI.** Alle Aenderungen sind bis zum Publish
  **gestaged** → kein halb-live Zustand. Genau EINMAL am Ende publishen.
- **Bestehende Styles wiederverwenden** (`data_style_tool > query_styles include_properties`),
  nicht neue erfinden. Vor dem Umbau lesen, WO das CSS lebt (Webflow-Klasse vs. Head-Freeform).
- **Publish pusht die ganze Site** (`publish_site` mit customDomains-IDs + `publishToWebflowSubdomain`).
  Vorher Freigabe.

## Abhaengige Scripts erhalten (Scroll-Pin, Slider ...)

Wenn ein Footer/Head-Script auf eine Klasse/Struktur zielt (z.B. Scroll-Pin sucht
`.owl-team-track` und misst `scrollWidth`), MUSS diese Klasse/Struktur nach dem Umbau erhalten
bleiben.

- Muster: die **Webflow-Collection-List** (DynamoList = `ul.w-dyn-items`, die Flex-Reihe) bekommt
  die vom Script gesuchte Klasse. Dann greift das Script weiter.
- Nach dem Umbau strukturell verifizieren: **genau ein** Element mit der Zielklasse
  (`query_elements` mit `style`-Filter), alte statische Traeger vorher entfernen.

## CMS: Collection-List als Kachel-/Slider-Quelle

Struktur einer Collection-List: `DynamoWrapper` → `DynamoList` (`ul.w-dyn-items`, die Reihe) →
`DynamoItem` (Template-Item, einmal, repetiert beim Render) + `DynamoEmpty`.

Ablauf:
1. `data_element_builder type:"CMSCollection"` in den Ziel-Container → gibt Wrapper zurueck.
2. Teilbaum `query_elements` → DynamoList + DynamoItem IDs merken.
3. Query/Source setzen ueber `data_element_settings_tool > set_settings` (NICHT ueber data_cms):
   - `source` = `static_json` `{"collectionId":"..."}`
   - `sort` = `static_json` `[{"fieldSlug":"reihenfolge","direction":"ascending"}]`
   - `limit` = `static_number`
   - Danach `get_settings` verifizieren (source persistiert nicht immer stumm).
4. Ins **DynamoItem** die Kachel-Kinder bauen (Image/Heading/Paragraph/TextLink) mit bestehenden
   Klassen. Ein `data_element_builder`-Call mit mehreren append-Actions haelt die Reihenfolge.
5. Felder binden (siehe unten). Klasse fuer das Script auf die DynamoList setzen; alte statische
   Reihe entfernen.

## CMS-Bindung: die Stolpersteine (WICHTIG)

- **Setting-Keys je Elementtyp** (via `get_settings query_settings` + `get_bindable_sources`):
  Image → `assetId` (value_type `image`), Text (Heading/Paragraph) → `text` (`textContent`),
  Link (TextLink/LinkBlock) → `link` (`link`/`url`).
- **Binden** ueber `set_settings` mit `binding:{source_type:"cms", collection_id, field_id}` auf
  den passenden Key.
- **Attribut-Value NICHT direkt an CMS bindbar.** Ein `set_attributes` mit CMS-Wert scheitert
  ("value must be a string or a binding"). Wenn du CMS-Werte in ein Custom-Script brauchst
  (data-Attribute), Muster **gebundene Kind-Elemente**: unsichtbare Kind-Elemente je Feld,
  Text/Src an CMS gebunden, mit stabilem `data-f="feldname"`-Marker; das Script liest die
  gerenderten Kinder statt CMS-Attribute. (Siehe Memory "Webflow Custom-JS aus CMS".)

## Zweisprachigkeit — zwei Muster, je Konvention

- **Echte CMS-Locales:** `get_site` liefert `locales.primary`/`secondary` mit `id` (Page) und
  `cmsLocaleId` (CMS). Item-Anlegen: `create_collection_items` — **beim Anlegen `cmsLocaleIds`
  beider Locales setzen**, sonst existiert der Sekundaer-Datensatz nicht (Update/Publish 404,
  Geist-Records; leere EN-Liste). Danach EN-Felder via `update_collection_items` mit `cmsLocaleId`.
- **Feld-Paar-Muster:** Collection hat `feld` + `feld-en` (z.B. `rolle`/`rolle-en`). Dann kein
  Locale-Handling im CMS — die Sprache waehlt das Binding/Script anhand der Seiten-Locale.
- **Vor dem Bau pruefen, welches Muster die Collection nutzt** (`get_collection_details`) und es
  respektieren — nicht mischen.

## Custom-Visualisierungen: selbst-enthalten statt Laufzeit-CDN

Fuer Karten/Charts/Geo-Viz NICHT d3+topojson+Daten zur Laufzeit vom CDN laden (fragil, im
Abnahme-Artifact per CSP nicht previewbar, schwer).

- Projektion/Layout **einmal offline** rechnen (Node + d3-geo etc.), SVG-Pfade + Koordinaten fest
  einbetten → kein Laufzeit-d3, kein CDN. (Siehe Memory "Webflow Offline-SVG-Karten".)
- Einbau: `data_element_builder type:"HtmlEmbed"`, Code via `set_settings` key `code`
  (`static_text`). Das funktioniert headless (anders als der 406/404-Block mancher
  Custom-Code-Pfade). Klassen mit Prefix (z.B. `owlmap-`) gegen Kollision. Hover via CSS.
- **Grenze eines Bild-Assets:** ein statisches Bild kann keinen Hover; wenn Interaktion gewuenscht
  ist → Inline-SVG-Embed statt Image.
- **Groesse/Skalierung:** eine Inline-SVG mit `viewBox` braucht eine definierte Breite
  (`width:100%; max-width:...`), sonst kollabiert sie auf ~300px. Label-Lesbarkeit ist meist ein
  Font-Groessen-Problem, nicht ein Karten-Groessen-Problem — ehrlich benennen statt blind
  vergroessern.

## Verify vor Publish

- Bindung/Settings zuruecklesen (`get_settings`), Code-Setting auf Vollstaendigkeit pruefen
  (nicht abgeschnitten, Umlaute intakt).
- Struktur: genau ein Element mit der Script-Zielklasse.
- Render-Check fuer SVG: `rsvg-convert -w <breite> render.svg -o out.png` → `Read` (Kollisionen,
  Geometrie). macOS ohne `timeout`.
- E2E fuer JS-gerenderte Embeds: Live-HTML per `curl` ziehen und auf erwartete Strings/Feldwerte
  pruefen (z.B. alle N Items, DE+EN, Links vorhanden, Anzahl unerwuenschter Alt-Styles = 0).
- Ehrliche Grenze: kein Browser-Tool → finaler visueller/Interaktions-Check liegt beim Nutzer.

## Typische Reihenfolge (dynamische Sektion)

1. Inspizieren (Struktur, Styles, Freeform-Scripts, Collection-Felder).
2. Prototyp → Freigabe.
3. CMS: Collection/Felder/Items (beide Locales beim Anlegen).
4. Struktur: Collection-List im Ziel-Container, Source/Sort/Limit.
5. Kachel-Inhalt im DynamoItem + Feld-Bindung.
6. Styles auf die Formensprache umstellen (bestehende Klassen updaten, neue mit Prefix).
7. Script-Zielklasse setzen, alte statische Reihe entfernen.
8. Verify → Publish (mit Freigabe) → Nutzer-Augencheck.
