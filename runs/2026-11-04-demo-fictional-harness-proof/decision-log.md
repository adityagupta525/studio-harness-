# Decision log — FICTIONAL DEMO

Append only. **FICTIONAL**: nothing here is a real decision by Ashish.

## Decisions
| Id | Date | Decision | Decided by | Basis (source ids, his exact words, measurements) | Affects |
|---|---|---|---|---|---|
| D-01 | 2026-11-04 | Context is `demo`; size is sprint-shaped, stopping at G4 | harness build | none: structural proof only | STATUS.md |
| D-02 | 2026-11-04 | No pick is recorded: a demo has no human, and an agent must not invent his words | harness build | docs/01-operating-model.md, gate G5 | routes.md, shots/ |

## Options rejected
| Id | Option | Why rejected | His words (if any) |
|---|---|---|---|
| none | | no human pick exists | |

## Accepted risks
| Id | Risk | Owner | Revisit by |
|---|---|---|---|
| R-01 | Shot specs S01 and S02 are drafted from Route A as a stand-in, before any pick, to illustrate the schema. In a real run they wait for G5 and G6 | Ashish | when this demo is archived |

## Actions (audit log for reversible drafts and local commands)
| Date | Agent | Action | Path or command |
|---|---|---|---|
| 2026-11-04 | harness build | created demo run folder from runs/_template | runs/2026-11-04-demo-fictional-harness-proof/ |
| 2026-11-04 | harness build | drafted brief, routes, two draft shot specs, NOT RUN qa-report | files in this folder |
