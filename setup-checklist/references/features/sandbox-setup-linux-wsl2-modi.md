# Sandbox-Setup (Linux/WSL2 + Modi)

> **Modus:** global+projekt · **Prioritaet:** kritisch · **Status:** include
> Verifiziert 2026-06-02 gegen die offizielle Anthropic-Doku (code.claude.com/docs).

## Schritt: Gesandboxtes Bash-Tool einrichten

Das eingebaute Sandbox-Feature laesst Claude die meisten Shell-Befehle ausfuehren, ohne bei jedem Befehl nachzufragen. Statt einzelne Kommandos zu bestaetigen, definierst du einmal, welche Dateien und Netzwerk-Domains die Befehle erreichen duerfen — das Betriebssystem erzwingt diese Grenze fuer jeden Bash-Befehl und alle Kindprozesse. WARUM: Das verschiebt Sicherheit von "Modell-Urteil pro Befehl" auf eine OS-erzwungene Grenze, die auch dann haelt, wenn ein erlaubter Befehl mehr tut als sein Name verspricht. Das ist die Grundlage fuer autonomeres, aber kontrolliertes Arbeiten.

So gehst du vor:

1. **Aktivieren.** In einer Session `/sandbox` ausfuehren. Das Panel zeigt drei Tabs (Mode, Overrides, Config) — oder nur einen Dependencies-Tab, falls auf Linux/WSL2 ein Paket fehlt. Fuer projektuebergreifende Aktivierung `sandbox.enabled: true` in `~/.claude/settings.json` setzen; pro Projekt in `.claude/settings.json`.

2. **Linux/WSL2 vorbereiten.** Auf macOS ist nichts zu installieren (eingebautes Seatbelt-Framework). Auf Linux und WSL2 braucht die Sandbox zwei Pakete: `bubblewrap` (Filesystem-Isolation) und `socat` (Netzwerk-Relay zum Proxy). Installation z.B. `sudo apt-get install bubblewrap socat` (Ubuntu/Debian) bzw. `sudo dnf install bubblewrap socat` (Fedora). Danach Claude Code neu starten — der Dependency-Check laeuft beim Start. Optional fuer Unix-Domain-Socket-Blocking: `npm install -g @anthropic-ai/sandbox-runtime` (der seccomp-Filter). Auf nativem Windows laeuft die Sandbox nicht; dort Claude Code in einer WSL2-Distribution betreiben (WSL1 wird nicht unterstuetzt, weil bubblewrap WSL2-Kernel-Features braucht — pruefen mit `wsl -l -v`). Bei Ubuntu 24.04+ kann ein AppArmor-Profil fuer `bwrap` noetig sein — pruefen mit `sysctl kernel.apparmor_restrict_unprivileged_userns` (fehlt der Key oder gibt 0 zurueck, ist nichts zu tun; gibt 1 zurueck, AppArmor-Profil fuer `bwrap` ergaenzen).

3. **Modus waehlen.** Im Mode-Tab Auto-Allow oder Regular Permissions waehlen. WARUM: Auto-Allow fuehrt gesandboxte Befehle ohne Prompt aus (die Sandbox-Grenze ersetzt die Bestaetigung) — schnell, aber setzt voraus, dass FS- und Netz-Grenzen sauber gesetzt sind; Befehle, die nicht sandboxbar sind, fallen in den normalen Permission-Flow zurueck. Regular Permissions behaelt die normalen Prompts auch bei gesandboxten Befehlen — mehr Kontrolle, mehr Klicks. In beiden Modi gelten dieselben FS-/Netz-Grenzen; selbst in Auto-Allow prompten explizite Deny-Rules sowie `rm`/`rmdir` auf `/`, Home oder kritische Systempfade weiterhin. Die Modus-Wahl schreibt in `.claude/settings.local.json` (nicht ins Git).

