# 06 — Source, rights and licensing

Vocabulary is adopted from `~/creative-os/standards/evidence-protocol.md`. Four tags answer four different questions; do not merge them.

| Question | Tag set | Written in |
|---|---|---|
| What kind of claim is this? | claim class | reports, ledgers |
| How solid is an external fact? | `[V]` official page · `[W]` widely reported · `[U]` unverified, plus the date seen | replies and files |
| Who or what made this artefact? | `real` · `AI-made` · `unknown` | `sources.csv` |
| May it go into a deliverable? | `own` · `licensed` · `public-domain` · `analysis-only` (or `unknown`) | `sources.csv`, `rights.csv` |

## Claim classes
| Class | Means | Minimum pointer |
|---|---|---|
| `OBSERVED` | seen in an artefact we captured or he supplied | file and region, frame or timecode |
| `MEASURED` | a number from a tool | tool, input, settings |
| `SOURCE-VERIFIED` | found in source, config, docs we can read | path and line, or selector |
| `PUBLICLY-DOCUMENTED` | stated by an attributable public source | full URL and date read |
| `OWNER-STATED` | Ashish or the client said it | date and exact words |
| `INFERRED` | reasoned from several signals | the signals and the strongest alternative |
| `RECOMMENDED` | our proposal | none; says nothing about the target |
| `UNKNOWN` | not established | what would establish it |

## Source ledger (`sources.csv`)
One row per source, with a **full URL** (never a bare ID or handle), the date accessed, the access method, the tags above, and, for any signal, the platform, geography, format, date or window, value, unit, item count and uncertainty. Header and rules are enforced by `scripts/check-source-ledger.sh`. Column list: `templates/source-ledger.csv`.

## Asset rights ledger (`rights.csv`)
One row per asset the project touches: references, client supplies, generated outputs, music, fonts, stock. Header: `templates/asset-rights-ledger.csv`. Enforced rules:
- **Model input** (anything fed to a generation model) must be `own`, `licensed` or `public-domain`, with `status: cleared`, a recorded `licence_decision` (`approved` or `not-needed`) and `licence_or_permission` filled.
- **`analysis-only`** references (third-party stills, footage, frames) may be studied for technique and nothing else: never model input, never delivered.
- **Delivered** assets must be `cleared`.
- An `approved` licence decision points to an approved `licence_decision` row in `approvals.csv`.

## Style, not theft
Take technique, structure, grade and pacing from references; build something new. Never reproduce a creator's footage, frames or signature look, and never present their work as ours. A reference is analysed; it is not copied. Downloaded references live in git-ignored `runs/<run-id>/refs/`; their full URLs live in `sources.csv`.

## Licensing is Ashish's call
Agents write `unknown` or `pending`, never `cleared`, until he records a licence decision. This includes music tracks (reuse of a specific track is flagged, not assumed), fonts, stock, talent, locations and generated-output terms of any tool. The studio does not add credit lines on its own initiative; credits and licence wording are decisions for him and his legal or compliance advisors. This harness gives no legal advice.

## AI-made references and outputs
An AI-made reference is labelled `AI-made` and is never counted as primary evidence of how real work looks. An AI-generated asset the studio produced is `own` only if the generating tool's terms allow it, which is a licence decision for Ashish; until then it is `unknown`.

## Public vs private
Only public content is accessed. Private accounts, stories, gated or DRM content are not accessed, and paywalls, captchas and member walls are never bypassed. If a source is blocked, the report says so and, per Ashish's standing OK in creative-os (19 Oct 2026), the live session may use his Chrome **read-only**, without following, posting or buying; this is not available to subagents or unattended runs.
