# Sandbox setup (Linux/WSL2 + modes)

> **Mode:** global+project · **Priority:** critical · **Status:** include
> Verified 2026-06-02 against the official Anthropic docs (code.claude.com/docs).

## Step: Set up the sandboxed Bash tool

The built-in sandbox feature lets Claude run most shell commands without asking for confirmation on every command. Instead of confirming individual commands, you define once which files and network domains the commands may reach — the operating system enforces this boundary for every Bash command and all child processes. WHY: This shifts security from "model judgment per command" to an OS-enforced boundary that holds even when an allowed command does more than its name suggests. This is the foundation for more autonomous but controlled work.

Here is how to proceed:

1. **Activate.** Run `/sandbox` in a session. The panel shows three tabs (Mode, Overrides, Config) — or just a Dependencies tab if a package is missing on Linux/WSL2. For cross-project activation set `sandbox.enabled: true` in `~/.claude/settings.json`; per project in `.claude/settings.json`.

2. **Prepare Linux/WSL2.** On macOS there is nothing to install (built-in Seatbelt framework). On Linux and WSL2 the sandbox needs two packages: `bubblewrap` (filesystem isolation) and `socat` (network relay to the proxy). Install e.g. `sudo apt-get install bubblewrap socat` (Ubuntu/Debian) or `sudo dnf install bubblewrap socat` (Fedora). Then restart Claude Code — the dependency check runs at startup. Optional for Unix domain socket blocking: `npm install -g @anthropic-ai/sandbox-runtime` (the seccomp filter). On native Windows the sandbox does not run; there run Claude Code in a WSL2 distribution (WSL1 is not supported because bubblewrap needs WSL2 kernel features — check with `wsl -l -v`). On Ubuntu 24.04+ an AppArmor profile for `bwrap` may be needed — check with `sysctl kernel.apparmor_restrict_unprivileged_userns` (if the key is missing or returns 0, there is nothing to do; if it returns 1, add an AppArmor profile for `bwrap`).

3. **Choose a mode.** In the Mode tab choose Auto-Allow or Regular Permissions. WHY: Auto-Allow runs sandboxed commands without a prompt (the sandbox boundary replaces the confirmation) — fast, but assumes that FS and network boundaries are set cleanly; commands that cannot be sandboxed fall back to the normal permission flow. Regular Permissions keeps the normal prompts even for sandboxed commands — more control, more clicks. In both modes the same FS/network boundaries apply; even in Auto-Allow, explicit deny rules as well as `rm`/`rmdir` on `/`, home, or critical system paths still prompt. The mode choice is written to `.claude/settings.local.json` (not into Git).

4. **Set boundaries.** Default: write access only to the working directory, read access to the whole system. WHY this matters: The default read policy also allows credential files like `~/.aws/credentials` and `~/.ssh/` — these belong in `sandbox.filesystem.denyRead`. Add additional write paths (e.g. for `kubectl`, `terraform`, `npm`) via `sandbox.filesystem.allowWrite` instead of taking the whole tool out of the sandbox via `excludedCommands`. Network: by default no domain is pre-allowed — on first access you are asked. Enter trusted domains in `sandbox.network.allowedDomains`, risky ones in `sandbox.network.deniedDomains` (this also blocks against a broader allowedDomains wildcard). Be careful with broad domains (e.g. `github.com`): the proxy only checks the hostname without TLS inspection — an exfiltration path (domain fronting) is possible.

5. **Harden (optional, for teams/security gates).** `sandbox.failIfUnavailable: true` aborts startup instead of continuing unsandboxed when the sandbox does not initialize. `sandbox.allowUnsandboxedCommands: false` (strict sandbox mode) ignores the `dangerouslyDisableSandbox` escape hatch entirely. Both are typically rolled out via Managed Settings. Additionally relevant for organizations: `sandbox.filesystem.allowManagedReadPathsOnly: true` (only Managed allowRead entries apply) and `allowManagedDomainsOnly: true` (domains locked to Managed values), so developers cannot widen the policy locally.

## Reference (machine-readable)