4. **Grenzen setzen.** Standard: Schreibzugriff nur aufs Arbeitsverzeichnis, Lesezugriff aufs ganze System. WARUM das wichtig ist: Die Default-Lesepolitik erlaubt auch Credential-Dateien wie `~/.aws/credentials` und `~/.ssh/` — diese gehoeren in `sandbox.filesystem.denyRead`. Zusaetzliche Schreibpfade (z.B. fuer `kubectl`, `terraform`, `npm`) ueber `sandbox.filesystem.allowWrite` statt das ganze Tool ueber `excludedCommands` aus der Sandbox zu nehmen. Netzwerk: Standardmaessig ist keine Domain vorab erlaubt — beim ersten Zugriff wird gefragt. Vertraute Domains in `sandbox.network.allowedDomains` eintragen, Riskantes in `sandbox.network.deniedDomains` (sperrt auch gegen ein breiteres allowedDomains-Wildcard). Vorsicht bei breiten Domains (z.B. `github.com`): Der Proxy prueft nur den Hostnamen ohne TLS-Inspection — Exfiltrations-Pfad (Domain Fronting) moeglich.

5. **Hart absichern (optional, fuer Teams/Security-Gates).** `sandbox.failIfUnavailable: true` bricht den Start ab, statt ungesandboxt weiterzulaufen, wenn die Sandbox nicht initialisiert. `sandbox.allowUnsandboxedCommands: false` (Strict sandbox mode) ignoriert den `dangerouslyDisableSandbox`-Escape-Hatch komplett. Beides wird typischerweise ueber Managed Settings ausgerollt. Fuer Organisationen zusaetzlich relevant: `sandbox.filesystem.allowManagedReadPathsOnly: true` (nur Managed-allowRead-Eintraege gelten) und `allowManagedDomainsOnly: true` (Domains auf Managed-Werte gesperrt), damit Entwickler die Policy nicht lokal aufweiten.

## Referenz (maschinenlesbar)

