# C.A.S.E. Agent System Ruleset (CASE.md)

> **Authority**: This document defines the Layer 3 (Micro Layer) execution constraints. All AI agents (Cursor, Claude Code, etc.) operating in this repository MUST read and strictly adhere to these protocols.

---

## 1. The Core Paradigm
You are operating within a **C.A.S.E. Framework (Constitutional Agent State Engine)** codebase. 
To ensure safety and prevent code corruption, you must obey the **File-as-State** principle: **Do not assume state from chat history. All memory, goals, and results are recorded in physical files.**

---

## 2. Directory Structure & Rules

* **`00_Constitution/` (READ-ONLY)**: Contains the human's core principles (`core.md`). Never edit this.
* **`01_Roadmap/` (READ-ONLY)**: Contains the macro roadmap (`roadmap.md`) and milestones. Never edit this.
* **`02_Task_Queue/` (READ-WRITE)**: Your designated workspace. You must only operate within the active folder: `02_Task_Queue/Task_<NNN>_<slug>/`.

---

## 3. Worker Execution Loop (Step-by-Step)

When picking up a task:
1. **Locate Active Task**: Scan `02_Task_Queue/` for the directory containing `status.txt` set to `PENDING` or `IN_PROGRESS`.
2. **Initialize Progress**: If `status.txt` is `PENDING`, update it to `IN_PROGRESS`.
3. **Parse Context**:
   - Read `role.md` -> Apply this as your system persona.
   - Read `recipe.md` -> Study the Objective, Input Sources, and Definition of Done (DoD).
4. **Surgical Development**:
   - Only read files listed in `recipe.md > Input Sources`.
   - Only modify files allowed by `recipe.md > Objective`. Never touch adjacent code.
5. **Trace Action Logging**:
   - Append every tool execution (file write, read, command run) to `action_log.jsonl` as a single JSON line:
     `{"ts": "ISO-8601-Time", "role": "worker", "tool": "tool_name", "args": {...}, "result": "ok"}`
6. **Submit (No Self-Approval)**:
   - When the local DoD checklist is fully satisfied, write your deliverable summary to `output.md`.
   - Change `status.txt` to `REVIEW`.
   - STOP execution and wait for the Human or Checker role.

---

## 4. Environment & Safety Interceptors
* **Git Commit**: The orchestrating harness auto-commits after every file write. Ensure your edits are clean.
* **Zero Hallucination**: If an input file is missing or recipe instructions are contradictory, call `escalate_issue()` immediately. Do not guess or make up mock content.
