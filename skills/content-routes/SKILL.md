---
name: content-routes
description: Produce three genuinely different routes (safe, brave, wild) with an axis table, blind scores and a contrarian pass, then present the best two for the owner's pick. Use after the research pack and before any treatment.
---
# content-routes

**Owner:** creative-producer · **Gates:** G4, G5 · **Routes to:** creative-os `story-architect`, `brand-strategy`, `creative-pipeline`, `creative-critic` / `critic-judge` (blind), `taste-judge` (read-only).

## When to use
Any brief that needs a creative direction: film, motion, graphic, content series, brand. For content briefs the route also names the format, pillar and cadence idea (no posting).

## Steps
1. Confirm G1 (concrete practice set) and G3: references examined, evidence in `sources.csv`. If fewer than 8 real, say so; do not pad.
2. Set the parameters the work will be judged on before designing: brand fit, distinctiveness, craft, cultural accuracy, accessibility and usability, feasibility, the brief's success measure.
3. Write three routes in `runs/<run-id>/routes.md` from `templates/creative-route.md`: safe, brave, wild. Fill the axis table (palette, medium/capture, light, composition device, pacing, concept). **Any two routes share at most one axis position.**
4. Each route cites reference ids (technique only) and says what is invented. Style comes from the client system, never a house style.
5. Score each route **alone** (blind): one critic run per route. Vetoes cannot be averaged away.
6. Run one contrarian pass trying to kill the front-runner; write the result.
7. Present the best two to the owner with scores, costs `[TO VERIFY]` and rights risks. Ask him to pick.
8. On his reply, log his exact words, the pick and the rejects in `decision-log.md` (G5). Fusions of routes are explored on purpose and built before they are judged.

## Outputs
`routes.md`, a D-nn row for the pick.

## Verification
Pairwise axis comparison written out; contrarian result present; his words logged.

## Never
Write the treatment before the pick, hide a veto behind a high average, or decide the route for him.
