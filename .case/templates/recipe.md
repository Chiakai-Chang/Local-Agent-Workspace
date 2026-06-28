# Task Recipe: [Task Title]

## Objective
[Clear explanation of what the task must achieve. One paragraph max.]

## Input Sources
- [Path or description of read-only inputs]
- [e.g., "02_Task_Queue/Task_001_InitialScan/output.md"]

## Output Specification
- [Path and structure of files that must be created or modified]
- [e.g., "output.md — Markdown report summarizing findings"]

## Local Definition of Done (DoD)
- [ ] Checklist item 1
- [ ] Checklist item 2
- [ ] Checklist item 3 (Include verification commands where applicable)

## Constraints
- Do not modify files outside: [List allowed files/directories]
- [Any additional constraints specific to this task]

## Escalation Trigger
Set `status.txt` to `ESCALATED` if:
- Self-healing attempts exceed 3 consecutive failures
- Input data is corrupt or unavailable
- The task scope has fundamentally changed from the Roadmap
