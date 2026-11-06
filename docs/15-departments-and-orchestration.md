# 15. Departments and orchestration

The harness runs like an agency: one **director** thread, seven departments, a **chief** per department, one **owner** and one **monitor** per task. The same job is run the same way every time, so results are comparable across days and buyers.

## Departments
| Department | Chief | Specialists | Owns |
|---|---|---|---|
| Director's office | **director** | — | intake, Job Plan, routing, gates, every question to the owner, STATUS.md |
| Intelligence | **intel-chief** | channel-analyst, audience-analyst, trend-scout, reference-forensics | Channel Dossier (biography, timeline, formats, cadence, performance, competitors, monetization and earning points), audience, trends, measured reference DNA |
| Strategy | **strategy-chief** | — (draws on Intelligence and Growth) | positioning, promise, pillars, series, calendar, monetization plan, 90-day goals |
| Growth & Platforms | **growth-chief** | youtube-strategist, instagram-strategist, analytics-analyst, channel-setup-lead, packaging-lead | channel setup, algorithm-literate packaging, SEO, posting system, analytics loop, weekly review |
| Creative | **creative-producer** | script-writer, art-director | three routes, treatment, scripts, look and design sheets |
| Production | **production-chief** | ai-generation-artist, voice-producer, animation-3d-lead, ai-film-lead, blender-cinematographer, motion-editor | the build: AI image and video, VO, 3D, film, edit, motion, exports |
| QA & Standards | **qa-chief** | panel-judge (x3 per item), fact-checker, consistency-auditor, qa-rights-reviewer | blind panel scoring, facts, consistency and drift, rights, platform specs |
| Learning & Engineering | **chief-engineer** | eval-engineer, knowledge-ingester, memory-curator | the harness itself: checks, evals, capability probe, knowledge cards, lessons, releases |

Role cards: `agents/<name>.md`. Every card has the same sections and the same HANDOFF block, so any agent can read any other agent's output.

## Owner + monitor per task (RACI)
Each task line in the Job Plan (`templates/job-plan.md`) names:
| Letter | Who | Rule |
|---|---|---|
| R (does it) | one specialist | exactly one |
| A (accountable) | the department chief | signs the handoff before it leaves the department |
| M (monitor) | an agent from a **different** department, usually QA & Standards | checks the output against the task's "done means" line; never the maker |
| C (consulted) | other departments | named, optional |
| D (decides) | the owner | only for decisions that are the owner's (brand, money, publishing, licences, accounts) |

## Flow of a job
1. **Intake (director).** Context line, the owner's words in `brief.md`, success test. A quick question needs no run.
2. **Job Plan (director).** Pick the route (standard loop, channel launch, brand identity, channel dossier, growth review), list tasks with R/A/M, the "done means" line per task (the sprint contract), tools available today (capability probe + `docs/CATALOG.md`), cost (free first; paid only with a quote), gates. The owner's yes is recorded in `approvals.csv`.
3. **Departments run their tasks in parallel where nothing depends on another task;** research, variations and critique are parallel, decisions are not.
4. **Handoffs** go chief → director with the HANDOFF block; the director never accepts a "done" without `verification` and `risks` filled.
5. **QA gate (qa-chief).** Blind panel against the anchored rubric for the deliverable; vetoes stand; the monitor's checks and the mechanical checks (`studio-harness check`, job-specific scripts) are run, with exit codes.
6. **Show (director).** Only what the plan says (usually the best two of three routes), one line each, then the owner's pick and exact words are logged.
7. **Closeout + learning.** `project-closeout`; misses become candidate checks (chief-engineer) and candidate lessons (memory-curator); knowledge cards are refreshed weekly by the `learning-loop` skill (knowledge-ingester: `sources/registry.json` → inbox → cards → index → promote after two runs).

## Escalation
| Situation | Goes to |
|---|---|
| a decision that is the owner's | director → owner |
| two departments disagree | director, with both handoffs side by side |
| a check fails twice on the same task | chief-engineer (missing capability: add a check, rule or skill step) |
| a platform fact is older than 30 days | fact-checker re-reads the official page before it is quoted |
| spend, publish, connect, delete | director → owner, approval row first |

## Consistency (why the same work gets the same score)
- One template per job type; validators reject runs that skip a step.
- One rubric per deliverable type with anchored levels (`rubrics/`); three blind `panel-judge` agents, median, re-judge when a criterion spreads more than 1 point; spread and median logged (`scripts/panel.py`, skill `qa-panel`).
- Calibration sets with gold scores (`calibration/`); `scripts/drift.py` must pass before new scores are trusted.
- Regression evals from real failures (`evals/`, `claude plugin eval`).
- The consistency-auditor re-scores a calibration set on every release and flags drift.
- Owner picks outrank critics; an axis capped by the owner's choice is logged as capped, not as a failure.
