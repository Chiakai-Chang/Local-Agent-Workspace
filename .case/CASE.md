# C.A.S.E. Framework — Project Rules

> This project uses the **C.A.S.E.** (Constitution-Architecture-State-Execution) framework.
> All AI agents MUST read and follow these rules.

## Directory Structure
```
00_Constitution/    — READ-ONLY: Global constraints (core.md)
01_Roadmap/         — READ-ONLY: Phase plan (roadmap.md, global_dod.md)
02_Task_Queue/      — READ-WRITE: Agent workspace (task folders)
```

## Agent Operating Rules

1. **Read MAP.md first** — it is your navigation index. Do NOT read all files at once.
2. **Obey the Constitution** — never modify `00_Constitution/` or `01_Roadmap/`.
3. **Stay in your lane** — only read/write your assigned task folder.
4. **File-as-State** — all progress lives in files, NOT in conversation context.
5. **Dual-track verification** — Worker and Checker roles must be separate. Worker MUST NOT self-approve.
6. **Git small steps** — commit after every meaningful change.
7. **3-strike self-healing** — max 3 consecutive attempts before escalating.

## Status Machine
```
PENDING → IN_PROGRESS → REVIEW → DONE
                ↘ ESCALATED
REVIEW → IN_PROGRESS (if feedback requires changes)
```

## Task Folder Structure
Every task in `02_Task_Queue/` MUST contain:
| File | Purpose |
|------|---------|
| `role.md` | Agent persona (system prompt equivalent) |
| `recipe.md` | Task instructions + Local Definition of Done |
| `status.txt` | State machine token (see above) |
| `planning.md` | Step-by-step execution plan |
| `inputs/` | Source data or symlinks |
| `output.md` | Primary deliverable |
| `feedback.md` | Checker review notes (written by Checker only) |
| `action_log.jsonl` | Append-only tool call log |

## Verification
Before accepting a task as DONE:
1. Run `node .case/verifiers/verify.js <task_folder>` or `python .case/verifiers/verify.py <task_folder>`
2. Confirm `status.txt` has valid token
3. Confirm `output.md` is non-empty and meets DoD
4. Confirm `action_log.jsonl` has valid entries

## For Humans
To deploy the full agent protocol into this project:
```bash
sh .case/bootstrap.sh
```
Then instruct your AI agent:
> "This project uses C.A.S.E. framework. Read CASE.md and MAP.md."
