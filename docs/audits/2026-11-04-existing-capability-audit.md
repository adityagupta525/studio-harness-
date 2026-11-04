# Existing capability audit — 2026-11-04

**Phase A of Studio Harness v1. Read-only.** Method: directory listings, config *key names*, command `--version`, and reading `~/creative-os/CHARTER.md`, `ops/REGISTRY.md`, `standards/evidence-protocol.md`, `runs/README.md`, `tools/README.md`, `taste/README.md`. Nothing was installed, connected, launched, logged into, spent, sent or committed.

**Not examined on purpose** (secrets or private data): `~/.codex/auth.json`, values in `~/.codex/config.toml`, `env` values in any `settings.json`, `~/.claude/history.jsonl`, `~/.codex/memories*`, `*.sqlite`, browser profiles, `taste/picks.jsonl` contents, any client folder. Only tool *names* and *status* appear below.

Claim classes follow `~/creative-os/standards/evidence-protocol.md`: `OBSERVED` (seen in this audit), `SOURCE-VERIFIED` (read in a config/doc), `UNKNOWN`. Dates are 2026-11-04 unless stated.

---

## 1. Charter (highest-priority source)

`~/creative-os/CHARTER.md` (18 Oct 2026) was read first. Rules that shape this harness — `SOURCE-VERIFIED`:

| Charter point | Harness consequence |
|---|---|
| §5 No house style; style is derived from client, brand, product, audience | Client/project system outranks generic taste or tool defaults |
| §6 Method: brief → strategy → real research → parameters → ≥3 routes → blind critique (4.5/5 gate) → build → case study → memory | The operating loop in `docs/01-operating-model.md` mirrors this |
| §7 Zero AI slop; real references only; measured QA | `qa-rights-reviewer` agent + `docs/05-verification-and-qa.md` |
| §8 Two contexts (`studio` / `client:<name>` / `employer`) never mixed | Every run declares a context; memory scopes are separated |
| §9 Studio brand not decided; Drishya Studio relation is his decision | Harness holds no brand identity; ask, never assume |
| §10 No linked social accounts; he publishes | Publishing stays Stage 3, disabled |

## 2. Environment — commands (`OBSERVED`)

| Command | Result |
|---|---|
| `git` | 2.50.1 (Apple), `/usr/bin/git` |
| `node` | v24.18.0, `/usr/local/bin/node` |
| `npm` | 11.17.0, `~/.npm-global/bin/npm` |
| `pnpm` | **not on PATH** |
| `python3` | 3.14.7, `/opt/homebrew/bin/python3` |
| `python3.12` | 3.12.10, `/usr/local/bin/python3.12` |
| `uv` | **not on PATH** |
| `ffmpeg` | 9.0.2, `/opt/homebrew/bin/ffmpeg` |
| `yt-dlp` | 2026.08.19, `/opt/homebrew/bin/yt-dlp` |
| `blender` | **no CLI on PATH**; `/Applications/Blender.app` exists, `…/MacOS/Blender --version` → 5.1.2 (build 2026-05-19) |
| `remotion` | **no global CLI**; a local CLI exists at `~/mythos-studio/node_modules/.bin/remotion` (not run). Remotion *plugin* is enabled in Claude Code (§4) |
| `claude` | 2.1.278, `~/.npm-global/bin/claude` |

Drift found against `~/.claude/CLAUDE.md` (which says Node lives in `/opt/homebrew`): `node` on PATH is `/usr/local/bin/node`. Harmless, but scripts here use `command -v`, never hard-coded paths.

## 3. creative-os (reuse; do not duplicate)

`~/creative-os` is a git repo (`origin` = `adityagupta525/creative-os`). Its working tree is **dirty** (many modified/untracked files at session start). This harness never edits it.

