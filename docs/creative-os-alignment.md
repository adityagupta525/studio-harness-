# creative-os alignment — 2026-11-04

**Rule of this page:** Studio Harness is the **orchestration layer** (run contract, gates, ledgers, validators, approvals). `~/creative-os` stays the **authoritative studio knowledge and taste source**: charter, taste ledger, skills, standards, measurement tools. Nothing from creative-os is copied into this repository; the harness links to it and hands work to it. Method: read-only inspection on 2026-11-04 of `~/creative-os/CHARTER.md`, `.agents/skills/`, `.claude/skills/`, `.claude/agents/`, `.codex/agents/`, `ops/`, `~/.claude` (skills, agents, plugins, hooks, settings), MCP configuration (server **names** only, never arguments or environment values), `~/.codex/config.toml` names, the Claude Desktop extension manifest for Blender, and command availability. Nothing was installed, enabled, connected, launched or modified.

Verdict vocabulary:
| Verdict | Meaning |
|---|---|
| **keep and reference** | authoritative as it is; the harness links to it and never edits it |
| **reuse through a handoff** | the harness agent or skill calls it at a named step with a typed handoff |
| **adapt into Studio Harness** | the harness holds a thin, gated version (policy, template, validator) and links to the source for craft |
| **duplicate** | the same capability exists twice; one copy is named authoritative |
| **stale** | a copy or generated file that has drifted from its source |
| **unsafe** | can act outward or spend without a gate; stays disabled or gated |
| **needs verification** | present on paper; reachability, auth, version or provenance not proven |

## 1. Knowledge and taste sources (creative-os)
| Capability | Where | Verdict | Handling in Studio Harness |
|---|---|---|---|
| Charter, the North Star | `~/creative-os/CHARTER.md` | **keep and reference** | read first by every run; wins every conflict |
| Project rules | `~/creative-os/CLAUDE.md`, `AGENTS.md` | keep and reference | harness `CLAUDE.md` and `AGENTS.md` stay short maps that point to it |
| Taste ledger, picks, exemplars | `taste/ashish.md`, `taste/picks.jsonl`, `taste/exemplars/` | keep and reference | **read-only here**; only a live reply from Ashish writes it, in creative-os |
| Lessons, style library | `lessons/`, `style-library/` | keep and reference | harness `memory/` holds only candidates until two real projects confirm ([docs/03](03-context-and-memory.md)) |
| Evidence vocabulary | `standards/evidence-protocol.md` | keep and reference | adopted as-is by `policies/source-policy.yaml` |
| Taxonomy, client flow, practices | `standards/visual-taxonomy.md`, `client-flow.md`, `practices/` | keep and reference | linked from research and brief skills |
| Studio atlas and library | `design-intel` `library/` | keep and reference | read before recommending any library, creator or tool |
| Job log convention | `runs/README.md` (creative-os) | **adapt into Studio Harness** | harness `runs/` is stricter: status, evidence, verification, risks, next action, approval record |
| Backlog and board | `ops/BACKLOG.md`, `ops/BOARD.md` | keep and reference | studio-level queue; modified and uncommitted in creative-os, so not edited from here |
| Registry | `ops/REGISTRY.md`, `ops/registry.json` | **stale** | generated 2026-10-26 (169 items); last committed 2026-10-23; regenerated files sit uncommitted. Treat as a map only and re-check live before promising a tool |
| Measurement tools | `tools/run.sh`, `palette.py`, `dna_measure.py`, `grid.py`, `ui_measure.mjs`, `taste_miner.py`, `medium_feed.py` | reuse through a handoff | `reference-forensics` calls them; `run.sh` needs its analyzer venv, so **needs verification** per job |
| Planner hook | `tools/hooks/autopilot_hint.py` | keep and reference | fires only inside creative-os sessions; harness routing is independent |
| Night-shift routines | `night-shift/` | keep and reference | propose-only, branch plus PR, never merge; harness never runs them |
| Packaged copies | `_build/`, `_dist/`, `portable/`, `plugins/studio-os/` | **duplicate** | the tracked `.claude/skills/` is the source; packaged forms are generated |

