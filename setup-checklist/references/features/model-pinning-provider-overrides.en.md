# Model Pinning & Provider Overrides

> **Mode:** global · **Priority:** important · **Status:** include
> Verified 2026-06-02 against the official Anthropic docs (code.claude.com/docs).

### Step: Pin the model instead of letting aliases drift

Claude Code knows aliases like `opus`, `sonnet`, `haiku`, and `opusplan`. Convenient, but: according to the docs, aliases point to the version currently recommended for your provider and change over time. For reproducible sessions (team, CI, shared settings) this is a problem, because the same setup may run a different model tomorrow.

WHY pin: If you want control, set fixed model names instead of aliases. There are two levels:

1. `settings.json` `"model"` is a starting selection, not enforcement. The user can still choose "Default" in the `/model` picker, which resolves to the system default for their tier. Watch-out detail from the docs: Without the `env` block below, "Default" bypasses your version pin in `model` and `availableModels`.

2. The three ENV variables `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL` control what the aliases and the Default option actually resolve to. They must be full model names (e.g. `claude-opus-4-8`), not an alias. That is how you pin reliably. (Concrete IDs are examples and should be checked against the Models overview.)

Full control according to the docs means: combine three settings. `availableModels` restricts the picker (enforcement only in managed/policy settings; in user/project settings the arrays are merely merged and deduplicated), `model` sets the starting selection, and the `ANTHROPIC_DEFAULT_*_MODEL` pin what Default and the aliases resolve to.

You can force subagents and agent teams onto a fixed model separately with `CLAUDE_CODE_SUBAGENT_MODEL`. This overrides the per-invocation model parameter and the model frontmatter of the subagent definition; `inherit` switches back to normal resolution. Handy for your agent-team setup, e.g. when sub-agents should deliberately run on Haiku.

Third-party providers (Bedrock, Vertex AI, Foundry): The docs make a clear statement here as a warning. As part of the initial setup, set all three `ANTHROPIC_DEFAULT_*_MODEL` to version-specific provider IDs. Otherwise, on a new Anthropic release that is not yet enabled in the account, Bedrock/Vertex users see a notice and a fallback to the previous version for the session, while Foundry users see errors (Foundry has no equivalent startup check). If multiple versions of a family should point to different provider IDs (ARN, version name, deployment name), use `modelOverrides` in the settings file: it maps individual Anthropic model IDs to provider strings. Keys must be valid Anthropic model IDs, unknown keys are ignored; `modelOverrides` works together with `availableModels` (the allowlist is checked against the Anthropic model ID, not against the override value). By the way, `ANTHROPIC_BASE_URL` only changes WHERE requests go, not WHICH model answers.

## Reference (machine-readable)

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

## Audit criteria

- If a reproducible model is desired: settings.json model is a full model name (e.g. claude-opus-4-8), not a bare alias
- When version-pinning via model/availableModels, the matching ANTHROPIC_DEFAULT_*_MODEL are additionally set in the env block (otherwise the picker Default bypasses the pin)
- Third-party providers (Bedrock/Vertex/Foundry): all three ANTHROPIC_DEFAULT_OPUS/SONNET/HAIKU_MODEL pinned to version-specific provider IDs
- availableModels enforcement only in managed/policy settings (in user/project settings the arrays are merely merged and deduplicated, not enforced)
- modelOverrides keys are valid Anthropic model IDs (unknown keys are ignored)
- Do not use ANTHROPIC_SMALL_FAST_MODEL anymore (deprecated in favor of ANTHROPIC_DEFAULT_HAIKU_MODEL)