| Asset | Where | Status |
|---|---|---|
| Charter, project rules | `CHARTER.md`, `CLAUDE.md`, `AGENTS.md` | Authoritative. Link, never copy |
| 24 skills (project) | `.claude/skills/`: `autopilot`, `creative-pipeline`, `design-intel`, `design-forensics`, `video-reference-analyzer`, `pinterest-visual-research`, `ai-film-prompt-director`, `model-intel`, `visual-library`, `graphic-design-director`, `creative-critic`, `music-studio`, `brand-strategy`, `story-architect`, `content-studio`, `product-studio`, `product-qa`, `own-product-audit`, `studio-manager`, `mac-native-control`, `reverse-engineer-anything`, `emil-design-eng`, `design-taste-frontend`, `wealthtech-pm-os`, `archify` | Reuse. Harness skills *call* these |
| 9 subagents | `.claude/agents/`: `scout`, `deconstructor`, `critic-judge`, `taste-judge`, `spec-checker`, `skill-smith`, `forensics-*` ×3 | Reuse |
| Taste ledger + picks | `taste/ashish.md`, `taste/picks.jsonl`, `taste/exemplars/` | Only a live reply from Ashish writes here. This harness is read-only on it |
| Lessons, style library | `lessons/LESSONS.md`, `style-library/` | Reuse as the global promoted-lesson store |
| Evidence vocabulary | `standards/evidence-protocol.md` (claim classes, `[V]/[W]/[U]`, real/AI-made/unknown, own/licensed/public-domain/analysis-only) | **Adopted as-is** by `policies/source-policy.yaml` |
| Other standards | `standards/visual-taxonomy.md`, `client-flow.md`, `practices/`, `taxonomy/` | Link |
| Run conventions | `runs/README.md` (job log template, gate log, heavy media git-ignored, `runs/*/refs/` ignored) | **Adapted** into `runs/_template/` (stricter: adds status/evidence/verification/risks/next action) |
| Measurement tools | `tools/run.sh` + `palette.py`, `dna_measure.py`, `grid.py`; `ui_measure.mjs`; `taste_miner.py`; `medium_feed.py`; `studio_mcp.py` | Reuse. `run.sh` picks a Python with cv2 (system `python3` has none) |
| Registry | `ops/REGISTRY.md` / `registry.json` — 169 items, generated 2026-10-26 | **Possibly stale** (regenerated files show as modified, uncommitted). Treat as a map, verify live |
| Ops | `ops/BACKLOG.md`, `ops/BOARD.md` | Reuse for studio-level backlog |
| Prompt hook | `tools/hooks/autopilot_hint.py` (nudges the `autopilot` planner) | Active in creative-os only |
| Night shift | `night-shift/` | Propose-only routines, never merge |

**Overlap to manage.** creative-os already has a Director (`creative-pipeline`), planner (`autopilot`) and critics. This harness does **not** replace them: it adds the repo-local contract (policies, templates, validators, run layout) and thin agent *cards* that route to those skills. Where a harness agent has a creative-os equivalent, the card says so (see `docs/02-agent-roles.md`).

## 4. Claude Code configuration (`OBSERVED`, values redacted)

- `~/.claude/CLAUDE.md` — global working rules (same text mirrored in `~/.codex/AGENTS.md`).
- `~/.claude/skills/` — 27 entries: `framer`, `framer-code-components`, `gsap-*` ×8, `threejs-*` ×14, `hallmark`, `unslop`, `synced`.
- `~/.claude/agents/` — 9 files (same as the project agents).
- **Hooks** (`~/.claude/settings.json`): one `SessionStart` hook that injects `~/.claude/toolkit-reminder.md` via `jq`. No other hooks found in user settings. Project settings (`~/creative-os/.claude/settings.json`) have no hooks; the project hook is `tools/hooks/autopilot_hint.py`.
- **Permissions:** user allow-list has one entry (`mcp__Claude_Browser__javascript_tool`). Everything else prompts.
- **Plugins enabled (user settings):** `mcp-server-dev`, `pr-review-toolkit`, `claude-code-setup`, `skill-creator`, `remotion@remotion`, `studio-os@creative-os`, `hyperframes@hyperframes`. **Disabled:** `frontend-design`, `figma@claude-plugins-official`. Also installed at local scope: `designer-skills` set (design-research, design-systems, ux-strategy, ui-design, interaction-design, prototyping-testing, design-ops, designer-toolkit, visual-critique).
- Drift: the creative-os registry note says HyperFrames was "installed but not enabled (18 Oct)"; user settings now show it `true`. Treat HyperFrames status as `needs verification`.
- **MCP (project):** `~/creative-os/.mcp.json` declares one server, `rea` (reverse-engineering; only for targets with no source).
- **MCP / connectors visible in *this* session's tool list** (names only; **not exercised**, so reachability and auth are `UNKNOWN`): Figma (two server entries), Magnific/Freepik, vidIQ, Higgsfield, Blender, Notion, Vercel, Zapier, Microsoft 365 (read), Adobe, Mobbin, Control Chrome / Claude in Chrome / built-in browser, `rea`. Servers reported as needing OAuth: Adobe plugin, Canva, BigQuery, Asana, Atlassian, Intercom, Linear, Slack, Ahrefs, Amplitude, HubSpot, Klaviyo, Similarweb. One failed to connect: `plugin:data:definite`.
- **Danger inventory.** The session also exposes *write/publish/spend* tools (e.g. vidIQ publish/update, Higgsfield generate/publish and TikTok connect/publish, Vercel deploy/delete, Notion writes, Zapier writes, Supermetrics social management). The harness policies treat all of them as gated (§ `policies/permissions.yaml`).

