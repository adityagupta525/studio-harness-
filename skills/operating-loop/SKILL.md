---
name: operating-loop
description: The Studio Harness operating loop for every job that produces a deliverable (channel plan, competitor or channel research, brand, banner, logo, thumbnail, script, reel, film, 3D video, post series, growth plan). Finds or opens the run, works only on the gate STATUS.md names, routes each task to its department owner and monitor, plans before building, verifies mechanically, shows only what the plan says, logs the owner's words. Use at the start of any job, when the session context says "Studio Harness is on", or when the owner says "agency ki tarah", "harness se karo", "plan banao", "isko poora karo".
---
# operating-loop

The harness is the process; skills and tools do the craft. One director thread (this conversation) owns decisions that are not the owner's.

## Steps
1. **Find the run.** The workspace (`$CLAUDE_PLUGIN_OPTION_WORKSPACE_DIR`, default `~/StudioHarness`) holds `ACTIVE_RUN`. Read that run's `STATUS.md` (gate, next action) and `PLAN.md`. New job: `studio-harness new <slug>`. Switching: `studio-harness use <run>`.
2. **Read memory first (G0).** `profile.md` (owner's rules), the channel dossier under `channels/<handle>/` if the job is for a channel, `memory/` lessons and knowledge cards for the job type, `taste/picks.jsonl` (last 10 for the medium). Write what applies into `brief.md`. Context isolation: a run reads only its own folder and the shared evidence it cites; a brand run never reads episode folders.
3. **Know the gate.** Work only on the step STATUS names. Gates: `policies/approval-gates.yaml` (G1–G11); brand work adds `skills/brand-identity` (B0–B8); new channels follow `skills/channel-launch`.
4. **Plan before build.** `PLAN.md`: goal and success test, departments and owners, one monitor per task, research, pipeline, gates, tools available today (capability probe in the session context), cost (free first; paid only with a quote and the owner's yes), what is not promised. Record the owner's yes in `approvals.csv` before any generation or spend.
5. **Route to the department.**
   | Department | Owner (agent card in `agents/`) | Procedures (`skills/`) |
   |---|---|---|
   | Director's office | director | studio-brief, operating-loop |
   | Intelligence | trend-scout, reference-forensics | research-pack, competitor-watch, channel-strategy |
   | Strategy and growth | creative-producer (until the growth agents land) | channel-strategy, channel-launch, content-programming |
   | Creative | creative-producer | content-routes, brand-identity |
   | Production | ai-film-lead, blender-cinematographer, motion-editor | ai-film-treatment, shot-spec |
   | QA and standards | qa-rights-reviewer | qa |
   | Packaging and memory | packaging-lead, memory-curator | packaging, project-closeout |
   Private packs listed in `profile.md` may add stronger craft skills; the harness gates still apply.
6. **Diverge, then judge blind.** Three routes (safe / brave / wild) that share at most one axis position. One critic per route, blind, against the anchored rubric for the deliverable; vetoes stand; show the best two with one line each.
7. **Verify mechanically before showing.** `studio-harness check` (run completeness + source ledger), plus the job's own checks (`scripts/check-banner.py`, `scripts/check-brand-assets.py`, `scripts/check-channel-plan.sh`). Known and unknown claims both get verified: open, watch, listen, measure. A link is not research.
8. **Log at once.** The owner's exact words → `decision-log.md` and `taste/picks.jsonl`; approvals → `approvals.csv`; then `STATUS.md` (updated date, gate, next action). The Stop hook blocks once if STATUS is stale.
9. **Close out.** `project-closeout`: deliverables, evidence, lessons as candidates in `memory/candidates/`.

## Loop engineering
- A miss is a missing capability: ask "what check, rule or file would have caught this?", then add it (a check with a fix message, a rule in the run's core file, a step in a skill) and log it in `memory/candidates/`.
- A lesson seen in two runs is promoted into a skill or a check, with the owner's yes.
- Fresh context per job: nothing from a past run unless the run's core file says so.

## Never
Work without a run on a job · build before PLAN + yes · show unscored routes · change a locked value without the owner's lock · write taste without the owner's live words · spend, publish, connect, delete or push without a recorded yes.
