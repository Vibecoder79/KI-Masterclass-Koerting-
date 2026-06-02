# additionalDirectories / Working Dirs (Multi-Directory Access)

> **Mode:** global+project · **Priority:** important · **Status:** include-with-fixes
> Verified 2026-06-02 against the official Anthropic docs (code.claude.com/docs).

## Working Directories: Access Beyond the Start Directory

By default, Claude Code only sees files in the directory it was started from. As soon as you work on multiple repos or a shared library in parallel, you need additional working directories — otherwise Claude has to laboriously request every file outside the start folder, or can't reach it at all.

The docs name three ways to extend access:

- **Persistent (recommended for a permanent setup):** Add the paths under `permissions.additionalDirectories` in a `settings.json` — globally in `~/.claude/settings.json` for cross-project paths, project-scoped in `.claude/settings.json` for repo neighbors. (Note: the permissions page shows no concrete code example for the value; whether relative or only absolute paths are allowed is not specified there — when in doubt, check the settings reference.)
- **At startup (one-time):** Start with `--add-dir <path>`.
- **Mid-session:** Type `/add-dir` to add a folder to the running session.

Files in additional directories follow the same permission rules as the start directory: they become readable without prompting, and edits follow the current permission mode. In `acceptEdits` mode, file edits and common filesystem commands for paths in the start directory or in `additionalDirectories` are accepted automatically; a `cd` into a path within these directories is treated as read-only.

**Important pitfall (per the docs):** An additional directory grants file access but does not turn the folder into a full configuration root. Only `--add-dir`/`/add-dir` load limited configuration on top (skills from `.claude/skills/` with live reload; plugin settings limited to `enabledPlugins` and `extraKnownMarketplaces`; CLAUDE.md, `.claude/rules/`, and `CLAUDE.local.md` only when the environment variable `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` is set — `CLAUDE.local.md` additionally requires the `local` setting source, which is active by default). Paths in `permissions.additionalDirectories` load none of this — they grant file access only. So if you expect skills or CLAUDE.md from a neighboring repo to take effect, the settings.json entry alone is not enough.

## Reference (machine-readable)

```yaml
# Working Directories / additionalDirectories — access beyond the start directory
# Source: https://code.claude.com/docs/en/permissions (section "Working directories")
# Default: Claude only has access to the directory it was started in.
# Three ways to extend this access:

working_directories:
  # 1) Persistent configuration in the settings.json (global ~/.claude/ or project .claude/)
  additionalDirectories:
    key: permissions.additionalDirectories   # entry in a settings file
    wirkung: >-
      Additional directories follow the same permission rules as the
      start directory: they become readable without prompting, and file edits follow
      the current permission mode. CAUTION: grants ONLY file access, NO
      configuration discovery (no skills/CLAUDE.md/hooks from these directories).
    # NOTE: The permissions docs show NO code example for the value.
    # The form (list of paths) is strongly implied by the text, but is not
    # literally documented on this page. Whether relative or only absolute paths are allowed
    # is NOT specified here — check the settings reference before use.

  # 2) At startup: CLI flag (temporary for the session)
  add_dir_cli: "--add-dir <path>"   # extends access at program startup

  # 3) During the session: slash command
  add_dir_command: "/add-dir"       # adds a directory to the running session

# IMPORTANT DIFFERENCE (per the docs):
# The following configuration exceptions apply ONLY to directories added via
# the --add-dir flag or the /add-dir command:
#   - Skills from .claude/skills/ (with live reload)
#   - Plugin settings from .claude/settings.json (only enabledPlugins + extraKnownMarketplaces)
#   - CLAUDE.md / .claude/rules/ / CLAUDE.local.md ONLY when ENV
#     CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 is set
#     (CLAUDE.local.md additionally requires the 'local' setting source, active by default)
# Directories from permissions.additionalDirectories (settings.json) load
# NONE of this — file access only.

# permission_mode_bezug (per the docs):
#   - acceptEdits accepts file edits and common filesystem commands automatically
#     for paths in the start directory OR in additionalDirectories.
#   - A 'cd' into a path within the start/additional directory is treated as read-only.
```

## Audit criteria

- Check settings.json: when working on multiple repos/a shared library, permissions.additionalDirectories is set (list of paths)
- Paths in additionalDirectories actually exist and point to the intended directories
- Check the expectation: is skill/CLAUDE.md discovery expected from an additional directory? Then --add-dir/-/add-dir is needed (possibly CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1) instead of just settings.json
- No sensitive/overly broad paths (e.g. the entire home directory) in additionalDirectories, since contents become readable without prompting

## Removed / softened by the verifier (not documented)

- Concrete example paths in the YAML/JSON example ('../shared-lib', '/abs/path/to/other/repo'): the permissions docs show NO code example for the value of permissions.additionalDirectories. Neither an array-of-strings snippet nor concrete paths are documented on this page. The named example paths are invented and were replaced by generic placeholders or marked as undocumented.
- Permissibility of relative paths (e.g. '../shared-lib') in additionalDirectories: NOT specified on this page. Removed, as it cannot be substantiated (the settings reference page might clarify this, but was not consulted).
- The schema form 'array of strings' as a documented fact: only strongly implied by the text (plural 'Directories listed in permissions.additionalDirectories'), but no literal code example on this page. Marked in the cleaned-up example as plausible-but-not-literally-documented.