---
name: competitor-watch
description: Track and compare competitors or comparable studios and channels with dated, measured cards and honest limits. Use for a recurring watch or a one-off competitor study; paid data only with an approved quote.
---
# competitor-watch

**Owner:** trend-scout · **Gate:** feeds G2 · **Routes to:** a scouting skill from a private pack listed in the workspace profile.md, if any (read its library first), a design-forensics skill for a deep teardown.

## When to use
"Who else does this, and what do they do?", a monthly watch, or a competitor section inside a research pack.

## Steps
1. Define the set: closest cases, parallel cases from other sectors, one outsider. Include leading **and** small craft-led studios or channels (small means craft evidence, not headcount).
2. One `templates/competitor-card.md` per subject, with full URLs and "last checked" date.
3. Observed facts are dated and cited; interpretations are labelled `INFERRED` with the strongest alternative; unknowns are listed (retention is unknown without owner analytics).
4. Log every source in `sources.csv`; measured signals carry platform, geography, format, window, value, unit, `n_items`, uncertainty.
5. Instagram: public only, constraint stated. TikTok Creative Center and Pinterest Trends: discovery only.
6. Re-run the ledger check; record the date so the next watch can diff against it.

## Outputs
Competitor cards, `sources.csv` rows, a short "what changed since last check" note.

## Verification
`scripts/check-source-ledger.sh` exit 0; each card names its access method and limits.

## Never
Copy a competitor's footage or signature look; claim their performance beyond the measured signal; use paid tools without approval.