## 2. creative-os skills (24 in `.claude/skills/`)
| Skill | Verdict | Where the harness uses it |
|---|---|---|
| `creative-pipeline` (Director) | reuse through a handoff | harness `director` owns the **run contract**; `creative-pipeline` owns the **creative method** when medium or look is open. No overlap in decisions: Ashish decides either way |
| `autopilot` (planner) | reuse through a handoff | optional at intake to price and route; its Job Plan card feeds `studio-brief`. Not a second approval path |
| `design-intel` + `scout` | reuse through a handoff | `trend-scout`; library read first |
| `video-reference-analyzer` | reuse through a handoff | `reference-forensics` for video; measured frames and cuts |
| `pinterest-visual-research` | reuse through a handoff | `reference-forensics` for stills |
| `design-forensics` + 3 forensics agents | reuse through a handoff | deep teardown of a competitor or system; transfer matrix (keep, swap, never) |
| `ai-film-prompt-director` | reuse through a handoff | `ai-film-lead` for story to prompt craft; the harness adds the shot-spec schema and approval-to-generate gate |
| `model-intel` + `spec-checker` | reuse through a handoff | specs and prices are **never stored in this repo**; verified within 7 days before any promise |
| `visual-library` | keep and reference | art forms, Indian art, cliché blacklist |
| `graphic-design-director` | reuse through a handoff | `packaging-lead` for thumbnails, covers, carousels |
| `creative-critic` + `critic-judge` + `taste-judge` | reuse through a handoff | `qa-rights-reviewer` for blind scoring; taste-judge stays read-only |
| `brand-strategy` | reuse through a handoff | only on Ashish's request; the studio's own brand is undecided (charter section 9) |
| `story-architect` | reuse through a handoff | `creative-producer` for concept, script and structure |
| `music-studio` | reuse through a handoff, needs verification | Suno is an account-bound subscription; any generated track is a licensing call for Ashish |
| `content-studio` | **adapt into Studio Harness** (partial duplicate) | the Channel Launch skills carry the gated, validated version (assumptions, locks, ledgers); craft and niche method stay in `content-studio`. The harness skills should link to it rather than restate it |
| `product-studio`, `product-qa`, `own-product-audit`, `wealthtech-pm-os`, `design-taste-frontend`, `emil-design-eng` | keep and reference | outside the harness's content, film and channel scope; used only on a matching brief. Employer-context work stays in its own context |
| `mac-native-control` | keep and reference, **unsafe if used by clicking** | ExtendScript and CLI routes only; GUI automation stays last resort and gated |
| `reverse-engineer-anything` | needs verification | REA MCP runs through `npx` (project `.mcp.json`); only for targets with no source; confirm the pinned version before use |
| `studio-manager` | keep and reference | backlog and next-up; L0 and L1 only |
| `archify` | needs verification | **untracked** in creative-os (new, unreviewed) |

## 3. Copies, mirrors and generated duplicates
| Item | Finding | Verdict | Action (needs Ashish, none taken) |
|---|---|---|---|
| `~/creative-os/.agents/skills/` (25 skills, untracked) | same names as `.claude/skills/`; at least `ai-film-prompt-director` and `autopilot` **differ** from the tracked copies | **stale** | name `.claude/skills/` authoritative; regenerate or remove the `.agents` copy by a creative-os change |
| `~/creative-os/.codex/agents/*.toml` (9) | Codex-format twins of `.claude/agents/*.md` | duplicate | keep in step by generation, not by hand |
| `~/.agents/skills/` (28) | mirror of `~/.claude/skills/` plus `reverse-engineer-anything` | duplicate | Codex side; no extra capability |
| `~/.claude/agents/` (9) | same nine agents as the project folder | duplicate | one authoritative copy (the project one) |
| `~/.claude/skills/synced` and `anthropic-skills:*` (claude.ai-synced) | copies of creative-os skills served from the account | duplicate, **stale risk** | the account copies can lag the repo; prefer the repo copies |
| `studio-os@creative-os` plugin (enabled) | packages the same skills a second time, so each appears twice (`studio-os:name` and `name`) | duplicate | keep one route per run to avoid double-loading |
| `designer-skills` plugins (9, local scope, enabled flag not listed) | overlap `product-studio` and critique skills | duplicate, needs verification | confirm whether enabled; do not load both families |

