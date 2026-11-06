---
name: channel-strategy
description: Research and position a zero-post channel. Category and audience research, competitor evidence from actual posts and videos, post-level deconstruction, an opportunity and positioning hypothesis, then the channel promise and editorial voice. Use for steps 2 to 6 of Channel Launch.
---
# channel-strategy

**Owners:** trend-scout (research, evidence pack), reference-forensics (deconstruction), creative-producer (positioning, promise, voice) · **Steps:** C2 to C6 · **Routes to:** scouting, video and still analysis, brand, story and critic skills from a private pack listed in the workspace profile.md (if any). Rules: [docs/12-channel-launch-and-growth.md](../../docs/12-channel-launch-and-growth.md), [docs/08-trend-and-competitor-research.md](../../docs/08-trend-and-competitor-research.md).

## When to use
Inside a `channel-launch` run after the brief exists. A new niche gets its own pack: audience, conventions, platform rules, competitors.

## Steps
1. **Category and audience research (C2):** build `research-pack.md` from public sources. Log every source in `sources.csv` with its full URL, access date and tags. State the audience as hypotheses by moment (when they open the app, what they want next), never as facts about a channel that has no data.
2. **Competitor set (C3):** choose competitors in `channel-competitor-map.md`: leaders, small craft-led channels (respected for craft evidence, not headcount), the closest cases, parallel cases from another sector, and **at least one outsider**. Public access only; Instagram rows state public / private / rate-limit limits. A discovery tool (TikTok Creative Center, Pinterest Trends) suggests where to look and never counts as proof.
3. **Competitor evidence from actual posts (C4):** for each competitor analyse at least two real posts or videos, **watching the video or viewing its frames** (the `reference-forensics` agent or a pack's video-analysis skill; `yt-dlp` on public URLs; or a file the owner supplies). One row per post in `competitor-posts.csv`, linked to a `sources.csv` row with the same URL. Collect available date, views, likes and comments (a whole number or `unknown`, as of the access date), format, duration, hook, shot structure (at least three timed beats), packaging, audience promise, retention hypothesis, and the evidence URL. A post that could not be pulled is listed under Unknowns and is not counted.
4. **Keep facts, interpretation and unknowns apart:** `observed_facts` starts `OBSERVED:`, `interpretation` starts `INFERRED:`, `retention_hypothesis` starts `H:`, `unknowns` starts `UNKNOWN:`. An outlier statement needs a comparative signal (a ratio against a named comparator with its sample size); otherwise `none`. A claim that a post went viral or outperformed needs a `CLAIM[...]` tag on the same line (label OBSERVED or INFERRED, metric, ratio basis, n, platform, date, source id; format in docs/08); the literal word inside a title, quote, creator name or URL is not a claim.
5. **Opportunity and positioning hypothesis (C5):** from the patterns across posts, write the whitespace as hypotheses, each creating an assumption id (H-nn) in `channel-brief.md` with a test. Use a blind critic (`panel-judge`, or a private pack's critic skill) on the positioning options (blind, one at a time) and name the contrarian case.
6. **Promise and editorial voice (C6):** one repeatable sentence, what the channel will never do, and a voice with original do and do-not examples. Structure and technique are learned from competitors; their footage, writing, music and visual identity are never reused.
7. **Ask the owner to lock positioning:** write a pending `lock_positioning` row, show the owner the positioning, promise and voice, the evidence behind them and the strongest case against; on the owner's yes record the owner's exact words and set `positioning_lock: locked`.
8. Run `scripts/check-source-ledger.sh` and `scripts/check-channel-plan.sh runs/<run-id>`; hand off.

## Outputs
`research-pack.md`, `sources.csv`, `channel-competitor-map.md`, `competitor-posts.csv`, positioning, promise and voice in `channel-brief.md`.

## Verification
At least 3 competitors (one outsider), 2 posts each and 8 posts in total, all examined from the post itself; full post URLs; prefixes present on every row; the ledger and plan checkers pass.

## Never
Judge a competitor from a bio, title or thumbnail alone; present packaging data as retention evidence; use paid vidIQ without a quote and an approved row; bypass a paywall, captcha or login; copy a creator's identity; state audience facts for a channel with no posts.
