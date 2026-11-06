# 12 — Channel Launch and growth

A new channel has **zero posts**. This route builds the system that researches, positions, plans, produces, packages, measures and improves it like a high-performing media team, **without inventing performance data and without publishing anything**. Machine rules: `policies/channel-launch.yaml`, enforced by `scripts/check-channel-plan.sh`. Skills: [channel-launch](../skills/channel-launch/SKILL.md), [channel-strategy](../skills/channel-strategy/SKILL.md), [content-programming](../skills/content-programming/SKILL.md).

## Principles
- **Hypotheses, not audience truth.** With no posts there is no audience data. Every belief about the audience, category, format, platform or distribution is an assumption (H-nn) with a status and a test.
- **Evidence from real posts.** A competitor is analysed from actual posts or videos that were watched or whose frames were viewed. A bio, title, thumbnail or metadata alone is not analysis.
- **Facts, interpretation and unknowns stay separate** (OBSERVED, INFERRED, H, UNKNOWN).
- **No performance claim without a comparative signal.** A statement that a post went viral or outperformed is a claim: it needs a `CLAIM[...]` tag (label OBSERVED or INFERRED, metric, ratio basis, sample size, platform, date, source id) on the same line, or it is rejected. The literal word inside a source title, quoted caption, creator name or URL is not a claim. Format and rules: [08](08-trend-and-competitor-research.md).
- **Style, not theft.** Structure and technique are learned. A creator's footage, writing, music and visual identity are never reused.
- **Humans lock, agents prepare.** Positioning, visual direction, pillars and formats, the first calendar and any production spend each need the owner's approval row.
- **Prepared, not posted.** No account is linked. The owner publishes by hand from a prepared package.

## The route
Opened as a run with `route: channel-launch` and `practice: content` ([runs/README.md](../runs/README.md)). Twelve steps:

| # | Step | Owner | Output | Lock |
|---|---|---|---|---|
| C1 | Channel brief | director | `channel-brief.md` | |
| C2 | Category and audience research | trend-scout | `research-pack.md`, `sources.csv` | |
| C3 | Competitor evidence pack | trend-scout | `channel-competitor-map.md` | |
| C4 | Competitor video and reel deconstruction | reference-forensics | `competitor-posts.csv` | |
| C5 | Opportunity and positioning hypothesis | creative-producer | `channel-brief.md` | |
| C6 | Channel promise and editorial voice | creative-producer | `channel-brief.md` | **lock_positioning** |
| C7 | 3 to 5 content pillars | creative-producer | `pillars/` | |
| C8 | Repeatable formats and series | creative-producer | `formats/` | **lock_pillars** |
| C9 | Packaging system: title, hook, thumbnail or cover, caption, CTA | packaging-lead | `channel-style-system.md`, `hook-library.md` | **lock_visual_direction** |
| C10 | Production system: research, script, treatment, shot spec, make, QA | director | `post-cards/` | |
| C11 | First 30-post calendar and 90-day strategy | packaging-lead | `content-calendar.md` | **lock_calendar** |
| C12 | Measurement, review and iteration loop | memory-curator | `channel-metrics.md`, `reviews/` | |

Order of locks: positioning first; pillars and visual direction need locked positioning; the calendar needs all three. The measurement plan (C12's definitions) is written before the calendar locks.

## Competitor evidence (steps C3 and C4)
Choose competitors on purpose: leaders, small craft-led channels (respected for craft evidence, not headcount), the closest cases, parallel cases from another sector and at least one outsider. Analyse at least 2 real posts each and 8 in total (uncalibrated defaults in the policy file).

One row per post in `competitor-posts.csv` ([templates/competitor-post-ledger.csv](../templates/competitor-post-ledger.csv)), linked to a `sources.csv` row with the same URL:

| Field group | Fields |
|---|---|
| Identity | competitor, URL of the post or video (never a profile page), platform, source id |
| Numbers (as of access date) | published date, views, likes, comments; a whole number or the word `unknown` |
| Structure | format, duration, hook, shot structure (at least three timed beats), packaging |
| Reading | audience promise, retention hypothesis |
| Separation | observed facts (`OBSERVED:`), interpretation (`INFERRED:`), hypothesis (`H:`), unknowns (`UNKNOWN:`) |
| Method | how it was examined (video watched, frames viewed, transcript read, file supplied) and the comparative signal |

A post that cannot be pulled (private, rate-limited, blocked) is named under Unknowns and does not count. Public content only; Instagram rows state public, private and rate-limit constraints; no paywall, captcha or login is bypassed. Retention and watch time are unknown without the owner's analytics, so they are written as hypotheses.

## From evidence to a position
1. Read across the posts and write patterns (INFERRED, citing post ids).
2. Find whitespace: what the audience moments need that the patterns do not give.
3. State the positioning as one hypothesis: for this audience moment, this channel promises this, unlike these patterns, because of this evidence, and we will know it is working when this metric moves. Each part becomes an assumption with a test.
4. Pressure-test with a blind critic and a contrarian pass. Show the owner the best option, the evidence and the strongest case against it, then request `lock_positioning`.

## Programme
- **Pillars (3 to 5):** distinct promises and audience moments, each tied to evidence and a metric. Two pillars that promise the same thing are one pillar.
- **Formats:** repeatable structures (at least three beats), so each post is cheaper to make and easier to learn from.
- **Packaging system:** one rule each for title, hook, thumbnail or cover, caption and CTA, with the basis for each. Hooks are hypotheses until tested.
- **Every idea** carries ten facts: audience moment, one-line promise, format, hook, proof or value, making method, packaging idea, effort, risk, success metric ([content-calendar template](../templates/content-calendar.md)).

## 90-day strategy (structure, not promised numbers)
| Phase | Days | Purpose | Ends with |
|---|---|---|---|
| 1 | 1 to 30 | ship the first posts, learn which hooks and formats the audience reacts to, build a baseline for this channel's own medians | a review of the first posts; inconclusive is an honest verdict at this size |
| 2 | 31 to 60 | repeat the formats the data supports with at least 5 posts of evidence, retire the weak, test one new hypothesis at a time | a review that may propose changes; changing a locked item needs a new approval |
| 3 | 61 to 90 | consolidate: a stable cadence, a hook library with tested entries, a revised calendar | a 90-day review and lesson candidates for the memory-curator |

Growth levers are **hypotheses to test**, one at a time: hook pattern, packaging, format repeatability, cadence, distribution, collaboration, cross-posting. This repo asserts no platform algorithm rules; anything about a platform's current rules is `[TO VERIFY]` against its official page.

## Approvals and limits
| Action | Rule |
|---|---|
| Lock positioning, pillars and formats, visual direction, calendar | an approved `lock_*` row with the owner's exact words before the artifact is marked locked |
| Production spend (generation, stock, paid tools) | quote, then an approved `paid_generation` row per batch |
| vidIQ or any paid research | never automatic; quote first |
| Publishing, account connection, email, any message | not part of v1; each needs its own approval and is disabled |

Rows live in `runs/<run-id>/approvals.csv` ([07](07-publishing-and-approval-policy.md)).

## What "complete" means
`scripts/check-channel-plan.sh` fails a plan marked `complete` without: real competitor and post URLs, stated assumptions (at least three, one about the audience), at least three distinct pillars, the four lock approvals with the owner's exact words, a measurement plan, a 30-post calendar with all ten facts per idea, and a three-phase strategy. The standard rules still apply (independent QA PASS, closeout). See [13](13-content-production-system.md) for making the posts and [14](14-channel-measurement-and-learning.md) for measuring and improving.
