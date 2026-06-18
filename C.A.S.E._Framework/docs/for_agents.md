# C.A.S.E. Framework — System Protocol for AI Agents

> **Audience:** AI agents (Coding Agents, Content/Data Agents, local LLMs, cloud models, automated tools) operating within the C.A.S.E. framework.
> **Language:** English (to maximize instruction-following compliance across all LLM backends).
> **Authority:** This document is a Macro Layer (Architect Role) protocol. It MUST be followed by all Micro Layer (Executor/Worker Role) agents.
> **Compatibility:** Model-Agnostic. Fully supports Full-Cloud, Full-Local, and Hybrid cloud-local topologies. Suitable for code development, intelligence patrolling, slide generation, thesis writing, and data analysis.

---

## 1. Core Axioms (Non-Negotiable)

These axioms are the foundation of C.A.S.E. Violating any axiom is a critical error.

| Axiom | Rule |
|-------|------|
| **Tiered Intelligence** | Executor agents MUST NOT attempt macro-level planning or change the Roadmap. Only interpret and execute the assigned Atomic Task Package. |
| **File as State** | All memory, progress, and context MUST be materialized as files. Never rely on conversational context as the sole source of truth. |
| **Dual-track Verification** | Worker (Executor) and Checker (Verifier) roles MUST be separate. A Worker MUST NOT self-approve its own output as final. |
| **Weak Model Resilience** | Pre-defined I-Lang soft-hybrid syntax is optional. If smaller/weaker models (e.g., lightweight open-source models) struggle with shorthand (`[T]`, `[A]`, `[V]`), they MUST fall back to structured natural language. |
| **Git-Backed Integrity** | Any unauthorized write attempts to read-only directories (`00_Constitution/`, `01_Roadmap/`) will trigger an automatic security rollback by the controller. |


---

## 2. Directory Structure — Standard Layout

All C.A.S.E. projects MUST conform to the following directory schema:

```
<project_root>/
├── 00_Constitution/          # READ-ONLY for all agents
│   └── core.md               # Human-authored global constraints and mission objective
│
├── 01_Roadmap/               # READ-ONLY for Layer 3 agents
│   ├── roadmap.md            # Phase breakdown and milestone definitions
│   └── global_dod.md         # Global Definition of Done — final acceptance criteria
│
└── 02_Task_Queue/            # READ-WRITE for Layer 3 agents (own task folder only)
    └── Task_<NNN>_<slug>/    # Atomic Task Package
        ├── role.md           # Agent persona for this task (System Prompt equivalent)
        ├── recipe.md         # Task instructions + local Definition of Done (DoD)
        ├── status.txt        # State machine file — see Section 4
        ├── inputs/           # Source data or symlinks to prior task outputs
        ├── output.md         # Agent's primary deliverable
        ├── feedback.md       # Checker's review notes (written by Checker role only)
        └── action_log.jsonl  # Append-only tool call log (one JSON object per line)
```

---

## 3. Atomic Task Package — Required Files

Every task folder MUST contain all of the following before a Layer 3 agent begins work:

### `role.md`
- Defines the agent's persona and scope for this task.
- Written by Layer 2 (cloud model).
- Agents MUST load this as their effective System Prompt for the task.
- Example: `"You are a rigorous data extraction specialist. Your sole focus is the inputs/ directory."`

### `recipe.md`
Required sections (in order):
1. **Objective** — What this task must produce.
2. **Input Sources** — Which files in `inputs/` to process and how.
3. **Output Specification** — Exact format and content required in `output.md`.
4. **Local Definition of Done (DoD)** — Checklist the Checker will use. Each item MUST be verifiable.
5. **Constraints** — Anything the agent MUST NOT do.
6. **Escalation Trigger** — Conditions under which the agent MUST call `escalate_issue`.

### `status.txt`
- Contains exactly one of the five allowed status tokens (see Section 4).
- No other content is permitted in this file.

### `inputs/`
- All source material the agent is authorized to read.
- Agents MUST NOT read files outside `inputs/`, `role.md`, `recipe.md`, `00_Constitution/core.md`, and `01_Roadmap/*.md` (only when explicitly listed in `recipe.md > Input Sources`).

---

