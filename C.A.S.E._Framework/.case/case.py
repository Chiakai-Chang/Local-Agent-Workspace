# -*- coding: utf-8 -*-
"""
C.A.S.E. Framework Controller Tool (case.py)
===========================================
A portable, zero-dependency controller script for initialized C.A.S.E. environments.
Supports:
  - init: Setup directories & templates
  - start: Pick a task, transition status, scaffold planning
  - submit: Pre-validate output, transition status to REVIEW, git commit
  - check: Verify read-only directories (Security Defense), parse DoD basics, transition to DONE/PENDING, perform learnings.md Hot/Cold compression.
"""

import os
import sys
import json
import datetime
import subprocess

def run_git(args, cwd=None):
    """Safely run a git command and return stdout. Returns None if git fails or is missing."""
    try:
        res = subprocess.run(["git"] + args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, cwd=cwd)
        if res.returncode == 0:
            return res.stdout.strip()
    except Exception:
        pass
    return None

def get_iso_time():
    return datetime.datetime.now().astimezone().isoformat()

def case_init():
    print("==========================================================")
    print("🚀 Initializing C.A.S.E. (Constitutional Agent State Engine) Setup")
    print("==========================================================")

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

    # For non-interactive or batch scripts, check environment or CLI args
    user_goal = ""
    if len(sys.argv) > 2:
        user_goal = " ".join(sys.argv[2:])
    else:
        print("\n📝 What is the primary development goal/objective for the AI Agent in this repository?")
        try:
            user_goal = input("👉 Enter Goal (e.g. 'Build user auth & profile page'): ").strip()
        except KeyboardInterrupt:
            print("\n\nSetup aborted.")
            sys.exit(0)
        
    if not user_goal:
        user_goal = "Refactor and optimize the current codebase."
        print(f"⚠️  No goal specified. Defaulting to: '{user_goal}'")

    folders = ["00_Constitution", "01_Roadmap", "02_Task_Queue"]
    for folder in folders:
        if not os.path.exists(folder):
            os.makedirs(folder)
            print(f"📁 Created folder: {folder}/")
        else:
            print(f"ℹ️  Folder already exists: {folder}/")

    # core.md
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

    # learnings.md (Hot Memory)
    learnings_path = os.path.join("00_Constitution", "learnings.md")
    if not os.path.exists(learnings_path):
        with open(learnings_path, "w", encoding="utf-8") as f:
            f.write("""# 🧠 C.A.S.E. Trainable Learnings (SkillOpt Space)

This document is the trainable state of this repository. The AI Agent writes findings here and reads them during task initialization.

## ## Anti-Patterns & Mistakes
*(AI Checker will auto-populate this section when mistakes are identified or tasks are rejected)*

## ## Reusable Patterns & Discoveries
*(AI Checker will auto-populate this section when new patterns or configurations are completed)*
""")
        print(f"📄 Generated learnings template: {learnings_path}")

    # archive_learnings.md (Cold Memory Archive)
    archive_path = os.path.join("00_Constitution", "archive_learnings.md")
    if not os.path.exists(archive_path):
        with open(archive_path, "w", encoding="utf-8") as f:
            f.write("""# 🗄️ C.A.S.E. Learnings Archive (Cold Storage)

This file stores consolidated and archived historical learnings to keep the active learnings context window small.

## ## Historical Anti-Patterns & Archival Notes
- Archival started on: """ + get_iso_time() + """
""")
        print(f"📄 Generated cold learning archive: {archive_path}")

    # roadmap.md & global_dod.md
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

    # Task_001_InitialScan
    task_dir = os.path.join("02_Task_Queue", "Task_001_InitialScan")
    if not os.path.exists(task_dir):
        os.makedirs(task_dir)
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
        with open(os.path.join(task_dir, "role.md"), "w", encoding="utf-8") as f:
            f.write("You are an expert system auditor. Examine the current workspace structure and output a meticulous audit report.")
        with open(os.path.join(task_dir, "status.txt"), "w", encoding="utf-8") as f:
            f.write("PENDING")
        print(f"📂 Setup initial task: {task_dir}")

    # IDE Guardrails (.cursorrules)
    cursorrules_content = """# C.A.S.E. Framework Guardrails
- Before modifying any code, identify the active task folder inside `02_Task_Queue/` (where `status.txt` is `PENDING` or `IN_PROGRESS`).
- Use the CLI helper: `python .case/case.py start <task_id>` to initiate your plan.
- Load that task's `role.md` as your System Prompt and `recipe.md` as your instruction manual.
- Write a `planning.md` file within the task folder detailing execution steps before editing production code.
- Modify files ONLY as specified in `recipe.md > Input Sources / Output Specification`.
- Track and append all tool calls to `action_log.jsonl` in the current task folder.
- Do NOT modify task status to DONE yourself. Run `python .case/case.py submit <task_id> "<summary>"` to submit.
"""
    if not os.path.exists(".cursorrules"):
        with open(".cursorrules", "w", encoding="utf-8") as f:
            f.write(cursorrules_content)
        print("🔗 Injected C.A.S.E. rules into `.cursorrules`.")
    else:
        with open(".cursorrules", "r", encoding="utf-8") as f:
            existing = f.read()
        if "C.A.S.E. Framework" not in existing:
            with open(".cursorrules", "a", encoding="utf-8") as f:
                f.write("\n\n" + cursorrules_content)
            print("🔗 Appended C.A.S.E. rules to your existing `.cursorrules`.")
        else:
            print("ℹ️  .cursorrules already contains C.A.S.E. rules.")

    # Gitignore
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

    print("\n==========================================================")
    print("🎉 C.A.S.E. Framework has been successfully initialized!")
    print("🤖 Your AI Agent will now respect the physical directory boundaries.")
    print("👉 Run: python .case/case.py start Task_001_InitialScan")
    print("==========================================================")