```yaml
# ============================================================
# Sandbox-Setup (gesandboxtes Bash-Tool) — Claude Code
# Quelle: https://code.claude.com/docs/en/sandboxing + /en/settings
# Platzierung: global (~/.claude/settings.json) UND projekt (.claude/settings.json)
# ============================================================

sandbox:
  # Sandbox global aktivieren. Default false. Boolean.
  # Laeuft auf macOS, Linux, WSL2 — NICHT auf nativem Windows (dort WSL2 nutzen).
  enabled: true

  # Harte Pflicht: bricht Claude-Code-Start ab, wenn die Sandbox nicht
  # initialisiert (z.B. bubblewrap fehlt). Default false -> sonst nur Warnung
  # und Fallback auf ungesandboxte Ausfuehrung. Fuer Security-Gates auf true.
  failIfUnavailable: false

  # Escape-Hatch: erlaubt, fehlgeschlagene Sandbox-Befehle via
  # dangerouslyDisableSandbox ausserhalb der Sandbox erneut zu versuchen
  # (geht dann durch den normalen Permission-Flow). Default true.
  # Auf false = "Strict sandbox mode" (Overrides-Tab in /sandbox).
  allowUnsandboxedCommands: true

  # Befehle, die grundsaetzlich ausserhalb der Sandbox laufen.
  # Typisch: inkompatible Tools. Beispiel aus Doku: "docker *".
  # Auf WSL2 noetig fuer Windows-Binaries (cmd.exe, powershell.exe, /mnt/c/...).
  excludedCommands:
    - "docker *"

  filesystem:
    # Zusaetzliche Schreibpfade ausserhalb des Arbeitsverzeichnisses.
    # Default: Sandbox darf NUR ins aktuelle Arbeitsverzeichnis schreiben.
    # Pfad-Prefixe: "/" absolut, "~/" Home, "./" bzw. ohne Prefix = Projekt-Root
    # (bei Projekt-Settings) bzw. ~/.claude (bei User-Settings).
    allowWrite:
      - "~/.kube"
      - "/tmp/build"
    # Schreibzugriff auf bestimmte Pfade explizit sperren.
    denyWrite: []
    # Lesezugriff sperren. WICHTIG: Default-Lesepolitik erlaubt das gesamte
    # System inkl. Credentials (~/.aws/credentials, ~/.ssh/) — hier blocken!
    denyRead:
      - "~/.aws"
      - "~/.ssh"
    # Innerhalb eines gesperrten denyRead-Bereichs wieder freigeben.
    # Beispiel: Home sperren, aber Projekt erlauben (nur in Projekt-Settings,
    # weil "." dort auf den Projekt-Root aufloest).
    allowRead:
      - "."

  network:
    # Vorab erlaubte Domains. Default: KEINE Domain vorab erlaubt — beim ersten
    # Zugriff auf eine neue Domain fragt Claude Code nach. Hier eintragen,
    # um den Prompt zu vermeiden. Breite Domains (z.B. github.com) sind ein
    # Exfiltrations-Risiko (Proxy macht kein TLS-Inspection).
    allowedDomains: []
    # Domains explizit sperren — auch wenn ein breiteres allowedDomains-Wildcard
    # sie sonst erlauben wuerde.
    deniedDomains: []
    # Optional: eigener Corporate-Proxy (HTTPS-Inspection / Logging).
    # httpProxyPort: 8080
    # socksProxyPort: 8081

# ------------------------------------------------------------
# Modus-Wahl (geschrieben von /sandbox in .claude/settings.local.json):
#   - Auto-Allow: gesandboxte Befehle laufen ohne Prompt (Sandbox-Grenze
#     ersetzt die Bestaetigung). Befehle, die nicht sandboxbar sind, fallen
#     in den normalen Permission-Flow zurueck. Deny-Rules sowie rm/rmdir auf
#     /, Home oder kritische Systempfade prompten weiter.
#   - Regular permissions: alle Bash-Befehle gehen durch den normalen
#     Permission-Flow, auch wenn gesandboxt.
# Beide Modi erzwingen dieselben FS-/Netz-Grenzen.
# ------------------------------------------------------------

# ------------------------------------------------------------
# Linux/WSL2-Voraussetzungen (auf macOS nichts noetig — Seatbelt eingebaut):
#   Ubuntu/Debian: sudo apt-get install bubblewrap socat
#   Fedora:        sudo dnf install bubblewrap socat
#   - bubblewrap = Filesystem-Isolation (unprivilegiert)
#   - socat      = Netzwerk-Relay zum Sandbox-Proxy
#   - ripgrep    = im nativen Claude-Code-Binary gebuendelt
#   - seccomp-Filter (optional, blockt Unix-Domain-Sockets):
#       npm install -g @anthropic-ai/sandbox-runtime
#   Nach Installation Claude Code neu starten; Status via /sandbox -> Dependencies.
#   Ubuntu 24.04+: ggf. AppArmor-Profil fuer bwrap noetig (User-Namespaces),
#     pruefen mit: sysctl kernel.apparmor_restrict_unprivileged_userns
#     (fehlt der Key oder gibt 0 zurueck = nichts zu tun; 1 = Profil noetig)
#   WSL1 nicht unterstuetzt (bubblewrap braucht WSL2-Kernel-Features):
#     WSL-Version pruefen mit wsl -l -v.
# ------------------------------------------------------------
```

## Audit-Kriterien

- sandbox.enabled ist gesetzt (true/false bewusst entschieden, nicht implizit Default false)
- Auf Linux/WSL2: bubblewrap UND socat installiert (Check via /sandbox -> Dependencies-Tab)
- Credential-Verzeichnisse ~/.aws und ~/.ssh stehen in sandbox.filesystem.denyRead (Default-Lesepolitik erlaubt sie sonst)
- sandbox.network.allowedDomains enthaelt keine zu breiten Wildcards wie github.com ohne bewusste Risikoabwaegung (kein TLS-Inspection, Domain-Fronting moeglich)
- Modus bewusst gewaehlt: Auto-Allow nur wenn FS-/Netz-Grenzen sauber gesetzt sind
- Fuer Security-Gates: sandbox.failIfUnavailable: true und sandbox.allowUnsandboxedCommands: false gesetzt
- Bei breitem allowWrite/allowedDomains/excludedCommands geprueft, dass die Gegenseite (Netz bzw. FS) die Lockerung nicht untergraebt
- Auf nativem Windows: Claude Code laeuft in WSL2 (nicht WSL1), nicht nativ
