---
name: add-task
description: Append a new task to the BLUEPRINT.md TASKS section. Use when the Principal runs /add-task [description].
disable-model-invocation: true
---

# Add Task

## Purpose

Append a single task to the BLUEPRINT.md TASKS section.
No trigger. No orchestration. Blueprint mutation only.

## Arguments

`$ARGUMENTS` is the full task description as the Principal wrote it.

Special case: if `$ARGUMENTS` starts with `PRINCIPAL_BREAK`, the task is a stop signal, not executable work.

## Instructions

1. Read BLUEPRINT.md TASKS section to confirm current state.
2. Append at the end of the task list:
   - Standard task: `- [ ] TODO — $ARGUMENTS`
   - Break signal: `- [ ] PRINCIPAL_BREAK — $ARGUMENTS`
3. Confirm to the Principal: "Task appended: [full task line as written]"

## Constraints

- Append only. No reordering. No deletion. No status change.
- If ARGUMENTS is empty, ask the Principal for the task description. Do not append a blank entry.
- Never trigger agent invocation.