## 4. Plugins, hooks, MCP, connectors
| Item | Finding | Verdict |
|---|---|---|
| `remotion@remotion` (enabled) | the programmatic video route; CLI exists only in `~/mythos-studio` | keep and reference; **needs verification** per project |
| `hyperframes@hyperframes` (enabled, user and project) | overlaps Remotion; the creative-os registry still says "not enabled" | duplicate (partial), **needs verification** (status drift) |
| `pr-review-toolkit`, `claude-code-setup`, `skill-creator`, `mcp-server-dev` (enabled) | developer tooling | keep and reference |
| `frontend-design`, `figma` plugin (disabled) | the Figma skills still arrive with the connector | keep disabled |
| SessionStart hook (user) | injects `toolkit-reminder.md` through `jq`; reads one local file; no network | keep and reference (read, no action) |
| Project hook `autopilot_hint.py` | local, never blocks, no network; only in creative-os | keep and reference |
| MCP in config files | `figma` (user, http); `freepik`, `magnific`, `figma`, `figma-desktop` (home project, http); `refero` (one project, http); `rea` (creative-os, npx) | needs verification (reachability and auth untested); Freepik and Magnific are **paid** (Stage 2) |
| Blender | the official Blender Lab MCP **server** is installed as a Claude Desktop extension (v1.0.1, enabled). The Blender-side add-on that is actually installed is the **community** BlenderMCP, not the official one | **unsafe** to enable as it stands; **needs verification** (see [tool-install-policy.md](tool-install-policy.md)) |
| Browser tools | built-in browser pane, Claude in Chrome, Control Chrome (all session tools), Playwright 1.64.1 with cached Chromium builds in `~/creative-os/tools` | keep and reference; logins and publishing gated |
| Connectors visible in the session | vidIQ, Higgsfield, Magnific or Freepik, Figma, Adobe (OAuth needed), Mobbin, Notion, Vercel, Zapier, Microsoft 365, Supermetrics and others | **needs verification**; the ones that can **publish, send, deploy or spend** (vidIQ publish and update, Higgsfield TikTok, Vercel deploy, Notion and Zapier writes, Supermetrics social) are **unsafe** without an approval row |
| `~/.codex/config.toml` connectors (`figma`, `figma-desktop`, `freepik`, `magnific`, `node_repl`, `computer-use`) | account-bound to Codex | needs verification here; never assumed to exist in Claude Code |

## 5. Commands (2026-11-04)
Present: `git` 2.50.1, `node` v24.18.0, `npm` and `npx` 11.17.0, `python3` 3.14.7, `python3.12` 3.12.10, `pip3`, `ffmpeg` and `ffprobe` 9.0.2, `yt-dlp` 2026.08.19, `claude` 2.1.278, `gh` 2.102.0, `jq` 1.7.1, `ruby` 2.6.10 (system), `swift` 6.3, `brew` 7.0.10. Apps: Blender 5.1.2 (no CLI on PATH), Chrome 151.0.7922.137, After Effects 2026, Premiere Pro 2026, Figma.
Absent: `pnpm`, `yarn`, `bun`, `uv`, `pipx`, `blender` CLI on PATH, global `remotion`, `shellcheck`, `pdftoppm`, `pdftotext`, `tesseract`, `whisper`, `magick`, `exiftool`, `sox`, `op`. Install plan and policy: [tool-install-policy.md](tool-install-policy.md).

## 6. How the two layers meet
| Question | Owner |
|---|---|
| What is the studio, what is its taste, what craft rules apply | creative-os |
| How is a job run, gated, evidenced, approved, validated and remembered | Studio Harness |
| Who decides creative direction | Ashish, through creative-os methods |
| Who may spend, publish, send, connect or install | nobody without an approval row ([docs/07](07-publishing-and-approval-policy.md)) |
| Where a lesson or preference is promoted | harness `memory/` after two real projects and his yes; creative-os `taste/` only by his live reply |

## 7. Findings that need Ashish (none acted on)
1. **Two Blender bridges, mismatched.** The official Blender Lab server is installed; the add-on in Blender's folder is the community one. Decide which stack to keep before anything is enabled.
2. **`.agents/skills` has drifted** from `.claude/skills` in creative-os. Decide the authoritative copy.
3. **Registry is stale** and regenerated files are uncommitted.
4. **Duplicate skill families** (`studio-os` plugin, `anthropic-skills:*`, `designer-skills`) can double-load; decide which route each job uses.
5. **HyperFrames status** differs from the registry; confirm whether it should stay enabled next to Remotion.
