# Permission granularity (Bash/Read/Edit/WebFetch/MCP/Agent)

> **Mode:** global+project · **Priority:** nice-to-have · **Status:** include
> Verified 2026-06-02 against the official Anthropic docs (code.claude.com/docs).

## Setting up permission granularity (Bash / Read / Edit / WebFetch / MCP / Agent)

Claude Code decides on every tool call based on fine-grained permission rules in the format `Tool` or `Tool(specifier)`. These rules live in three lists -- `allow`, `ask`, `deny` -- in your settings files. **Why this matters:** The rules are enforced by Claude Code itself, not by the model. Instructions in CLAUDE.md only influence what Claude *attempts*, not what is actually allowed. A clean permission configuration is therefore your real security boundary, not just a request.

Remember the evaluation order: **deny -> ask -> allow**, first match wins. So deny always trumps everything. A bare tool name as deny (e.g. `Bash`) removes the tool entirely from Claude's context; a scoped deny (e.g. `Bash(rm *)`) keeps the tool available and only blocks matching calls.

**Step 1 -- Block the dangerous stuff globally (`~/.claude/settings.json`).** Add machine-wide deny rules that should never apply in any project: secret files (`Read(.env)`, `Read(//**/.env)`, `Read(~/.ssh/**)`) and destructive pushes (`Bash(git push *)` if desired). Since deny overrides an allow from any scope, these boundaries hold across all projects.

**Step 2 -- Allow Bash deliberately.** Bash rules use `*` wildcards at any position; a single `*` also matches spaces and thus spans multiple arguments. The space is crucial: `Bash(ls *)` matches `ls -la`, but not `lsof`; `Bash(ls*)` matches both. The `:*` suffix is equivalent to ` *` only at the end of the pattern. **Why be careful:** Claude Code knows shell operators (`&&`, `||`, `;`, `|`, `|&`, `&` and newlines) -- each subcommand must match individually, so `Bash(safe-cmd *)` does not grant access to `safe-cmd && other-cmd`. Be careful with env runners like `npx`, `docker exec`, `devbox run`: they are not stripped, so write the full rule (`Bash(devbox run npm test)`) instead of just the runner. Argument constraints (e.g. limiting curl to one domain) are fragile and easy to bypass -- for URL filters it is better to block `curl`/`wget` via deny and allow `WebFetch(domain:...)`.

**Step 3 -- Control Read/Edit via path anchors.** Read and Edit rules follow the gitignore syntax with four anchors: `//path` (absolute from root), `~/path` (home), `/path` (project root), `path`/`./path` (current directory). **Common pitfall:** `/Users/alice/file` is NOT absolute, but project-relative -- for true absolute paths you need the double `//`. `*` matches one level, `**` recursively; a bare filename matches at any depth (`Read(.env)` == `Read(**/.env)`).

**Step 4 -- Scope WebFetch, MCP and Agent tightly.** Allow WebFetch by domain: `WebFetch(domain:example.com)`. MCP tools via `mcp__server__tool`: `mcp__puppeteer` (or `mcp__puppeteer__*`) allows all of the server's tools, `mcp__puppeteer__puppeteer_navigate` only one -- prefer allowing individual tools rather than entire servers. You control subagents with `Agent(Name)` in the deny list, e.g. `Agent(Explore)`.

**Checking:** With `/permissions` you see all active rules and which settings file they come from. Use this to uncover drift between global and project.

## Reference (machine-readable)

