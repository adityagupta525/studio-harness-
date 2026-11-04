# runs — one folder per project

A run folder is the evidence for everything the studio ships. Write it **while the work happens**, gate by gate, not afterwards from memory. It is the *task state* memory class ([docs/03-context-and-memory.md](../docs/03-context-and-memory.md)).

## Start a run
```bash
cd ~/studio-harness
cp -R runs/_template runs/$(date +%F)-<slug>
```
Then edit `STATUS.md` front matter (`run_id` = folder name, `context`, `practice`, `status`) and fill `brief.md` from the Director's intake.

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
- `status`: `draft`, `in_progress`, `blocked`, `awaiting_approval`, `complete`, `demo`.

## Rules the validator enforces
- Six STATUS sections exist; non-draft runs have no `[TO FILL]`.
- A gated action with `executed_on` must be an `approved` row with Ashish's words and `approved_on` not after `executed_on`.
- A rights row used as model input must be `own`, `licensed` or `public-domain`, cleared, with a recorded licence decision. `analysis-only` references never reach a model or a deliverable.
- A shot spec past `draft` has no empty field and no `[TO VERIFY]`; from `approved_to_generate` on it cites an approved `paid_generation` row.
- A `complete` run has a `qa-report.md` with `result: PASS`, a `closeout.md`, and every delivered asset cleared.

Run all checks: `scripts/validate-harness.sh`. Individual checks: `scripts/check-source-ledger.sh`, `scripts/check-run-completeness.sh`.

## Relation to creative-os
`~/creative-os/runs/README.md` is the older job-log convention (gate log with his exact words). This layout keeps its spirit (log while you work, heavy media out of git, references analysis-only) and adds the status / evidence / verification / risks / next-action contract and the approval record.

The folder `2026-11-04-demo-fictional-harness-proof/` is a **fictional** proof that the system works. It contains no client, no real sources, no media and no paid or account actions.
