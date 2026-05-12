# Aenderungs-Checkliste (generisch)

PFLICHT bei jeder Code-Aenderung, egal wie klein. Durchgehen am Ende von Schritt 5 im `/implement`-Workflow.

## 1. Doku-Impact pro Aenderungs-Typ

Aus dem Linear-Label oder dem geaenderten Bereich den Aenderungs-Typ ableiten. Dann die entsprechenden Docs aktualisieren.

| Aenderungs-Typ | Docs die IMMER geprueft werden |
|----------------|-------------------------------|
| **Neue Komponente / Modul** | `ARCHITECTURE_DESIGN.md §9 Referenzen`, `COMPONENT_INVENTORY.md`, `SYSTEM_ARCHITECTURE.md`, Component-Doc (Obsidian oder `docs/components/`) |
| **API-Integration** (extern) | `SECURITY.md` (Threat-Surface), Component-Doc, `.env.example` (neue Variablen), `CHANGELOG.md` |
| **Konfiguration / Secrets** | `.env.example`, `SECURITY.md` (Secret-Handling), `lib/config.js` (falls SSoT-Werte), `CLAUDE.md` (wenn Systemverhalten sich aendert) |
| **Security-relevante Aenderung** | `SECURITY.md` (immer), `ARCHITECTURE_DESIGN.md §3 Quality Attributes`, ADR falls Architektur-Impact |
| **Doku / Governance-Aenderung** | `GOVERNANCE.md`, `DEVELOPMENT_PROCESS.md`, `CLAUDE.md`, betroffene Skill-Files |
| **Neue Abhaengigkeit** | `package.json` / `pyproject.toml`, `SECURITY.md` (Supply-Chain-Risk), ggf. `SYSTEM_ARCHITECTURE.md` |
| **Neuer ADR** | `ARCHITECTURE_DESIGN.md §7 ADR-Tabelle`, `Decisions/ADR-XX.md` (in Obsidian oder `docs/adr/`), Referenz in betroffenen Component-Docs |
| **Neue Datei** (jede `*.md`) | `ARCHITECTURE_DESIGN.md §9 Referenzen` (erzwungen durch `orphan-check.sh` wenn installiert), `INDEX.md` |
| **Hook / Governance-Hook-Aenderung** | `GOVERNANCE.md`, `.claude/settings.json` + `settings.local.json`, `hooks-setup.md` falls Skill-Teil |
| **Phase-Uebergang** (z.B. Phase 0 → 1) | PMO-Hub (Obsidian), `ARCHITECTURE_DESIGN.md §6 Phasen-Mapping`, alle Component-Docs (Phase-Status), `CHANGELOG.md` |

**Immer gilt:**
- Component-Doc der betroffenen Komponente aktualisieren (Stack, Phase-Status, Verbundene Stories, offene Fragen)
- `lib/config.js` VERSION bumpen wenn DOC_FILES aktualisiert wurden
- Alle DOC_FILES auf neue VERSION bringen (erzwungen durch `doc-version-sync.sh`)
- `CHANGELOG.md` Eintrag mit Version + Beschreibung

---

## 2. Privacy-Check (IMMER)

Fuer jede Aenderung pruefen:

- [ ] Wird eine neue Datenflussgrenze zu externem System ueberschritten? (Cloud-API, Third-Party-Service, Webhook)
- [ ] Werden personenbezogene Daten verarbeitet oder uebertragen?
- [ ] Ist das Projekt mit `Privacy`-Add-on konfiguriert? Dann: Datenflusskontrolle pruefen (Redaktion? Tier-Modell?)
- [ ] Werden Secrets im Code oder Log sichtbar? (`.env`-Check, Log-Sanitizing)

Bei Privacy-relevanten Aenderungen: `SECURITY.md` Privacy-Sektion aktualisieren.

---

## 3. Architektur-Konsistenz-Check

- [ ] Keine hardcoded Werte die in `lib/config.js` gehoeren (SSoT respektieren)
- [ ] Config-Werte ueber `.env` konfigurierbar wenn umgebungs-spezifisch
- [ ] Error-Handling vorhanden wo noetig (API-Calls, File-I/O, User-Input)
- [ ] Logging implementiert bei Fehlern und wichtigen State-Aenderungen
- [ ] Bestehende Patterns eingehalten (nicht neue Konventionen einfuehren wenn nicht noetig)

---

## 4. Git Commit + Push

- Code UND Doku-Aenderungen in einem Commit
- Commit-Message: `feat: <PREFIX>XXX — [Titel]` / `fix: <PREFIX>XXX — [Titel]` / `docs: ...` / `refactor: ...`
- `spec-gate.sh` + `doc-version-sync.sh` muessen gruen sein
- Push nach dem erfolgreichen Commit