```yaml
# ============================================================
# Sandbox setup (sandboxed Bash tool) — Claude Code
# Source: https://code.claude.com/docs/en/sandboxing + /en/settings
# Placement: global (~/.claude/settings.json) AND project (.claude/settings.json)
# ============================================================

sandbox:
  # Enable sandbox globally. Default false. Boolean.
  # Runs on macOS, Linux, WSL2 — NOT on native Windows (use WSL2 there).
  enabled: true

  # Hard requirement: aborts Claude Code startup if the sandbox does not
  # initialize (e.g. bubblewrap missing). Default false -> otherwise only a warning
  # and fallback to unsandboxed execution. Set to true for security gates.
  failIfUnavailable: false

  # Escape hatch: allows retrying failed sandbox commands via
  # dangerouslyDisableSandbox outside the sandbox
  # (which then goes through the normal permission flow). Default true.
  # Set to false = "Strict sandbox mode" (Overrides tab in /sandbox).
  allowUnsandboxedCommands: true

  # Commands that always run outside the sandbox.
  # Typically: incompatible tools. Example from the docs: "docker *".
  # Needed on WSL2 for Windows binaries (cmd.exe, powershell.exe, /mnt/c/...).
  excludedCommands:
    - "docker *"

  filesystem:
    # Additional write paths outside the working directory.
    # Default: the sandbox may write ONLY to the current working directory.
    # Path prefixes: "/" absolute, "~/" home, "./" or no prefix = project root
    # (for project settings) or ~/.claude (for user settings).
    allowWrite:
      - "~/.kube"
      - "/tmp/build"
    # Explicitly deny write access to specific paths.
    denyWrite: []
    # Deny read access. IMPORTANT: the default read policy allows the entire
    # system incl. credentials (~/.aws/credentials, ~/.ssh/) — block here!
    denyRead:
      - "~/.aws"
      - "~/.ssh"
    # Re-allow within a denied denyRead area.
    # Example: deny home, but allow the project (only in project settings,
    # because "." resolves to the project root there).
    allowRead:
      - "."

  network:
    # Pre-allowed domains. Default: NO domain is pre-allowed — on first
    # access to a new domain Claude Code asks. Enter here
    # to avoid the prompt. Broad domains (e.g. github.com) are an
    # exfiltration risk (the proxy does no TLS inspection).
    allowedDomains: []
    # Explicitly deny domains — even if a broader allowedDomains wildcard
    # would otherwise allow them.
    deniedDomains: []
    # Optional: your own corporate proxy (HTTPS inspection / logging).
    # httpProxyPort: 8080
    # socksProxyPort: 8081

# ------------------------------------------------------------
# Mode choice (written by /sandbox into .claude/settings.local.json):
#   - Auto-Allow: sandboxed commands run without a prompt (the sandbox boundary
#     replaces the confirmation). Commands that cannot be sandboxed fall
#     back to the normal permission flow. Deny rules as well as rm/rmdir on
#     /, home, or critical system paths still prompt.
#   - Regular permissions: all Bash commands go through the normal
#     permission flow, even when sandboxed.
# Both modes enforce the same FS/network boundaries.
# ------------------------------------------------------------

# ------------------------------------------------------------
# Linux/WSL2 prerequisites (nothing needed on macOS — Seatbelt built in):
#   Ubuntu/Debian: sudo apt-get install bubblewrap socat
#   Fedora:        sudo dnf install bubblewrap socat
#   - bubblewrap = filesystem isolation (unprivileged)
#   - socat      = network relay to the sandbox proxy
#   - ripgrep    = bundled in the native Claude Code binary
#   - seccomp filter (optional, blocks Unix domain sockets):
#       npm install -g @anthropic-ai/sandbox-runtime
#   After installation restart Claude Code; status via /sandbox -> Dependencies.
#   Ubuntu 24.04+: AppArmor profile for bwrap may be needed (user namespaces),
#     check with: sysctl kernel.apparmor_restrict_unprivileged_userns
#     (key missing or returns 0 = nothing to do; 1 = profile needed)
#   WSL1 not supported (bubblewrap needs WSL2 kernel features):
#     check the WSL version with wsl -l -v.
# ------------------------------------------------------------
```

## Audit criteria

- sandbox.enabled is set (true/false consciously decided, not implicitly default false)
- On Linux/WSL2: bubblewrap AND socat installed (check via /sandbox -> Dependencies tab)
- Credential directories ~/.aws and ~/.ssh are in sandbox.filesystem.denyRead (the default read policy allows them otherwise)
- sandbox.network.allowedDomains contains no overly broad wildcards like github.com without a conscious risk assessment (no TLS inspection, domain fronting possible)
- Mode chosen consciously: Auto-Allow only if FS/network boundaries are set cleanly
- For security gates: sandbox.failIfUnavailable: true and sandbox.allowUnsandboxedCommands: false set
- With broad allowWrite/allowedDomains/excludedCommands, checked that the other side (network or FS) does not undermine the relaxation
- On native Windows: Claude Code runs in WSL2 (not WSL1), not natively
