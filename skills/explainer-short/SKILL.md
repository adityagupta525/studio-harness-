---
name: explainer-short
description: Recipe for a narrated 30-60 s vertical explainer short (3D, AI image-to-video or motion graphics) - script lane (how-it-works, true story, what-if / POV), words-per-second budget, a hook that lands in 2 s with sound off, shots per 10 s, character and location sheets for consistency, production route per shot, a retry ladder for bad takes, captions in the edit, then QC with scripts/video-measure.py and the short-video rubric. Use for "explainer short banao", "how it works video", "what if short", "3D explainer", "faceless narrated short", "Shorts / Reels explainer series", or any VO-led vertical short.
---
# explainer-short

Owner: production-chief (Production). Script: script-writer (Creative). Monitor: qa-chief through `qa-panel` with `rubrics/short-video.json`. It runs inside the normal gates (G1-G11): it says what this format needs, it does not replace them.

## Steps
1. **Measure the lane before claiming a style (G2-G3).** Run `reference-research` on at least 8 narrated shorts in the chosen lane, from several channels, not one. For each: `python3 scripts/video-measure.py <file> runs/<run-id>/refs/<slug>/measure` with its auto-captions beside it, then read the contact sheet. Write the lane's measured ranges in `research-pack.md`: duration, words per second, shots per 10 s at both thresholds, cuts in the first 3 s, LUFS. A starting point only, from the owner's own measurement of three narrated explainer shorts (Oct 2026): 35-47 s, 2.8-3.0 words per second, 6-10 shots per 10 s at a low scene threshold, burned-in captions of 1-3 words, characters who gesture but never speak. Replace it with your lane's numbers; style comes from the measurements and the client's brand, never from one channel's look, characters, scripts or logo.
2. **Pick the script lane (G4-G5).** script-writer drafts three routes; the owner picks one.
   | Lane | Beat shape | Watch for |
   |---|---|---|
   | How it works | hook question → inside the object, one beat per part → one gag or macro surprise → payoff back on the whole object | every part named once; can run on picture and sound alone |
   | True story | cold-open fact → complication → the turn ("but here's the thing") → reveal → resolution | every claim sourced and tagged by fact-checker; real victims, families or children need a named source and the owner's yes |
   | What-if / POV | "what if you…" or "you and a friend" → consequence 1 → escalation with a timestamp or number → the limit → reframe kicker | physics and numbers checked; the kicker reframes, it does not moralise |
3. **Budget the words.** Words = target seconds × the lane's measured words per second (about 85-180 words for 30-60 s at 2.8-3.0 w/s). Write the line, then cut hedges, put a number in every vague phrase, drop adjectives the picture cannot show. Read it aloud against a timer; over budget → cut words, never speed up the voice.
4. **Hook in 2 s, sound off.** Frame 1 already shows the question or the action; the premise reads with sound muted by 2 s (an on-screen prop word or the caption carries it). No logo, title card or slow setup. script-writer writes 5 hook options; the panel judges them on the rubric's hook anchors.
5. **Shot plan.** Blocks of about 10 s, each a timed cut list: one idea per shot, shot size or angle changes on every cut, a shot every 1.0-2.0 s (target the lane's measured shots per 10 s; fewer than 5 per 10 s needs a deliberate hold written in). One gag and one macro or x-ray cutaway are cheap retention devices. Text inside the picture only as props of 3 words or fewer, spelling checked. Each shot gets a `shot-spec`.
6. **Sheets for consistency.** art-director makes one style-key still, then a sheet per recurring character (2:3), prop (1:1) and place (target aspect), plus damage or state variants (intact, cracked, broken) derived from the base sheet. A place plate made from the style key is prompted as an empty location that takes only render style and palette, and is checked for the hero subject leaking in before any video uses it.
7. **Choose the production route per shot (production-chief).**
   | Route | Owner | Best for | Cost |
   |---|---|---|---|
   | Blender 3D | animation-3d-lead | mechanisms, x-ray and cutaways, scale cuts, push-ins; repeatable bpy scenes | free, render time |
   | AI image → video | ai-generation-artist | characters, places, true-story moments; sheets as references | paid: quote the whole job (stills, N blocks, retry allowance, voice, upscale) and record a `paid_generation` row before the first call |
   | Motion graphics | motion-editor | diagrams, numbers, maps, text-led beats | free |
   Mixing routes is normal; the look must hold across them (same palette tokens, light direction, grain).
8. **Retry ladder for a bad take.** Diagnose the batch first on a takes contact sheet: the same failure in most takes → the prompt or source image is wrong, fix it before rolling again; high variance → bad rolls, sample once more; all competent but forgettable → the concept or shot is wrong. Then: same prompt ×2 → soften trigger words (clash for battle, dust for blood, no tight faces on distressed characters) ×2 → reframe the shot (size, angle, simpler action). Never drop a block or leave a gap; after about 8 attempts on one shot, stop and surface it to the owner with the takes. Every paid retry counts against the approved row.
9. **Voice, then captions (post).** voice-producer records or generates the narration as one continuous take and checks its length against the picture; a voice clone is only ever the owner's own voice with the owner's yes. Word timestamps give the beat map. motion-editor adds captions in the edit, never inside a generation: 1-3 words per chunk, high contrast, clear of the platform's UI zones (`knowledge/platforms/`), in sync with the voice. Punch-ins and impact shakes land on those words. Music and SFX licences go to the owner.
10. **QC with numbers (G8).** On the cut: `python3 scripts/video-measure.py final.mp4 runs/<run-id>/qa/measure` with the caption `.srt` beside it. Check against the plan and the lane's reference ranges: duration, shots per 10 s, cuts in the first 3 s, words per second, integrated LUFS and true peak against the platform target in `knowledge/platforms/`, and the contact sheet for sheet consistency. Write measured values beside the reference values with each gap explained.
    | Check | Fails when |
    |---|---|
    | Hook | the premise does not read by 2 s with sound off |
    | Sheets hold | a character, prop or place differs between blocks |
    | Cut rate | under 5 shots per 10 s without a planned hold |
    | Text | a prop word is misspelt or longer than 3 words |
    | Captions | they lag the voice or sit in a UI zone |
    | Sound | dead air over 1 s, or loudness off target |
    | Facts | any true-story line without a source |
    | Look | it would pass for a reference channel's work (the "500 others" and style-not-theft test) |
    Then `qa-panel` with `rubrics/short-video.json`: three blind judges, median, vetoes (rights, fact, policy, AI tell) stand. Only a cut at or above the rubric bar goes to the owner.
11. **Deliver.** One 1080×1920 file with sound from frame 1, the caption file, `measure.md`, and the panel result. Offer an upscale or a title and description pass through `packaging`; never run paid steps unasked, never post.

## Never
Claim a pace or style ("fast", "snappy", "like channel X") without measured reference numbers · copy a channel's characters, look, scripts, logo, footage or music · bake captions into a generation · time-stretch the voice to fit · generate or retry on a paid tool without an approved row · clone any voice but the owner's own, with the owner's yes · ship a true-story claim without a source · show a cut that did not pass the panel.
