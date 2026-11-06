# Studio Harness

**v2.0.0-alpha.1 (6 Nov 2026): now a Claude Code plugin.** Install once and it is on in every session: no slash command needed.

## Install (Claude Code)
```text
/plugin marketplace add adityagupta525/studio-harness-
/plugin install studio-harness@studio-harness
```
It asks for a workspace folder (default `~/StudioHarness`) and an optional YouTube Data API key. Your profile, runs, channel dossiers, memory and taste live in the workspace; the plugin ships only the system. First session: it asks your name, language and channels and writes `profile.md`.

| Always on | How |
|---|---|
| Operating contract + workspace + tool probe | SessionStart hook (`scripts/hooks/session_start.py`) |
| Active run gate + next action on every prompt | UserPromptSubmit hook (`harness_context.py`) |
| STATUS must be fresh before a turn ends | Stop hook (`harness_stop_check.py`) |
| Reply and work rules | output style `Studio Harness` (forced, coding instructions kept) |
| Runs from the shell | `studio-harness init / new <slug> / use <run> / show / check / doctor` |

The core is plain files (Markdown, YAML, CSV, Python, shell), so other agent runtimes can use it through `AGENTS.md`; the Claude Code plugin is one adapter.

## What it is
A Claude Code-native, **local-first, evidence-led** operating system for an independent global design studio: content creation, AI film, social strategy, motion, 3D and client delivery.

It is a contract made of files: Markdown, YAML, CSV and shell validators. It works on its own and can reuse craft skills, standards and measurement tools from a private pack listed in the workspace profile.md (if any). It adds the parts such packs usually lack: staged tool and approval policy, source and rights ledgers, shot-spec schema, a validated run layout, and memory with a promotion rule.

**Status (2026-11-06):** plugin alpha. Roadmap: departments and director orchestration, channel dossier (competitors, biography, monetization), YouTube and Instagram growth department, calibrated critic panels, learning loop, generalised production skills. Integrations are **designed and gated**; anything unknown is marked `[TO VERIFY]`.

## The loop
```
Brief → research and evidence → real references examined → three genuinely different routes
→ human pick → treatment and shot specs → production → independent QA → approval
→ closeout → validated memory
```

## Layout
| Path | What |
|---|---|
| [CLAUDE.md](CLAUDE.md), [AGENTS.md](AGENTS.md) | short root maps |
| [docs/](docs/00-charter-and-scope.md) | rules (00–16), [private packs](docs/16-private-packs.md) and [tool install policy](docs/tool-install-policy.md) |
| `agents/` | ten role cards (mission, limits, handoff) |
| `skills/` | twelve procedures: the standard nine (brief, research, competitor watch, routes, treatment, shot spec, packaging, QA, closeout) and three for [Channel Launch](docs/12-channel-launch-and-growth.md) (channel-launch, channel-strategy, content-programming) |
| `templates/` | every artifact's fixed form |
| `policies/` | permissions, tool manifest, approval gates, source, memory, model routing (YAML) |
| `runs/` | the repo keeps only `_template/` and a [fictional demo](runs/2026-11-04-demo-fictional-harness-proof/STATUS.md); real runs live in the workspace's `runs/` |
| `memory/` | approved canon, client scopes, validated lessons, candidates, expired |
| `scripts/` | `validate-harness.sh`, `check-source-ledger.sh`, `check-run-completeness.sh`, `check-channel-plan.sh` |

## Start a project
```bash
studio-harness new <slug>
```
Or just describe the job in a session: the `operating-loop` skill opens the run, plans, and asks for your yes before building.

## Routes
| Route | Use it when | Start |
|---|---|---|
| Standard loop | any brief: film, motion, graphic, brand, product, one-off content | `studio-brief` |
| **Channel Launch** | a new channel with **zero posts**: research, position, plan, produce, package, measure, improve, without invented data or auto-publishing | `skills/channel-launch/SKILL.md`; set `route: channel-launch` and `practice: content` in `STATUS.md` |

Channel Launch in twelve steps: channel brief, category and audience research, competitor evidence pack, competitor video and reel deconstruction, opportunity and positioning hypothesis, channel promise and editorial voice, 3 to 5 pillars, repeatable formats, packaging system, production system, first 30-post calendar and 90-day strategy, measurement and review. The owner locks positioning, visual direction, pillars and formats, and the first calendar with approval rows; production spend is a separate approval; nothing is published. A channel plan cannot be marked `complete` without real competitor and post URLs, stated assumptions, three distinct pillars, approval records and a measurement plan ([docs/12](docs/12-channel-launch-and-growth.md), [docs/13](docs/13-content-production-system.md), [docs/14](docs/14-channel-measurement-and-learning.md)).

## Validate
```bash
scripts/validate-harness.sh
```
Needs `bash` and `python3` (standard library only); `ruby` and `jq` (if present) enable the YAML checks.

## Principles in one breath
One Director decides. The client system outranks taste. Evidence before assertion. References are studied, never copied. Nothing paid, public or external happens without a recorded yes. Memory is promoted only after two real projects.

## Relation to private packs
The owner's workspace profile.md and any private packs it lists outrank generic defaults; the harness decides process, packs may add craft skills. This repo links to a pack and never edits it ([docs/16-private-packs.md](docs/16-private-packs.md)).

## Remote
`origin`: https://github.com/adityagupta525/studio-harness-
