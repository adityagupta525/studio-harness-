# 13 — Content production system

How a post goes from calendar idea to something Ashish can publish, repeatedly and with quality control. Applies to every channel post; the AI-film pipeline ([09](09-ai-film-production-pipeline.md)) is used when a post is a generated film or a film component.

## The six stages
```
research → script → treatment → shot spec → make → QA
```
Tracked per post in `post-cards/<post>.md` ([template](../templates/post-production-card.md)). Stages run in order; the validator rejects a stage marked done after an earlier one is still todo, and rejects a done stage with an empty section.

| Stage | What happens | Output | Notes |
|---|---|---|---|
| Research | confirm the audience moment, the one-line promise, the proof or value; gather sources | source ids in `sources.csv`, card section | public sources; claims carry a source |
| Script | words and structure for the format, original to the channel | card section | structure and technique may echo a format; no creator's writing |
| Treatment | look, pacing, sound for this post, from the style system | card section | style comes from the locked visual direction, not a competitor's |
| Shot spec | one complete spec per shot where footage or generation is used | `shots/Sxx.md` | all fields, then approval before paid generation ([09](09-ai-film-production-pipeline.md)) |
| Make | produce with the chosen method and tools | files (git-ignored), make log | local tools first; each paid step needs a quote and an approved row |
| QA | independent review against brief, style system, rights | `qa` done, notes | reviewer is not the maker |

## Effort levels
Every idea declares effort so the calendar stays honest about capacity: **S** under half a day, **M** about a day, **L** several days (adjust the scale in the calendar's Principles). A week mixes levels on purpose, so S posts keep cadence while L posts carry ambition. Effort estimates are hypotheses, corrected by the production metrics in the review.

## Formats make production repeatable
A format card fixes the structure, hook pattern, proof, making method and packaging pattern. The first post of a format is the expensive one; later posts reuse the structure and change the content. Fewer formats, made well and often, are easier to learn from than many one-offs.

## Packaging is part of production
Title, hook, thumbnail or cover, caption and CTA are designed with the post, using the packaging rules in `channel-style-system.md`. Each rule states its basis. A title or thumbnail score from a tool is a hint, never proof, and a paid scorer needs a quote and an approved row. Platform requirements (ratio, length, captions, AI-content disclosure) are read from the platform's current official page and dated; until then they are `[TO VERIFY]`.

## Making: tools by stage
Stage 0 first: `ffmpeg`, Remotion and After Effects (once verified), Blender previz (once integrated), creative-os builders (`graphic-design-director`, `ai-film-prompt-director`, `music-studio`). Stage 2 tools (Higgsfield, Freepik/Magnific, Fal, paid music or voice) only with a quote and an approved `paid_generation` row per batch; the post card records `spend_approval_id`. See [04](04-tool-and-permission-policy.md).

## Rights, every post
Each asset, track and font has a row in `rights.csv`. Competitor posts are analysis-only: their footage, writing, music and visual identity are not reused, not fed to a model and not delivered; the validator rejects a rights row that does. Music reuse of a specific track is flagged for Ashish's licensing decision.

## QA gate
The reviewer is not the maker (`made_by` and `qa_by` differ). QA checks: the one-line promise is delivered, the hook matches the post, packaging matches the rules, technical delivery (codec, duration, loudness) is measured with commands ([05](05-verification-and-qa.md)), rights are in order, no banned wording. A failed QA returns the post to the stage that can fix it.

## Handoff to Ashish
A ready post is delivered as a package ([social-package template](../templates/social-package.md)): files, title options, caption, thumbnail or cover, timing with its basis, rights rows, checklist. It is stamped **PREPARED, NOT POSTED**. He publishes by hand and records `published_by_ashish` in the calendar and the real numbers in `channel-metrics.md` ([14](14-channel-measurement-and-learning.md)).

## Throughput and honesty
Record actual effort against the S/M/L estimate in the make log; the review uses it to adjust the calendar. Never back-fill. A missed date is recorded as missed, and the calendar is revised through a review, not silently.
