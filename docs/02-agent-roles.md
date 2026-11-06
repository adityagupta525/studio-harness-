# 02 — Agent roles

Ten role cards in `agents/`. They are **cards, not auto-registered subagents**: nothing here changes `~/.claude/agents`. To use one as a Claude Code subagent, review it and copy or symlink it into `.claude/agents/` yourself (that is a `tool_install_or_update`-class change and needs the owner's yes).

Each card defines: mission, inputs it may read, outputs it must create, eventual tools, forbidden actions, verification required, escalation conditions, exact handoff format.

| Agent | Mission in one line | Closest private-pack capability, if a private pack listed in the workspace profile.md provides one (reused, not copied) |
|---|---|---|
| [director](../agents/director.md) | owns decisions, runs the loop, records approvals | a director, planner or studio-manager skill |
| [trend-scout](../agents/trend-scout.md) | dated, measured trend and competitor evidence | a scouting skill or scout agent |
| [reference-forensics](../agents/reference-forensics.md) | measured DNA of real references | video and still deconstruction skills, a deconstructor agent, a design-forensics skill |
| [creative-producer](../agents/creative-producer.md) | three routes, treatment, story bible, content routes | story, brand-strategy and director skills |
| [ai-film-lead](../agents/ai-film-lead.md) | shot list, shot specs, generation plan | film-prompt, model-spec and visual-library skills |
| [blender-cinematographer](../agents/blender-cinematographer.md) | deterministic cameras, lenses, light, previews | a native-app automation skill; future official Blender Lab MCP |
| [motion-editor](../agents/motion-editor.md) | edit, captions, sound, exports | `ffmpeg`, Remotion, a music skill, a native-app automation skill |
| [packaging-lead](../agents/packaging-lead.md) | thumbnails, titles, social package, calendar draft | graphic-design and content-planning skills |
| [qa-rights-reviewer](../agents/qa-rights-reviewer.md) | independent QA, source and rights review | a critic skill, a blind critic agent, a UI QA skill |
| [memory-curator](../agents/memory-curator.md) | candidate lessons, validated promotion, expiry | a lessons store, a taste judge (read-only) |

## Decision rights
| Decision | Owner | Director | Specialists |
|---|---|---|---|
| Brand, positioning, studio name | decides | prepares options | may propose, never decide |
| Which route to build | picks | presents best two | score and critique |
| Client matters (scope, price, contact) | decides | records | none |
| Publishing, scheduling, posting | decides and does | prepares a package | none |
| Licensing and clearance of any asset | decides | records the decision | write "unknown" or "pending" |
| Legal or financial statements, spend | approves each | requests with a quote | none |
| Linking an account, installing a tool | approves each | requests | none |
| Technical choices inside an approved route | informed | decides | propose |

## Channel Launch route: who does what
For a run with `route: channel-launch` ([docs/12](12-channel-launch-and-growth.md)). Each agent card has a `## Channel Launch` section with its duties.

| Steps | Agent | Hands off |
|---|---|---|
| C1 brief, C10 production system, every lock request | director | locks requested, never self-approved |
| C2 research, C3 competitor evidence pack | trend-scout | `research-pack.md`, `channel-competitor-map.md`, `sources.csv` rows |
| C4 competitor video and reel deconstruction | reference-forensics | `competitor-posts.csv` rows, each from a watched video or viewed frames |
| C5 to C8 positioning, promise, voice, pillars, formats | creative-producer | positioning in `channel-brief.md`, `pillars/`, `formats/` |
| C9 packaging system, C11 calendar and 90-day strategy | packaging-lead | `channel-style-system.md`, `hook-library.md`, `content-calendar.md` |
| per-post making | ai-film-lead, motion-editor | post cards, shot specs, exports, rights rows |
| plan and post QA | qa-rights-reviewer | `qa-report.md` with `scripts/check-channel-plan.sh` exit code |
| C12 measurement and review | memory-curator | `channel-metrics.md` custody, `reviews/`, lesson candidates |

Handoff additions for channel runs (the block itself does not change): `deliverables` lists the channel files by name; `evidence` gives counts (competitors, posts analysed, assumptions, pillars, calendar rows) and source or post ids; `verification` quotes the exit code of `scripts/check-channel-plan.sh`; `risks` names the assumptions still untested; `open_decisions` names the lock approval the owner must give next.

## Independence rules
- **The producer never signs off its own work.** `qa-rights-reviewer` must be a different agent run from the one that produced the artifact; the QA report names both.
- **Critics are blind.** Each route is scored alone, without seeing the others; one contrarian pass tries to kill the front-runner.
- **Parallelism is for reading, not deciding.** Parallel specialists may research, draft variations or critique. Only the Director thread decides.
- **No swarm.** There is no orchestrator of orchestrators; ten fixed roles, one decision thread.

## Handoff block
Every agent ends with this block. Cards add the agent-specific `deliverables` and `evidence` expected, but never change the field names, because `STATUS.md` and the next agent read them.

```
HANDOFF
from: <agent id>
to: <agent id or director>
run: runs/<run-id>/
context: studio | client:<name> | employer | demo
status: complete | partial | blocked
deliverables: <file paths created or changed>
evidence: <source ids, measurement commands, reference counts>
verification: <what was checked and how; what was NOT checked>
risks: <list, [TO VERIFY] items included>
open_decisions: <questions only the Director or the owner can answer>
next_action: <one line and its owner>
```

A handoff with an empty `verification` or `risks` field is invalid. "None" must be written, and "not verified" must be said when true.
