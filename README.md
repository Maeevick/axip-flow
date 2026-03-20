# axip-flow

**status: in progress under heavy development | not production-ready**

> An opinionated (sub)agentic (AI) engineering team following (almost) Extreme Programming (XP) principles for autonomous and supervised software delivery.

---

## What is axip?

**axip** (AI × XP) is a reusable Claude Code (sub)agentic system that brings, or try to bring, Extreme Programming discipline to autonomous software delivery. It lives entirely in `.claude/` and is deployable into any project via copy-paste (to begin with).

The system runs as a team of specialized agents, empowered by skills, coordinated by a single orchestrator (`CLAUDE.md`), guided by a project contract (`BLUEPRINT.md`), and enforced by a hook layer that fires on every write, session boundary, and agent lifecycle event.

Every commit produced by axip is authored by `axip-flow` and follows the `flow(ci-green|ci-red|ci-unset)` convention — making the TDD red/green cycle visible in git history and reviewable without an IDE and observable/auditable easily by human or machine.

---

## Core principles

- **XP-first** — TDD/Test First, Explicit Naming, No Comments, Small Verifiable Increments, ...
- **Structural over instructional** — enforcement via hooks, tool locks, and agent constraints, not advisory prose
- **Blueprint-driven** — a single `BLUEPRINT.md` is the contract between the Principal (human) and axip (the team)
- **Dual mode** — autonomous runs for the initial ~80%, iterative and supervised slash commands for the ~20% remaining
- **Atomic commits** — every source file write produces a `flow(ci-*)` commit, enabling atomic review, audit, monitoring outside the IDE
- **Terminal-first** — full enforcement requires Claude Code CLI in a terminal (IDE integrations do not reliably load project hooks, for the moment...)

---

## Architecture

```
.claude/
├── BLUEPRINT.md              # Project contract — written by the Principal
├── CLAUDE.md                 # Orchestrator — Tech Lead + Product Owner + Principal Proxy
├── agents/                   # Specialized agents (implementing + reviewer)
├── hooks/                    # Enforcement layer (lifecycle + quality + guard)
│   ├── session-start.sh      # Injects BLUEPRINT at session start
│   ├── session-end.sh        # Emits task summary on exit
│   ├── instructions-loaded.sh# Traces context loading
│   ├── subagent-start.sh     # Logs agent spawn
│   ├── subagent-stop.sh      # Logs completion + review reminder
│   ├── task-completed.sh     # Checks BLUEPRINT sync
│   ├── pre-tool-guard.sh     # Blocklist guard for Bash tool
│   ├── post-tool-flowgate.sh # Quality gate + flow(ci-*) commit
│   └── post-tool-failure.sh  # Write failure enforcer
├── skills/                   # Loadable skill modules
│   ├── extreme-programming/  # XP practices (mandatory)
│   ├── python/               # Python 3.12+ standards
│   ├── data-manipulation/    # Scientific data formats
│   ├── ...                   # More to come I have just started with my current needs
│   ├── read-tasks/           # /read-tasks slash command
│   ├── add-task/             # /add-task slash command
│   ├── run-next-task/        # /run-next-task slash command
│   └── run-tasks/            # /run-tasks slash command
└── settings.json             # Config and Hook registrations
```

---

## How it works

### The two modes

**Autonomous mode** — Principal writes BLUEPRINT, describes intent, axip runs the full task list:

```
Principal → CLAUDE.md reads BLUEPRINT → agent implements -> ci-gate hook validate → reviewer double checks → DONE
```

**Supervised mode** — Principal drives task by task using slash commands:

| Command                   | What it does                                        |
| ------------------------- | --------------------------------------------------- |
| `/read-tasks`             | Sync and display current task state from BLUEPRINT  |
| `/add-task [description]` | Append a TODO task to BLUEPRINT                     |
| `/run-next-task`          | Execute the next TODO task, return to Principal     |
| `/run-tasks`              | Run autonomously until `PRINCIPAL_BREAK` or failure |

