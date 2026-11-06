# 01 — Operating model

## The loop
```
Brief → research and evidence → real references examined → three genuinely different routes
→ human pick → treatment and shot specs → production → independent QA → approval → closeout
→ validated memory
```
The loop is the studio's method made checkable. Gate ids (G1 to G11) live in `policies/approval-gates.yaml`; this page explains them.

| Gate | Step | Owner | Exit criteria | Human approval | Key artifact |
|---|---|---|---|---|---|
| G1 | Brief | director | context declared; brief in the owner's exact words; **concrete practice set**; success measure stated; unknowns marked `[TO VERIFY]` | yes | `brief.md`, `STATUS.md` |
| G2 | Research and evidence | trend-scout | ledger rows carry date, platform, geography, format, signal, uncertainty | no | `research-pack.md`, `sources.csv` |
| G3 | Real references examined | reference-forensics | 8+ real references viewed and measured; each tagged real / AI-made / unknown | no | DNA cards in the pack |
| G4 | Three routes | creative-producer | safe / brave / wild; two routes share at most one axis position; scored blind | no | `routes.md` |
| G5 | Human pick | director | the owner picks in chat; the owner's exact words and rejects logged | yes | `decision-log.md` |
| G6 | Treatment and shot specs | ai-film-lead | one complete spec per shot; no empty field | yes | `treatment.md`, `shots/` |
| G7 | Production | ai-film-lead (or builder) | approved row before each paid generation; rights row per asset; continuity QA | yes | assets, `rights.csv`, `approvals.csv` |
| G8 | Independent QA | qa-rights-reviewer | reviewer did not produce the work; measured where measurable; PASS/FAIL stated | no | `qa-report.md` |
| G9 | Approval | director | the owner approves delivery; licence decisions made | yes | `approvals.csv`, `rights.csv` |
| G10 | Closeout | director | what shipped, learned, not done | no | `closeout.md` |
| G11 | Validated memory | memory-curator | promotion only with two separate real projects and the owner's yes | yes | `memory/` |

Gates are sequential. A run may not move past a gate whose exit criteria fail. Skipping is recorded in `decision-log.md` as an **accepted risk** with an owner and a revisit date; it is never silent.

## One Director
One Director thread owns decisions. Specialists run in parallel only for research, variations and critique, and they cannot silently decide brand, client, publishing, licensing, legal, financial or account matters. They return a [handoff](02-agent-roles.md#handoff-block) and stop.

## Run size
| Size | When | Gates used |
|---|---|---|
| full | new brief, new domain, anything that ships to a client | G1–G11 |
| sprint | known domain, fixed look, short turnaround | G1, G2 (light), G4–G5 (two routes minimum plus the contrarian note), G6–G10 |
| one-off | a single asset | G1, G7, G8, G10 |

The size is chosen by the Director, recorded in `STATUS.md`, and the owner can overrule it. Gates G7 (approval before spend) and G9 (approval before delivery) are never skipped at any size.

## Routes
The standard loop above fits any brief. A **Channel Launch** route (`route: channel-launch`, `practice: content` in `STATUS.md`) fits a new channel with zero posts: twelve steps from channel brief to measurement loop, four human locks (positioning, pillars and formats, visual direction, calendar), no invented data, no publishing ([12-channel-launch-and-growth.md](12-channel-launch-and-growth.md)). It uses the same gates for evidence, approval, independent QA and closeout; its plan has its own validator, `scripts/check-channel-plan.sh`.

## Intake state: `practice: unknown`
Before the brief exists, a run is in intake: `status: draft` or `blocked`, `practice: unknown`. This is the only state where `unknown` is valid, and nothing may start in it: no research, routes, treatment, shot specs, QA, ledger rows or approvals. The validator fails a run that has any of those while the practice is `unknown`, and fails `unknown` on any other status. G1 closes only when the practice is a concrete value, and the practice decides the builder (for example `film` is the only practice that enters the AI-film pipeline). A value is never filled in just to satisfy the validator; `unknown` is the honest value.

## Run lifecycle and status
`draft` → `in_progress` → (`blocked` | `awaiting_approval`) → `complete`. `demo` marks the fictional proof run. Status lives in the front matter of `STATUS.md` ([runs/README.md](../runs/README.md)).

## Task report contract
Every task, in every run, ends with a report that has these six parts, in `STATUS.md` and repeated in the chat reply:

| Part | Content |
|---|---|
| Status | one line and the gate it is at |
| Deliverables | file paths of what exists now |
| Evidence | source ids, measurement commands, reference counts |
| Verification | what was checked and how, **and what was not checked** |
| Risks | open risks and `[TO VERIFY]` items |
| Next action | one concrete step and its owner |

`scripts/check-run-completeness.sh` fails a non-draft run whose sections are missing or empty.

## Replies to the owner
Short, answer first, tables over paragraphs, in the language and register set in the workspace profile.md, full clickable URLs for any external source. Run checks silently and show at most one line ("Checked: …"). Model facts carry a tag `[V]` official page, `[W]` widely reported, `[U]` unverified, plus the date seen.

## Where private packs fit
The owner's workspace profile.md and any private packs it lists outrank generic defaults; the harness decides process, packs may add craft skills (director, planner, critic and builder skills). This harness adds the contract around them (policies, ledgers, validators, run layout); see [16-private-packs.md](16-private-packs.md). The mapping is in [02-agent-roles.md](02-agent-roles.md).