---

## Spezial-Checklisten (pro Aenderungs-Typ)

### Neue Komponente / Modul hinzufuegen

- [ ] `ARCHITECTURE_DESIGN.md §9 Referenzen`: neuer Eintrag
- [ ] `COMPONENT_INVENTORY.md`: Zeile mit Status, Pfad, Zweck
- [ ] `SYSTEM_ARCHITECTURE.md`: Tabelle ergaenzen
- [ ] Component-Doc anlegen (Skelett-Struktur aus `bootstrap/references/doc-architecture-proposal.md`)
- [ ] `INDEX.md`: neuer Eintrag
- [ ] `.env.example`: neue Variablen dokumentiert
- [ ] `lib/config.js`: wenn konfigurierbar, VERSION bump

### Neue externe API integrieren

- [ ] Rate-Limit-Handling implementiert
- [ ] Timeout gesetzt
- [ ] Offline-/Error-Fallback (Graceful Degradation)
- [ ] API-Key nur in `.env` (niemals in Git, niemals in Log)
- [ ] Logger sanitized (`logger.sanitize()` fuer Response-Text)
- [ ] `SECURITY.md`: neue Threat-Surface dokumentiert
- [ ] Component-Doc aktualisiert (Stack-Tabelle, offene Fragen)
- [ ] Privacy-Tier-Kompatibilitaet dokumentiert (wenn Privacy-Add-on aktiv)

### Secrets-Management aendern

- [ ] `.env.example` mit Format-Erklaerung (NIE echte Werte)
- [ ] `SECURITY.md §API-Key-Policy` aktualisiert
- [ ] Bestehende `.gitignore`-Eintraege validieren
- [ ] Bei Secret-Rotation: alte Keys deaktivieren, Event-Log schreiben
- [ ] Keine Secrets in Logs (sanitize)

### Neuer ADR

- [ ] ADR-Datei in `Decisions/ADR-XX.md` (Obsidian) oder `docs/adr/ADR-XX.md` mit: Status, Kontext, Entscheidung, Konsequenzen, Alternativen
- [ ] `ARCHITECTURE_DESIGN.md §7 ADR-Tabelle`: Eintrag
- [ ] Betroffene Component-Docs: Referenz zum ADR
- [ ] `CHANGELOG.md`: Eintrag
- [ ] Enforcement-Frage: "Ist die Entscheidung maschinell erzwungen oder nur dokumentiert?" — bei nur dokumentiert: Guard-Story-Kandidat (Hook / Test / Self-Healing-Check)

### Hook / Governance-Aenderung

- [ ] `GOVERNANCE.md` Sektion aktualisieren
- [ ] Hook-Skript in `.claude/hooks/` liegt
- [ ] Hook in `.claude/settings.json` UND `.claude/settings.local.json` registriert (Harness-Fallback)
- [ ] Hook-Test: Manuell ausloesen (z.B. Dummy-Commit) und Blockade pruefen
- [ ] `bootstrap/references/hooks-setup.md` aktualisieren falls generischer Hook
- [ ] `specs/<PREFIX>XXX.md` dokumentiert den neuen Hook

### Security-Feature aendern

- [ ] `SECURITY.md` relevante Sektion aktualisieren (Threat Model, Input-Validation, Auth)
- [ ] Threat-Response-Matrix pruefen — wird bestehende Bedrohung mitigiert?
- [ ] Bei neuem Inbound-Webhook: HMAC-Signierung, Replay-Schutz, Rate-Limit, Body-Limit
- [ ] Bei neuer .env-Variable mit Credential: Sanitize in Logger, Dokumentation in `.env.example`

### Governance / Skill aendern

- [ ] Betroffene `SKILL.md` aktualisieren
- [ ] `references/*.md` nachziehen wenn referenziert
- [ ] `GOVERNANCE.md` aktualisieren wenn projekt-globale Regel betroffen
- [ ] Version im Skill-Frontmatter erhoehen (`version:` in SKILL.md)
- [ ] `publish_skill.py` laufen lassen wenn Skill ins Master-Repo soll

---

## 5. Component-Doc-Update (wenn Obsidian aktiv)

Jede Code-Aenderung die eine Komponente beruehrt muss das Component-File aktualisieren:
- `{OBSIDIAN_VAULT}/02 Projekte/{PROJECT_NAME}/Components/<komponente>.md`
- Sektionen: Stack-Tabelle (wenn Tool-Aenderung), Phase-Status, Verbundene Stories (Link zu JAR-XXX + Spec), offene Fragen

Wenn DocSync aktiviert (Block D.2): laeuft automatisch via `node lib/doc-sync.js`.
