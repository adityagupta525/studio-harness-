# runs — one folder per project

A run folder is the evidence for everything the studio ships. Write it **while the work happens**, gate by gate, not afterwards from memory. It is the *task state* memory class ([docs/03-context-and-memory.md](../docs/03-context-and-memory.md)).

## Start a run
```bash
cd ~/studio-harness
cp -R runs/_template runs/$(date +%F)-<slug>
```
Then edit `STATUS.md` front matter (`run_id` = folder name, `context`, `practice`, `status`) and fill `brief.md` from the Director's intake. The template starts with `practice: unknown`. Leave it `unknown` until a real brief exists (status `draft` or `blocked`), then set a concrete practice before any research.

## Folder layout
| Path | What | Created by |
|---|---|---|
| `STATUS.md` | front matter + six sections: Status, Deliverables, Evidence, Verification, Risks, Next action | Director; updated at every gate |
| `brief.md` | the brief in his words, business logic, constraints | Director |
| `sources.csv` | source ledger (full URLs, dates, tags, signals) | trend-scout, reference-forensics |
| `rights.csv` | asset rights ledger | any agent adding an asset; cleared only by his licence decision |
| `approvals.csv` | every gated action: pending → approved → executed | Director |
| `decision-log.md` | decisions, rejected options, accepted risks, action audit log | Director |
| `research-pack.md`, `routes.md`, `treatment.md` | created from `templates/` as the loop advances | specialists |
| `shots/S01.md …` | one shot spec each | ai-film-lead |
| `qa-report.md`, `closeout.md` | independent QA and the closing record | qa-rights-reviewer, Director |
| `refs/`, `renders/`, media files | heavy or third-party material | git-ignored, never committed |

## Naming and status
- Folder name `YYYY-MM-DD-<slug>`; `run_id` in `STATUS.md` must equal it.
- `context` is one of `studio`, `client:<name>`, `employer`, `demo`. Declared at the start; never mixed.
- `practice` is `brand`, `product`, `web`, `motion`, `film`, `graphic`, `content`, `music` or `research`. `unknown` is valid **only** for intake runs (status `draft` or `blocked`) that have no research, routes, treatment, shot specs, QA, closeout, ledger rows or approvals. `brief.md` must repeat the same Context and Practice as `STATUS.md`.
- `status`: `draft`, `in_progress`, `blocked`, `awaiting_approval`, `complete`, `demo`.
- `route` (optional, default `standard`): `standard` or `channel-launch`. A Channel Launch run (a new channel with zero posts) uses `practice: content` and adds `channel-brief.md`, `channel-competitor-map.md`, `competitor-posts.csv`, `pillars/`, `formats/`, `hook-library.md`, `channel-style-system.md`, `content-calendar.md`, `channel-metrics.md`, `post-cards/` and `reviews/`, created from `templates/` by the `channel-launch` skill. Its approvals also use `lock_positioning`, `lock_pillars`, `lock_visual_direction` and `lock_calendar` ([docs/12](../docs/12-channel-launch-and-growth.md)).

## Rules the validator enforces
- Six STATUS sections exist; non-draft runs have no `[TO FILL]`.
- `practice: unknown` only in `draft` or `blocked` intake runs, with nothing started and a decision-log row that says so; `brief.md` and `STATUS.md` agree on Context and Practice.
- A gated action with `executed_on` must be an `approved` row with Ashish's words and `approved_on` not after `executed_on`.
- A rights row used as model input must be `own`, `licensed` or `public-domain`, cleared, with a recorded licence decision. `analysis-only` references never reach a model or a deliverable.
- A shot spec past `draft` has no empty field and no `[TO VERIFY]`; from `approved_to_generate` on it cites an approved `paid_generation` row.
- A `complete` run has a `qa-report.md` with `result: PASS`, a `closeout.md`, and every delivered asset cleared.
- A Channel Launch run passes `scripts/check-channel-plan.sh`: competitors analysed from real post URLs, stated assumptions, three distinct pillars, approved lock rows, a measurement plan, and zero-post honesty (no audience data, tested hooks, observations or reviews while `posts_published` is 0).

Run all checks: `scripts/validate-harness.sh`. Individual checks: `scripts/check-source-ledger.sh`, `scripts/check-run-completeness.sh`.

## Relation to creative-os
`~/creative-os/runs/README.md` is the older job-log convention (gate log with his exact words). This layout keeps its spirit (log while you work, heavy media out of git, references analysis-only) and adds the status / evidence / verification / risks / next-action contract and the approval record.

The folder `2026-11-04-demo-fictional-harness-proof/` is a **fictional** proof that the system works. It contains no client, no real sources, no media and no paid or account actions.
