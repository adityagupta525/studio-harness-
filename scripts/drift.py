#!/usr/bin/env python3
"""drift.py: does the judging panel still score like the gold set? (consistency-auditor, P4)

usage: drift.py CAL_RESULTS_DIR GOLD.json [--tol-criterion 0.6] [--tol-total 0.4]
CAL_RESULTS_DIR holds one sub-folder per calibration item (named as in gold.json) with that item's panel.json
(from scripts/panel.py). Reports per criterion the mean absolute error of the panel median against gold, the
weighted-score error per item, and the worst items. Exit 1 when any criterion MAE or the mean weighted error is
over tolerance (drift: fix the rubric anchors or the judge set before trusting new scores). Stdlib only.
"""
import json, os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def main():
    a = sys.argv[1:]
    if len(a) < 2:
        print(__doc__); sys.exit(2)
    res, gold = a[0], json.load(open(a[1]))
    tc = float(a[a.index('--tol-criterion') + 1]) if '--tol-criterion' in a else 0.6
    tt = float(a[a.index('--tol-total') + 1]) if '--tol-total' in a else 0.4
    r = json.load(open(os.path.join(ROOT, 'rubrics', gold['rubric'] + '.json')))
    w = {c['id']: c['weight'] for c in r['criteria']}; tw = sum(w.values())
    errs = {c: [] for c in w}; tot, missing, rows = [], [], []
    for item, g in gold['items'].items():
        p = os.path.join(res, item, 'panel.json')
        if not os.path.exists(p):
            missing.append(item); continue
        pj = json.load(open(p))
        for c in w:
            errs[c].append(abs(pj['criteria'][c]['median'] - g[c]))
        gt = sum(w[c] * g[c] for c in w) / tw
        tot.append(abs(pj['score'] - gt))
        rows.append((item, round(gt, 2), pj['score'], round(pj['score'] - gt, 2), pj['verdict']))
    if not rows:
        print('FAIL no panel.json found for any calibration item'); sys.exit(2)
    mae = {c: round(sum(v) / len(v), 2) for c, v in errs.items() if v}
    mt = round(sum(tot) / len(tot), 2)
    print(f"Calibration {gold['rubric']} v{gold['rubric_version']}: {len(rows)} item(s), missing {missing or 'none'}")
    print('| Item | Gold | Panel | Diff | Verdict |\n|---|---|---|---|---|')
    for x in rows: print('| ' + ' | '.join(map(str, x)) + ' |')
    print('Criterion MAE: ' + ', '.join(f'{c} {v}{" ⚠" if v > tc else ""}' for c, v in mae.items()))
    print(f'Mean weighted error: {mt} (tolerance {tt})')
    bad = [c for c, v in mae.items() if v > tc] + (['total'] if mt > tt else [])
    print('DRIFT on: ' + ', '.join(bad) if bad else 'PASS: panel within tolerance of gold')
    sys.exit(1 if bad else 0)

if __name__ == '__main__':
    main()
