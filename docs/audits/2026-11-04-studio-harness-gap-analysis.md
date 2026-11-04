# Studio Harness — gap analysis — 2026-11-04

Companion to [the capability audit](2026-11-04-existing-capability-audit.md). Statuses: **Ready** (observed working or a plain local tool), **Verify** (present on paper; needs a live check), **Gap** (nothing usable). Nothing here was installed or called.

## 1. Readiness by job

| Job | Status | What exists today | What blocks "Ready" |
|---|---|---|---|
| Trend / competitor research | **Verify** | `design-intel` + `scout`, `WebSearch` (standard/extended), built-in browser, `medium_feed.py`; vidIQ tools in session (paid, credits) | No repo-local trend-claim format (built here: `templates/research-pack.md`, `competitor-card.md`, `source-ledger.csv`). vidIQ credits unquoted. No Instagram/TikTok/Pinterest-Trends access verified |
| YouTube / Instagram analysis | **Verify** | `yt-dlp` 2026.08.19 (public only), `video-reference-analyzer`, vidIQ outliers (paid) | Instagram rate-limits bulk pulls; private/age-gated/DRM fails. No watch-time data without a linked channel (none linked, `UNKNOWN` today) |
| Video / still / reference deconstruction | **Ready** | `video-reference-analyzer`, `pinterest-visual-research`, `deconstructor`, `tools/run.sh` (`palette.py`, `dna_measure.py`, `grid.py`), `ffmpeg` | Needs the analyzer venv (`~/.local/share/video-analyzer/venv`, per global CLAUDE.md; not re-checked) |
| Scripts, treatments, storyboards, shot specs | **Ready** (text) | `story-architect`, `ai-film-prompt-director`, `brand-strategy` | No enforced shot-spec schema → built here (`templates/shot-spec.md` + validator) |
| AI film / image workflows | **Verify** (paid) | `ai-film-prompt-director`, `model-intel`, `visual-library`; Higgsfield and Magnific/Freepik tools in session | Credits and rights. Specs rot: `spec-checker` must re-verify before any model promise. Third-party reference imagery must never be fed to a model |
| Blender camera / lens / light / render | **Verify** | Blender 5.1.2 app; Blender MCP tools in session; `mac-native-control` | No CLI on PATH; MCP needs the app running with its add-on; server provenance `UNKNOWN`; no camera/lens metadata artifact convention (designed here) |
| Editing, captions, sound, exports | **Verify** | `ffmpeg` 9.0.2 (cuts, encode, frames); Remotion plugin enabled; HyperFrames plugin (status drift); After Effects / Premiere via ExtendScript; `music-studio` (Suno, subscription) | Remotion CLI only inside `~/mythos-studio`; no captioning/transcription tool confirmed locally; no loudness/LUFS check script |
| Thumbnails, packaging, calendars | **Ready** (drafts) | `graphic-design-director`, `content-studio`; vidIQ title/thumbnail scoring (paid) | Packaging template/QA built here. Scoring is a hint, never proof |
| Figma / web / client delivery | **Verify** | Figma connector (needs a `fileKey`); Framer via `npx @framer/agent` (auth per-Mac, not re-checked); Vercel tools (write) | Stage 1 approval; deploy is Stage 3 |
| QA, rights, source tracking, memory | **Gap → built here** | `creative-critic`, `product-qa`, evidence protocol, taste/lessons stores | No per-project source ledger, rights ledger, or completeness validator existed; added as CSV + shell checks |
| Publishing, CRM, email, calendar | **Gap (by design)** | Notion Calendar, Zapier, Microsoft 365 (read), Supermetrics, vidIQ publish, TikTok connect are *visible* in the session | None of it is approved. No social account linked (`UNKNOWN`, assume none). Stage 3, disabled |

## 2. Gap register

