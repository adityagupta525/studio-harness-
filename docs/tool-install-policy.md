# Tool install policy and plans — 2026-11-04

Companion to [creative-os-alignment.md](creative-os-alignment.md) and to the staged tool policy in [04](04-tool-and-permission-policy.md) (`policies/tool-manifest.yaml`). **Nothing was installed, enabled, connected or modified while writing this page.** Only dry-runs and read-only inspection were run.

## Rules for every install
1. **No blind installs.** Every install is a `tool_install_or_update` approval row from Ashish first ([07](07-publishing-and-approval-policy.md)).
2. **Dry-run first.** Record what would be installed, upgraded or downgraded; stop on any downgrade or conflict.
3. **Scope.** Project scope or a standalone environment. Never `npm -g`, system `pip`, or a global skill installer. Never touch the existing creative-os environment (its analyzer venv, `node_modules`, plugins) without his approval.
4. **Read before running.** Read the package's install hooks or scripts (npm lifecycle scripts, a formula's source) and any plugin hook before it runs.
5. **Verify after.** One read-only call, recorded in the run or the manifest ([04](04-tool-and-permission-policy.md), "Moving a tool up a stage").

## A. Already available (observed 2026-11-04)
| Tool | Detail | Note |
|---|---|---|
| Claude Code | 2.1.278 | |
| git, gh | 2.50.1, 2.102.0 | `gh` and an osxkeychain credential helper exist; any push still needs his go-ahead |
| node, npm, npx | v24.18.0, 11.17.0 | `pnpm`, `yarn`, `bun` absent and not needed |
| python3, python3.12, pip3 | 3.14.7, 3.12.10 | validators use the standard library only; never `pip install` into either |
| ffmpeg, ffprobe, yt-dlp | 9.0.2, 2026.08.19 | public content only; downloaded media is analysis-only |
| jq, ruby (system), swift, brew | 1.7.1, 2.6.10, 6.3, 7.0.10 | `swift` reads PDFs locally through PDFKit, which already covers the missing `pdftoppm` |
| Blender app | 5.1.2 at `/Applications/Blender.app` (no CLI on PATH) | use the full binary path; do not download another Blender |
| Google Chrome | 151.0.7922.137 | profile folder exists and was **not** opened, read or copied |
| After Effects 2026, Premiere Pro 2026, Figma | installed apps | automation via ExtendScript or connectors only after Stage 1 approval |
| Playwright 1.64.1 + cached Chromium builds | `~/creative-os/tools` | isolated browser contexts; reuse, do not reinstall |
| Remotion plugin | enabled; CLI only in `~/mythos-studio` | needs verification per project |
| Official Blender Lab MCP **server** | Claude Desktop extension v1.0.1, enabled | the Blender-side add-on is not the official one (see the Blender plan) |
| Browser tools in the session | built-in pane, Claude in Chrome, Control Chrome | read-only by default |
| creative-os skills, agents and standards | 24 skills, 9 agents | referenced, never copied |

## B. Safe and required now
**None.** Everything the harness needs today is already present (the validators, the ledgers, the scanner, `ffmpeg`, `yt-dlp`, a local PDF reader through `swift`). Nothing has to be installed to continue.

## C. Approval-required (each its own `tool_install_or_update` row)
| Candidate | Why | Dry-run result (2026-11-04) | Scope and next step |
|---|---|---|---|
| `shellcheck` | lint the harness shell scripts | `brew install --dry-run`: 1 formula plus 1 new dependency (gmp); **no upgrades** | clean; safe next install. Read the formula with `brew cat` at approval time |
| `uv` | isolated Python environments for future tools | `brew install --dry-run`: 1 formula, no dependencies, **no upgrades** | clean; safe next install; used only for standalone environments |
| Official Blender Lab add-on (Blender side) | complete the official MCP bridge | not a package install; see the Blender plan | blocked until the security review is finished |
| Remotion in a studio project | programmatic motion, captions, exports | `npm install --dry-run --ignore-scripts remotion @remotion/cli` in a standalone scratch folder: 244 packages added, **no install lifecycle scripts declared** for either package (registry metadata), version 4.0.540 | project scope only, per project, after Stage 1 approval; render a 2-second test into a run folder |
| `poppler` (`pdftoppm`, `pdftotext`) | PDF page rendering for the Read tool | dry-run: 1 formula, **21 new dependencies and 12 existing formulae would be upgraded** | **not needed now** (PDFKit through `swift` works); upgrading 12 existing formulae is the reason to wait |
| `whisper-cpp` | local transcripts and captions | dry-run: 1 formula, 4 new dependencies (libomp, ggml, openssl@4, llama.cpp), **3 existing formulae would be upgraded** (ca-certificates, sdl3, sdl2-compat); models are separate downloads | defer; test accuracy on Hindi and English before adopting [TO VERIFY] |
| Framer CLI through `npx @framer/agent` | websites | auth is per-Mac; not re-verified | read-only project list first; publishing is a `deployment` approval |
| Figma, Adobe, Mobbin connectors | Stage 1 | tools visible; Adobe needs OAuth; none tested | one read-only call each, recorded, after approval |
| vidIQ, Higgsfield, Freepik or Magnific, Fal | Stage 2 | paid; connectors visible, none used | a quoted cost and an approved `paid_generation` row per job |

