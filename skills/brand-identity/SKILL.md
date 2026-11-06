---
name: brand-identity
description: Procedure for a brand identity job in the harness (channel or studio brand: name lockup, logo, palette, DP, banner, kit). Agency structure with gates B0-B8, exactly 3 researched routes, mechanical checks and blind critics. Use for any logo, banner, DP, palette or brand-kit work.
---
# brand-identity

**Owner:** director · **Routes to:** brand-strategy, graphic-design, still-reference, scouting and critic skills and agents from a private pack listed in the workspace profile.md (if any); `impeccable` for layout polish; Figma on the owner's yes.
Born from a real channel-brand run (6 Nov 2026), where skipping these steps cost five rejected rounds.

## Steps

| Gate | Step | Exit criteria | Check |
|---|---|---|---|
| B0 | Plan | `PLAN.md` + the owner's yes row in `approvals.csv` | manual |
| B1 | Brief + brand core | `brief.md` with the owner's exact words; `brand-core.md` rules (dated, the owner's exact words), incl. a ban list; taste traits that apply | the owner's lock (`lock_brand_core`) |
| B2 | Research | `research/style-research.md`: ≥ 8 style families with primary sources; channel/media identity cases; logo precedents and similarity risks; banner craft; every source in `sources.csv` using the enum values in `scripts/check-source-ledger.sh` (agents' free-text labels failed 108 checks on 6 Nov) | `check-source-ledger.sh` |
| B3 | Palette lock | palette card measured from approved art (never invented); rules of use | the owner's lock (`lock_palette`) |
| B4 | Three routes | `routes.md` from `templates/creative-route.md`: vision line, 2-second story (first / second / third read), style family + ≥ 8 viewed refs, composition on the master ratio, recognition device; axis table, any two share ≤ 1 axis | qa reads axis table |
| B5 | Build | per route: master art (free model first), logo in SVG, type set in code (never generated), assembly in HTML/Figma, `impeccable` polish; files in `routes/<R>/` | `check-banner.py` with keep boxes **measured from the DOM** (headless Chrome `--dump-dom` of a page that writes `getBoundingClientRect` into `#boxes`; estimated boxes let a cut tagline pass on 6 Nov), `check-brand-assets.py` pass |
| B6 | QA gate | one blind critic per route (`panel-judge`, or a private pack's critic agent), one contrarian pass, a taste check against the taste ledger; scores in `qa-report.md` | ≥ 4.5, no veto |
| B7 | Show + pick | 3 routes + device check, one line each; the owner's exact words logged | `lock_route` |
| B8 | Kit + closeout | logo files (SVG/PNG, mono, reversed), banner upload + master, DP/avatar, palette, type, do/don't; `closeout.md` | `check-run-completeness.sh` |

## Platform facts (re-verify at use time)
YouTube banner: min 2048×1152, 16:9, safe area 1235×338 at min size (1544×423 at 2560 wide), recommended 2560×1440, ≤ 6 MB [V https://support.google.com/youtube/answer/10456525, 6 Nov 2026]. Compose wide masters (21:9) and place them in the 16:9 file; logo and hero inside the safe band.

## Never
Show more or fewer than the plan's routes · generate type or logos with an image model · reuse episode assets · use a colour outside the locked palette · present a route with a critic veto.
