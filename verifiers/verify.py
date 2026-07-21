#!/usr/bin/env python3
"""
C.A.S.E. Framework — Task Verifier (Python)

Validates a task's completeness before submission.
Usage: python verify.py <task_folder_path>

Exit codes: 0 = PASS, 1 = FAIL (with reason printed to stderr)
"""

import sys
import os
import json

# Windows consoles often default to a legacy codepage (e.g. cp950) that
# can't encode the emoji used below, crashing the PASS path itself.
for _stream in (sys.stdout, sys.stderr):
    if hasattr(_stream, "reconfigure"):
        _stream.reconfigure(encoding="utf-8")


def verify(task_dir: str) -> dict:
    errors = []
    warnings = []
    status = 'PENDING'

    # 1. Check required files exist
    required_files = ['recipe.md', 'role.md', 'status.txt', 'output.md']
    for fname in required_files:
        fpath = os.path.join(task_dir, fname)
        if not os.path.isfile(fpath):
            errors.append(f"Missing required file: {fname}")

    # 2. Check status.txt has valid token
    status_path = os.path.join(task_dir, 'status.txt')
    if os.path.isfile(status_path):
        with open(status_path, 'r', encoding='utf-8') as f:
            status = f.read().strip()
        valid_statuses = ['PENDING', 'IN_PROGRESS', 'REVIEW', 'DONE', 'ESCALATED']
        if status not in valid_statuses:
            errors.append(f'Invalid status token: "{status}" (must be one of: {", ".join(valid_statuses)})')

    # 3. Check action_log.jsonl (or fallback log.md) exists and has valid log entries
    log_path = os.path.join(task_dir, 'action_log.jsonl')
    fallback_log_path = os.path.join(task_dir, 'log.md')
    
    if os.path.isfile(log_path):
        with open(log_path, 'r', encoding='utf-8') as f:
            lines = [l.strip() for l in f.readlines() if l.strip()]
        if lines:
            valid_lines = 0
            for line in lines:
                try:
                    json.loads(line)
                    valid_lines += 1
                except json.JSONDecodeError:
                    pass
            if valid_lines == 0:
                errors.append("action_log.jsonl has no valid JSON entries")
            invalid_count = len(lines) - valid_lines
            if invalid_count > 0:
                warnings.append(f"action_log.jsonl has {invalid_count} invalid JSON line(s)")
    elif os.path.isfile(fallback_log_path):
        with open(fallback_log_path, 'r', encoding='utf-8') as f:
            content = f.read().strip()
        if len(content) < 10:
            warnings.append("log.md fallback exists but appears too short (< 10 chars)")
    else:
        warnings.append("Missing trace log: Neither action_log.jsonl nor log.md was found in task directory")

    # 4. Check output.md is non-empty
    output_path = os.path.join(task_dir, 'output.md')
    if os.path.isfile(output_path):
        with open(output_path, 'r', encoding='utf-8') as f:
            content = f.read().strip()
        if len(content) < 10:
            warnings.append("output.md appears very short (< 10 chars) — may be a placeholder")

    # 5. Check recipe.md has DoD section
    recipe_path = os.path.join(task_dir, 'recipe.md')
    if os.path.isfile(recipe_path):
        with open(recipe_path, 'r', encoding='utf-8') as f:
            recipe = f.read()
        if '## Local Definition of Done' not in recipe:
            warnings.append('recipe.md missing "## Local Definition of Done" section')
        if '## Objective' not in recipe:
            warnings.append('recipe.md missing "## Objective" section')

    # 6. Check for ESCALATED status with feedback
    if os.path.isfile(status_path):
        with open(status_path, 'r', encoding='utf-8') as f:
            status = f.read().strip()
        if status == 'ESCALATED':
            feedback_path = os.path.join(task_dir, 'feedback.md')
            if not os.path.isfile(feedback_path):
                errors.append("ESCALATED status requires feedback.md with failure details")

    # 7. Check planning.md exists with a Self-Review section (Section 6 step 4)
    planning_path = os.path.join(task_dir, 'planning.md')
    if not os.path.isfile(planning_path):
        warnings.append("Missing planning.md — Section 6 step 4 requires a plan + Self-Review before execution begins")
    else:
        with open(planning_path, 'r', encoding='utf-8') as f:
            planning = f.read()
        if '## Self-Review' not in planning and '[R]' not in planning:
            warnings.append('planning.md missing a Self-Review section — the plan must be reviewed against recipe.md before execution (Section 6 step 4)')

    # 8. Check retro.md exists with required sections when status is DONE (Section 13a)
    if status == 'DONE':
        retro_path = os.path.join(task_dir, 'retro.md')
        if not os.path.isfile(retro_path):
            errors.append("DONE status requires retro.md (Section 13a: mandatory retrospective before every DONE transition)")
        else:
            with open(retro_path, 'r', encoding='utf-8') as f:
                retro = f.read()
            for section in ['Gaps & Missteps', 'Optimization Opportunities', 'Lessons Learned', 'Feedback to CASE']:
                if section not in retro:
                    warnings.append(f'retro.md missing expected section: "{section}" (Section 13a requires all four)')

    # Report
    if errors:
        print("❌ VERIFICATION FAILED:", file=sys.stderr)
        for e in errors:
            print(f"  • {e}", file=sys.stderr)
        if warnings:
            print("\n⚠️  WARNINGS:", file=sys.stderr)
            for w in warnings:
                print(f"  • {w}", file=sys.stderr)
        return {"success": False, "errors": errors, "warnings": warnings}

    print("✅ VERIFICATION PASSED")
    
    # Run memory tiering automatically if status is DONE or REVIEW
    if status in ['DONE', 'REVIEW']:
        project_root = os.path.abspath(os.path.join(task_dir, '..', '..'))
        # Search for path where 00_Constitution/learnings.md exists
        # In case structure is flat or nested
        if not os.path.isdir(os.path.join(project_root, '00_Constitution')):
            # Fallback: check one level up
            project_root = os.path.abspath(os.path.join(task_dir, '..'))
        
        if os.path.isdir(os.path.join(project_root, '00_Constitution')):
            try:
                sys.path.append(os.path.dirname(os.path.abspath(__file__)))
                from memory_tiering import manage_memory
                manage_memory(project_root)
            except Exception as ex:
                warnings.append(f"Could not run memory tiering: {ex}")

    if warnings:
        print("\n⚠️  WARNINGS:")
        for w in warnings:
            print(f"  • {w}")
    return {"success": True, "errors": [], "warnings": warnings}


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python verify.py <task_folder_path>")
        sys.exit(1)

    task_dir = sys.argv[1]
    if not os.path.isdir(task_dir):
        print(f"Error: Directory not found: {task_dir}", file=sys.stderr)
        sys.exit(1)

    result = verify(task_dir)
    sys.exit(0 if result['success'] else 1)
