---
name: qa
description: Run independent QA and rights review on a run and write the qa-report with a PASS, FAIL or NOT RUN verdict. The reviewer must not be the agent that produced the work.
---
# qa

**Owner:** qa-rights-reviewer · **Gate:** G8 · **Routes to:** creative-os `creative-critic`, `critic-judge` (blind), `product-qa` (UI).

## Steps
1. Confirm independence: name the reviewer and the producer; they must differ.
2. Run, and record exit codes for: `scripts/validate-harness.sh`, `scripts/check-source-ledger.sh`, `scripts/check-run-completeness.sh runs/<run-id>`.
3. Technical delivery: `ffprobe` and `ebur128` numbers (commands in `docs/05-verification-and-qa.md`); targets come from the brief or the platform's current page, never from memory.
4. Continuity: read the contact sheet against the shot specs and bible.
5. Craft: blind read against the picked route and the charter quality bar; apply the AI-tell list and the "500 others" test.
6. Rights: every delivered asset cleared; no `analysis-only` reference used as input or output; every executed action has an approved row.
7. Write `qa-report.md` from `templates/qa-report.md`. First line `result: PASS | FAIL | NOT RUN`. List failures with the shot or file, and a "Not verified" section. Withhold PASS if a required check did not run.
8. Hand off to the Director with the standard block. Do not fix the work yourself.

## Outputs
`qa-report.md`.

## Verification
All scripts run in this review, exit codes quoted; measured values carry command and file.

## Never
Review your own output, edit the ledgers to pass a check, declare a licence cleared, or decide creative direction.
