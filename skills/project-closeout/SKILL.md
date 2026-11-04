---
name: project-closeout
description: Close a run. Writes the closeout record, sets the status honestly, and hands lesson candidates to the memory-curator. Promotion to shared memory is never part of closeout itself.
---
# project-closeout

**Owner:** director (with memory-curator for G11) · **Gates:** G10, G11 · **Routes to:** creative-os `lessons/` (read-only here).

## Steps
1. Confirm G8 (`qa-report.md` result PASS) and G9 (Ashish approved delivery; licence decisions made and recorded).
2. Write `runs/<run-id>/closeout.md` from `templates/project-closeout.md`: what shipped (paths), against the brief, evidence and QA, approvals and spend (quoted vs actual), rights, what went wrong, lesson candidates, memory proposals, next action.
3. Update `STATUS.md` (all six sections true, no `[TO FILL]`) and set `status: complete`. If something was stopped or partial, say `blocked` or leave `in_progress` and explain.
4. Run `scripts/check-run-completeness.sh runs/<run-id>` and `scripts/validate-harness.sh`; fix failures.
5. Hand lesson candidates to `memory-curator`: each is logged in `memory/lesson-candidates.md` as **single-observation**. Promotion needs a second separate real project and Ashish's yes.
6. Tell Ashish where finals live, what was not done, and the next action.

## Outputs
`closeout.md`, final `STATUS.md`, candidate entries.

## Verification
Completeness check passes; every approval row that was executed is approved; every delivered asset cleared.

## Never
Mark `complete` with a failed check, a missing QA PASS, an uncleared delivered asset, or an executed action without approval; promote memory on one project.