def case_start(task_id):
    task_dir = os.path.join("02_Task_Queue", task_id)
    if not os.path.exists(task_dir):
        print(f"❌ Error: Task folder '{task_dir}' does not exist.")
        sys.exit(1)

    status_file = os.path.join(task_dir, "status.txt")
    current_status = "PENDING"
    if os.path.exists(status_file):
        with open(status_file, "r", encoding="utf-8") as f:
            current_status = f.read().strip()

    if current_status in ["DONE", "REVIEW"]:
        print(f"❌ Error: Cannot start task. Task {task_id} is already in status '{current_status}'.")
        sys.exit(1)

    with open(status_file, "w", encoding="utf-8") as f:
        f.write("IN_PROGRESS")
    print(f"🔄 Task {task_id} status updated to: IN_PROGRESS")

    # Create planning.md template
    plan_path = os.path.join(task_dir, "planning.md")
    if not os.path.exists(plan_path):
        with open(plan_path, "w", encoding="utf-8") as f:
            f.write(f"""# 📝 Task Micro-Plan: {task_id}

[T] Constraints/Truths
- No modifications outside recipe constraints.
- Read learnings.md before executing.

[A] Planned Actions
- [A] Scan code directories => draft suggestions
- [A] Create output.md

[V] Verification Criteria
- [V] output.md matches recipe DoD items
""")
        print(f"📄 Scaffolded planning layout: {plan_path}")

    # Append to action_log.jsonl
    log_path = os.path.join(task_dir, "action_log.jsonl")
    log_entry = {
        "ts": get_iso_time(),
        "role": "worker",
        "tool": "case_start",
        "args": {"task_id": task_id},
        "result": "ok"
    }
    with open(log_path, "a", encoding="utf-8") as f:
        f.write(json.dumps(log_entry) + "\n")
    print(f"📝 Appended start log trace to: {log_path}")