## D. Do not install
| Item | Reason |
|---|---|
| DeepSeek Harness, `dsh-superagent` | unrequested orchestration layers that would duplicate the Director and the gates |
| Cordis as a separate dependency | not needed; would add a second control plane |
| Kimi K3 locally | local models have no value here (he is never offline); large and unreviewed |
| Agent-Reach | unreviewed access layer for external platforms; outside the approval model |
| Random Chrome MCP packages | arbitrary code with browser reach; the existing browser tools already cover read-only research |
| A second Blender download | one Blender 5.1.2 is installed |
| A second Blender MCP stack | two bridges on one port conflict; decide one stack first |
| Duplicate plugins or skill families (`designer-skills`, a second `studio-os` route, `anthropic-skills:*` copies) | double-loading; see the alignment page |
| Any global package (`npm -g`, system `pip`, skill installers with `-y`) | standing rule |
| OmniRoute, `open-interpreter`, `mac_computer_use` | OmniRoute reroutes subscription credentials; the other two were removed on purpose |
| `pnpm`, `yarn`, `bun`, `pipx`, `tesseract`, `magick`, `exiftool`, `sox` | no job needs them; add only with a named job |

## Blender: official Blender Lab MCP integration plan (not enabled)
**Status: stopped before enabling the bridge. The security review is incomplete.** Port 9876 was checked read-only: nothing is listening on it, and nothing was exposed.

### What is on this Mac
| Piece | Finding | Provenance |
|---|---|---|
| Blender | 5.1.2, build 2026-05-19 | the official app; the official MCP requires Blender 5.1 or newer, so the version fits |
| MCP **server** (client side) | Claude Desktop extension `ant.dir.gh.blender.blender-mcp`, manifest version 1.0.1 (package info 1.0.0), enabled; author Blender Lab, repository `https://projects.blender.org/lab/blender_mcp`, homepage `https://www.blender.org/lab/mcp-server/`, license GPL-3.0-or-later | read from the installed manifest: this matches the official project |
| Blender-side **add-on** | `~/Library/Application Support/Blender/5.1/scripts/addons/blender_mcp_addon.py`, 111,925 bytes, SHA-256 `8a95c52fd0141a0e90943e96804845bd25b76c944f7355e422b96db971f50050`, header credits **Siddharth Ahuja (community BlenderMCP, v1.2)**; its socket binds the host `localhost` on port 9876 | **not** the official add-on |
| Official add-on | not found: Blender's `extensions` folder holds only a cache | not installed |

### Findings
1. **Mismatch.** The official server expects the official add-on. The add-on actually installed is the community one, so the bridge is two different projects on one default port (9876). Do not enable both.
2. **The community add-on is wider than a local bridge:** it embeds a third-party free-trial API key string (not repeated here) and makes outbound HTTP calls (35 references to a requests library) to asset services; it also executes received Python by design (one `exec` call).
3. **Execution risk, by design.** Blender Lab's own page warns that the official server runs LLM-generated code in Blender with no protection for data deletion or transmission (reported by a search result quoting the page; confirm on the official page). Blender automation runs with the user's privileges and is **not a security boundary** ([10](10-blender-cinematography-pipeline.md)).
4. A secondary source says the official add-on may require Blender's **Allow Online Access** preference. That widens Blender's network permission and must be evaluated, not toggled casually [TO VERIFY].