## 4. State Machine — `status.txt` Tokens

`status.txt` MUST contain exactly one of these tokens, with no trailing whitespace:

| Token | Meaning | Who Sets It |
|-------|---------|-------------|
| `PENDING` | Task awaiting execution | Layer 2 (initial) or Checker (on rejection) |
| `IN_PROGRESS` | Worker agent actively executing | Worker agent (upon starting) |
| `REVIEW` | Worker complete; awaiting Checker | Worker agent (upon submitting) |
| `DONE` | Checker approved; task closed | Checker agent |
| `ESCALATED` | Task halted; human or Layer 2 intervention required. Triggered by: (a) Checker retry limit exceeded, or (b) Worker discovered a prerequisite gap and created a subtask via `create_subtask` (see Section 10a). | Checker agent (scenario a) or Worker agent (scenario b) |

**Transition rules:**
```
PENDING      → IN_PROGRESS  (Worker starts)
IN_PROGRESS  → REVIEW       (Worker submits via submit_for_review)
IN_PROGRESS  → ESCALATED    (Worker finds prerequisite gap; creates subtask then escalates — see Section 10a)
REVIEW       → DONE         (Checker approves)
REVIEW       → PENDING      (Checker rejects; retry count < 3)
REVIEW       → ESCALATED    (Checker rejects; retry count >= 3)
```

---

## 5. Authorized Tool API

Layer 3 agents MUST only use the following tools. No direct shell access or arbitrary file system operations are permitted.

| Tool | Parameters | Permission Boundary |
|------|-----------|-------------------|
| `read_file(filepath)` | `filepath: str` | Allowed: `00_Constitution/core.md`, `01_Roadmap/*.md`, current `Task_<NNN>/` only |
| `list_directory(path)` | `path: str` | Same boundary as `read_file` |
| `write_artifact(filepath, content)` | `filepath: str`, `content: str` | Current `Task_<NNN>/` only. Recommended: follow with `git commit` (manually, via CI, or optional helper scripts). |
| `change_status(task_id, status)` | `task_id: str`, `status: enum` | `status` MUST be one of the five allowed tokens. |
| `submit_for_review(summary)` | `summary: str` | Sets status to `REVIEW`; notifies Checker role. |
| `escalate_issue(reason)` | `reason: str` | Halts task; writes to `action_log.jsonl`; sets status to `ESCALATED`. |
| `create_subtask(slug, recipe_content, role_content)` | `slug: str`, `recipe_content: str`, `role_content: str` | Orchestrator creates `02_Task_Queue/Task_<next_NNN>_<slug>/` with provided content and `status.txt = PENDING`. Agent MUST NOT write outside its own folder directly — this tool is the only sanctioned path for micro-level Task Queue injection. |

**MUST NOT use:**
- Native shell commands (`rm`, `cp`, `mv`, `mkdir`) directly.
- Any write target inside `00_Constitution/` or `01_Roadmap/`.
- File paths outside the current task folder (except authorized read paths).

---

## 6. Worker Agent Protocol

Upon receiving a task (status = `PENDING`):

1. **Set status** to `IN_PROGRESS` using `change_status`.
2. **Load role**: Read `role.md` and apply as effective system persona.
3. **Read recipe**: Parse all sections of `recipe.md`. If any required section is missing, call `escalate_issue("recipe.md missing required section: <section_name>")`.
4. **Draft Micro-Plan**: Write a `planning.md` file within the task folder describing the specific steps, targeted files, and testing strategy. Double check constraints to ensure alignment.
5. **Read inputs**: Process only files listed in `recipe.md > Input Sources`.
6. **Execute Cautiously**: Make modifications step-by-step. Keep edits atomic. Run unit tests frequently to confirm behavior and check trace integrity.
7. **AI Self-Review & Self-Healing**: Before presenting the work, perform a thorough review of your modifications against `recipe.md` and run all verification tests. If any test fails or code gaps are found, you MUST continue working to fix them (or create subtasks).
8. **Write output**: Use `write_artifact("output.md", <content>)`.
9. **Submit**: Call `submit_for_review(<clean summary of what was produced>)` to set status to `REVIEW`.
10. **Acknowledge Natural Language Feedback**: Wait for natural language feedback. If the user (or Checker) approves (e.g., "Pass", "Looks good"), automatically set status to `DONE` and perform git commit/push. If changes are requested, set status back to `IN_PROGRESS` and fix the issues.