def case_submit(task_id, summary=""):
    task_dir = os.path.join("02_Task_Queue", task_id)
    if not os.path.exists(task_dir):
        print(f"❌ Error: Task folder '{task_dir}' does not exist.")
        sys.exit(1)

    status_file = os.path.join(task_dir, "status.txt")
    current_status = "PENDING"
    if os.path.exists(status_file):
        with open(status_file, "r", encoding="utf-8") as f:
            current_status = f.read().strip()

    if current_status != "IN_PROGRESS":
        print(f"❌ Error: Task status is '{current_status}'. Only 'IN_PROGRESS' tasks can be submitted.")
        sys.exit(1)

    # Pre-validation
    output_path = os.path.join(task_dir, "output.md")
    if not os.path.exists(output_path) or os.path.getsize(output_path) == 0:
        print(f"❌ Error: 'output.md' is missing or empty. Cannot submit.")
        sys.exit(1)

    with open(status_file, "w", encoding="utf-8") as f:
        f.write("REVIEW")
    print(f"🔄 Task {task_id} status updated to: REVIEW")

    # Append to action_log.jsonl
    log_path = os.path.join(task_dir, "action_log.jsonl")
    log_entry = {
        "ts": get_iso_time(),
        "role": "worker",
        "tool": "case_submit",
        "args": {"task_id": task_id, "summary": summary},
        "result": "ok"
    }
    with open(log_path, "a", encoding="utf-8") as f:
        f.write(json.dumps(log_entry) + "\n")

    # Git Commit
    git_status = run_git(["status", "--porcelain", task_dir])
    if git_status:
        run_git(["add", task_dir])
        commit_msg = f"agent: worker submitted {task_id} - {summary}"
        run_git(["commit", "-m", commit_msg])
        print(f"💾 Automatically committed {task_id} changes to Git.")
    else:
        print("ℹ️  No changes detected in task folder; Git commit skipped.")