### Verification before enabling (all must pass, in a scratch copy of a .blend)
| # | Check | Pass condition |
|---|---|---|
| 1 | **Source** | the add-on comes from `https://projects.blender.org/lab/blender_mcp` (or the Blender extensions listing for it), documented at `https://www.blender.org/lab/mcp-server/` |
| 2 | **Version** | the add-on release matches the server's major version; a secondary source reports add-on v1.0.3 (2026-09-11), so record the version from the official release page [TO VERIFY] |
| 3 | **Checksum** | record the SHA-256 of the downloaded archive and the commit of the release tag; compare with any checksum the official release page publishes; if none is published, state that, and rely on the official URL, the tag and reading the source |
| 4 | **Localhost only** | read the add-on source for its bind host: it must be `127.0.0.1` or `localhost`, never `0.0.0.0`; after starting it in a scratch session, `lsof -nP -iTCP:9876 -sTCP:LISTEN` must show the loopback address only; a connection attempt to the Mac's LAN address on 9876 must fail |
| 5 | **No exposure** | no port forwarding, tunnel or reverse proxy; the macOS firewall stays on; stop the server (quit Blender) when not in use |
| 6 | **Network permission** | decide whether Allow Online Access is truly required; keep it off if the bridge works without it |
| 7 | **No stray bridge** | the community add-on is disabled or removed (Ashish's approval) so only one bridge can bind 9876 |
| 8 | **Safe first use** | a scratch scene, no secrets or client files, a script read before it runs, one read-only call (list objects) recorded in a run |

### Approvals needed
`tool_install_or_update` for the official add-on; a decision on the community add-on (OD-style: keep, disable or remove); then a Stage 1 approval per scene. The bridge stays **off** until all eight checks are recorded.

## Chrome and browser automation: project-scoped plan (nothing installed)
**Detected:** Google Chrome 151.0.7922.137 (running). Browser automation already available without any install: the built-in browser pane (isolated, no personal profile), the Claude in Chrome tools (his real, signed-in Chrome), Control Chrome (needs verification), and Playwright 1.64.1 with cached Chromium builds in `~/creative-os/tools` (isolated contexts). REA covers web capture for targets with no source.

**Plan**
| Need | Tool | Rule |
|---|---|---|
| Read-only research, page text, frames | the built-in pane or Playwright in a **fresh, empty context** | no cookies, no profile, no extensions; every page read is logged in `sources.csv` with `access_method: browser-readonly` |
| A page blocked to plain fetch (403, JS wall) | Claude in Chrome, read-only | only in a live session under his standing OK (creative-os rule 11), never in a subagent or unattended run; never follow, post or buy; report afterwards |
| Anything signed in | Ashish logs in himself in his own browser | the harness never types credentials, never reads, copies or exports cookies, tokens or profile data; any signed-in step beyond read-only is a `login` approval |
| Posting, scheduling, sending, connecting | not part of v1 | `publishing`, `external_communication` and `account_connection` approvals, each its own row; Stage 3 is disabled |
| Scraping at volume | not allowed | rate limits stop the work and are reported; no bypass |

**Not done:** no random Chrome-control package, no profile or cookie copy, no new extension, no change to Chrome settings.

## Install procedure for the first approved package (template)
1. Write a pending `tool_install_or_update` row naming the package, source and scope.
2. Re-run the dry-run and paste the result. Stop on any downgrade, conflict or upgrade of an existing formula that he has not accepted.
3. Read the install scripts (`brew cat <formula>`, or the package's lifecycle scripts) and any hook it adds.
4. Install into project scope or a standalone environment, never the creative-os environment.
5. Run one read-only verification, then update `policies/tool-manifest.yaml` in a reviewed change.

## Safe next installs (all need his yes)
`shellcheck` and `uv` (clean dry-runs, no upgrades), Remotion in a project folder, then the official Blender add-on after the eight checks. Everything else waits for a named job.

## Remaining approvals
Install approvals for each item above; the Blender stack decision; the decision on the community add-on; and, from earlier work, the push of local commit d4c7576 and any decision locks pending in private runs, which this page does not touch.
