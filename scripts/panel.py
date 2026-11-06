#!/usr/bin/env python3
"""panel.py: aggregate a blind QA panel (qa-chief, P4 consistency).

usage: panel.py PANEL_DIR [--rubrics DIR]
PANEL_DIR holds judge-*.json files for ONE item (schema: agents/panel-judge.md). Validates every file, then per
criterion takes the median score and the spread (max - min); the weighted score is the weight-averaged medians
(1-5) and the same on 0-100. Re-judge is required when any criterion spreads more than 1 point or the weighted
scores of the judges spread more than 0.75. Any veto with evidence stands (qa-chief may only overturn it in
writing). Verdict: PASS (score >= rubric bar, no veto, no re-judge), BELOW_BAR, VETO or REJUDGE.
Writes PANEL_DIR/panel.json and panel.md. Exit 0 PASS, 1 not passing, 2 invalid input. Stdlib only.
"""
import glob, json, os, statistics as st, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def load(panel, rdir):
    files = sorted(glob.glob(os.path.join(panel, 'judge-*.json')))
    errs, js = [], []
    for f in files:
        try:
            js.append((os.path.basename(f), json.load(open(f, encoding='utf-8'))))
        except ValueError as e:
            errs.append(f'{os.path.basename(f)}: not JSON ({e})')
    if len(js) < 3:
        errs.append(f'{len(js)} judge file(s): a panel needs 3 independent judges')
    rid = {j.get('rubric') for _, j in js}
    if len(rid) != 1:
        errs.append(f'judges used different rubrics: {sorted(map(str, rid))}')
        return None, js, errs
    r = json.load(open(os.path.join(rdir, f'{rid.pop()}.json'), encoding='utf-8'))
    crit = {c['id']: c for c in r['criteria']}
    vids = {v.split(':')[0].strip() for v in r.get('vetoes', [])}
    for name, j in js:
        sc = j.get('scores', {})
        for cid in crit:
            s = sc.get(cid)
            if not s:
                errs.append(f'{name}: no score for "{cid}" -> score every criterion'); continue
            if not isinstance(s.get('score'), int) or not 1 <= s['score'] <= 5:
                errs.append(f'{name}: "{cid}" score must be an integer 1-5')
            if not str(s.get('anchor', '')).strip() or len(str(s.get('evidence', '')).strip()) < 10:
                errs.append(f'{name}: "{cid}" needs the anchor cited and concrete evidence (>= 10 chars)')
        for v in j.get('vetoes', []):
            if v.get('id') not in vids or len(str(v.get('evidence', ''))) < 10:
                errs.append(f'{name}: veto "{v.get("id")}" is not a rubric veto id or has no evidence')
    return r, js, errs

def wscore(r, scores):
    tw = sum(c['weight'] for c in r['criteria'])
    return sum(c['weight'] * scores[c['id']] for c in r['criteria']) / tw

def main():
    a = sys.argv[1:]
    if not a:
        print(__doc__); sys.exit(2)
    panel = a[0]
    rdir = a[a.index('--rubrics') + 1] if '--rubrics' in a else os.path.join(ROOT, 'rubrics')
    r, js, errs = load(panel, rdir)
    if errs:
        for e in errs: print('INVALID', e)
        sys.exit(2)
    per = {}
    for c in r['criteria']:
        v = [j['scores'][c['id']]['score'] for _, j in js]
        per[c['id']] = {'scores': v, 'median': st.median(v), 'spread': max(v) - min(v)}
    med = wscore(r, {k: x['median'] for k, x in per.items()})
    judge_tot = [wscore(r, {k: j['scores'][k]['score'] for k in per}) for _, j in js]
    vetoes = [(n, v['id'], v['evidence']) for n, j in js for v in j.get('vetoes', [])]
    rejudge = [k for k, x in per.items() if x['spread'] > 1] + (['total'] if max(judge_tot) - min(judge_tot) > 0.75 else [])
    verdict = 'VETO' if vetoes else 'REJUDGE' if rejudge else 'PASS' if med >= r['bar'] else 'BELOW_BAR'
    out = {'item': js[0][1].get('item'), 'rubric': r['id'], 'rubric_version': r['version'], 'bar': r['bar'],
           'score': round(med, 2), 'score_100': round((med - 1) / 4 * 100), 'judge_totals': [round(x, 2) for x in judge_tot],
           'criteria': per, 'vetoes': vetoes, 'rejudge_on': rejudge, 'verdict': verdict}
    json.dump(out, open(os.path.join(panel, 'panel.json'), 'w'), indent=1, ensure_ascii=False)
    L = [f"# Panel: {out['item']} · rubric {r['id']} v{r['version']} · bar {r['bar']}", '',
         f"**{verdict}** · score {out['score']}/5 ({out['score_100']}/100) · judges {out['judge_totals']}", '',
         '| Criterion | Weight | Scores | Median | Spread |', '|---|---|---|---|---|']
    L += [f"| {c['name']} | {c['weight']} | {per[c['id']]['scores']} | {per[c['id']]['median']} | {per[c['id']]['spread']}{' ⚠' if per[c['id']]['spread'] > 1 else ''} |" for c in r['criteria']]
    if vetoes: L += ['', '## Vetoes (stand unless qa-chief overturns in writing)'] + [f'- {n}: {i}: {e}' for n, i, e in vetoes]
    if rejudge: L += ['', f"## Re-judge required on: {', '.join(rejudge)} (fresh blind judges for those criteria; log both rounds)"]
    open(os.path.join(panel, 'panel.md'), 'w', encoding='utf-8').write('\n'.join(L) + '\n')
    print('\n'.join(L[:3]))
    sys.exit(0 if verdict == 'PASS' else 1)

if __name__ == '__main__':
    main()
