---
run_id: 2026-11-04-demo-fictional-harness-proof
context: demo
practice: film
status: demo
director: Ashish
created: 2026-11-04
updated: 2026-11-04
---
# STATUS — FICTIONAL DEMO: "The Lamp Between Tides"

**FICTIONAL. No client, no real sources, no performance claims, no external assets, no media, no account actions, no paid work.** It exists only to prove that the harness structure and its checks work. It must not be used as precedent, and it does not count toward memory promotion.

## Status
Demo. Stopped at G4: three routes drafted ([routes.md](routes.md)); blind scores not run; no human pick exists (a demo has no human decision), so no treatment was written.

## Deliverables
brief.md, routes.md, decision-log.md, shots/S01.md and shots/S02.md (draft, schema illustrations only), qa-report.md (NOT RUN), plus empty-by-design sources.csv, rights.csv and approvals.csv.

## Evidence
None. sources.csv holds one `[TO VERIFY]` placeholder row, not a source. Zero real references were examined, so the 8-real-references rule (G3) is deliberately **not met** and the demo cannot pass G3.

## Verification
`scripts/check-run-completeness.sh` and `scripts/check-source-ledger.sh` were run against this folder at build time and must pass for a demo. Not verified: every creative claim (nothing was reviewed), every cost, every tool.

## Risks
A demo can be mistaken for a real project: the `demo` context and the FICTIONAL stamp guard against it. Shot specs are drafted from Route A as a stand-in for a pick that a human never made; they illustrate the schema only. Everything unknown is `[TO VERIFY]`.

## Next action
None for this demo. Start the first real project with `cp -R runs/_template runs/$(date +%F)-<slug>` and delete or archive this folder when it is no longer useful.
