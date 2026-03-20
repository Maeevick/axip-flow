---
name: read-tasks
description: Display the current task list from BLUEPRINT.md and sync internal task state. Use when the Principal runs /read-tasks.
disable-model-invocation: true
---

# Read Tasks

## Purpose

Force-sync Claude's internal understanding of task state from BLUEPRINT.md.
Display the current TASKS section in a readable format.
Use when resuming a session or after manual blueprint edits.

## Instructions

1. Read BLUEPRINT.md in full.
2. Extract the TASKS section.
3. Display every task with its current status symbol, in order:
   - `[x] DONE`
   - `[ ] TODO`
   - `[ ] IN PROGRESS`
   - `[ ] FAIL`
   - `[ ] SKIP`
   - `[ ] PRINCIPAL_BREAK`
4. Count and summarize: X done, Y todo, Z pending review.
5. Identify the next actionable task (first TODO that is not a PRINCIPAL_BREAK).

## Output format
```
## Task State — [project name]

[x] DONE — [description]
[x] DONE — [description]
[ ] TODO — [description]          ← next
[ ] PRINCIPAL_BREAK — [description]
[ ] TODO — [description]

Summary: 2 done · 2 todo · 1 break ahead
Next: [task description]
```

No blueprint edits. Read only.
