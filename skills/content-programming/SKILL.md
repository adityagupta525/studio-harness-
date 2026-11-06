---
name: content-programming
description: Turn a locked positioning into a programme: 3 to 5 distinct pillars, repeatable formats and series, a packaging system (title, hook, thumbnail or cover, caption, CTA), a production system, and the first 30-post calendar with a 90-day strategy. Use for steps 7 to 11 of Channel Launch.
---
# content-programming

**Owners:** creative-producer (pillars, formats), packaging-lead (packaging system, calendar), ai-film-lead and motion-editor (production methods), director (production system) · **Steps:** C7 to C11 · **Routes to:** creative-os `content-studio`, `story-architect`, `graphic-design-director`, `ai-film-prompt-director`, `creative-critic`. Rules: [docs/12-channel-launch-and-growth.md](../../docs/12-channel-launch-and-growth.md), [docs/13-content-production-system.md](../../docs/13-content-production-system.md).

## When to use
After `lock_positioning` is approved. Pillars, packaging and the calendar are built on a locked position, never before.

## Steps
1. **Pillars (C7):** write 3 to 5 files in `pillars/` from `templates/content-pillar.md`. Each has a one-line promise, an audience moment, evidence (source ids and assumption ids), a success metric id, and a risk. Pillars must be **distinct** in promise and audience moment.
2. **Formats and series (C8):** at least 2 files in `formats/` from `templates/format-card.md`: a repeatable structure of at least three beats, a hook pattern, proof or value, making method (with tool stage), packaging pattern, effort S/M/L, risk and success metric. Ask the owner to lock pillars and formats (`lock_pillars`).
3. **Packaging system (C9):** in `channel-style-system.md` set one rule each for title, hook, thumbnail or cover, caption and CTA, each with its basis (competitor post ids or the hypothesis it tests) and an original example. Derive the visual direction from the positioning, not from a house style or a competitor's identity. Fill `hook-library.md` (at least 5 hooks, all `hypothesis` while posts are zero). Ask for `lock_visual_direction`.
4. **Production system (C10):** define the stages for every post (research, script, treatment, shot spec, make, QA) and create `post-cards/` from `templates/post-production-card.md` as posts enter production. QA is by someone other than the maker. Any paid step needs a quote and an approved `paid_generation` row first.
5. **Measurement plan (before the calendar locks):** `channel-metrics.md` with at least four metrics (one packaging, one retention), the comparative-signal definition, at least three decision rules each needing at least 5 posts, review cadence and honest limits ([docs/14-channel-measurement-and-learning.md](../../docs/14-channel-measurement-and-learning.md)).
6. **30-post calendar and 90-day strategy (C11):** in `content-calendar.md` give every idea all ten facts: audience moment, one-line promise, format, hook, proof or value, making method, packaging idea, effort, risk and success metric (naming a metric id). Add three phases that each test named hypotheses and end in a decision. Every pillar appears in the calendar. Ask for `lock_calendar` once positioning, pillars, formats and visual direction are locked.
7. Run `scripts/check-channel-plan.sh runs/<run-id>` and fix every error; hand off.

## Outputs
`pillars/`, `formats/`, `hook-library.md`, `channel-style-system.md`, `channel-metrics.md`, `content-calendar.md`, post-card pattern.

## Verification
3 to 5 distinct pillars; at least 2 formats; 5 packaging rules with basis; 30 calendar rows with all ten facts and a known pillar, format and metric id; 3 strategy phases; each lock has an approved row before its artifact is marked locked.

## Never
Program content before positioning is locked; assume spend; let one pillar duplicate another; promise numeric targets as facts; write a hook as `tested` before posts exist; reuse a creator's footage, writing, music or visual identity; schedule, post or message anything.