**On error or uncertainty:**
- Insufficient inputs where a prerequisite task can be defined → call `create_subtask(...)` first, then `escalate_issue(...)` (see Section 10a). Do NOT skip directly to `escalate_issue`.
- Insufficient inputs due to a recipe specification error (e.g., referenced file does not exist and cannot be produced by a subtask) → `escalate_issue("Insufficient input: <specific gap>")`
- Contradictory instructions → `escalate_issue("Contradictory instructions in recipe.md: <detail>")`
- NEVER hallucinate data or invent file contents to fill gaps.

---

## 7. Checker Agent & Human Review Protocol

Upon detecting status = `REVIEW` (or when a human begins reviewing):

1. **Read** `recipe.md > Local Definition of Done` — this is the authoritative checklist.
2. **Read** `output.md` — evaluate against every DoD item.
3. **Natural Language Gating**:
   - **APPROVE** (all DoD items satisfied, or human says "looks good" / "pass"):
     - Transition task status to `DONE` (e.g., via `change_status(task_id, "DONE")`).
   - **REJECT** (DoD items not satisfied, or human requests changes):
     - Write specific feedback to `feedback.md` or communicate via chat.
     - Increment retry counter (tracked in `action_log.jsonl`).
     - Retry count < 3 → transition status to `PENDING` (or let Worker set to `IN_PROGRESS` directly to fix).
     - Retry count >= 3 → transition status to `ESCALATED`.

---

## 8. Action Log Format — `action_log.jsonl`

Every tool call MUST be appended to `action_log.jsonl` as one JSON object per line:

```json
{"ts": "2026-05-21T09:30:00+08:00", "role": "worker", "tool": "write_artifact", "args": {"filepath": "output.md"}, "result": "ok"}
{"ts": "2026-05-21T09:31:00+08:00", "role": "checker", "tool": "change_status", "args": {"task_id": "Task_001", "status": "DONE"}, "result": "ok"}
```

Fields: `ts` (ISO 8601 + timezone) | `role` (`worker`/`checker`) | `tool` (tool name) | `args` (parameters) | `result` (`ok` or error string)

> **⚠️ Weak Model Fallback**: If generating JSONL formatting causes parser failures or syntax errors, smaller parameter models are permitted to record tool execution logs as simple markdown lists inside a `log.md` file in the task directory.

---

## 9. Information Isolation Principle

Layer 3 agents MUST NOT:
- Read task folders other than their own assigned `Task_<NNN>/`.
- Retain or reference conversational history from previous tasks.
- Access external networks or URLs not explicitly listed in `recipe.md > Input Sources`.

Each agent operates as a **stateless executor**: its entire world is the current task folder plus the two authorized read paths.

---

## 10. Escalation and Recovery

When `escalate_issue` is called:
1. Status is set to `ESCALATED`. Task is frozen — no further tool calls permitted.
2. A human or Layer 2 agent MUST review `feedback.md` and `action_log.jsonl`.
3. Resolution options:
   - **Re-specify**: Layer 2 rewrites `recipe.md`, resets status to `PENDING`.
   - **Split task**: Layer 2 replaces this task with two smaller sub-tasks. The new sub-task folders MUST be created directly inside `02_Task_Queue/` immediately — do NOT wait for Global Aggregation.
   - **Human intervention**: Human directly resolves the constraint or provides missing input.

## 10a. Micro-Level Feedback — Direct Task Queue Injection

A Worker agent that discovers a prerequisite gap during execution MUST use this path **before** resorting to `escalate_issue`:

1. Worker detects a missing precondition (e.g., required input does not exist yet).
2. Worker calls `create_subtask(slug="<descriptive-slug>", recipe_content="<full recipe.md text>", role_content="<full role.md text>")`. The orchestrator creates the new task folder in `02_Task_Queue/` with `status.txt = PENDING`. Worker MUST NOT use `write_artifact` to write outside its own task folder.
3. Worker logs the `create_subtask` call in its own `action_log.jsonl`.
4. Worker calls `escalate_issue("Prerequisite gap found; sub-task <slug> created in queue.")` to pause itself and signal that the new task must be completed first.

