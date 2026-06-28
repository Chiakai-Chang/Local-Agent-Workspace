# SKILL.md — C.A.S.E. Framework Extension

## Skill Identity
- **Name:** `case-framework`
- **Version:** 1.0.0
- **Description:** Portable C.A.S.E. (Constitution-Architecture-State-Execution) framework extension. Deploys a three-layer, file-as-state, dual-track verification system into any target project. Model-agnostic, zero-code-deployment, works with any AI agent harness (Pi, Claude Code, Cursor, Codex, etc.).

## Triggers
Activate this skill when:
- User mentions "C.A.S.E.", "C.A.S.E. framework", or "case framework"
- User asks to "bootstrap C.A.S.E." or "deploy C.A.S.E. rules"
- User says "this project uses C.A.S.E."
- User references `CASE.md`, `MAP.md`, or `.case/` directory
- User asks to enforce "three-layer architecture", "file-as-state", or "dual-track verification"

## Capabilities

### 1. Bootstrap Deployment
When invoked, run `.case/bootstrap.sh` to deploy the full C.A.S.E. directory structure:
```
<project_root>/
├── .case/                    # Extension source (gitignored)
│   ├── bootstrap.sh          # One-command deploy script
│   ├── CASE.md               # Minimal ruleset for project root
│   ├── MAP.md                # Navigation index
│   ├── SKILL.md              # This file
│   ├── templates/            # Starter templates
│   │   ├── core.md           # Constitution template
│   │   ├── recipe.md         # Task recipe template
│   │   ├── role.md           # Agent role template
│   │   ├── planning.md       # Micro-planning template
│   │   └── status.txt        # Status machine token
│   └── verifiers/            # Pre-built verification scripts
│       ├── verify.js         # Node.js verifier
│       └── verify.py         # Python verifier
├── 00_Constitution/          # READ-ONLY: Global constraints
│   └── core.md               # Human-authored mission & constraints
├── 01_Roadmap/               # READ-ONLY: Phase plan
│   ├── roadmap.md            # Milestone breakdown
│   └── global_dod.md         # Global Definition of Done
├── 02_Task_Queue/            # READ-WRITE: Agent workspace
│   └── Task_<NNN>_<slug>/    # Atomic task packages
│       ├── role.md           # Agent persona
│       ├── recipe.md         # Task instructions + DoD
│       ├── status.txt        # State machine (PENDING|IN_PROGRESS|REVIEW|DONE|ESCALATED)
│       ├── planning.md       # Step-by-step plan
│       ├── inputs/           # Source data
│       ├── output.md         # Deliverable
│       ├── feedback.md       # Checker review notes
│       └── action_log.jsonl  # Append-only tool call log
└── MAP.md                    # Navigation index (read first)
```

### 2. Task Lifecycle Enforcement
Enforce the status machine for every task:
```
PENDING → IN_PROGRESS → REVIEW → DONE
                ↘ ESCALATED
REVIEW → IN_PROGRESS (if feedback requires changes)
```

### 3. Verification
Before accepting a task as DONE:
- Run `verify.js` or `verify.py` on the task folder
- Validate `status.txt` contains a valid token
- Validate `action_log.jsonl` has valid JSON entries
- Validate `output.md` is non-empty
- Validate `recipe.md` has DoD section
- If ESCALATED, verify `feedback.md` exists

### 4. Agent Role Enforcement
- **Worker (Executor):** Read `role.md` + `recipe.md` → Plan → Execute → Self-review → Submit
- **Checker (Verifier):** Read `recipe.md` DoD → Validate `output.md` → Approve or reject
- **Worker MUST NOT self-approve**

## Constraints
- This skill is READ-ONLY for all AI agents. Only the human Architect may modify `00_Constitution/core.md`.
- Layer 3 agents MUST NOT modify `00_Constitution/` or `01_Roadmap/`.
- Maximum 3 self-healing attempts before escalation.
- `learnings.md` has a 40-line hard limit; auto-shard to `archive_learnings.md` when exceeded.

## References
- Full protocol: `docs/for_agents.md` (in C.A.S.E._Framework repo)
- Human guide: `docs/for_humans.md` (in C.A.S.E._Framework repo)
- Harness engineering: `docs/harness_engineering.md` (in C.A.S.E._Framework repo)
