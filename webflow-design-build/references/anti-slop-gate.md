# Anti-Slop-Gate (visuell)

Pflicht-Pass vor jedem Publish. Das visuelle Pendant zur Text-`anti-slop`. Zusaetzlich immer
`00 Kontext/Anti-Slop.md` und `00 Kontext/Branding.md` im SecondBrain konsultieren; bei Motion
`design-motion-principles` (Audit-Modus).

## Die KI-Default-Cluster (vermeiden, wenn nicht bewusst gewaehlt)

Aktueller KI-Design-Default clustert um wenige Looks. Wenn nichts vorgegeben ist, NICHT die
Freiheit auf einen davon verschwenden:

- Warmes Creme (#F4F1EA) + Serif-Display + Terracotta-Akzent.
- Fast-Schwarz + ein einzelner Acid-Green/Vermilion-Pop.
- Broadsheet-Haarlinien + dichte Spalten.
- Lila-zu-Blau-Verlaufs-Hero auf Weiss.
- Inter oder Space Grotesk als "sichere" Schrift.
- Emoji als Sektions-Marker.
- Alles zentriert; `rounded-lg` ueberall; Akzent-Rail auf gerundeter Karte.

**Wichtig:** Wenn der Nutzer eine Richtung explizit vorgibt (z.B. "Richtung C", eine DESIGN.md,
eine Referenz), gewinnt sie IMMER — auch wenn sie einem Cluster aehnelt. Das Gate greift nur, wo
nichts festgelegt ist.

## Checkliste vor Publish

1. **Tokens statt Zufall:** Jede Farbe/Groesse kommt aus dem fixierten System (Phase-0-Tokens),
   nicht ad hoc. Neutrale mit leichtem Hue-Bias zum Akzent, nicht reines Mid-Grey.
2. **Typo-Hierarchie echt:** Display + Body als bewusstes Paar, klare Skala, Labels mit Sperrung.
   Nicht die "sichere" Default-Schrift, wenn die Marke etwas anderes hat.
3. **Formensprache konsistent:** dasselbe Divider-/Radius-/Spacing-Muster wie die Nachbar-Sektionen
   (Wiedererkennbarkeit ist Anti-Slop). Ein System, mehrere Varianten — kein Fremdkoerper.
4. **Struktur ist Information:** Nummerierung/Eyebrows/Divider kodieren etwas Wahres, sind nicht
   Deko. Keine 01/02/03-Marker ohne echte Sequenz.
5. **Copy als Material:** aus Nutzersicht benannt, aktiv, spezifisch. Deutsch = Schweizer
   Hochdeutsch (ss statt ss-scharf). Keine Gedankenstriche als Stilmittel im Fliesstext.
   (Content-Regeln: `00 Kontext/Schreibstil.md` + `Anti-Slop.md`.)
6. **Motion sparsam + zweckhaft:** kein Effekt-Feuerwerk; jede Bewegung dient. Hover dezent
   (z.B. leichtes Lift/Farbe). `prefers-reduced-motion` respektieren.
7. **Beide Themes/States** wo relevant; Fokus sichtbar; kein stiller Font-Fallback.
8. **Ehrlicher Blick:** Wirkt es wie ein bewusst gestaltetes System oder wie ein Template? Wenn
   Template-Verdacht → benennen und die betroffene Stelle ueberarbeiten, nicht durchwinken.

## Verdikt statt Schmeichelei

Am Ende ein ehrliches Urteil geben — auch negativ ("wirkt generisch, weil X"). Kein
"sieht super aus" ohne Beleg. Das ist Teil des Anti-Slop, nicht Kosmetik.