## 5. Codex / agents directories (`OBSERVED`)

Codex desktop connectors are **account-bound**; a config entry is not proof the tool works in Claude Code.

| Source | What exists | Status for this harness |
|---|---|---|
| `~/.codex/config.toml` | MCP server names: `node_repl`, `computer-use`, `figma`, `figma-desktop`, `freepik`, `magnific` (values not read) | **Requires separate verification.** Do not assume available |
| `~/.codex/AGENTS.md` | Mirror of the global working rules | Reuse as reference only |
| `~/.codex/hooks.json` | Same `SessionStart` reminder hook | Nothing extra |
| `~/.codex/auth.json`, `memories*`, `*.sqlite` | Credentials / private memory | **Not read.** Never copied into this repo |
| `~/.agents/skills/` | 29 entries mirroring `~/.claude/skills` plus `reverse-engineer-anything` | Duplicate of Claude skills; no extra capability |
| `~/creative-os/.agents`, `.codex/agents` | Project-local agent dirs (untracked in creative-os) | Not examined further |

## 6. Verdict list

### Keep (use as-is)
- `~/creative-os/CHARTER.md` and `CLAUDE.md` as the source of truth.
- `standards/evidence-protocol.md` vocabulary.
- `video-reference-analyzer`, `pinterest-visual-research`, `design-intel` + `scout`, `design-forensics`, `story-architect`, `ai-film-prompt-director`, `model-intel`, `creative-critic` + `critic-judge` + `taste-judge`, `content-studio`, `graphic-design-director`, `brand-strategy`.
- `tools/run.sh` measurement tools; `ffmpeg`; `yt-dlp` (public content only).
- Taste ledger / lessons / style library as read-only inputs.
- `studio-os@creative-os` plugin (packaged creative-os skills).

### Reuse with changes
- `runs/README.md` job-log template → stricter `runs/_template/` with status, evidence, verification, risks, next action and an approval record.
- `ops/REGISTRY.md` → read as a map; `scripts/validate-harness.sh` does not trust it, and a live check is required before promising a tool.
- `mac-native-control` (After Effects / Premiere / Blender via ExtendScript) → keep for later; gate behind Stage 1 approval.
- Blender 5.1.2 app + the Blender MCP tools visible in this session → keep as the base for the future official Blender Lab MCP plan (provenance of the present server `UNKNOWN`).
- `remotion@remotion` plugin + local CLI in `~/mythos-studio` → verify before relying on it for a client job.

### Do not use
- `OmniRoute` (reroutes subscription credentials; account risk) — standing rule.
- `open-interpreter`, `mac_computer_use` — deliberately removed (global CLAUDE.md).
- Any **write/publish** connector tool (vidIQ publish/update, Higgsfield TikTok, Vercel deploy, Notion write, Zapier write, Supermetrics social) without an approval record.
- Any global install (`npm -g`, system pip, brew, skill installers with `-y`).
- Codex-side connectors as if they were Claude-side.
- Copying employer (Centricity) data, design-system values or taste into studio work.

### Missing but worth adding (all future, all approval-gated)
See `2026-11-04-studio-harness-gap-analysis.md`: official Blender Lab MCP, a verified Remotion render path, a caption/transcribe tool, a rights-ledger validator (built in this task), a trend-signal log format (built in this task), and—later—publishing/CRM/email/calendar.

## 7. What could not be examined

| Item | Why |
|---|---|
| Live auth/health of every connector | Would require calling them (possibly paid or write-capable); out of scope for a read-only audit |
| Whether Blender is currently running with its add-on | Not launched; connection attempts skipped |
| Content of `~/.codex/config.toml` values and `auth.json` | Secrets |
| `taste/picks.jsonl` and client folders | Private; not needed to build a harness |
| Remotion render ability | CLI present only in a project folder; not executed |
| Current accuracy of `ops/REGISTRY.md` | Generated 2026-10-26; creative-os has uncommitted registry changes |
| Social accounts linked | CLAUDE.md (18 Oct) says none linked; not re-verified today. Treat as `UNKNOWN` and assume none |
