# Skills (.claude/skills/) — Ordnerstruktur, Skills vs. Subagents, Skill-Settings

> **Modus:** ? · **Prioritaet:** ? · **Status:** include-with-fixes
> Verifiziert 2026-06-02 gegen die offizielle Anthropic-Doku (code.claude.com/docs).

## Schritt: Skills einrichten (.claude/skills/)

Skills erweitern, was Claude kann: Du legst eine SKILL.md mit Anweisungen an, und Claude nimmt sie in sein Repertoire auf — entweder automatisch (wenn die `description` passt) oder direkt per `/skill-name`. Der Clou gegenueber CLAUDE.md: Der Skill-Body laedt nur, wenn der Skill wirklich genutzt wird. Lange Referenz-Prozeduren kosten also fast keine Tokens, bis sie gebraucht werden. Faustregel: Sobald du dieselbe Checkliste oder Mehrschritt-Prozedur wiederholt in den Chat kopierst — oder ein CLAUDE.md-Abschnitt von einer Tatsache zu einer Prozedur gewachsen ist — gehoert das in einen Skill.

Lege Skills an zwei Orten ab. Global (`~/.claude/skills/<name>/SKILL.md`) fuer alles, was du projektuebergreifend brauchst; pro Projekt (`.claude/skills/<name>/SKILL.md`, in die Versionskontrolle eingecheckt) fuer projektspezifische Ablaeufe, die das ganze Team teilen soll. Bei Namensgleichheit gilt: enterprise ueberschreibt personal, personal ueberschreibt project; Plugin-Skills nutzen einen `plugin-name:skill-name`-Namespace und kollidieren nicht. Jeder Skill ist ein Ordner, in dem nur SKILL.md Pflicht ist; Detail-Doku, Beispiele und Scripts kommen als Begleitdateien daneben und werden erst bei Bedarf geladen. Wichtig: Der Kommandoname kommt vom Ordnernamen, nicht vom Frontmatter-Feld `name`.

In der SKILL.md ist nur die `description` wirklich empfohlen — sie entscheidet, wann Claude den Skill von selbst zieht, also den Schluessel-Use-Case nach vorne. WARUM die Disziplin: Beschreibungen werden in den Kontext geladen und bei vielen Skills auf ein Budget gekuerzt; eine schwammige description faellt dann zuerst raus. Steuere die Aufruf-Logik bewusst: `disable-model-invocation: true` (Default false) fuer Aktionen mit Nebenwirkungen (Deploy, Commit), die nur du ausloesen sollst; `user-invocable: false` (Default true) fuer reines Hintergrundwissen, das nie als Kommando sinnvoll ist.

Entscheide Skill vs. Subagent nach Isolation: Ein normaler Skill laeuft inline im aktuellen Kontext (gut fuer Wissen und Konventionen). Soll ein Skill abgeschottet und ohne deine Chat-Historie laufen, setzt du `context: fork` und waehlst mit `agent:` den Subagent-Typ (ohne Angabe `general-purpose`) — aber nur, wenn die SKILL.md einen konkreten Task enthaelt, sonst bekommt der Subagent Richtlinien ohne Auftrag und liefert nichts.

Vier Settings sind relevant: `skillOverrides` steuert die Sichtbarkeit einzelner Skills aus den Settings heraus (Werte on / name-only / user-invocable-only / off; fehlende Skills gelten als on) — praktisch fuer fremde oder eingecheckte Skills, deren SKILL.md du nicht editieren willst; `skillListingBudgetFraction` hebt das Beschreibungs-Budget an (skaliert standardmaessig auf 1% des Context-Windows, dokumentiertes Beispiel 0.02 fuer 2%); `maxSkillDescriptionChars` deckelt jeden Eintrag (Doku-Cap-Wert 1.536 Zeichen); `disableSkillShellExecution` schaltet die !`cmd`-Shell-Injektion ab (ersetzt durch `[shell command execution disabled by policy]`; bundled und managed Skills ausgenommen) und ist vor allem in managed settings sinnvoll, wo Nutzer es nicht ueberschreiben koennen. Bei Problemen zeigt `/doctor`, ob das Budget ueberlaeuft und welche Skills betroffen sind.

## Referenz (maschinenlesbar)