`PRINCIPAL_BREAK` is a first-class task type — a stop signal placed anywhere in the task list to enforce a review checkpoint.

### The hook lifecycle

```
SessionStart    → BLUEPRINT injected into context
InstructionsLoaded → context load traced
SubagentStart   → agent spawn logged
  Write/Edit →
    PreToolUse  → pre-tool-guard blocks destructive Bash commands
    [write happens]
    PostToolUse → post-tool-flowgate runs make ci-gate → flow(ci-green|ci-red|ci-unset) commit
    PostToolUseFailure → write failure surfaced, agent stopped
SubagentStop    → completion logged + review cycle reminder
TaskCompleted   → BLUEPRINT sync checked
SessionEnd      → task state summary emitted
```

### The commit convention

Every source file write produces an atomic commit:

```
flow(ci-green): axip - work in progress   # make ci-gate passed
flow(ci-red): axip - work in progress     # make ci-gate failed
flow(ci-unset): axip - work in progress   # no ci-gate target found
```

The `flow(ci-red)` / `flow(ci-green)` cycle is TDD made visible in git history (_it's AI's hallucinations observability too_). Squash and rewrite during rebase — that is the human's responsibility according to his/her preferences/rules.

---

## Getting started

### Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- A project with a `Makefile` exposing a `ci-gate` target
- Git initialized

### Installation

```bash
# Copy .claude/ into your project root
cp -r path/to/axip/.claude your-project/.claude
```

Hook scripts are made executable automatically at session start via the `SessionStart` hook command _(experimental)_.

If you encounter permission issues on first run, execute manually:

```bash
# Make hooks executable
chmod +x your-project/.claude/hooks/*.sh
```

### Configure ci-gate

Add a `ci-gate` target to your `Makefile`. The content is project-specific:

```makefile
# Example: Python project
ci-gate:
    ruff format --check .
    ruff check .
    mypy .
    pyright .
    pytest -v

# Example: Node project
ci-gate:
    npm run lint
    npm run typecheck
    npm test
```

### Write your BLUEPRINT

Copy `.claude/BLUEPRINT.md` and fill in the WHY, WHAT, HOW, AGENTS, SKILLS, and TASKS sections. The BLUEPRINT is the contract — write it before running any agent.

### Run

```bash
cd your-project
claude  # starts Claude Code CLI — hooks activate automatically
```

---

## The BLUEPRINT contract

The BLUEPRINT is the single source of truth for the agentic team. Structure:

| Section          | Author    | Purpose                                          |
| ---------------- | --------- | ------------------------------------------------ |
| `WHY`            | Principal | Value statement and success criteria             |
| `WHAT`           | Principal | Expected result and output specification         |
| `HOW`            | Principal | Principles, constraints, and technical decisions |
| `AGENTS`         | Principal | Active agents for this project                   |
| `SKILLS`         | Principal | Active skills and their scope                    |
| `TASKS`          | axip      | Task list with status tracking                   |
| `DECISIONS`      | axip      | Architectural and product decision log           |
| `OPEN QUESTIONS` | axip      | Blockers requiring Principal input               |

### Task status schema

```
- [ ] TODO           — pending
- [ ] IN PROGRESS    — currently executing
- [x] DONE           — passed review, CI green
- [ ] FAIL           — correction cycles exhausted, Principal decision needed
- [ ] SKIP           — manually dropped by Principal
- [ ] PRINCIPAL_BREAK — mandatory stop signal
```

---

## Security

The `pre-tool-guard.sh` hook blocks destructive Bash commands by default:

- Filesystem destruction (`rm -rf`, `shred`, `truncate`)
- Disk operations (`mkfs`, `dd of=`, `fdisk`)
- Process killing (`killall`, `pkill`, `kill -9`)
- System operations (`shutdown`, `reboot`, `sudo`)
- Remote code execution (`curl | bash`, `wget | bash`, `eval`)
- Destructive git operations (`--force`, `--hard`, `rebase`, `--amend`)
- SQL destructive operations (`DROP TABLE`, `TRUNCATE`, `DELETE FROM`)
- Python arbitrary execution (`python -c`, `python -m`)