**Key principle:** Micro-level feedback bypasses Global Aggregation entirely. The gap is patched in real time, preventing technical debt accumulation that would otherwise only surface after all tasks complete.

| Feedback Path | Trigger | Route | Timing |
|--------------|---------|-------|--------|
| **Micro (⑤)** | Worker finds gap during execution | Worker → `02_Task_Queue/` directly | Immediate |
| **Macro (⑥)** | Global Aggregation finds Global DoD unmet | AGG → Layer 2 → new task packages | After all tasks complete |

---

## 11. Git Integration (Recommended Best Practice)

Git integration is **strongly recommended** but not mandatory. It provides the integrity backbone for the Write Defense mechanism. When available, the recommended practices are:
- Commit after significant `write_artifact` actions: `git commit -m "agent: <role> updated <filepath> in <task_id>"`.
- Support task-level rollback via `git restore` to restore last committed state of the task folder.
- Upon Checker approval and transition to `DONE`, commit the finalized task folder (`git commit -m "task(Task_<NNN>): <slug> completed"`).
- Optionally trigger `git push` if configured to sync with a remote repository.

> **Note**: These operations can be performed manually by the user or automated via CI/CD pipelines. The protocol does not require any specific automation mechanism.

---

## 13. Self-Optimizing Learning Loop (SkillOpt) & Memory Tiering

To prevent rule poisoning and context window bloat, learnings are tiered into two physical files inside `00_Constitution/`:

### A. Hot Memory (`learnings.md`)
- A highly condensed list of active anti-patterns and reusable patterns.
- Read-only for Workers; writable only by Checkers or Humans during the review/check phase.
- Recommended limit: **40 lines (approx. 15 distinct entries)** to maintain context window efficiency.

### B. Cold Memory Archive (`archive_learnings.md`)
- When `learnings.md` exceeds the recommended threshold, the oldest entries should be migrated to `archive_learnings.md`.
- This migration can be performed by: (a) a human reviewer, (b) the Checker agent itself as part of its review protocol, or (c) the optional helper scripts.
- Used as background retrieval for macro re-planning.

---

## 14. Write Defense & Anti-Poisoning Enforcement

If an executor agent attempts to modify any files in `00_Constitution/` or `01_Roadmap/` (other than sanctioned Checker writes):
1. During the verification phase, detect unauthorized changes in read-only directories via `git diff` (or manual inspection).
2. The verification fails immediately.
3. Roll back the poisoned directories using `git restore` (or equivalent version control operation).
4. The task status transitions to `ESCALATED`, and feedback is written to `feedback.md` highlighting the security policy violation.

> **Implementation options**: This defense can be enforced by (a) a human reviewer checking `git diff` before approving, (b) a CI/CD pipeline with automated checks, or (c) the optional helper scripts' `check` command.

---

---

## 15. BDD Spec-by-Example & Acceptance Gating (起草 - 驗證 - 潤飾)

To eliminate guesswork during execution (regardless of whether the task is programming, intelligence patrolling, slide generation, or academic writing):
- **Given-When-Then Formulation**: Workers should translate local DoD conditions into explicit Cucumber-like scenarios or factual checks in `planning.md` prior to any content/deliverable edits.
- **Draft-Verify-Refine Gating (RED-GREEN-REFACTOR equivalent)**: Workers MUST specify the draft state, define how to verify it (e.g., verifying links, testing syntax, or fact-checking citations), and only refine/polish (REFINE) the draft once it satisfies all validation tests.

## 16. Context Compaction & Handoff Capsules

When context window limits force a compaction or clear:
- **Handoff Capsule**: Write a YAML block in `planning.md` summarizing the active state, active pivot points, and pending decisions.
- **Resiliency**: The orchestrator or agent reads the handoff capsule post-clear to resume execution seamlessly without losing historical context.

## 17. Cross-Model Adversarial Protocol

To guarantee verification honesty:
- **Separate Model Families**: Worker (executor) and Checker (verifier) roles SHOULD be operated by models from different families (e.g. Gemini for execution, Claude for checking) or independent context instances.
- **Thread Freshness**: Checker reviews the file outcomes directly in a fresh context session, ensuring they are not biased by the Worker's conversational history.