def case_check(task_id, force_done=False):
    task_dir = os.path.join("02_Task_Queue", task_id)
    if not os.path.exists(task_dir):
        print(f"❌ Error: Task folder '{task_dir}' does not exist.")
        sys.exit(1)

    status_file = os.path.join(task_dir, "status.txt")
    if not os.path.exists(status_file):
        print("❌ Error: status.txt is missing in task folder.")
        sys.exit(1)

    with open(status_file, "r", encoding="utf-8") as f:
        status = f.read().strip()

    if status != "REVIEW" and not force_done:
        print(f"⚠️  Task status is '{status}'. Only tasks in 'REVIEW' status can be checked.")
        sys.exit(1)

    # 1. SECURITY AUDIT: Check if Constitution or Roadmap was modified or if untracked files were added
    status_output = run_git(["status", "--porcelain", "00_Constitution", "01_Roadmap"])
    toxic_files = []
    git_root = run_git(["rev-parse", "--show-toplevel"])
    
    if status_output:
        for line in status_output.split("\n"):
            line = line.strip()
            if not line or len(line) < 3:
                continue
            # Extract the file path after the git status prefix (e.g. "M ", "?? ")
            filepath = line[3:].strip()
            # Resolve to absolute path relative to git root
            if git_root:
                abs_filepath = os.path.join(git_root, filepath)
            else:
                abs_filepath = os.path.abspath(filepath)
            toxic_files.append(abs_filepath)

    if toxic_files:
        print("🚨 SECURITY VIOLATION: Read-only directories modified by Worker!")
        for tf in toxic_files:
            print(f"   ↳ Toxic modification: {tf}")
        
        print("🛡️  Activating Security Defense: Reverting toxic files and removing untracked files...")
        run_git(["restore", "--staged"] + toxic_files)
        run_git(["restore"] + toxic_files)
        
        # Clean any untracked files or folders in protected directories
        for tf in toxic_files:
            if os.path.exists(tf):
                if os.path.isdir(tf):
                    import shutil
                    shutil.rmtree(tf)
                else:
                    os.remove(tf)
        
        with open(status_file, "w", encoding="utf-8") as f:
            f.write("ESCALATED")
        
        relative_toxic_names = [os.path.basename(tf) for tf in toxic_files]
        with open(os.path.join(task_dir, "feedback.md"), "w", encoding="utf-8") as f:
            f.write(f"### Security Rejection\n- Task halted due to unauthorized modification of read-only files: {', '.join(relative_toxic_names)}. Files have been reverted.")
        
        log_path = os.path.join(task_dir, "action_log.jsonl")
        log_entry = {
            "ts": get_iso_time(),
            "role": "checker",
            "tool": "security_audit",
            "args": {"toxic_files": toxic_files},
            "result": "SECURITY_VIOLATION_REVERTED"
        }
        with open(log_path, "a", encoding="utf-8") as f:
            f.write(json.dumps(log_entry) + "\n")
        sys.exit(1)

    # 2. Output and Log Validation
    output_path = os.path.join(task_dir, "output.md")
    if not os.path.exists(output_path) or os.path.getsize(output_path) == 0:
        print("❌ Verification Failed: output.md does not exist or is empty.")
        sys.exit(1)

    log_path = os.path.join(task_dir, "action_log.jsonl")
    if not os.path.exists(log_path) or os.path.getsize(log_path) == 0:
        print("❌ Verification Failed: action_log.jsonl is missing or empty (No traces).")
        sys.exit(1)

    # ANTI-LYING CHECK: If recipe requires testing, verify structured command runs in action_log.jsonl
    recipe_path = os.path.join(task_dir, "recipe.md")
    needs_test = False
    if os.path.exists(recipe_path):
        with open(recipe_path, "r", encoding="utf-8") as rf:
            recipe_content = rf.read().lower()
            if "test" in recipe_content or "testing" in recipe_content:
                needs_test = True

    if needs_test:
        has_test_trace = False
        with open(log_path, "r", encoding="utf-8") as lf:
            for line in lf:
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                    tool = entry.get("tool", "")
                    if tool in ["run_command", "execute", "execute_command", "run_shell_command", "shell_command"]:
                        args = entry.get("args", {})
                        cmd_line = ""
                        if isinstance(args, dict):
                            cmd_line = args.get("CommandLine", "") or args.get("command", "") or ""
                        else:
                            cmd_line = str(args)
                        if any(kw in cmd_line.lower() for kw in ["test", "pytest", "npm run test", "cargo test", "go test", "check"]):
                            has_test_trace = True
                            break
                except Exception:
                    # Fallback for plain lines (excluding case command lines themselves to avoid task ID matches)
                    if "case_start" not in line and "case_submit" not in line:
                        if any(kw in line.lower() for kw in ["test", "execute", "run_command"]):
                            has_test_trace = True
                            break
        if not has_test_trace:
            print("🚨 VERIFICATION FAILED (Anti-Lying Guard): Lying detected!")
            print("   ↳ The recipe specifies 'test' or 'testing' requirements, but no test or command execution traces were found in action_log.jsonl.")
            with open(status_file, "w", encoding="utf-8") as f:
                f.write("PENDING")
            with open(os.path.join(task_dir, "feedback.md"), "w", encoding="utf-8") as f:
                f.write("### Verification Rejected (Anti-Lying)\n- The task checklist specifies testing, but action_log.jsonl contains no execution traces of tests or runtime scripts. Do not claim done without running tests.")
            sys.exit(1)

    print("✅ Basic file specifications & Anti-Lying traces validated.")

    # 3. Transition to DONE
    with open(status_file, "w", encoding="utf-8") as f:
        f.write("DONE")
    print(f"🎉 Task {task_id} is approved and marked as DONE!")

    # Log Done
    log_entry = {
        "ts": get_iso_time(),
        "role": "checker",
        "tool": "case_check",
        "args": {"task_id": task_id, "approved": True},
        "result": "ok"
    }
    with open(log_path, "a", encoding="utf-8") as f:
        f.write(json.dumps(log_entry) + "\n")

    # 4. learnings.md Hot/Cold Consolidation (SkillOpt Maintenance)
    consolidate_learnings()

    # Git Commit finalized state
    run_git(["add", task_dir, "00_Constitution"])
    run_git(["commit", "-m", f"task({task_id}): checker approved and closed task"])

