# 05 — Verification and QA

**Evidence over assertion.** Never describe media you have not examined. "Fast cutting" is a guess; "7 shots in 11.35 s, average 1.62 s" is a finding. Summarising from a title, URL or metadata is not analysis. If an artifact cannot be pulled, say so instead of guessing.

## Claim classes
Adopted from `~/creative-os/standards/evidence-protocol.md`; full table in [06](06-source-rights-and-licensing.md).
`OBSERVED` · `MEASURED` · `SOURCE-VERIFIED` · `PUBLICLY-DOCUMENTED` · `OWNER-STATED` · `INFERRED` · `RECOMMENDED` · `UNKNOWN`. One class per claim. Eyeballed numbers are estimates, never `MEASURED`. Confidence is High / Medium / Low, never a percentage without a statistical basis.

## Verification ladder (strongest first)
1. **A script or tool measured it** (checker exit code, `ffprobe` number, palette script). Record the command.
2. **A different agent reviewed it** against a written criterion (independent QA).
3. **The producer checked it** against the spec. Allowed, but never enough for G8.
4. **Not verified.** Say so in the report.

## What gets checked, and by what
| Check | Method | When |
|---|---|---|
| Harness integrity | `scripts/validate-harness.sh` | before closing any harness change |
| Source ledger | `scripts/check-source-ledger.sh` | G2; every time `sources.csv` changes |
| Run completeness, approvals, rights, shot specs | `scripts/check-run-completeness.sh` | every gate |
| References really examined | frames viewed, measurement command logged (`~/creative-os/tools/run.sh palette.py`, `dna_measure.py`, `grid.py`) | G3 |
| Route divergence | axis table in `routes.md`: any two routes share at most one position | G4 |
| Continuity | per-shot checklist in each `shots/Sxx.md` | G7 |
| Technical delivery | commands below | G8 |
| Craft against the charter bar | blind read plus AI-tell list (creative-os `creative-critic`, `critic-judge`) | G8 |
| Rights | every asset has a row; nothing `analysis-only` is delivered or fed to a model | G7, G8, G9 |

## Technical delivery checks (documented, run when media exists)
Replace `FILE` with the delivered file. These read the file and write nothing next to it.

```bash
# container, codecs, resolution, frame rate, duration
ffprobe -v error -show_entries format=duration,size:stream=codec_name,width,height,r_frame_rate,sample_rate,channels -of default=nw=1 FILE

# integrated loudness and true peak (read-only analysis, no output file)
ffmpeg -hide_banner -nostats -i FILE -af ebur128=peak=true -f null - 2>&1 | tail -n 14

# a contact sheet of 16 evenly spaced frames for continuity review
ffmpeg -hide_banner -i FILE -vf "fps=1/2,scale=320:-1,tile=4x4" -frames:v 1 contact-sheet.png
```
Targets (loudness, ratio, length) come from the platform's current official page, recorded with the date seen, or from the brief. Do not hard-code them from memory. `[TO VERIFY]` until read.

## Independence
- The QA reviewer is a different agent run from the producer. `qa-report.md` names both.
- A producer's own check is recorded under Verification but never satisfies G8.
- QA may veto delivery on rights or technical failure. It does not decide creative direction; that stays with Ashish.

## Pass / fail
`qa-report.md` starts with one line: `result: PASS`, `result: FAIL` or `result: NOT RUN`. A run cannot be `complete` without `PASS`. A FAIL lists each failure with the shot or file, and the run returns to the gate that can fix it.

## Report honesty
- Name what you skipped: failed download, rate limit, missing transcript, unverified claim, credit not spent.
- Do not claim a tool or integration works unless a read-only call passed in this session.
- Do not write a performance number without a source id and a method.