## 18. Sharded Knowledge Base Standard

To scale project memory beyond simple logs:
- **Directory**: `00_Constitution/knowledge_base/`
- **Format**: Atomic markdown files with YAML frontmatter tags (`type`, `tags`, `updated`).
- **Indexing**: Keep a top-level `index.md` directory mapping shards once files exceed 150 pages.
## 19. C.A.S.E. Pure-Text Scaffolding Blueprint

When asked to initialize a new task folder (e.g., `02_Task_Queue/Task_<NNN>_<slug>/`), you MUST create the following four files.

> [!IMPORTANT]
> **💡 Important Guideline: Context-Aware Adaptation (情境適應與靈活剪裁原則)**
> The templates below (especially `recipe.md` and `planning.md`) are standard baseline structures. The illustrative examples (Section E) are provided solely to show how C.A.S.E. adapts to different domains.
> Do NOT copy the example content blindly. You MUST dynamically customize the objective, constraints, input/output paths, and Definition of Done (DoD) checks to perfectly fit the unique context, resources, and requirements of the current task.

### A. File: `status.txt`
```text
PENDING
```

### B. File: `role.md`
```markdown
You are a [Insert Target Persona Role]. Your objective is to: [Brief target task goal].
```

### C. File: `recipe.md`
```markdown
# Task Recipe: [Task Title]

## Objective
[Clear explanation of what the task must achieve]

## Input Sources
- [Paths to read-only inputs or files that are allowed to be analyzed]

## Output Specification
- [Path and structure of files that must be created or modified]

## Local Definition of Done (DoD)
- [ ] Checklist item 1
- [ ] Checklist item 2
- [ ] Checklist item 3 (Must include verification test commands)

## Constraints
- Do not modify files outside: [List files]
```

### D. File: `planning.md`
```markdown
# 📝 Task Micro-Plan: Task_[NNN]_[slug]

## [T] Constraints & Truths (Context & Anti-Repetition)
- No modifications outside recipe boundaries.
- Read learnings.md before executing.
- Anti-Repetition Check: Review learnings.md to avoid repeating known mistakes.

## [H] Compaction & Handoff Capsule (YAML syntax)
```yaml
session_summary: |
  Describe the current progress and architecture decisions made so far to survive context compaction/reset.
active_pivot_point: |
  Name of the specific function, file, or test currently being worked on.
pending_blockers: []
```

## [A] Planned Actions (BDD Flows / Spec-by-Example)
- [A] Define acceptance criteria as Cucumber-like scenarios (Given-When-Then).
- [A] Implement target logic incrementally (Red-Green-Refactor pipeline).
- [A] Perform self-review and clean up code debt.

## [V] Verification & Acceptance Criteria
- [V] Verify Given-When-Then scenarios pass successfully.
- [V] Confirm all checkboxes in recipe.md DoD are completed.
```

### E. Illustrative Example: OSINT Web Patrol Recipe (Non-Code Workload)
To illustrate non-code usage, here is how a patrol task `recipe.md` can be customized:
```markdown
# Task Recipe: Illegal Gambling Patrol and Information Report

## Objective
Identify active illegal gambling platforms targeting the region and compile a structured intelligence report containing domain hosts, active IPs, and promotional screenshots.

## Input Sources
- `inputs/patrol_keywords.txt` (list of localized keywords)
- Online intelligence sources via `search_web`

## Output Specification
- `output.md` (markdown table showing Domain, Active IP, Registrar, Evidence Link, and Severity Score)

## Local Definition of Done (DoD)
- [ ] Query all keywords and identify at least 5 active gambling domain URLs.
- [ ] Resolve each domain's active server IP and registrar using network lookup tools.
- [ ] Verify that all domain links are indeed active and serve gambling content (no dead links).
- [ ] Format findings into a clean markdown table.
```


---

*This protocol is version-controlled. Changes require Layer 1 (human) approval and a new git commit.*

🔗 See also: [for_humans.md](for_humans.md) | [glossary.md](glossary.md) | [Framework README](../README.md)
