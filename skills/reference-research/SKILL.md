---
name: reference-research
description: The evidence gate before any look, style, STYLE_ANCHOR or generation - at least 8 real references (stills and video) actually examined, saved with full URLs, tagged real / AI-made / unknown with a rights class, measured (video with scripts/video-measure.py, stills with a contact sheet and a measured palette), then a references index, a DNA card (keep / swap / never) and a draft style anchor that passes the "500 others" test. Use before routes, before any image or video prompt, for "references dhundho", "moodboard", "iska look decode karo", "is style me banana hai", "iska DNA nikalo", or whenever someone describes a look nobody has measured.
---
# reference-research

Owner: reference-forensics (Intelligence; chief intel-chief). Monitor: qa-chief (counts, provenance and rights checked before the anchor is used). Gates: G2, G3. It is the detailed procedure behind step 5 of `research-pack`; the look itself is locked later by art-director.

Output lives in the run: media in `runs/<run-id>/refs/` (git-ignored, analysis-only), rows in `sources.csv`, and `look/references.md` (index), `look/dna.md` (DNA card), `look/STYLE_ANCHOR.draft.md` (draft anchor).

## Steps
1. **Frame the look question.** From `brief.md`: medium, platform and aspect, the brand or client system the look must serve, and the axes still open (palette, capture or medium, light, composition device, pacing, concept). Read `taste/picks.jsonl` and any locked brand tokens first: a project's own design system outranks every reference.
2. **Collect wide, primary first.** Aim for 12+ candidates so 8 survive: film and series stills, award-winning work, museum and archive collections, real campaigns, the platform's own top posts in the lane, then aggregators (Pinterest, Behance, Dribbble) used to find a look and then traced to its origin. Mix stills and video when the deliverable moves. Public pages only; no login, paywall or captcha.
3. **Save and log every one.** Download into `runs/<run-id>/refs/<slug>/` (video: `yt-dlp` on public URLs; stills: the largest public size). One row per reference in `sources.csv` with the full URL (never a bare ID or handle), date accessed, access method, `origin_tag` = `real` / `AI-made` / `unknown` (reason in `notes`: AI tells seen, gallery label, traced origin), and `rights_class`: `analysis-only` unless the asset is `own`, `licensed` or `public-domain` with proof. A download that fails is listed in "Could not examine" with the error, never counted.
4. **Examine video.** `python3 scripts/video-measure.py <file> runs/<run-id>/refs/<slug>/measure` (add an auto-caption `.vtt` beside the file with `yt-dlp --write-auto-subs --sub-langs en` for words per second). Read `contact-sheet.jpg` and `measure.md` before writing a word. Report both thresholds and say which one an average shot length came from; for a doubtful stretch pull every frame of that window (`ffmpeg -ss A -to B -i <file> -vf fps=8,scale=360:-2,tile=6x4 window.jpg`) and look.
5. **Examine stills.** One contact sheet per set, then measure the 3-5 references the look will stand on:
   - sheet: `ffmpeg -pattern_type glob -i 'refs/<slug>/*.jpg' -vf "scale=300:300:force_original_aspect_ratio=decrease,pad=300:300:(ow-iw)/2:(oh-ih)/2:color=gray,tile=4x3:padding=4" -frames:v 1 sheet.jpg` (convert PNG/WebP to JPG first so the glob is one format)
   - palette with area share (ffmpeg + standard-library Python; 3 bits per channel buckets):
     `ffmpeg -v error -i IMG -vf scale=64:64:flags=area -f rawvideo -pix_fmt rgb24 - | python3 -c "import sys,collections as c;b=sys.stdin.buffer.read();px=[tuple(x//32*32+16 for x in b[i:i+3]) for i in range(0,len(b),3)];n=len(px);[print('#%02x%02x%02x'%k,f'{100*v//n}%') for k,v in c.Counter(px).most_common(6)]"`
   - key and saturation: `ffmpeg -v error -i IMG -vf "signalstats,metadata=print:file=-" -f null - | grep -E "YLOW|YAVG|YHIGH|SATAVG"` (low YAVG = low key; YHIGH-YLOW = contrast spread)
   - an alternative palette is `palettegen=max_colors=8` written to PNG and read back as rgb24; any number without a command beside it is labelled `estimate`.
6. **Write what each reference supplies.** In `look/references.md`, one row per reference: R#, full URL, real / AI-made / unknown, rights class, what it contributes (light, palette, composition, texture, type, pacing, camera), the measured values with their command, and keep / swap / never. Head the file with the honest count: "n of 8 reached; real x / AI-made y / unknown z". AI-made references never count as evidence of how real work looks; if most of the set is AI-made, say so.
7. **DNA card.** `look/dna.md`: palette roles in hex with area %, key and contrast, light (direction, hardness, shadow colour), composition devices, texture and grain, type if any, pacing for video (shots per 10 s, ASL at a named threshold, cuts in the first 3 s, words per second), and **the 2-3 choices that, if dropped, make it generic**. Then a transfer matrix: keep (structure, rhythm, technique), swap (values that come from our brand system), never (a creator's footage, frames, characters, signature look, logo, scripts, music).
8. **Draft the style anchor.** `look/STYLE_ANCHOR.draft.md`: every token traced to an R# or a measured number; palette and type values from the project's own system where one exists. Below 8 references it is headed `draft, n/8 refs` and cannot pass G3.
9. **"500 others" test.** Picture the anchor executed by a competent stranger: would it sit unnoticed among 500 posts in the same feed? Name the nearest cliché (stock teal-orange, glossy default CG, centred hero on gradient, and so on). If the 2-3 defining choices do not lift it clear, swap one axis and re-run steps 7-9. Record pass or fail with the reason.
10. **Check and hand off.** `scripts/check-source-ledger.sh runs/<run-id>/sources.csv` exits 0; qa-chief confirms the count, the tags and that no `analysis-only` file is listed as model input in `rights.csv`. Hand off with the reference-forensics block, naming what could not be fetched or examined.

## Outputs
`look/references.md` (index with the honest count), `look/dna.md` (DNA card with keep / swap / never), `look/STYLE_ANCHOR.draft.md`, `sources.csv` rows, measure folders and contact sheets under `refs/` (git-ignored).

## Verification
Every reference was opened and its frames or sheet read, not only downloaded; every number has its command; the count is reported as "n of 8" with the real / AI-made / unknown split; "Could not examine" lists each failed fetch, blocked site, missing caption track or unmeasured file.

## Never
Describe a still or video nobody examined (a title, URL, thumbnail or caption is not analysis) · pad the count with AI-made or duplicate references · write a numeric claim without its command · feed an `analysis-only` reference to a generation model or ship it · turn one creator's signature look into the anchor · get past a login, paywall or captcha · pass G3 below 8 real references.
