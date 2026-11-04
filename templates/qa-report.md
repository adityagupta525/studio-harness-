# QA report — [TO FILL: title]

result: NOT RUN   <!-- PASS | FAIL | NOT RUN. The completeness check reads this line. -->

| Field | Value |
|---|---|
| Run | runs/[TO FILL]/ |
| Reviewer | [TO FILL: qa-rights-reviewer — must not be the agent that produced the work] |
| Produced by | [TO FILL] |
| Date | [TO FILL] |
| Scope | [TO FILL: what was reviewed] |

## Checks
| # | Check | Method or command | Result | Evidence |
|---|---|---|---|---|
| 1 | Brief and success measure met | read against brief.md | | |
| 2 | Sources and evidence ledger valid | scripts/check-source-ledger.sh | | |
| 3 | Rights ledger valid; no unlicensed model input | scripts/check-run-completeness.sh | | |
| 4 | Shot specs complete and approvals recorded | scripts/check-run-completeness.sh | | |
| 5 | Continuity across shots | per-shot checklist | | |
| 6 | Technical delivery (codec, resolution, duration, loudness) | ffprobe / ffmpeg ebur128, numbers recorded | | |
| 7 | Craft against the picked route and the charter quality bar | blind read, AI-tell list | | |

## Measured values
(number, unit, tool, input file)

## Failures
-

## Not verified
(anything not checked, named plainly)

## Risks
-

## Recommendation
[TO FILL: ship / fix and re-review / stop]