def parse_markdown_blocks(section_lines):
    """Groups lines into markdown blocks based on list items starting with '-' or '*'."""
    blocks = []
    current_block = []
    for line in section_lines:
        # A new block starts when a line starts with a dash or asterisk (optionally indented by spaces)
        stripped = line.lstrip()
        if stripped.startswith("- ") or stripped.startswith("* "):
            if current_block:
                blocks.append("".join(current_block))
                current_block = []
        current_block.append(line)
    if current_block:
        blocks.append("".join(current_block))
    return blocks

def consolidate_learnings():
    """Manages the 40-line threshold for learnings.md by moving older entries to archive_learnings.md"""
    learnings_path = os.path.join("00_Constitution", "learnings.md")
    archive_path = os.path.join("00_Constitution", "archive_learnings.md")

    if not os.path.exists(learnings_path):
        return

    with open(learnings_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    if len(lines) <= 40:
        return

    print("🧠 Consolidation Threshold Exceeded (learnings.md > 40 lines). Activating SkillOpt Consolidation...")
    
    header_section = []
    antipattern_lines = []
    discovery_lines = []
    
    current_sec = None
    for line in lines:
        if line.startswith("# ") or "This document" in line:
            header_section.append(line)
        elif "## Anti-Patterns" in line or "## ## Anti-Patterns" in line:
            current_sec = "anti"
        elif "## Reusable Patterns" in line or "## ## Reusable Patterns" in line:
            current_sec = "pattern"
        else:
            if current_sec == "anti":
                antipattern_lines.append(line)
            elif current_sec == "pattern":
                discovery_lines.append(line)
            else:
                header_section.append(line)

    antipattern_blocks = parse_markdown_blocks(antipattern_lines)
    discovery_blocks = parse_markdown_blocks(discovery_lines)

    keep_count = 5
    archive_anti = antipattern_blocks[:-keep_count] if len(antipattern_blocks) > keep_count else []
    keep_anti = antipattern_blocks[-keep_count:] if len(antipattern_blocks) > keep_count else antipattern_blocks
    
    archive_pat = discovery_blocks[:-keep_count] if len(discovery_blocks) > keep_count else []
    keep_pat = discovery_blocks[-keep_count:] if len(discovery_blocks) > keep_count else discovery_blocks

    if archive_anti or archive_pat:
        with open(archive_path, "a", encoding="utf-8") as af:
            af.write(f"\n### Consolidated on {get_iso_time()}\n")
            if archive_anti:
                af.write("#### Archived Anti-Patterns:\n")
                af.write("".join(archive_anti))
            if archive_pat:
                af.write("#### Archived Reusable Patterns:\n")
                af.write("".join(archive_pat))
        print(f"🗄️  Archived {len(archive_anti)} anti-patterns and {len(archive_pat)} discoveries to archive_learnings.md.")

    with open(learnings_path, "w", encoding="utf-8") as f:
        f.write("".join(header_section))
        f.write("\n## ## Anti-Patterns & Mistakes\n")
        if keep_anti:
            f.write("".join(keep_anti))
        else:
            f.write("*(AI Checker will auto-populate this section when mistakes are identified or tasks are rejected)*\n")
            
        f.write("\n## ## Reusable Patterns & Discoveries\n")
        if keep_pat:
            f.write("".join(keep_pat))
        else:
            f.write("*(AI Checker will auto-populate this section when new patterns or configurations are completed)*\n")
            
    print("🧹 learnings.md successfully compacted and updated.")

def case_create_subtask(slug, recipe_content):
    queue_dir = "02_Task_Queue"
    if not os.path.exists(queue_dir):
        print(f"❌ Error: Task queue directory '{queue_dir}' does not exist. Please run init first.")
        sys.exit(1)

    # Scan for existing Task_NNN folders to find the next index
    existing_tasks = [d for d in os.listdir(queue_dir) if os.path.isdir(os.path.join(queue_dir, d)) and d.startswith("Task_")]
    max_idx = 0
    for task in existing_tasks:
        parts = task.split("_")
        if len(parts) > 1:
            try:
                idx = int(parts[1])
                if idx > max_idx:
                    max_idx = idx
            except ValueError:
                pass

    next_idx = max_idx + 1
    new_task_id = f"Task_{next_idx:03d}_{slug}"
    new_task_dir = os.path.join(queue_dir, new_task_id)

    os.makedirs(new_task_dir)

    # Write status.txt
    with open(os.path.join(new_task_dir, "status.txt"), "w", encoding="utf-8") as f:
        f.write("PENDING")

    # Write role.md
    with open(os.path.join(new_task_dir, "role.md"), "w", encoding="utf-8") as f:
        f.write(f"You are a specialized agent tasked with executing: {slug}.")

    # Write recipe.md
    with open(os.path.join(new_task_dir, "recipe.md"), "w", encoding="utf-8") as f:
        f.write(recipe_content)

    # Update Roadmap
    roadmap_path = os.path.join("01_Roadmap", "roadmap.md")
    if os.path.exists(roadmap_path):
        with open(roadmap_path, "a", encoding="utf-8") as rf:
            rf.write(f"\n- [ ] {new_task_id}: {slug} (Created dynamically)\n")
        print(f"🗺️  Updated roadmap: Added {new_task_id}")

    print(f"🎉 Sub-task '{new_task_id}' successfully created in queue.")

def show_help():
    print("""C.A.S.E. Controller CLI Helper Tools
Usage:
  python .case/case.py init [optional goal]          - Initialize directories, constitutions & .cursorrules
  python .case/case.py start <task_id>               - Transition task to IN_PROGRESS & create planning.md
  python .case/case.py submit <task_id> "msg"        - Transition task to REVIEW & Git commit task changes
  python .case/case.py check <task_id>               - Run Security and DoD Verification, close task as DONE.
  python .case/case.py create_subtask <slug> "<recipe>" - Dynamically inject a new subtask into the Queue.
""")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        show_help()
        sys.exit(0)

    cmd = sys.argv[1]
    if cmd == "init":
        case_init()
    elif cmd == "start":
        if len(sys.argv) < 3:
            print("❌ Error: Missing task_id. Example: python .case/case.py start Task_001_InitialScan")
            sys.exit(1)
        case_start(sys.argv[2])
    elif cmd == "submit":
        if len(sys.argv) < 3:
            print("❌ Error: Missing task_id. Example: python .case/case.py submit Task_001_InitialScan \"Done audit\"")
            sys.exit(1)
        summary_msg = " ".join(sys.argv[3:]) if len(sys.argv) > 3 else "completed"
        case_submit(sys.argv[2], summary_msg)
    elif cmd == "check":
        if len(sys.argv) < 3:
            print("❌ Error: Missing task_id. Example: python .case/case.py check Task_001_InitialScan")
            sys.exit(1)
        case_check(sys.argv[2])
    elif cmd == "create_subtask":
        if len(sys.argv) < 3:
            print("❌ Error: Missing slug. Example: python .case/case.py create_subtask DownloadDeps \"Download external deps\"")
            sys.exit(1)
        recipe = sys.argv[3] if len(sys.argv) > 3 else "No description specified."
        case_create_subtask(sys.argv[2], recipe)
    else:
        show_help()
