# 🗺️ MAP — C.A.S.E. Framework Extension Navigation

> **Purpose:** Entry point for all agents interacting with this extension.
> Read this file first, then navigate to specific files on-demand.
> Do NOT read all files at once — use this map as a table of contents.

## Extension Structure

| Path | Purpose | Authority |
|------|---------|-----------|
| `.case/SKILL.md` | Skill definition & triggers | Read by agent harness |
| `.case/bootstrap.sh` | One-command deployment script | Run by human or agent |
| `.case/CASE.md` | Minimal ruleset for project root | Read by all agents |
| `.case/MAP.md` | This file — navigation index | Read by all agents |
| `.case/templates/` | Starter templates for new projects | Copy via bootstrap |
| `.case/verifiers/` | Pre-built verification scripts | Run for task validation |

## Templates

| Template | Use Case |
|----------|----------|
| `templates/core.md` | Constitution — mission, constraints, domain rules |
| `templates/recipe.md` | Task recipe — objective, inputs, output, DoD |
| `templates/role.md` | Agent role — persona, mindset, workflow, boundaries |
| `templates/planning.md` | Micro-planning — step-by-step execution plan |
| `templates/status.txt` | Status machine token (PENDING/IN_PROGRESS/REVIEW/DONE/ESCALATED) |

## Verifiers

| Script | Language | Use |
|--------|----------|-----|
| `verifiers/verify.js` | Node.js | Task validation (recommended) |
| `verifiers/verify.py` | Python | Task validation (fallback) |

**Usage:**
```bash
node .case/verifiers/verify.js <task_folder_path>
python .case/verifiers/verify.py <task_folder_path>
```

## Deployment Flow

```
1. Human clones/copies .case/ into target project
2. Run: sh .case/bootstrap.sh [target_dir]
3. Edit 00_Constitution/core.md with project-specific constraints
4. Edit 01_Roadmap/roadmap.md with project phases
5. Instruct AI agent: "This project uses C.A.S.E. framework. Read CASE.md."
6. Agent reads MAP.md → follows three-layer architecture
```

## Key Concepts Quick Reference

| Concept | Rule |
|---------|------|
| **Three-Layer Architecture** | Constitution (Layer 1) → Roadmap (Layer 2) → Task Queue (Layer 3) |
| **File-as-State** | All memory/progress in files, never in conversation context |
| **Dual-Track Verification** | Worker executes, Checker verifies — never self-approve |
| **Status Machine** | PENDING → IN_PROGRESS → REVIEW → DONE (with ESCALATED branch) |
| **Self-Healing Limit** | Max 3 consecutive attempts, then ESCALATED |
| **Git Small Steps** | Commit after every meaningful change |
| **MAP Navigation** | Read MAP.md first, navigate on-demand, don't load everything at once |

---
*This MAP.md is part of the .case/ extension. Do not edit manually — it is a reference for understanding the extension structure.*