| # | Gap | Job unlocked | Current alternative | Recommended future tool | Risk / cost | Approval | Priority |
|---|---|---|---|---|---|---|---|
| G1 | Per-project **source ledger** and checker | Every research claim traceable | Free-text `sources.md` per run | `templates/source-ledger.csv` + `scripts/check-source-ledger.sh` (**built**) | None | none (draft) | P0 |
| G2 | **Asset rights ledger** | Safe delivery, no unlicensed model input | Memory + `licensing-his-call` note | `templates/asset-rights-ledger.csv` (**built**) | Legal exposure if skipped | His call on any licence | P0 |
| G3 | **Run completeness check** (status, deliverables, evidence, verification, risks, next action) | Every task reports the same way | Gate log in `runs/README.md` | `scripts/check-run-completeness.sh` (**built**) | None | none | P0 |
| G4 | **Shot-spec schema** | AI-film continuity and QA | Free-form prompts | `templates/shot-spec.md` (**built**) | None | none | P0 |
| G5 | Blender camera/lens **metadata artifact** + localhost-only MCP plan | Deterministic cinematography | Blender MCP add-on (provenance unknown) | Official Blender Lab MCP — plan only in `docs/10-…` | Automation runs with user privileges; not a security boundary | Stage 1, per-install | P1 |
| G6 | Verified **Remotion** render path | Programmatic motion/captions/exports | Local CLI in `~/mythos-studio` | Project-scope Remotion in a studio repo | `node_modules` growth; render CPU | Stage 1 | P1 |
| G7 | **Transcription/captions** | Captions, searchable reference transcripts | vidIQ transcript (paid, YouTube only) | A local, project-scoped transcriber (to be evaluated, e.g. whisper-family) | Download size; accuracy on Hindi/Hinglish `[TO VERIFY]` | Stage 1; dry-run first | P1 |
| G8 | **Loudness / export QA** (LUFS, true-peak, codec/size) | Delivery QA for audio/video | `ffmpeg` filters by hand | A small script around `ffmpeg` `ebur128` (not built here; listed in `docs/05-verification-and-qa.md`) | None | none | P2 |
| G9 | **Trend-signal log** with date/platform/geo/format/metric/uncertainty | Honest trend claims | Ad-hoc notes | `templates/research-pack.md` signal table (**built**) | Over-claiming | none | P0 |
| G10 | Verified **Instagram / TikTok / Pinterest Trends** access | Short-form research | Public `yt-dlp` pulls (rate-limited) | Stay public-only; Creative Center / Pinterest Trends as *discovery signals* only | Rate limits, ToS | Stage 0 public only | P2 |
| G11 | **vidIQ** per-job quote | Outlier/trend data at scale | `WebSearch`, `yt-dlp` | vidIQ with a quoted credit cost | Credits | Stage 2, per job | P2 |
| G12 | **Higgsfield / Freepik / Fal** generation | AI shots | None | Same, per-job quote | Credits; rights | Stage 2 | P2 |
| G13 | **Client messaging, calendar, CRM, publishing** | Client ops | Ashish does it by hand | Later, after real projects prove the loop | Irreversible external action | Stage 3 | P3 |
| G14 | **Registry freshness** | Honest tool claims | `tools/build_registry.py --check` in creative-os | `validate-harness.sh` warns, never trusts | Stale map | none | P2 |
| G15 | **Memory promotion rule** (2 real projects) | No fake "lessons" | `lessons/` candidate→promoted | `policies/memory-policy.yaml` (**built**) | Slop compounding | His approval | P0 |

## 3. Explicit lists

**Keep** — charter; evidence protocol; creative-os skills and subagents named in the audit; `tools/run.sh`; `ffmpeg`; `yt-dlp` (public only); taste/lessons/style-library as read-only inputs.

**Reuse with changes** — run log template (stricter); registry (as a map only); `mac-native-control`; Blender app + MCP (provenance check); Remotion (verify); Framer (verify auth); Figma (needs `fileKey`).

**Do not use** — OmniRoute; open-interpreter; mac_computer_use; write/publish connectors without an approval record; global installs; Codex connectors assumed available; employer data in studio work; unlicensed third-party imagery as model input.

**Missing but worth adding** — official Blender Lab MCP (plan only); verified Remotion path; local transcriber; audio-loudness check; vidIQ/Higgsfield per-job approvals; later: publishing, calendar, CRM, email.

## 4. Order of work this implies

1. Contract first (done in this task): policies, templates, validators, run layout, agent cards.
2. First real project proves the loop with **zero paid tools** (`yt-dlp`, `ffmpeg`, browser, creative-os skills).
3. Stage 1 verifications one at a time, each with its own approval and a written verification record.
4. Stage 2 only per job, after a quoted cost.
5. Stage 3 only after two real projects shipped by hand.
