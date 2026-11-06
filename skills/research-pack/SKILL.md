---
name: research-pack
description: Build a dated, evidence-led research pack with a validated source ledger and at least eight real references examined and measured. Use after the brief, before any route is written.
---
# research-pack

**Owner:** trend-scout (signals) with reference-forensics (measured references) · **Gates:** G2, G3 · **Routes to:** scouting, video and still analysis and design-forensics skills from a private pack listed in the workspace profile.md (if any).

## When to use
After G1, for any brief. G1 includes a concrete `practice`; a run with `practice: unknown` cannot start research (the validator fails it). A new domain always gets its own pack: category, audience, competitors, conventions, regulation.

## Steps
1. Open `templates/research-pack.md` as `runs/<run-id>/research-pack.md`; write the question, platforms, geography and date window.
2. Search public sources only. For each source: open it, log a row in `sources.csv` with the full URL, date accessed, access method and tags (class, real / AI-made / unknown, rights class).
3. For each signal: platform, geography, format, date or window, value, unit, `n_items`, uncertainty. Separate YouTube packaging from retention. State Instagram constraints.
4. Find comparables: the closest cases, parallel cases from other sectors, one outsider; read each rationale in three layers (published, our interpretation, unknown).
5. Examine at least 8 real references: view the frames, measure (`ffprobe`, or a pack's measuring tools), record keep / swap / never. Never describe media you have not examined.
6. Run `scripts/check-source-ledger.sh runs/<run-id>/sources.csv`; fix every error.
7. Write findings with claim class, source ids, confidence; list what could not be examined; add implications for three routes.
8. Hand off with the standard block.

## Outputs
`research-pack.md`, `sources.csv`, DNA cards, competitor cards (if any).

## Verification
Ledger check exit 0; honest reference count "n of 8" with real / AI-made / unknown split.

## Never
Claim a post went viral or outperformed without a valid CLAIM tag, present packaging as retention, treat discovery-only sources as proof, bypass a login or paywall, use vidIQ without a quote and an approved row.
