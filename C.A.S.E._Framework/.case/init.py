# -*- coding: utf-8 -*-
"""
C.A.S.E. Framework Initializer Script
=======================================
This script sets up the physical directory structure (00_Constitution, 01_Roadmap, 02_Task_Queue)
and automatically writes Cursor / Windsurf / IDE configuration rules.
"""

import os
import sys

def main():
    print("==========================================================")
    print("🚀 Initializing C.A.S.E. (Constitutional Agent State Engine) Setup")
    print("==========================================================")

    # 1. Project Context Scanning
    current_files = os.listdir('.')
    project_type = "Generic"
    if "package.json" in current_files:
        project_type = "JavaScript/TypeScript"
    elif "requirements.txt" in current_files or "pyproject.toml" in current_files:
        project_type = "Python"
    elif "Cargo.toml" in current_files:
        project_type = "Rust"
    elif "go.mod" in current_files:
        project_type = "Go"
    
    print(f"👁️  Detected Project Type: {project_type}")

    # 2. Get User's Target Goal
    print("\n📝 What is the primary development goal/objective for the AI Agent in this repository?")
    try:
        user_goal = input("👉 Enter Goal (e.g. 'Build user auth & profile page'): ").strip()
    except KeyboardInterrupt:
        print("\n\nSetup aborted.")
        sys.exit(0)
        
    if not user_goal:
        user_goal = "Refactor and optimize the current codebase."
        print(f"⚠️  No goal specified. Defaulting to: '{user_goal}'")

    # 3. Create Physical State Folders
    folders = ["00_Constitution", "01_Roadmap", "02_Task_Queue"]
    for folder in folders:
        if not os.path.exists(folder):
            os.makedirs(folder)
            print(f"📁 Created folder: {folder}/")
        else:
            print(f"ℹ️  Folder already exists: {folder}/")

    # 4. Generate 00_Constitution/core.md
    core_path = os.path.join("00_Constitution", "core.md")
    if not os.path.exists(core_path):
        with open(core_path, "w", encoding="utf-8") as f:
            f.write(f"""# 📂 Global Constitution

## 1. Core Mission Objective
- **Target Goal**: {user_goal}
- **Project Context**: {project_type} Development

## 2. Universal Principles
- **No Hallucinations**: Always base assertions on physical codebase search. Do not assume APIs exist without importing or viewing their implementation.
- **Strict Typing**: Maintain type safety and avoid implicit conversions (where language supports it).
- **Code Reuse**: Always search the codebase for existing utility functions before writing redundant code.

## 3. Forbidden Operations
- Never bypass tests or delete test files without user confirmation.
- Never write credentials, database passwords, or secret keys to source files.
""")
        print(f"📄 Generated core constitution: {core_path}")

    # Generate 00_Constitution/learnings.md (Trainable Skill Document)
    learnings_path = os.path.join("00_Constitution", "learnings.md")
    if not os.path.exists(learnings_path):
        with open(learnings_path, "w", encoding="utf-8") as f:
            f.write("""# 🧠 C.A.S.E. Trainable Learnings (SkillOpt Space)

This document is the trainable state of this repository. The AI Agent writes findings here and reads them during task initialization.

## ## Anti-Patterns & Mistakes
*(AI will auto-populate this section when mistakes are identified or tasks are rejected)*

## ## Reusable Patterns & Discoveries
*(AI will auto-populate this section when new patterns, configurations, or endpoints are successfully completed)*
""")
        print(f"📄 Generated learnings template: {learnings_path}")

    # 5. Generate 01_Roadmap/roadmap.md & global_dod.md
    roadmap_path = os.path.join("01_Roadmap", "roadmap.md")
    if not os.path.exists(roadmap_path):
        with open(roadmap_path, "w", encoding="utf-8") as f:
            f.write(f"""# 🗺️ Project Roadmap - {user_goal}

## Phase 1: Context Auditing
- [ ] Task_001_InitialScan: Perform deep file structure scan and identify optimization targets.

## Phase 2: Feature Implementation
- [ ] Task_002_CoreImplementation: Implement main logic according to spec.
- [ ] Task_003_UnitTestSuite: Create unit test cases covering edge behaviors.
""")
        print(f"📄 Generated roadmap: {roadmap_path}")

    dod_path = os.path.join("01_Roadmap", "global_dod.md")
    if not os.path.exists(dod_path):
        with open(dod_path, "w", encoding="utf-8") as f:
            f.write("""# ✅ Global Definition of Done (Global DoD)

The entire project is considered completed and shippable only when:
1. All task queues in `02_Task_Queue/` are marked as `DONE` and validated by Checkers.
2. The compiler/transpiler executes with 0 warnings/errors.
3. Test suites execute successfully with no failing test cases.
4. No structural placeholders (TODO, FIXME) remain in production code.
""")
        print(f"📄 Generated Global DoD: {dod_path}")

    # 6. Initialize Task_001_InitialScan in Task Queue
    task_dir = os.path.join("02_Task_Queue", "Task_001_InitialScan")
    if not os.path.exists(task_dir):
        os.makedirs(task_dir)
        # Create recipe.md
        with open(os.path.join(task_dir, "recipe.md"), "w", encoding="utf-8") as f:
            f.write(f"""# Task Recipe: Initial Project Scan

## Objective
Analyze current directory structures and draft an implementation plan for: "{user_goal}".

## Input Sources
- Existing source files in the project root.

## Output Specification
- Write a report to `output.md` containing files to be modified and architectural suggestions.

## Local Definition of Done (DoD)
- [ ] List all core directories and their languages/frameworks.
- [ ] Scan for potential codebase dependencies or conflicts.
- [ ] List at least 3 concrete steps for the upcoming implementation tasks.

## Constraints
- Do not modify any production source files.
""")
        # Create role.md
        with open(os.path.join(task_dir, "role.md"), "w", encoding="utf-8") as f:
            f.write("You are an expert system auditor. Examine the current workspace structure and output a meticulous audit report.")
        # Create status.txt
        with open(os.path.join(task_dir, "status.txt"), "w", encoding="utf-8") as f:
            f.write("PENDING")
        
        print(f"📂 Setup initial task: {task_dir}")

    # 7. Configure IDE Guardrails (.cursorrules)
    cursorrules_content = """# C.A.S.E. Framework Guardrails
- Before modifying any code, identify the active task folder inside `02_Task_Queue/` (where `status.txt` is `PENDING` or `IN_PROGRESS`).
- Load that task's `role.md` as your System Prompt and `recipe.md` as your instruction manual.
- Write a `planning.md` file within the task folder detailing execution steps before editing production code.
- Modify files ONLY as specified in `recipe.md > Input Sources / Output Specification`.
- Track and append all tool calls to `action_log.jsonl` in the current task folder.
- Never set task status to `DONE` yourself. Submit task for review when finished.
"""
    if not os.path.exists(".cursorrules"):
        with open(".cursorrules", "w", encoding="utf-8") as f:
            f.write(cursorrules_content)
        print("🔗 Injected C.A.S.E. rules into `.cursorrules`.")
    else:
        # Append safely
        with open(".cursorrules", "r", encoding="utf-8") as f:
            existing = f.read()
        if "C.A.S.E. Framework" not in existing:
            with open(".cursorrules", "a", encoding="utf-8") as f:
                f.write("\n\n" + cursorrules_content)
            print("🔗 Appended C.A.S.E. rules to your existing `.cursorrules`.")
        else:
            print("ℹ️  .cursorrules already contains C.A.S.E. rules.")

    # 8. Gitignore Adjustment
    print("\n📁 Manage Gitignore preferences:")
    print("  [1] Keep active execution logs and caches local (Prevents Git pollution, Recommended)")
    print("  [2] Track all execution logs and task files in Git (Full Compliance Audit Trail)")
    try:
        choice = input("👉 Enter choice (1/2, default: 1): ").strip()
    except KeyboardInterrupt:
        print("\n\nSetup aborted.")
        sys.exit(0)
        
    if choice != "2":
        ignore_lines = [
            "\n# C.A.S.E. Execution Logs and Caches",
            "02_Task_Queue/*/inputs/",
            "02_Task_Queue/*/action_log.jsonl",
            "worktrees/"
        ]
        with open(".gitignore", "a+", encoding="utf-8") as f:
            f.seek(0)
            content = f.read()
            for line in ignore_lines:
                if line not in content:
                    f.write(line + "\n")
        print("🛡  Added C.A.S.E. worktree & cache paths to `.gitignore`.")
    else:
        print("ℹ️  Git tracking of all C.A.S.E. execution files enabled.")

    print("\n==========================================================")
    print("🎉 C.A.S.E. Framework has been successfully initialized!")
    print("🤖 Your AI Agent will now respect the physical directory boundaries.")
    print("👉 Open 02_Task_Queue/Task_001_InitialScan/recipe.md to begin development!")
    print("==========================================================")

if __name__ == "__main__":
    main()
