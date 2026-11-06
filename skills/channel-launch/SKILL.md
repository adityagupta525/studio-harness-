---
name: channel-launch
description: Launch a new channel that has zero posts. Runs the 12-step Channel Launch workflow (brief, research, competitor evidence, positioning, pillars, formats, packaging, production system, 30-post calendar, measurement and review), with human locks and no invented data and no publishing. Use for a new YouTube, Instagram or other channel; orchestrates channel-strategy and content-programming.
---
# channel-launch

**Owner:** director · **Route:** `route: channel-launch`, `practice: content` · **Routes to:** `channel-strategy` (steps 2 to 6), `content-programming` (steps 7 to 11), creative-os `content-studio`, `design-intel`, `video-reference-analyzer`, `story-architect`, `brand-strategy`, `graphic-design-director`, `creative-critic`. Rules: [docs/12-channel-launch-and-growth.md](../../docs/12-channel-launch-and-growth.md), policy `policies/channel-launch.yaml`.

## When to use
A channel has no posts yet and needs a researched position, a plan, a production system and a measurement loop. Not for posting (the harness never publishes) and not for a one-off asset (use the standard loop).

## Steps
1. **Open the run** with `studio-brief`: `cp -R runs/_template runs/$(date +%F)-channel-<slug>`, context, and his brief in his words. Set `practice: content` and `route: channel-launch` in `STATUS.md` (and the Practice row of `brief.md`) **before** any channel file exists; the validator rejects channel files while the practice is `unknown`.
2. **Create the working files** from the templates: `channel-brief.md`, `channel-competitor-map.md`, `competitor-posts.csv` (from `templates/competitor-post-ledger.csv`), `hook-library.md`, `channel-style-system.md`, `content-calendar.md`, `channel-metrics.md`, plus empty folders `pillars/`, `formats/`, `post-cards/`, `reviews/`.
3. **C1 Channel brief:** fill `channel-brief.md` (state: zero posts, no audience data, `audience_data: none`). List every belief as an assumption with a status and a test.
4. **C2 to C6, with `channel-strategy`:** category and audience research, the competitor evidence pack, competitor video and reel deconstruction, the opportunity and positioning hypothesis, then the promise and editorial voice. Ask the owner to lock positioning (`lock_positioning`).
5. **C7 to C11, with `content-programming`:** 3 to 5 pillars, repeatable formats, the packaging system, the production system, then the 30-post calendar and 90-day strategy. Ask for `lock_pillars`, `lock_visual_direction`, then `lock_calendar`.
6. **C12 Measurement and review:** fill `channel-metrics.md` (metrics, comparative-signal definition, decision rules, review cadence, honest limits) before the calendar is locked. After posts exist, reviews go in `reviews/` ([docs/14-channel-measurement-and-learning.md](../../docs/14-channel-measurement-and-learning.md)).
7. **Approvals:** every lock is a row in `approvals.csv` first (`pending`), then his yes in chat with his words. Production spend is a separate `paid_generation` row with a cost quote. Nothing is locked or spent on an agent's word.
8. **Check** with `scripts/check-channel-plan.sh runs/<run-id>` and `scripts/check-run-completeness.sh runs/<run-id>`. A plan is `complete` only when both pass, QA (independent) says PASS, and `closeout.md` exists.
9. **Hand off** with the standard block; `open_decisions` names the next lock he must approve.

## Outputs
Channel brief, competitor map and post ledger, pillars, formats, hook library, style system, post-card pattern, calendar and 90-day strategy, metrics plan; approval rows for each lock.

## Verification
Competitor evidence thresholds met from real post URLs; at least three assumptions; three to five distinct pillars; four lock approvals with his words; measurement plan complete; zero-post honesty (no audience data, no tested hooks, no observations, no reviews).

## Never
Invent audience data, benchmarks or performance numbers; claim a post went viral or outperformed without a valid CLAIM tag; analyse a competitor from a bio or title alone; reuse a creator's footage, writing, music or visual identity; lock anything without his approval row; call a paid tool (vidIQ, generation), publish, connect an account or send any message without an approved row.