```yaml
# --- Permission-Granularitaet ---------------------------------------------
# Source: https://code.claude.com/docs/en/permissions (checked live 2026-06-02)
# Placement: global (~/.claude/settings.json) + project (.claude/settings.json
#   or .claude/settings.local.json). Rule format: "Tool" or "Tool(specifier)".
# Three lists: allow / ask / deny. Evaluation: deny -> ask -> allow; first
#   match wins, deny always wins.
permission_granularitaet:

  grundsatz:
    # Allow/block an entire tool: just the tool name without parentheses.
    # "Bash" as deny removes the tool entirely from Claude's context;
    # "Bash(rm *)" keeps the tool there and only blocks matching calls.
    bare_tool: 'Bash | Read | Edit | WebFetch  # matcht ALLE Nutzungen'
    bash_star_equiv: 'Bash(*) ist identisch zu Bash (auch als deny: entfernt Tool aus Kontext)'

  bash:
    # Wildcard * allowed at ANY position (start/middle/end).
    # A single * also matches spaces, so it spans multiple arguments.
    # A space before * forces a word boundary: "Bash(ls *)" matches "ls -la",
    #   but NOT "lsof". "Bash(ls*)" (without space) matches both.
    # ":*" suffix = equivalent to " *", but only valid at the END of the pattern
    #   (in the middle, e.g. "git:* push", ":" is a literal character).
    allow_beispiel:
      - 'Bash(npm run *)'        # alle npm-run-Befehle
      - 'Bash(git commit *)'     # git commit ...
      - 'Bash(git * main)'       # z.B. git checkout main, git push origin main
      - 'Bash(* --version)'      # alles was auf --version endet
    deny_beispiel:
      - 'Bash(git push *)'       # Push blockieren
    exakt: 'Bash(npm run build)  # exakter Match, kein Wildcard'
    # Compound commands: separators && || ; | |& & and newline are recognized.
    #   Each subcommand must match INDIVIDUALLY -> "Bash(safe-cmd *)" does NOT
    #   allow "safe-cmd && other-cmd".
    # Process wrappers are stripped beforehand: timeout, time, nice, nohup, stdbuf
    #   (and bare xargs without flags). Env runners like npx, docker exec, devbox run
    #   are NOT stripped -> write the full rule: Bash(devbox run npm test).
    # WARNING: argument constraints are fragile (e.g. curl URL filter bypassable).
    #   For URL filters better: block curl/wget via deny + WebFetch(domain:...).

  read_edit:
    # Follow the gitignore specification. 4 path types depending on anchor:
    #   //path  = absolute from filesystem root -> Read(//Users/alice/secrets/**)
    #   ~/path  = from home directory           -> Read(~/Documents/*.pdf)
    #   /path   = relative to PROJECT root       -> Edit(/src/**/*.ts)
    #   path / ./path = relative to CWD          -> Read(*.env)
    # NOTE: /Users/alice/file is NOT absolute, but project-relative!
    #   For absolute you must use //.
    # *  = one level, ** = recursive. Bare filename matches at any depth:
    #   Read(.env) == Read(**/.env).
    deny_beispiel:
      - 'Read(.env)'             # jede .env ab CWD abwaerts
      - 'Read(//**/.env)'        # jede .env irgendwo im Filesystem
      - 'Read(~/.ssh/**)'        # SSH-Keys sperren
    allow_beispiel:
      - 'Edit(/src/**/*.ts)'     # nur TS-Edits im Projekt-src
      - 'Read(src/**)'           # Lesen ab <cwd>/src/
    # Edit rules apply to all built-in file edit tools.
    #   Read rules are best-effort also applied to Grep/Glob/@file.
    # Read/Edit deny also applies to cat/head/tail/sed in Bash, BUT NOT
    #   to foreign subprocesses (Python/Node script) -> a sandbox is needed for that.

  webfetch:
    allow_beispiel:
      - 'WebFetch(domain:example.com)'  # nur Fetches an example.com
    # Note: WebFetch alone does not prevent network access -- with Bash allowed
    #   Claude can still reach any URL via curl/wget.

  mcp:
    # Syntax mcp__server__tool. Wildcard works.
    server_alle: 'mcp__puppeteer        # jedes Tool des puppeteer-Servers'
    server_wildcard: 'mcp__puppeteer__* # ebenfalls alle Tools des Servers'
    einzeltool: 'mcp__puppeteer__puppeteer_navigate  # nur dieses Tool'

  agent:
    # Control subagents via Agent(AgentName), typically in deny.
    deny_beispiel:
      - 'Agent(Explore)'         # Explore-Subagent deaktivieren
    weitere: 'Agent(Plan) | Agent(my-custom-agent)'

  precedence:
    # Settings order (highest first); deny from ANY scope beats allow:
    #   1) Managed settings  2) CLI arguments  3) .claude/settings.local.json
    #   4) .claude/settings.json  5) ~/.claude/settings.json
    # Once denied at any level -> no other level can allow.
    hinweis: 'deny -> ask -> allow; erster Treffer gewinnt'
    pruefen: '/permissions zeigt alle Regeln + Quell-settings.json-Datei'
```

## Audit criteria

- deny list contains secret protection: Read(.env) or Read(//**/.env) and Read(~/.ssh/**)
- Bash allow rules use the correct word boundary (space before * or :* suffix only at the end)
- No argument-constraint rules for network tools (curl/wget) as allow -- use WebFetch(domain:...) instead
- Read/Edit paths use the correct anchor (// for absolute, not /Users/...)
- MCP grants as tight as possible (individual tool mcp__server__tool instead of the whole server, where sensible)
- Env-runner commands (npx/docker exec/devbox run) have full rules including the inner command, not just the runner
- deny-first logic understood: no accidental allow meant to override a needed deny (deny wins anyway)
