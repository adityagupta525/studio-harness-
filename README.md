# Studio Harness v1

A Claude Code-native, **local-first, evidence-led** operating system for an independent global design studio: content creation, AI film, social strategy, motion, 3D and client delivery.

It is a contract made of files: Markdown, YAML, CSV and shell validators. It reuses the skills, standards and measurement tools already in `~/creative-os` and adds the parts that were missing: staged tool and approval policy, source and rights ledgers, shot-spec schema, a validated run layout, and memory with a promotion rule.

**Status (2026-11-04):** foundation only. No tool was installed, no account connected, nothing published, no credits spent, nothing committed or pushed. Integrations are **designed and gated, not connected**. Anything unknown is marked `[TO VERIFY]`.

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
| [docs/](docs/00-charter-and-scope.md) | rules (00–14) and [audits](docs/audits/2026-11-04-existing-capability-audit.md) |
| `agents/` | ten role cards (mission, limits, handoff) |
| `skills/` | twelve procedures: the standard nine (brief, research, competitor watch, routes, treatment, shot spec, packaging, QA, closeout) and three for [Channel Launch](docs/12-channel-launch-and-growth.md) (channel-launch, channel-strategy, content-programming) |
| `templates/` | every artifact's fixed form |
| `policies/` | permissions, tool manifest, approval gates, source, memory, model routing (YAML) |
| `runs/` | one folder per project; `_template/` and a [fictional demo](runs/2026-11-04-demo-fictional-harness-proof/STATUS.md) |
| `memory/` | approved canon, client scopes, validated lessons, candidates, expired |
| `scripts/` | `validate-harness.sh`, `check-source-ledger.sh`, `check-run-completeness.sh`, `check-channel-plan.sh` |

## Start a project
```bash
cd ~/studio-harness
cp -R runs/_template runs/$(date +%F)-<slug>
claude
```
Then tell Claude: "Use skills/studio-brief to start this run" and give the brief in your own words.

## Routes
| Route | Use it when | Start |
|---|---|---|
| Standard loop | any brief: film, motion, graphic, brand, product, one-off content | `studio-brief` |
| **Channel Launch** | a new channel with **zero posts**: research, position, plan, produce, package, measure, improve, without invented data or auto-publishing | `skills/channel-launch/SKILL.md`; set `route: channel-launch` and `practice: content` in `STATUS.md` |

Channel Launch in twelve steps: channel brief, category and audience research, competitor evidence pack, competitor video and reel deconstruction, opportunity and positioning hypothesis, channel promise and editorial voice, 3 to 5 pillars, repeatable formats, packaging system, production system, first 30-post calendar and 90-day strategy, measurement and review. Ashish locks positioning, visual direction, pillars and formats, and the first calendar with approval rows; production spend is a separate approval; nothing is published. A channel plan cannot be marked `complete` without real competitor and post URLs, stated assumptions, three distinct pillars, approval records and a measurement plan ([docs/12](docs/12-channel-launch-and-growth.md), [docs/13](docs/13-content-production-system.md), [docs/14](docs/14-channel-measurement-and-learning.md)).

## Validate
```bash
scripts/validate-harness.sh
```
Needs `bash` and `python3` (standard library only); `ruby` and `jq` (already on this Mac) enable the YAML checks.

## Principles in one breath
One Director decides. The client system outranks taste. Evidence before assertion. References are studied, never copied. Nothing paid, public or external happens without a recorded yes. Memory is promoted only after two real projects.

## Relation to creative-os
`~/creative-os` stays the authority for the charter, taste ledger, skills and builders. This repo links to it and never edits it.

## Remote
`origin` points at `https://github.com/adityagupta525/studio-harness-.git`. Nothing has been pushed; pushing is a `deployment`-class action that needs your go-ahead.
