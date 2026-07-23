# Prototyp-Gate (Abnahme vor Live-Bau)

Neues Design wird IMMER zuerst als klickbarer Artifact-Prototyp gezeigt und freigegeben, bevor
live gebaut wird. Grund: kein Browser-Tool → blindes Live-Bauen ist riskant; der Prototyp ist der
guenstige, iterierbare Abnahme-Punkt.

## So bauen

- **Echte Tokens/Formensprache** aus dem Phase-0-System (Farben exakt, Spacing, Divider, Radius).
- **Echte Inhalte** oder klar markierte Platzhalter — nie Lorem.
- **Interaktion echt:** Slider/Tabs/Hover im Prototyp funktionsfaehig, damit der Nutzer das
  Verhalten abnimmt, nicht nur ein Standbild.
- **Kontext mitzeigen:** wenn nur eine Sektion umgebaut wird, die angrenzenden fixen Teile
  (Headline/CTA) im Prototyp mit-andeuten, damit das Verhaeltnis stimmt.
- Bei Vergleich: zwei Varianten nebeneinander (z.B. "puristisch" vs. "mit Links"), damit der
  Nutzer "too much oder nicht" direkt sieht.

## Grenzen ehrlich nennen

- **Artifact-CSP blockt externe Fonts/CDN/Fetch.** Custom-Fonts (z.B. Poppins, Marken-Headline)
  rendern im Prototyp nur als Fallback; live rendern die echten. Das explizit sagen.
- Externe Libs (d3, Karten-Daten) im Artifact nicht ladbar → im Prototyp bereits die
  selbst-enthaltene Variante zeigen (vorberechnet), nicht die CDN-Fassung.
- Render-Check fuer statische Grafik zusaetzlich lokal (SVG→PNG), um Geometrie/Kollisionen mit
  eigenen Augen zu pruefen, bevor der Nutzer schaut.

## Ablauf

1. Prototyp als Artifact publishen, Link geben, Pruefpunkte auflisten (was genau abnehmen).
2. Offene Entscheidungen als klare Gabel stellen (AskUserQuestion mit konkreten Optionen +
   Preview), nicht offen "wie haettest du's gern".
3. Korrekturen im Prototyp einarbeiten, gleichen Artifact-Link aktualisieren (gleicher file_path).
4. Erst nach **expliziter Freigabe** in den Live-Bau (Phase 3).

## Fehlende Vorgaben transparent machen

Wenn eine Referenz (z.B. Screenshot) angekuendigt, aber nicht angekommen ist: nicht raten und
nicht stillschweigend weiterbauen — den Fehl-Stand benennen, aus der Textbeschreibung bauen und
zur Korrektur einladen.
