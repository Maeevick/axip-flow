---
name: run-next-task
description: Execute the next TODO task in BLUEPRINT.md and return to the Principal. Use when the Principal runs /run-next-task.
disable-model-invocation: true
---

# Run Next Task

## Purpose

Execute exactly one task — the first TODO in BLUEPRINT.md — then stop.
Returns control to the Principal after the task completes or fails.

## Instructions

1. Read BLUEPRINT.md in full.
2. Find the first task with status `TODO`.
3. If no TODO task exists: report "No pending tasks." and stop.
4. If the first TODO is a `PRINCIPAL_BREAK`:
   - Mark it DONE in BLUEPRINT.md.
   - Report: "PRINCIPAL_BREAK reached. Awaiting review and decision."
   - Stop. Do not run the task after it.
5. Otherwise: mark the task IN PROGRESS in BLUEPRINT.md.
6. Execute using the standard CLAUDE.md orchestration pattern:
   - Extract WHY, WHAT, constraints from BLUEPRINT.
   - Invoke the appropriate implementing agent with full context.
   - Invoke the reviewer agent with identical context.
   - On PASS: mark DONE in BLUEPRINT.md.
   - On FAIL (after 2 correction cycles): mark FAIL in BLUEPRINT.md, report to Principal, stop.
7. Report result to Principal: task description, PASS or FAIL, any reviewer findings.

## Constraints

- Exactly one task per invocation. Never continue to the next.
- All existing hooks fire normally (post-tool-quality, guard-commands).
- Do not modify any task other than the one being executed.
