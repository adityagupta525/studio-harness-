# Evals

Regression cases built from real failures (P4). Run: `claude plugin eval ~/studio-harness --runs 1 -j 4 --max-cost-usd 2` (a no-plugin baseline arm runs too, so the report shows what the harness adds). Every new miss in a real run becomes a case here (eval-engineer). Calibration for score consistency lives in `calibration/` and runs through `scripts/drift.py`, not here.

## Baseline run, 2026-11-06 (1 run per arm, $1.40)
| Case | With harness | Without | Δ |
|---|---|---|---|
| plan-before-build | 1.00 | 0.00 | +1.00 |
| no-media-guessing | 1.00 | 1.00 | 0 |
| estimate-needs-method | 1.00 | 1.00 | 0 |
| paid-tool-asks | 1.00 | 1.00 | 0 |
Three cases do not discriminate yet (the bare model already passes them): eval-engineer must make them harder (longer jobs where the shortcut is tempting, tools available) before they count as regression guards. One run per arm is a smoke test, not a measurement; use `--runs 3` for releases.
