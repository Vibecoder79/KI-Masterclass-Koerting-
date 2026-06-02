# Model-Pinning & Provider-Overrides

> **Modus:** global · **Prioritaet:** wichtig · **Status:** include
> Verifiziert 2026-06-02 gegen die offizielle Anthropic-Doku (code.claude.com/docs).

### Schritt: Modell pinnen statt Aliase treiben lassen

Claude Code kennt Aliase wie `opus`, `sonnet`, `haiku` und `opusplan`. Praktisch, aber: Aliase zeigen laut Doku auf die jeweils empfohlene Version fuer deinen Provider und aendern sich ueber die Zeit. Fuer reproduzierbare Sessions (Team, CI, geteilte Settings) ist das ein Problem, weil dasselbe Setup morgen ein anderes Modell fahren kann.

WARUM pinnen: Wer Kontrolle will, setzt feste Modellnamen statt Aliase. Es gibt zwei Ebenen:

1. `settings.json` `"model"` ist eine Startauswahl, keine Erzwingung. Der Nutzer kann im `/model`-Picker weiterhin "Default" waehlen, was auf den System-Default seines Tiers aufloest. Achtung-Detail aus der Doku: Ohne den `env`-Block unten umgeht "Default" deinen Versions-Pin in `model` und `availableModels`.

2. Die drei ENV-Variablen `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL` steuern, worauf die Aliase und die Default-Option tatsaechlich aufloesen. Sie muessen volle Modellnamen sein (z.B. `claude-opus-4-8`), kein Alias. So pinnst du verlaesslich. (Konkrete IDs sind Beispiele und sollten gegen die Models overview geprueft werden.)

Voll kontrollieren laut Doku heisst: drei Settings kombinieren. `availableModels` schraenkt den Picker ein (Enforcement nur in managed/policy settings, in User-/Projekt-Settings werden Arrays nur gemerged und dedupliziert), `model` setzt die Startauswahl, und die `ANTHROPIC_DEFAULT_*_MODEL` pinnen, worauf Default und Aliase aufloesen.

Subagents und Agent-Teams kannst du separat mit `CLAUDE_CODE_SUBAGENT_MODEL` auf ein festes Modell zwingen. Das ueberschreibt den per-invocation model-Parameter und das model-Frontmatter der Subagent-Definition; `inherit` schaltet zurueck auf normale Aufloesung. Fuer dein Agenten-Team-Setup praktisch, wenn z.B. Sub-Agents bewusst auf Haiku laufen sollen.

Drittanbieter (Bedrock, Vertex AI, Foundry): Die Doku macht hier eine klare Ansage als Warnung. Als Teil des initialen Setups alle drei `ANTHROPIC_DEFAULT_*_MODEL` auf versionsspezifische Provider-IDs setzen. Sonst sehen Bedrock-/Vertex-Nutzer bei einem neuen, im Account noch nicht freigeschalteten Anthropic-Release einen Hinweis und einen Fallback auf die Vorversion fuer die Session, Foundry-Nutzer sehen Errors (Foundry hat keinen aequivalenten Startup-Check). Wenn mehrere Versionen einer Familie auf unterschiedliche Provider-IDs (ARN, Version-Name, Deployment-Name) zeigen sollen, nutzt du `modelOverrides` in der Settings-Datei: es mappt einzelne Anthropic-Model-IDs auf Provider-Strings. Keys muessen gueltige Anthropic-Model-IDs sein, unbekannte Keys werden ignoriert; `modelOverrides` arbeitet mit `availableModels` zusammen (die Allowlist wird gegen die Anthropic-Model-ID geprueft, nicht gegen den Override-Wert). `ANTHROPIC_BASE_URL` aendert uebrigens nur, WOHIN Requests gehen, nicht WELCHES Modell antwortet.

## Referenz (maschinenlesbar)

