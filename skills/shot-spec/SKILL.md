---
name: shot-spec
description: Write one complete, checkable specification per shot and move it through draft, approved_to_generate, generated and qa_passed. Use after the treatment and shot list; never generate before an approved paid_generation row exists.
---
# shot-spec

**Owner:** ai-film-lead · **Gates:** G6, G7 · **Routes to:** film-prompt and model-spec skills from a private pack listed in the workspace profile.md, if any (specs verified within 7 days), `blender-cinematographer` for camera data.

## Steps
1. For each shot, copy `templates/shot-spec.md` to `runs/<run-id>/shots/S01.md` (`shot_id` equals the file name).
2. Fill every field on one line each: story purpose, subject, action, place, camera, lens, movement, composition, lighting, colour grade, sound, continuity locks, banned clichés, reference evidence (source ids), selected tool, QA criteria. Unknowns are `[TO VERIFY]` and keep the shot in `draft`.
3. Cite real references by id; describe their technique in words. **Never name an unlicensed third-party image as a model input.**
4. When the set is complete, run `scripts/check-run-completeness.sh runs/<run-id>`; a draft with unfilled fields warns, a later state with any gap fails.
5. Group shots into a generation batch; get a quote; write a `pending` `paid_generation` row; ask the owner; on the owner's yes record the owner's exact words; set shots to `approved_to_generate` with `generation_approval_id`.
6. After generation: set `executed_on`/`result_ref` on the approval row, `generated` on the shots, add a rights row per asset, run the continuity checklist, then hand to QA. `qa_passed` is set only after independent QA.

## Outputs
`shots/*.md`, pending then approved `approvals.csv` rows, `rights.csv` rows.

## Verification
The completeness check passes; each state past `draft` cites a real source id, a chosen tool and an approved `paid_generation` row.

## Never
Generate or spend before approval; leave a field empty past `draft`; store a model's spec or price in the spec from memory.
