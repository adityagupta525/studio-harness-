---
name: studio-brief
description: Start a project. Declares the context, captures the brief in Ashish's exact words, states business logic and success measure, creates the run folder from runs/_template, and lists the approvals needed up front. Use at the start of any new job.
---
# studio-brief

**Owner:** director · **Gate:** G1 · **Routes to:** creative-os `creative-pipeline` / `autopilot` when the medium or look is still open.

## When to use
A new brief arrives ("is style me banana hai", "reel banao", a client request, a content idea). Not for a quick question or a follow-up inside a running job.

## Steps
1. Read `~/creative-os/CHARTER.md`, then `memory/` scopes for the context. Ask at most five intake questions, each with a default; never ask "kaisa look chahiye".
2. Create the run: `cp -R runs/_template runs/$(date +%F)-<slug>`; set `run_id`, `context`, dates in `STATUS.md`. If the brief is not in his words yet (empty, or placeholder text like "[...]"), keep `practice: unknown`, set `status: blocked`, log a decision row saying practice is unknown, and ask him for one line. Do nothing else.
3. Once the brief exists, set a **concrete practice** (it picks the builder; `unknown` never routes anywhere) and `status: in_progress`, in both `STATUS.md` and the Practice row of `brief.md`. Fill `brief.md` from `templates/project-brief.md`: his words verbatim, business logic, success measure, style source (the client system outranks taste), constraints with a credit ceiling, rights, unknowns as `[TO VERIFY]`, approvals needed.
4. Choose the run size (full / sprint / one-off) and record it with the reason in `decision-log.md`.
5. Write `STATUS.md` sections honestly (Deliverables: brief.md; Verification: not yet checked).
6. Show Ashish the brief in one short block and ask him to confirm G1.

## Outputs
`brief.md`, `STATUS.md`, `decision-log.md` (D-01 context and size).

## Verification
`scripts/check-run-completeness.sh runs/<run-id>` passes (draft or in_progress).

## Never
Decide the brand, assume a house style, mix contexts, start research that spends credits, or write a practice value just to satisfy the validator.