```yaml
# ============================================================
# Skills (.claude/skills/) — Best-Practice-Baustein v17
# Quelle: https://code.claude.com/docs/en/skills (live geprueft 2026-06-02)
# Platzierung: global (~/.claude/skills/) UND projekt (.claude/skills/)
# ============================================================

skills:
  # --- Ordnerstruktur ---------------------------------------
  struktur:
    # Jeder Skill ist ein Ordner; SKILL.md ist der Pflicht-Einstiegspunkt.
    pflicht_datei: "SKILL.md"            # einziger Pflicht-Bestandteil je Skill
    # Personal/global: gilt fuer ALLE eigenen Projekte
    pfad_global: "~/.claude/skills/<skill-name>/SKILL.md"
    # Projekt: gilt nur fuer dieses Projekt (in Versionskontrolle einchecken)
    pfad_projekt: ".claude/skills/<skill-name>/SKILL.md"
    # Optionale Begleitdateien (werden nur bei Bedarf geladen):
    optionale_dateien:
      - "reference.md / examples.md"      # Detail-Doku, on-demand geladen
      - "scripts/<datei>"                 # ausfuehrbar, nicht in Kontext geladen
      - "template.md"                     # Vorlage zum Ausfuellen
    # Kommandoname = Ordnername (NICHT das Frontmatter-Feld 'name'):
    # .claude/skills/deploy-staging/ -> /deploy-staging
    # Vorrang bei Namensgleichheit: enterprise > personal > projekt
    # (Plugin-Skills nutzen plugin-name:skill-name-Namespace, kollidieren nicht)
    tipp_groesse: "SKILL.md unter 500 Zeilen halten; Details auslagern"

  # --- SKILL.md Frontmatter (alle Felder optional) ----------
  frontmatter:
    description: "empfohlen — Was + WANN; Schluessel-Use-Case zuerst"   # Cap 1.536 Zeichen
    name: "optional — Anzeigename in Listings; Default = Ordnername"
    when_to_use: "optional — Trigger-Phrasen; zaehlt zum 1.536-Zeichen-Cap"
    disable-model-invocation: false      # true = nur Nutzer (/name), Claude nicht (Default false)
    user-invocable: true                 # false = nur Claude, nicht im /-Menue (Default true)
    allowed-tools: ""                    # Tools ohne Nachfrage waehrend Skill aktiv
    context: ""                          # "fork" = isolierter Subagent-Kontext (ohne Chat-Historie)
    agent: ""                            # Subagent-Typ bei context: fork (Default general-purpose)
    paths: ""                            # Glob-Muster: Auto-Aktivierung nur bei passenden Dateien

  # --- Skills vs. Subagents ---------------------------------
  # Skill = Anweisungen/Wissen, laeuft INLINE im aktuellen Kontext.
  # Subagent = isolierte Ausfuehrung in eigenem Kontext.
  # Skill in Subagent laufen lassen: 'context: fork' + 'agent: <typ>' setzen.
  #   -> nur sinnvoll fuer Skills mit konkretem TASK, nicht fuer reine Guidelines.
  # Umgekehrt: Subagent mit 'skills'-Feld laedt Skills vorab als Referenz.

  # --- Relevante Settings (settings.json / .local.json) -----
  settings:
    # Sichtbarkeit pro Skill ueberschreiben, ohne SKILL.md zu editieren.
    # Werte: "on" | "name-only" | "user-invocable-only" | "off"
    # Fehlende Skills gelten als "on". /skills-Menue schreibt nach
    # .claude/settings.local.json. Plugin-Skills sind nicht betroffen.
    skillOverrides:
      # beispiel-skill: "name-only"
    # Budget fuer Skill-Beschreibungen (skaliert standardmaessig auf 1% des
    # Context-Windows). Wert ist ein Bruchteil; dokumentiertes Beispiel:
    skillListingBudgetFraction: 0.02     # 0.02 = 2% (Beispiel aus der Doku, nicht der Default)
    # Obergrenze pro Skill-Eintrag (description + when_to_use).
    # Doku-Cap-Wert: 1.536 Zeichen (Setting-Default auf der Seite nicht beziffert).
    maxSkillDescriptionChars: 1536
    # Schaltet !`cmd`-Shell-Injektion in Skills/Commands ab (Policy).
    # Standardverhalten: Ausfuehrung aktiv. Am sinnvollsten in managed settings.
    # Ersetzt jeden Befehl durch [shell command execution disabled by policy];
    # bundled und managed Skills sind ausgenommen.
    disableSkillShellExecution: false
```

## Audit-Kriterien

- Pro Skill existiert genau eine SKILL.md im Ordner ~/.claude/skills/<name>/ bzw. .claude/skills/<name>/
- Jede SKILL.md hat eine description mit Schluessel-Use-Case zuerst (description + when_to_use unter 1.536 Zeichen)
- SKILL.md unter 500 Zeilen; Detail-Doku in Begleitdateien ausgelagert
- Skills mit Nebenwirkungen (Deploy/Commit) haben disable-model-invocation: true
- Projekt-Skills unter .claude/skills/ sind in der Versionskontrolle eingecheckt
- Skills mit context: fork enthalten einen konkreten Task (keine reinen Guidelines)
- Falls disableSkillShellExecution-Policy gewuenscht: in managed settings gesetzt, damit Nutzer es nicht ueberschreiben
- /doctor zeigt keinen Ueberlauf des Skill-Listing-Budgets (sonst skillListingBudgetFraction anheben oder Eintraege auf name-only setzen)

## Vom Verifizierer entfernt / abgeschwaecht (nicht belegbar)

- maxSkillDescriptionChars Default 1.536 Zeichen — die Doku bestaetigt 1.536 nur als Cap-Wert der kombinierten description+when_to_use und sagt, der Cap sei 'configurable with maxSkillDescriptionChars'. Sie bestaetigt NICHT, dass 1.536 zugleich der Settings-Default ist. Kommentar von 'Default 1.536' auf 'Cap-Wert 1.536, konfigurierbar' korrigiert (kein Inhalt entfernt, nur praezisiert).
- disableSkillShellExecution Default false — die Doku beschreibt nur das Verhalten bei true und dass Ausfuehrung das Standardverhalten ist; 'Default: false' steht nicht woertlich auf der Seite. Kommentar entsprechend von 'Default false' auf 'Standardverhalten: Ausfuehrung aktiv (kein expliziter Default auf der Seite)' korrigiert.
- skillListingBudgetFraction numerischer Default — die Doku nennt nur '1% des Context-Windows', keinen numerischen Default-Bruchteil. Der eingetragene Wert 0.02 ist explizit nur das dokumentierte Beispiel (= 2%), nicht der Default. War im Entwurf bereits korrekt als Beispiel markiert, beibehalten.
