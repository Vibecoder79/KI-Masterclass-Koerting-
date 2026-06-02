# Worktrees & Housekeeping/Auth Keys

> **Mode:** project+global · **Priority:** nice-to-have · **Status:** include-with-fixes
> Verified 2026-06-02 against the official Anthropic docs (code.claude.com/docs).

## Worktrees, housekeeping and auth keys

If you work with isolated working copies (Git worktrees) or let subagents run in the background, it's worth looking at the `worktree` block in the project-level `.claude/settings.json`. With `worktree.baseRef` you set where new worktrees branch off from: the default `"fresh"` starts from `origin/<default-branch>` and gives you a clean state matching the remote; `"head"` branches off the local HEAD and carries over unpushed commits as well as your feature-branch state. This applies to `--worktree`, the `EnterWorktree` tool and subagent isolation. WHY: In large monorepos, worktrees cost disk space and checkout time. `worktree.symlinkDirectories` (e.g. `["node_modules", ".cache"]`) links large directories instead of copying them, and `worktree.sparsePaths` uses `git sparse-checkout` to check out only the paths actually needed (plus root files). Anyone working with background sessions should know `worktree.bgIsolation` — though this key is available ONLY in Managed Settings: the default `"worktree"` blocks Edit/Write in the main checkout until `EnterWorktree` has been called; `"none"` lets background jobs edit the working copy directly (as of Claude Code v2.1.143).

For housekeeping (global in `~/.claude/settings.json`) three keys are relevant. `cleanupPeriodDays` (default 30, minimum 1) determines after how long old session files and orphaned subagent worktrees are cleaned up at startup; `0` is rejected with a validation error. `autoUpdatesChannel` selects the release channel: `"latest"` (default) for the newest version or `"stable"` for a roughly one-week-old state that skips versions with larger regressions. WHY stable: fewer surprises in a productive setup. `minimumVersion` pins a lower bound (prevents background auto-updates and `claude update` below this version) and is mainly useful in Managed Settings to enforce a minimum version org-wide.

You only need the auth helper keys if you don't go through the standard login. `apiKeyHelper` points to a shell script (executed in `/bin/sh`) that generates an auth value (sent as `X-Api-Key` and `Authorization: Bearer`; refresh interval via `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`). For cloud providers there are `awsCredentialExport` (script outputs JSON with AWS credentials, Bedrock), `awsAuthRefresh` (script updates the `.aws` directory, e.g. `aws sso login --profile myprofile`) and `gcpAuthRefresh` (renews GCP Application Default Credentials, e.g. `gcloud auth application-default login`, Vertex AI). WHY helpers instead of static keys: rotating/temporary credentials never get hardcoded into the configuration this way.

## Reference (machine-readable)

```yaml
# === Worktrees (project level: .claude/settings.json) ===
# Controls how isolated Git worktrees are created for --worktree, EnterWorktree and subagent isolation.
worktree:
  baseRef: "fresh"            # Branch base for new worktrees: "fresh" (default, from origin/<default-branch>, clean state matching the remote) | "head" (from local HEAD, incl. unpushed commits and feature-branch state)
  symlinkDirectories: []      # Include directories from the main repo into each worktree via symlink instead of duplicating large directories. Default: none. Example: ["node_modules", ".cache"]
  sparsePaths: []             # Check out only these directories (+ root files) via git sparse-checkout. Faster in large monorepos. Example: ["packages/my-app", "shared/utils"]
  bgIsolation: "worktree"     # Managed Settings ONLY: isolation for background sessions: "worktree" (default, blocks Edit/Write in the main checkout until EnterWorktree is called) | "none" (background jobs may edit the working copy directly). Requires Claude Code >= 2.1.143

# === Housekeeping (global: ~/.claude/settings.json) ===
cleanupPeriodDays: 30         # Session files older than X days are deleted at startup (default 30, minimum 1, 0 is rejected with a validation error). Also controls cleanup of orphaned subagent worktrees at startup.
autoUpdatesChannel: "latest"  # Release channel: "latest" (default, newest version) | "stable" (~1 week old, skips versions with large regressions). Disable auto-update entirely: DISABLE_AUTOUPDATER in env.
minimumVersion: ""            # Lower bound: prevents background auto-updates and claude update below this version. Useful in Managed Settings for org-wide pinning. Example: "2.1.100"

# === Auth helpers (global: ~/.claude/settings.json) ===
apiKeyHelper: ""              # Script (executed in /bin/sh) that generates an auth value (sent as X-Api-Key + Authorization: Bearer header). Refresh interval via CLAUDE_CODE_API_KEY_HELPER_TTL_MS. Example: /bin/generate_temp_api_key.sh
awsCredentialExport: ""      # Script that outputs JSON with AWS credentials (Bedrock advanced credential configuration). Example: /bin/generate_aws_grant.sh
awsAuthRefresh: ""           # Script that updates the .aws directory (Bedrock). Example: aws sso login --profile myprofile
gcpAuthRefresh: ""           # Script that renews GCP Application Default Credentials when they expire or cannot be loaded (Vertex AI). Example: gcloud auth application-default login
```

## Audit criteria

- worktree.bgIsolation is available ONLY in Managed Settings; there, only set it to "none" if background jobs are deliberately allowed to edit the main checkout directly, and Claude Code >= 2.1.143 is installed
- cleanupPeriodDays is >= 1 (0 is rejected with a validation error); leave the default 30 unless there is a reason for shorter/longer retention
- In productive/team setups, check autoUpdatesChannel: "stable" reduces regression risk compared to "latest"
- minimumVersion set in Managed Settings when an org-wide minimum version should be enforced
- Auth helper scripts (apiKeyHelper, awsCredentialExport, awsAuthRefresh, gcpAuthRefresh) contain NO hardcoded secrets, but instead fetch rotating/temporary credentials
- symlinkDirectories/sparsePaths set in large monorepos to reduce worktree space requirements and checkout time

## Removed / softened by the verifier (not documented)

- gcpWorkloadIdentity as a settings key — NOT present at https://code.claude.com/docs/en/settings. Already correctly excluded from checklist_yaml/skill_section (it was only carried in the draft as a verified:false claim, not in the output). No action needed other than confirmation.
