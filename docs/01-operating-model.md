# 01 — Operating model

## The loop
```
Brief → research and evidence → real references examined → three genuinely different routes
→ human pick → treatment and shot specs → production → independent QA → approval → closeout
→ validated memory
```
The loop is the charter's method (§6) made checkable. Gate ids (G1 to G11) live in `policies/approval-gates.yaml`; this page explains them.

| Gate | Step | Owner | Exit criteria | Human approval | Key artifact |
|---|---|---|---|---|---|
| G1 | Brief | director | context declared, success measure stated, unknowns marked `[TO VERIFY]` | yes | `brief.md`, `STATUS.md` |
| G2 | Research and evidence | trend-scout | ledger rows carry date, platform, geography, format, signal, uncertainty | no | `research-pack.md`, `sources.csv` |
| G3 | Real references examined | reference-forensics | 8+ real references viewed and measured; each tagged real / AI-made / unknown | no | DNA cards in the pack |
| G4 | Three routes | creative-producer | safe / brave / wild; two routes share at most one axis position; scored blind | no | `routes.md` |
| G5 | Human pick | director | Ashish picks in chat; his exact words and rejects logged | yes | `decision-log.md` |
| G6 | Treatment and shot specs | ai-film-lead | one complete spec per shot; no empty field | yes | `treatment.md`, `shots/` |
| G7 | Production | ai-film-lead (or builder) | approved row before each paid generation; rights row per asset; continuity QA | yes | assets, `rights.csv`, `approvals.csv` |
| G8 | Independent QA | qa-rights-reviewer | reviewer did not produce the work; measured where measurable; PASS/FAIL stated | no | `qa-report.md` |
| G9 | Approval | director | Ashish approves delivery; licence decisions made | yes | `approvals.csv`, `rights.csv` |
| G10 | Closeout | director | what shipped, learned, not done | no | `closeout.md` |
| G11 | Validated memory | memory-curator | promotion only with two separate real projects and his yes | yes | `memory/` |

Gates are sequential. A run may not move past a gate whose exit criteria fail. Skipping is recorded in `decision-log.md` as an **accepted risk** with an owner and a revisit date; it is never silent.

## One Director
One Director thread owns decisions. Specialists run in parallel only for research, variations and critique, and they cannot silently decide brand, client, publishing, licensing, legal, financial or account matters. They return a [handoff](02-agent-roles.md#handoff-block) and stop.

## Run size
| Size | When | Gates used |
|---|---|---|
| full | new brief, new domain, anything that ships to a client | G1–G11 |
| sprint | known domain, fixed look, short turnaround | G1, G2 (light), G4–G5 (two routes minimum plus the contrarian note), G6–G10 |
| one-off | a single asset | G1, G7, G8, G10 |

The size is chosen by the Director, recorded in `STATUS.md`, and Ashish can overrule it. Gates G7 (approval before spend) and G9 (approval before delivery) are never skipped at any size.

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

## Replies to Ashish
Short, answer first, tables over paragraphs, his Hinglish register, full clickable URLs for any external source. Run checks silently and show at most one line ("Checked: …"). Model facts carry a tag `[V]` official page, `[W]` widely reported, `[U]` unverified, plus the date seen.

## Where creative-os fits
creative-os already owns the Director (`creative-pipeline`), planner (`autopilot`), critics and builders. This harness adds the contract around them (policies, ledgers, validators, run layout). The mapping is in [02-agent-roles.md](02-agent-roles.md).
