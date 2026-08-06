#!/usr/bin/env python3
"""
C.A.S.E. Framework — Task Verifier (Python)

Validates a task's completeness before submission.

Usage:
    python verify.py <task_folder_path> [--strict] [--tier-memory]
    python verify.py --queue <02_Task_Queue_path> [--strict]

Exit codes: 0 = PASS, 1 = FAIL (with reason printed to stderr)

  --strict        Treat warnings as errors. Ten of this verifier's fifteen
                  checks were warnings, so a task with no audit trail, no local
                  Definition of Done, no plan and a one-character output.md
                  printed "VERIFICATION PASSED". That is the "format passes,
                  function missing" shape the protocol's own convergence gate
                  warns against. The default stays permissive so existing task
                  queues keep their exit codes; callers that want the whole
                  protocol enforced ask for it.

  --tier-memory   Run memory tiering after a successful verification. This used
                  to happen automatically whenever status was DONE or REVIEW,
                  which meant a command named `verify` rewrote
                  00_Constitution/learnings.md as a side effect, and running it
                  twice did not mean the same thing as running it once.

  --queue         Check the invariants that span the whole queue rather than one
                  task package: at most one task IN_PROGRESS, and tasks finished
                  in order. "One task at a time" is the promise the framework is
                  built on and nothing verified it, because verify only ever saw
                  a single task directory.
"""

import argparse
import sys
import os
import json
import re

# Windows consoles often default to a legacy codepage (e.g. cp950) that
# can't encode the emoji used below, crashing the PASS path itself.
for _stream in (sys.stdout, sys.stderr):
    if hasattr(_stream, "reconfigure"):
        _stream.reconfigure(encoding="utf-8")


VALID_STATUSES = ['PENDING', 'IN_PROGRESS', 'REVIEW', 'DONE', 'ESCALATED']
TASK_DIR_RE = re.compile(r'^Task_(\d+)_')


def _report(errors, warnings, ok_message):
    """Print the outcome and return the result dict.

    Shared by verify() and verify_queue() so the two cannot drift into printing
    different things for the same condition.
    """
    if errors:
        print("❌ VERIFICATION FAILED:", file=sys.stderr)
        for e in errors:
            print(f"  • {e}", file=sys.stderr)
        if warnings:
            print("\n⚠️  WARNINGS:", file=sys.stderr)
            for w in warnings:
                print(f"  • {w}", file=sys.stderr)
        return {"success": False, "errors": errors, "warnings": warnings}

    print(ok_message)
    if warnings:
        print("\n⚠️  WARNINGS:")
        for w in warnings:
            print(f"  • {w}")
    return {"success": True, "errors": [], "warnings": warnings}


def verify_queue(queue_dir: str, strict: bool = False) -> dict:
    """Check the invariants that only exist across the whole queue.

    A task package can be perfect on its own while the queue around it is not
    being worked one task at a time — which is the entire point of the queue.
    Directories that are not task packages (an `_archive/`, notes, anything not
    matching `Task_<NNN>_<slug>`) are skipped rather than reported: the queue
    folder is allowed to hold other things.
    """
    errors = []
    warnings = []
    tasks = []

    if not os.path.isdir(queue_dir):
        return _report([f"Queue directory not found: {queue_dir}"], [], "")

    for name in sorted(os.listdir(queue_dir)):
        path = os.path.join(queue_dir, name)
        m = TASK_DIR_RE.match(name)
        if not os.path.isdir(path) or not m:
            continue
        status_path = os.path.join(path, 'status.txt')
        if not os.path.isfile(status_path):
            errors.append(f"{name}: missing status.txt — the queue cannot be read without it")
            continue
        with open(status_path, 'r', encoding='utf-8') as f:
            status = f.read().strip()
        if status not in VALID_STATUSES:
            errors.append(
                f'{name}: invalid status token "{status}" '
                f'(must be one of: {", ".join(VALID_STATUSES)})')
            continue
        tasks.append((int(m.group(1)), name, status))

    active = [n for _i, n, s in tasks if s == 'IN_PROGRESS']
    if len(active) > 1:
        errors.append(
            "More than one task is IN_PROGRESS (%s) — the queue is worked one "
            "task at a time" % ", ".join(active))

    # Finishing out of order is legitimate when tasks are genuinely independent,
    # so it is a warning by default and an error for callers who want the queue
    # order to mean something.
    for index, name, status in tasks:
        if status != 'DONE':
            continue
        earlier = [n for i, n, s in tasks if i < index and s != 'DONE']
        if earlier:
            warnings.append(
                "%s is DONE out of order — still open before it: %s"
                % (name, ", ".join(earlier)))

    if strict and warnings:
        errors.extend(warnings)
        warnings = []

    return _report(errors, warnings,
                   f"✅ QUEUE VERIFICATION PASSED ({len(tasks)} task(s))")


def verify(task_dir: str, strict: bool = False, tier_memory: bool = False) -> dict:
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
        if status not in VALID_STATUSES:
            errors.append(f'Invalid status token: "{status}" (must be one of: {", ".join(VALID_STATUSES)})')

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

    # Under --strict every check counts. The split between "error" and "warning"
    # was never about severity — a missing audit trail is not a lesser problem
    # than a missing file — it was about not breaking task queues that predate
    # each new rule.
    if strict and warnings:
        errors.extend(warnings)
        warnings = []

    result = _report(errors, warnings, "✅ VERIFICATION PASSED")
    if not result["success"]:
        return result

    # Only when asked. This used to run on every DONE or REVIEW verification,
    # so `verify` rewrote 00_Constitution/learnings.md without being asked to
    # and could not be run twice for the same answer.
    if tier_memory and status in ['DONE', 'REVIEW']:
        project_root = os.path.abspath(os.path.join(task_dir, '..', '..'))
        # The structure may be flat or nested; look one level up as a fallback.
        if not os.path.isdir(os.path.join(project_root, '00_Constitution')):
            project_root = os.path.abspath(os.path.join(task_dir, '..'))

        if os.path.isdir(os.path.join(project_root, '00_Constitution')):
            try:
                sys.path.append(os.path.dirname(os.path.abspath(__file__)))
                from memory_tiering import manage_memory
                manage_memory(project_root)
            except Exception as ex:
                print(f"  • Could not run memory tiering: {ex}")
                result["warnings"].append(f"Could not run memory tiering: {ex}")

    return result


def main(argv=None):
    ap = argparse.ArgumentParser(
        prog="verify.py",
        description="C.A.S.E. task and queue verifier.")
    ap.add_argument("path", nargs="?",
                    help="a task folder, or the queue folder when --queue is given")
    ap.add_argument("--queue", action="store_true",
                    help="check queue-wide invariants instead of one task package")
    ap.add_argument("--strict", action="store_true",
                    help="treat warnings as errors")
    ap.add_argument("--tier-memory", action="store_true", dest="tier_memory",
                    help="run memory tiering after a successful task verification")
    args = ap.parse_args(argv)

    if not args.path:
        ap.print_usage(sys.stderr)
        return 1
    if not os.path.isdir(args.path):
        print(f"Error: Directory not found: {args.path}", file=sys.stderr)
        return 1

    if args.queue:
        result = verify_queue(args.path, strict=args.strict)
    else:
        result = verify(args.path, strict=args.strict, tier_memory=args.tier_memory)
    return 0 if result['success'] else 1


if __name__ == '__main__':
    sys.exit(main())
