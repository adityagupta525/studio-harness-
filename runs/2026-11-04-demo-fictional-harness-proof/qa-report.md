# QA report — FICTIONAL DEMO: "The Lamp Between Tides"

result: NOT RUN   <!-- PASS | FAIL | NOT RUN. The completeness check reads this line. -->

| Field | Value |
|---|---|
| Run | runs/2026-11-04-demo-fictional-harness-proof/ |
| Reviewer | none: no independent reviewer ran |
| Produced by | harness build |
| Date | 2026-11-04 |
| Scope | none: there is no media and no deliverable to review |

**FICTIONAL.** This report exists to show the shape and to state plainly that QA did not happen. A demo run cannot be `complete`.

## Checks
| # | Check | Method or command | Result | Evidence |
|---|---|---|---|---|
| 1 | Brief and success measure met | read against brief.md | NOT RUN | no deliverable |
| 2 | Sources and evidence ledger valid | scripts/check-source-ledger.sh | run at build time (structure only) | one placeholder row; zero real sources |
| 3 | Rights ledger valid; no unlicensed model input | scripts/check-run-completeness.sh | run at build time (structure only) | no assets exist |
| 4 | Shot specs complete and approvals recorded | scripts/check-run-completeness.sh | drafts only; correctly not approved | S01, S02 in draft |
| 5 | Continuity across shots | per-shot checklist | NOT RUN | nothing generated |
| 6 | Technical delivery (codec, resolution, duration, loudness) | ffprobe / ffmpeg ebur128 | NOT RUN | no media file |
| 7 | Craft against the picked route and charter bar | blind read | NOT RUN | no pick, no work |

## Measured values
None.

## Failures
None recorded, because nothing was reviewed.

## Not verified
Everything creative, every tool, every cost, every platform rule.

## Risks
Mistaking this demo for a real QA pass.

## Recommendation
Stop. This is a structural proof. Start a real run for real work.
