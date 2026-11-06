---
name: qa-panel
description: Score any deliverable the same way every time - three blind panel judges on an anchored rubric (rubrics/), median per criterion, re-judge when judges disagree, vetoes stand, and a calibration drift check before scores are trusted. Use at every QA gate before work reaches the owner, when the owner asks "kitne number milenge", "score karo", "kaunsa better hai", or when scores look inconsistent across days.
---
# qa-panel

Owner: qa-chief (QA & Standards). Monitor: consistency-auditor. The maker never judges its own work.

## Steps
1. **Pick the rubric** for the deliverable type: `rubrics/short-video.json`, `short-script`, `thumbnail-title`, `brand-identity`, `channel-strategy`, `channel-dossier`. No rubric fits → stop and ask chief-engineer for one; never score on an ad-hoc scale.
2. **Check calibration first** (once per session or release): run three panel judges on the rubric's calibration set (`calibration/<rubric>/`, plus any items in the workspace `calibration/<rubric>/`), aggregate each item with `scripts/panel.py`, then `python3 scripts/drift.py <results> calibration/<rubric>/gold.json`. DRIFT → fix anchors or the judge setup before scoring real work.
3. **Run the panel blind.** Spawn three `panel-judge` agents in parallel. Each gets only: the item (files or text), the rubric path, the brief's success test, and the output path `runs/<run-id>/qa/panel/<item>/judge-<n>.json`. Never the other routes, the maker's notes, or each other's scores. Shuffle route labels.
4. **Aggregate.** `python3 scripts/panel.py runs/<run-id>/qa/panel/<item>` → `panel.json`, `panel.md`. INVALID → the judge redoes its file.
5. **Re-judge when told.** Verdict REJUDGE (a criterion spread > 1, or judge totals spread > 0.75) → three fresh blind judges score again; keep both rounds; the second round's panel decides; if it still disagrees, qa-chief writes the reason and shows the spread to the owner.
6. **Vetoes stand.** Any veto with evidence blocks the item. qa-chief may overturn only in writing, with evidence, in `decision-log.md`.
7. **Report** the verdict, score (x/5 and x/100), the spread and the anchor evidence in one table. Show the owner only items that PASS the bar, or say plainly that none did and why.
8. **Owner precedence.** The owner's pick outranks the panel. When the owner caps a criterion by choice (for example a layout he chose), log it as "capped by owner choice", not as a failure.

## Why this is consistent
Same rubric version, same anchors, three judges and a median, a measured spread, re-judging on disagreement, and a calibration set that proves the panel still scores like the gold before any real score is trusted. A score always carries its rubric id and version, so scores from different days are comparable or visibly not.

## Never
Score on an ad-hoc scale · let the maker judge its own work · show judges each other's scores or the other routes · average a veto away · report a score without its rubric id and version · trust new scores while drift.py says DRIFT.
