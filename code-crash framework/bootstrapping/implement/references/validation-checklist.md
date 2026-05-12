# Validation Checklist — /implement Schritt 6

Referenz-Dokument für alle Post-Implement-Gates. Wird von `/implement` Schritt 6 konsumiert.

## Gate-Übersicht

| Gate | Schritt | Tool | Block-Typ |
|------|---------|------|-----------|
| Code Quality — ESLint | 6a | ESLint CLI | Iterations-Loop (max 5) |
| Security — Semgrep | 6a-bis | Semgrep CLI | Iterations-Loop (max 5) |
| Dependency Check | 6a-tris | dependency-check.sh | Hard Block bei 404/High CVE |
| Coverage Gate | 6a-quart | coverage-check.sh | Block bei <60%, Warn 60-80% |
| Akzeptanzkriterien | 6b | Linear Issue | Hard Block (kein Done ohne AC) |
| Architektur-Quick-Check | 6c | Manuell | Soft Check |
| Smoke Test | 6d | Manuell | Soft Check |
| Security-Findings | 6e | Manuell | Dokumentation |
| Intent-Verifikation | 6g | intents/INTENT-XX.md | Non-blocking (nur Messen) |

## Review-Evidenz (BOO-18 — Mandatory Human Review)

Wenn `.claude/sensitive-paths.json` vorhanden und ein Treffer in Schritt 5.5 gefunden:

### Pflicht-Einträge im Spec-File

Unter `## Human Review` im Spec-File (`specs/CLAW-XXX.md`) müssen stehen:

```markdown
## Human Review

- **Date:** YYYY-MM-DD
- **Reviewer:** {Name / GitHub-Handle}
- **Comment:** {Was wurde geprüft, worauf wurde besonders geachtet}
- **Sensitive Paths Touched:** {Liste der Dateien die einen sensitiven Pattern getroffen haben}
```

### Checkliste für den Reviewer

Beim Review sensitiver Pfade prüfen:

- [ ] Input-Validierung: Werden alle User-Inputs vor der Verarbeitung validiert?
- [ ] Authentication: Werden Tokens/Sessions korrekt validiert und kein Bypass möglich?
- [ ] Authorization: Werden Berechtigungen auf Ressourcen-Ebene (nicht nur Route-Ebene) geprüft?
- [ ] Secrets: Werden Credentials/Keys ausschliesslich aus Environment-Variablen geladen (nie hardcoded)?
- [ ] Logging: Werden PII-Daten NICHT in Logs geschrieben?
- [ ] Error Handling: Gibt der Fehler-Handler keine sensiblen Details in der API-Response zurück?
- [ ] Crypto: Werden Passwörter mit einem sicheren Hashing-Algorithmus (bcrypt, argon2) gespeichert?

### Audit-Trail

Der Review-Kommentar (`review-ok: ...`) wird in zwei Artefakten gespeichert:
1. **Spec-File** (`specs/CLAW-XXX.md §Human Review`) — langfristiger Audit-Trail per Story
2. **Linear-Kommentar** — automatisch von `/implement` nach Schritt 6b gepostet (inkl. Reviewer + Datum)

### Fallback: Keine sensitive-paths.json

Wenn `.claude/sensitive-paths.json` fehlt: Schritt 5.5 wird übersprungen, kein Human Review erzwungen. Empfehlung: `/bootstrap` Phase 4.4i nachziehen oder Datei manuell anlegen.

---

## Validation PASS / FAIL Kriterien

**PASS** (alle müssen erfüllt sein):
- ESLint: 0 Errors
- Semgrep: 0 High/Critical Findings
- Dependency: kein 404, kein High/Critical CVE
- Coverage: ≥80% auf neuen Zeilen (oder Operator-Freigabe mit Begründung)
- AC-Check: alle ACs mit Evidenz abgehakt
- Sensitive Paths: Human Review dokumentiert (falls Treffer)

**FAIL** (einer genügt):
- ESLint Errors nach 5 Iterationen noch vorhanden
- Semgrep High/Critical nach 5 Iterationen
- Dependency 404 oder High/Critical CVE nicht mitigiert
- Coverage <60% ohne Operator-Freigabe
- Sensitive Path ohne `review-ok`-Bestätigung