```yaml
# Model-Pinning & Provider-Overrides (global)
# Quelle: https://code.claude.com/docs/en/model-config
# Zweck: Reproduzierbare Modellauswahl. Aliase (sonnet/opus/haiku) zeigen
# auf die jeweils empfohlene Version fuer den Provider und aendern sich ueber die Zeit.
# Wer reproduzierbar arbeiten will (Team, CI, Drittanbieter), pinnt feste IDs.

model_pinning:

  # settings.json "model": Startauswahl, KEINE Erzwingung.
  # Nutzer kann im /model-Picker weiterhin "Default" waehlen.
  # Voller Modellname pinnt auf eine Version (z.B. "claude-opus-4-8").
  settings_model: "claude-opus-4-8"   # oder Alias wie "opus" / "opusplan"

  # Aliase mappen auf feste Versionen. Diese ENV-Variablen MUESSEN
  # volle Modellnamen sein (kein Alias). Steuern, worauf opus/sonnet/haiku
  # und die Default-Option im Picker aufloesen.
  # HINWEIS: konkrete IDs sind Beispiele - vor Einsatz gegen die
  # Models overview (platform.claude.com) pruefen.
  env:
    ANTHROPIC_DEFAULT_OPUS_MODEL: "claude-opus-4-8"     # Modell fuer "opus" (+ opusplan bei aktivem Plan Mode)
    ANTHROPIC_DEFAULT_SONNET_MODEL: "claude-sonnet-4-6" # Modell fuer "sonnet" (+ opusplan bei NICHT aktivem Plan Mode)
    ANTHROPIC_DEFAULT_HAIKU_MODEL: "claude-haiku-4-5"   # Modell fuer "haiku" + Background-Funktionalitaet
    # 1M-Context an OPUS/SONNET-Alias haengen: Suffix [1m] anfuegen
    # ANTHROPIC_DEFAULT_OPUS_MODEL: "claude-opus-4-8[1m]"

  # ANTHROPIC_MODEL: Modell-Setting fuer EINE Session (wie --model).
  # Gilt nur fuer die damit gestartete Session, nicht persistent.
  # ANTHROPIC_MODEL: "opus"

  # Subagents/Agent-Teams auf ein festes Modell zwingen.
  # Ueberschreibt den per-invocation model-Parameter UND das
  # model-Frontmatter der Subagent-Definition.
  # "inherit" = normale Modell-Aufloesung statt Override.
  # CLAUDE_CODE_SUBAGENT_MODEL: "claude-haiku-4-5"

  # availableModels: Allowlist fuer den /model-Picker.
  # Enforcement nur in managed/policy settings (Enterprise);
  # in User-/Projekt-Settings werden Arrays nur gemerged und dedupliziert.
  # Matching laeuft ueber den Alias / die Anthropic-Model-ID, nicht
  # ueber die Provider-Override-Werte.
  # Die Default-Option im Picker bleibt von availableModels unberuehrt
  # und ist immer verfuegbar (Tier-Default).
  availableModels: ["sonnet", "haiku"]

# Drittanbieter (Bedrock / Vertex AI / Foundry):
# Warnung laut Doku: alle drei ANTHROPIC_DEFAULT_*_MODEL als Teil des
# initialen Setups auf versionsspezifische Provider-IDs pinnen.
# Ohne Pinning: Bedrock/Vertex zeigen Hinweis + Fallback auf Vorversion
# fuer die Session; Foundry zeigt Errors (kein Startup-Check).
# Provider-ID-Format (Beispiele aus Doku):
#   Bedrock:   us.anthropic.claude-opus-4-8
#   Vertex AI: claude-opus-4-8  (version name)
#   Foundry:   claude-opus-4-8  (deployment name)

# modelOverrides: mappt einzelne Anthropic-Model-IDs auf provider-spezifische
# Strings. Nutzen, wenn mehrere Versionen einer Familie auf unterschiedliche
# Provider-IDs (ARN / Version / Deployment) zeigen sollen.
# Keys MUESSEN gueltige Anthropic-Model-IDs sein (mit Datums-Suffix exakt
# wie in Models overview); unbekannte Keys werden ignoriert.
# Werte aus ANTHROPIC_MODEL/--model/ANTHROPIC_DEFAULT_*_MODEL werden NICHT
# durch modelOverrides transformiert.
modelOverrides:
  claude-opus-4-7: "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-prod"
  claude-sonnet-4-6: "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/sonnet-prod"
```

## Audit-Kriterien

- Wenn reproduzierbares Modell gewuenscht: settings.json model ist ein voller Modellname (z.B. claude-opus-4-8), kein blosser Alias
- Bei Versions-Pin via model/availableModels sind zusaetzlich die passenden ANTHROPIC_DEFAULT_*_MODEL im env-Block gesetzt (sonst umgeht Picker-Default den Pin)
- Drittanbieter (Bedrock/Vertex/Foundry): alle drei ANTHROPIC_DEFAULT_OPUS/SONNET/HAIKU_MODEL auf versionsspezifische Provider-IDs gepinnt
- availableModels-Enforcement nur in managed/policy settings (in User-/Projekt-Settings werden Arrays nur gemerged und dedupliziert, nicht erzwungen)
- modelOverrides-Keys sind gueltige Anthropic-Model-IDs (unbekannte Keys werden ignoriert)
- ANTHROPIC_SMALL_FAST_MODEL nicht mehr verwenden (deprecated zugunsten ANTHROPIC_DEFAULT_HAIKU_MODEL)
