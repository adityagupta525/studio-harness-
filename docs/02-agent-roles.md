# 02 — Agent roles

Ten role cards in `agents/`. They are **cards, not auto-registered subagents**: nothing here changes `~/.claude/agents`. To use one as a Claude Code subagent, review it and copy or symlink it into `.claude/agents/` yourself (that is a `tool_install_or_update`-class change and needs Ashish's yes).

Each card defines: mission, inputs it may read, outputs it must create, eventual tools, forbidden actions, verification required, escalation conditions, exact handoff format.

| Agent | Mission in one line | Closest creative-os capability (reused, not copied) |
|---|---|---|
| [director](../agents/director.md) | owns decisions, runs the loop, records approvals | `creative-pipeline`, `autopilot`, `studio-manager` |
| [trend-scout](../agents/trend-scout.md) | dated, measured trend and competitor evidence | `design-intel`, `scout` |
| [reference-forensics](../agents/reference-forensics.md) | measured DNA of real references | `video-reference-analyzer`, `pinterest-visual-research`, `deconstructor`, `design-forensics` |
| [creative-producer](../agents/creative-producer.md) | three routes, treatment, story bible, content routes | `story-architect`, `brand-strategy`, `creative-pipeline` |
| [ai-film-lead](../agents/ai-film-lead.md) | shot list, shot specs, generation plan | `ai-film-prompt-director`, `model-intel`, `visual-library` |
| [blender-cinematographer](../agents/blender-cinematographer.md) | deterministic cameras, lenses, light, previews | `mac-native-control`; future official Blender Lab MCP |
| [motion-editor](../agents/motion-editor.md) | edit, captions, sound, exports | `ffmpeg`, Remotion, `music-studio`, `mac-native-control` |
| [packaging-lead](../agents/packaging-lead.md) | thumbnails, titles, social package, calendar draft | `graphic-design-director`, `content-studio` |
| [qa-rights-reviewer](../agents/qa-rights-reviewer.md) | independent QA, source and rights review | `creative-critic`, `critic-judge`, `product-qa` |
| [memory-curator](../agents/memory-curator.md) | candidate lessons, validated promotion, expiry | `lessons/`, `taste-judge` (read-only) |

## Decision rights
| Decision | Ashish | Director | Specialists |
|---|---|---|---|
| Brand, positioning, studio name | decides | prepares options | may propose, never decide |
| Which route to build | picks | presents best two | score and critique |
| Client matters (scope, price, contact) | decides | records | none |
| Publishing, scheduling, posting | decides and does | prepares a package | none |
| Licensing and clearance of any asset | decides | records the decision | write "unknown" or "pending" |
| Legal or financial statements, spend | approves each | requests with a quote | none |
| Linking an account, installing a tool | approves each | requests | none |
| Technical choices inside an approved route | informed | decides | propose |

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
open_decisions: <questions only the Director or Ashish can answer>
next_action: <one line and its owner>
```

A handoff with an empty `verification` or `risks` field is invalid. "None" must be written, and "not verified" must be said when true.
