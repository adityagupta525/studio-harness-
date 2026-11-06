---
name: channel-dossier
description: Build a Channel Dossier for any YouTube channel (and its Instagram if public) from one handle or URL - biography and timeline, formats and series, cadence, measured performance and outliers, packaging patterns, competitor map, monetization streams with earning points, risks and lessons to steal (structure, not assets). Use for "is channel ke baare me batao", "tell me about channel X", "competitors kaun hain", "ye kitna kamata hai", "how does X grow", or before planning a channel in the same niche.
---
# channel-dossier

Owner: channel-analyst (Intelligence; chief intel-chief). Monitor: fact-checker (every number and claim has a source, method and tag). Output lives in the workspace: `channels/<handle>/dossier.md`, with raw pulls in `channels/<handle>/pull/<date>/`.

## Steps
1. **Pull (measured, free).** `python3 scripts/channel-pull.py @handle <workspace>/channels/<handle>/pull/<YYYY-MM-DD>` (yt-dlp, public pages; `--max`, `--detail-long`, `--detail-shorts` to size it). A bring-your-own YouTube Data API key adds exact channel statistics and the creation date. Paid tools (vidIQ, Social Blade Pro) only with a quote and the owner's yes.
2. **Stats.** `python3 scripts/channel-stats.py <pull dir>` writes `stats.md` and `stats.json`: medians and quartiles per format, outliers against the trailing median (>= 2x with n >= 10, >= 3x strong), cadence and engagement from the detailed sample, title patterns, sponsor and link markers. Copy numbers from these files only. Cadence needs >= 10 dated uploads over >= 7 days; date a few ranks across the tab (`yt-dlp -j` on rank 300, 750, 1500) to confirm it holds.
3. **Watch, don't guess.** Examine at least 3 outliers and 3 median uploads per format (frames, transcript, first 3 seconds, structure). Use a video-analysis skill if one is installed; otherwise `ffmpeg` frames and `yt-dlp --write-auto-subs`. Write the hook, beat structure, pacing and visual grammar you measured. Cuts: count hard cuts with `ffmpeg ... select='gt(scene,0.3)'`, and for 3D or motion-heavy work also cluster changes at `scene>0.08` (panel flips and whip pans fall under 0.3); report both and say which you used for the average shot length.
4. **Biography and timeline.** Start date (API, first upload, or a dated source), pivots, milestones, team and tools, from the channel's About, interviews, press and the creator's own posts. Every line dated and linked; unknown stays unknown.
5. **Competitors.** At least 5 channels with full URLs: direct (same format and audience), adjacent (same audience, other format), and one outsider. Pull each with `channel-pull.py --max 200 --detail-long 5 --detail-shorts 10` when the job needs numbers.
6. **Monetization and earning points.** List every stream seen with evidence: ads (long-form and Shorts revenue share), sponsors (from descriptions and spoken reads), memberships, merch, affiliate, courses, licensing, brand deals, other businesses. Revenue figures are **estimates**: state the method (views x RPM range from a cited source, by format and likely geography) and give a range, tagged [W] or [U]. Never present an estimate as earnings.
7. **What to learn (style, not theft).** The structure, cadence, packaging rules and production system worth adopting, and what must never be copied (footage, characters, signature look, scripts, music).
8. **Check.** `python3 scripts/check-dossier.py <workspace>/channels/<handle>/dossier.md` must pass before the owner sees it.

## Dossier sections (exact headings, the check enforces them)
`## Snapshot` · `## Biography and timeline` · `## Formats and series` · `## Performance` · `## Packaging patterns` · `## Competitor map` · `## Monetization and earning points` · `## Risks` · `## What to learn (style, not theft)` · `## Sources` · `## Could not examine`

## Never
Invent a number · present an estimate without method and range · describe a video nobody examined · log in, scrape private data or get past a paywall · copy the channel's assets.
