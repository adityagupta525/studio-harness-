---
name: ai-film-treatment
description: Write the treatment and the story, character and world bible for the route the owner picked, and the shot list that feeds shot specs. Use after the pick, before any shot spec or generation.
---
# ai-film-treatment

**Owner:** creative-producer with ai-film-lead · **Gate:** G6 (first half) · **Routes to:** story, film-prompt and visual-library skills from a private pack listed in the workspace profile.md (if any).

## When to use
After G5 (route picked and logged). Not before.

## Steps
1. Read the picked route, the brief and the evidence. State the context.
2. Write `runs/<run-id>/treatment.md` from `templates/treatment.md`: logline and intent, audience and moment, structure and beats, visual language **derived from the client or project system**, sound direction, deliverables, risks.
3. Write the bible inside it: story spine, characters (look locks, voice, wardrobe, props), world (places, time, rules of light and weather), and the **continuity locks** every shot inherits.
4. List banned clichés for this piece (use a pack's cliché blacklist as a start, if one exists).
5. Produce the shot list (the beats table with one row per shot); hand off to `shot-spec`.
6. Flag music or track reuse for the owner's licensing decision; list unknowns as `[TO VERIFY]`; verify platform specs against the platform's current official page at delivery time.
7. Ask the owner to confirm the treatment before shot specs begin.

## Outputs
`treatment.md`, shot list.

## Verification
Each beat maps to a story purpose; continuity locks are concrete; every reference cited exists in `sources.csv`.

## Never
Invent a house style, reuse a third-party frame as a visual spec, or begin generation.
