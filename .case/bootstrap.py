#!/usr/bin/env python3
# =============================================================================
# C.A.S.E. Framework — Portable Bootstrap Script (Python)
# =============================================================================
# Usage:  python bootstrap.py [target_project_root]
# Effect: Deploys the complete C.A.S.E. directory structure into the target
#         project root. Safe to re-run (idempotent).
#
# This script runs on any platform (Windows, macOS, Linux) and under any shell,
# requiring only Python 3.x.
# =============================================================================

import os
import sys
import shutil

def main():
    # Target directory defaults to current directory
    target_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    target_dir = os.path.abspath(target_dir)

    print("========================================================")
    print(" C.A.S.E. Framework — Portable Python Bootstrap")
    print(f" Target: {target_dir}")
    print(f" Source: {os.path.dirname(os.path.abspath(__file__))}")
    print("========================================================")

    if not os.path.isdir(target_dir):
        print(f"[ERROR] Target directory does not exist: {target_dir}")
        sys.exit(1)

    case_dir = os.path.dirname(os.path.abspath(__file__))

    # 1. Create three-layer architecture
    print("\n[1/5] Creating three-layer directory structure...")
    layers = ["00_Constitution", "01_Roadmap", "02_Task_Queue"]
    for layer in layers:
        path = os.path.join(target_dir, layer)
        if not os.path.exists(path):
            os.makedirs(path)
            print(f"      ✓ Created {layer}/")
        else:
            print(f"      ✓ {layer}/ already exists (skipped)")

    # 2. Copy starter templates
    print("\n[2/5] Copying starter templates...")
    templates_src = os.path.join(case_dir, "templates")
    
    mapping = {
        "core.md": "00_Constitution/core.md",
        "roadmap.md": "01_Roadmap/roadmap.md",
        "global_dod.md": "01_Roadmap/global_dod.md"
    }

    if os.path.isdir(templates_src):
        for name, dest_rel in mapping.items():
            src_file = os.path.join(templates_src, name)
            dest_file = os.path.join(target_dir, dest_rel)
            if os.path.isfile(src_file):
                if not os.path.exists(dest_file):
                    shutil.copy2(src_file, dest_file)
                    print(f"      ✓ Copied to {dest_rel}")
                else:
                    print(f"      ✓ {dest_rel} already exists (skipped)")
    else:
        print("      ⚠️ templates directory not found in source")

    # 3. Update .gitignore (idempotent)
    print("\n[3/5] Updating .gitignore...")
    gitignore_path = os.path.join(target_dir, ".gitignore")
    ignore_lines = [
        "",
        "# C.A.S.E. Framework — task queues are agent workspace",
        "02_Task_Queue/",
        "*.case/"
    ]

    if os.path.isfile(gitignore_path):
        with open(gitignore_path, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        
        needs_update = False
        for line in ignore_lines:
            if line and line not in content:
                needs_update = True
                break
        
        if needs_update:
            with open(gitignore_path, "a", encoding="utf-8") as f:
                f.write("\n" + "\n".join(ignore_lines[1:]) + "\n")
            print("      ✓ Appended task queue entries to .gitignore")
        else:
            print("      ✓ .gitignore is already up to date (skipped)")
    else:
        with open(gitignore_path, "w", encoding="utf-8") as f:
            f.write("\n".join(ignore_lines[1:]) + "\n")
        print("      ✓ Created .gitignore with C.A.S.E. rules")

    # 4. Generate MAP.md navigation index
    print("\n[4/5] Generating MAP.md navigation index...")
    project_name = os.path.basename(target_dir)
    map_path = os.path.join(target_dir, "MAP.md")

    map_content = f"""# 🗺️ MAP — C.A.S.E. Navigation Index for {project_name}

> **Purpose:** This file is the entry point for all agents entering this project.
> Read this file FIRST, then navigate to specific files on-demand.
> Do NOT read all files at once — use this map as a table of contents.

## Three-Layer Architecture

| Layer | Directory | Authority | Read/Write |
|-------|-----------|-----------|------------|
| **Constitution** | `00_Constitution/` | Human Architect | Read-only for AI |
| **Roadmap** | `01_Roadmap/` | Layer 2 (Macro) | Read-only for Layer 3 |
| **Task Queue** | `02_Task_Queue/` | Layer 3 (Micro) | Read/Write (own task only) |

## File Map

### 📜 Constitution (Read-Only)
- [00_Constitution/core.md](00_Constitution/core.md) — Mission, constraints, domain rules
- [00_Constitution/learnings.md](00_Constitution/learnings.md) — Trainable patterns & anti-patterns (auto-managed)

### 🗺️ Roadmap (Read-Only for Executors)
- [01_Roadmap/roadmap.md](01_Roadmap/roadmap.md) — Phase breakdown & milestones
- [01_Roadmap/global_dod.md](01_Roadmap/global_dod.md) — Global Definition of Done

### 📋 Task Queue (Agent Workspace)
- [02_Task_Queue/](02_Task_Queue/) — Active task folders
  - Each task folder: `Task_<NNN>_<slug>/`
  - Contains: role.md, recipe.md, status.txt, inputs/, output.md, feedback.md, action_log.jsonl

### 📖 Documentation
- [CASE_framework_for_agents.md](CASE_framework_for_agents.md) — Full agent protocol (if deployed)
- `docs/` — Additional documentation

## Quick Reference

### For AI Agents
1. Read `MAP.md` ← You are here
2. Read `00_Constitution/core.md` for constraints
3. Read `01_Roadmap/roadmap.md` for context
4. Find your task in `02_Task_Queue/`
5. Read `role.md` and `recipe.md` in your task folder
6. Begin execution

### Status Machine
`PENDING` → `IN_PROGRESS` → `REVIEW` → `DONE`
`IN_PROGRESS` → `ESCALATED` (on failure)
`REVIEW` → `IN_PROGRESS` (if feedback requires changes)

### Key Rules
- Worker MUST NOT self-approve (dual-track verification)
- All context materialized as files (file-as-state)
- Maximum 3 self-healing attempts before escalation
- Git commit after every meaningful change

---
*MAP.md is auto-generated by bootstrap.py. Do not edit manually.*
"""
    with open(map_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(map_content)
    print("      ✓ MAP.md generated")

    # 5. Generate CASE.md (minimal ruleset for project root)
    print("\n[5/5] Generating CASE.md ruleset...")
    case_path = os.path.join(target_dir, "CASE.md")
    case_content = """# C.A.S.E. Framework — Project Rules

> This project uses the C.A.S.E. (Constitution-Architecture-State-Execution) framework.
> All AI agents MUST read and follow the rules below.

## Directory Structure
```
00_Constitution/    — READ-ONLY: Global constraints (core.md)
01_Roadmap/         — READ-ONLY: Phase plan (roadmap.md, global_dod.md)
02_Task_Queue/      — READ-WRITE: Agent workspace (task folders)
```

## Agent Operating Rules
1. **Read MAP.md first** — it is your navigation index
2. **Obey the Constitution** — never modify `00_Constitution/` or `01_Roadmap/`
3. **Stay in your lane** — only read/write your assigned task folder
4. **File-as-State** — all progress lives in files, not conversation context
5. **Dual-track verification** — Worker and Checker roles must be separate
6. **Git small steps** — commit after every meaningful change
7. **3-strike self-healing** — max 3 attempts before escalating

## Status Machine
`PENDING` → `IN_PROGRESS` → `REVIEW` → `DONE`
`IN_PROGRESS` → `ESCALATED` (on persistent failure)

## For Humans
To deploy the full agent protocol, run:
```bash
python .case/bootstrap.py
```
Then instruct your AI agent: "This project uses C.A.S.E. framework. Read CASE.md."
"""
    with open(case_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(case_content)
    print("      ✓ CASE.md generated")

    print("\n========================================================")
    print(" ✅ C.A.S.E. Framework Bootstrap Complete!")
    print("\n Next steps:")
    print("  1. Edit 00_Constitution/core.md with your mission")
    print("  2. Edit 01_Roadmap/roadmap.md with your phases")
    print("  3. Instruct your AI agent:")
    print('     "This project uses C.A.S.E. framework. Read CASE.md."')
    print("========================================================")

if __name__ == "__main__":
    main()