The list is in `BLOCKED_PATTERNS` inside `pre-tool-guard.sh` — extend it for your context.

Agent tools are locked by design:

- Implementing agents: `Write, Edit, Read, Glob, Grep`
- Reviewer agents: `Read, Grep, Glob`

No agent has `Bash` access. The guard protects the main orchestrator only.

---

## IDE compatibility

The only verified environment for axip is a terminal. It is the only execution context confirmed to deliver full feature support, stability, and performance.

### Terminal (any)

Note: _current experiment: a tmux-based + neovim + diffview (not bad at all)_

All axip features work as designed — hooks fire, project `.claude/` is loaded, `settings.local.json` is respected. No known issues.

### VS Code extension

The official Anthropic extension runs the Claude Code CLI directly. Hooks and project settings are expected to load correctly. However, axip has not been battle-tested in VS Code. Known past reports include terminal scrolling instability under heavy output and general Electron-based reliability concerns. Your mileage may vary — feedback welcome.

### Zed agent panel (ACP-based IDEs)

Zed offers excellent UX, stability, and performance as an editor. However the Claude Code integration runs via ACP (Agent Client Protocol), which introduces the following limitations as of March 2026:

- Hooks do not fire
- `settings.local.json` is not loaded
- `/ide` (and other slash commands) CLI connection is not supported

Project `.claude/` files (CLAUDE.md, BLUEPRINT.md, agents, skills) are readable. Zed works well as a companion editor alongside a terminal running axip — use it to read and review files while the terminal handles agent execution.

---

## Extending axip

### Adding an agent

Create `.claude/agents/your-agent.md` with YAML frontmatter:

```markdown
---
name: your-agent
description: your description and invocation condition with key-words
model: claude-sonnet-4-6
tools: Write, Edit, Read, Glob, Grep
skills:
  - extreme-programming
---

# Your Agent

## Role

...
```

Register the agent in your project's `BLUEPRINT.md` AGENTS section.

### Adding a skill

Create `.claude/skills/your-skill/SKILL.md`:

```markdown
---
name: your-skill
description: When to load this skill. Claude uses this for automatic routing.
---

# Your Skill

...
```

### Customizing the guard

Add patterns to `BLOCKED_PATTERNS` in `pre-tool-guard.sh`:

```bash
'\byour-pattern\b'   # reason for blocking
```

Each entry is a `grep -E` extended regex. Linux/macOS only — no Windows/PowerShell support.

---

## Philosophy

axip is opinionated by design. It is not a framework that accommodates every preference — it encodes a specific set of practices that the author considers non-negotiable for quality autonomous software delivery.

The constraints are intentional:

- Agents cannot run arbitrary Bash — they write code, not scripts
- Every write produces a commit — no invisible work
- BLUEPRINT is the only source of truth — no ambient context
- Reviewer agents cannot write — separation of concerns is structural
- `make ci-gate` is the only quality gate interface — the hook doesn't know your toolchain

If these constraints don't fit your workflow, fork and adapt. The system is designed to be understood and modified, not abstracted away.

---

## Contributing

Issues and pull requests will be welcomed in future. Before contributing:

- Read the BLUEPRINT philosophy — changes should reinforce XP discipline, not weaken it
- The system serves its principal first — open source does not mean universally accommodating
- Strong opinions are non-negotiable constraints, not suggestions

---

## License

MIT — see [LICENSE](LICENSE)

---

## Acknowledgements

Inspired by the work of [Daniel Miessler (PAI)](https://github.com/danielmiessler/Personal_AI_Infrastructure), [Jeff Allan (claude-skills)](https://github.com/Jeffallan/claude-skills), and [Bryan Finster (agentic-dev-team)](https://github.com/bdfinst/agentic-dev-team) on agentic system design.

Built with [Claude Code](https://docs.anthropic.com/en/docs/claude-code) by Anthropic.
