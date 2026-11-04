---
shot_id: S[TO FILL]
story_purpose: [TO FILL]
subject: [TO FILL]
action: [TO FILL]
place: [TO FILL]
camera: [TO FILL]
lens: [TO FILL]
movement: [TO FILL]
composition: [TO FILL]
lighting: [TO FILL]
colour_grade: [TO FILL]
sound: [TO FILL]
continuity_locks: [TO FILL]
banned_cliches: [TO FILL]
reference_evidence: [TO FILL]   # source ids from sources.csv; "none" only while draft
selected_tool: [TO FILL]        # a tool from policies/tool-manifest.yaml, or "none yet"
qa_criteria: [TO FILL]
approval_state: draft           # draft | approved_to_generate | generated | qa_passed | rejected
generation_approval_id: none    # an approved paid_generation row in approvals.csv, required from approved_to_generate onward
---
# Shot [TO FILL] — [TO FILL: one-line description]

Every field above is required. Values stay one line each so the validator can read them. Unknowns are written [TO VERIFY] and block anything beyond draft.

## Prompt draft (English, only after the picked route and treatment exist)
[TO FILL]

## Continuity QA (filled after generation, by qa-rights-reviewer)
- [ ] Subject and wardrobe match the bible
- [ ] Light direction and colour match the neighbouring shots
- [ ] Lens and movement match this spec
- [ ] No banned cliché present
- [ ] Rights row exists for the generated asset

## Result log
| Date | Take | Approval id | Tool and settings | Verdict | Note |
|---|---|---|---|---|---|
