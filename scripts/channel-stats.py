#!/usr/bin/env python3
"""channel-stats.py: measured numbers for a Channel Dossier, from channel-pull.py output. No estimates.

usage: channel-stats.py PULL_DIR
Writes PULL_DIR/stats.json and PULL_DIR/stats.md: per format (long / short) counts, median and quartile views
(newest 30, newest 100, all pulled), outliers against the trailing median of the next 30 older uploads (docs/14:
>= 2x with n >= 10, >= 3x strong), cadence and engagement from the detailed sample, duration spread, title
patterns, sponsor and link markers. Public view counts are rounded by YouTube for large numbers; say so. Views are lifetime totals: the newest uploads
are young, so 'newest 30' medians understate them; compare like-aged uploads before calling a trend.
"""
import csv, json, os, re, statistics as st, sys
from datetime import date

def q(v, p):
    v = sorted(v)
    return v[min(len(v) - 1, int(p * (len(v) - 1)))] if v else None

def n(x):
    try:
        return int(float(x))
    except (TypeError, ValueError):
        return None

def fmt(x):
    if x is None: return '—'
    return f'{x/1e6:.2f}M' if x >= 1e6 else f'{x/1e3:.1f}K' if x >= 1e3 else str(x)

def title_patterns(ts):
    ts = [t for t in ts if t]
    if not ts: return {}
    has = lambda rx: round(100 * sum(1 for t in ts if re.search(rx, t, re.I)) / len(ts))
    return {'n': len(ts), 'median_chars': st.median(len(t) for t in ts), 'median_words': st.median(len(t.split()) for t in ts),
            'pct_question': has(r'\?'), 'pct_number': has(r'\d'), 'pct_money': has(r'\$|₹|€|£|million|billion'),
            'pct_what_if_how_why': has(r'^(what if|how|why|what happens)'), 'pct_first_person': has(r'\b(I|my|me)\b'),
            'pct_superlative': has(r"\b(most|best|worst|biggest|deadliest|craziest|disturbing|creepiest)\b"),
            'pct_hashtag': has(r'#\w'), 'pct_emoji': has(r'[\U0001F300-\U0001FAFF\u2600-\u27BF]')}

def per_format(rows):
    rows = sorted(rows, key=lambda r: n(r['rank']))
    views = [n(r['views']) for r in rows]
    vv = [v for v in views if v is not None]
    out = {'pulled': len(rows), 'with_views': len(vv)}
    for k, w in (('newest_30', 30), ('newest_100', 100), ('all', len(vv))):
        s = [v for v in views[:w] if v is not None]
        out[k] = {'n': len(s), 'median': st.median(s) if s else None, 'p25': q(s, .25), 'p75': q(s, .75), 'max': max(s) if s else None}
    outl = []
    for i, r in enumerate(rows):
        v = views[i]
        trail = [x for x in views[i + 1:i + 31] if x is not None]
        if v is None or len(trail) < 10: continue
        m = st.median(trail)
        if m and v >= 2 * m:
            outl.append({'title': r['title'], 'url': r['url'], 'views': v, 'trailing_median': m, 'ratio': round(v / m, 2), 'n': len(trail), 'strong': v >= 3 * m, 'rank': i})
    out['outliers'] = sorted(outl, key=lambda o: -o['ratio'])
    durs = [n(r['duration']) for r in rows if n(r['duration'])]
    out['duration_s'] = {'median': st.median(durs) if durs else None, 'p25': q(durs, .25), 'p75': q(durs, .75)}
    det = [r for r in rows if r.get('detail') == 'ok' and r.get('upload_date')]
    if len(det) >= 2:
        ds = sorted(date(int(d[:4]), int(d[4:6]), int(d[6:])) for d in (r['upload_date'] for r in det))
        span = max(1, (ds[-1] - ds[0]).days)
        ok = len(ds) >= 10 and span >= 7  # fewer dated uploads or a shorter window gives artefacts (e.g. 14/wk from 3 uploads in a day)
        out['cadence'] = {'sample': len(det), 'first': ds[0].isoformat(), 'last': ds[-1].isoformat(),
                          'per_week': round(7 * (len(ds) - 1) / span, 2) if ok else 'insufficient sample (need >= 10 dated uploads over >= 7 days)'}
        lr = [n(r['likes']) / n(r['views']) for r in det if n(r['likes']) and n(r['views'])]
        cr = [n(r['comments']) / n(r['views']) for r in det if n(r['comments']) and n(r['views'])]
        out['engagement'] = {'like_rate_median_pct': round(100 * st.median(lr), 2) if lr else None, 'comment_rate_median_pct': round(100 * st.median(cr), 3) if cr else None}
        out['markers'] = {'sponsor': [(r['title'], r['sponsor_marker'], r['url']) for r in det if r.get('sponsor_marker')],
                          'link_domains': sorted({d for r in det for d in (r.get('link_domains') or '').split()}),
                          'chapters_pct': round(100 * sum(1 for r in det if n(r.get('chapters'))) / len(det)),
                          'tags_median': st.median([n(r.get('tags')) or 0 for r in det])}
    out['titles'] = title_patterns([r['title'] for r in rows[:100]])
    return out

def main():
    d = sys.argv[1]
    ch = json.load(open(os.path.join(d, 'channel.json')))
    rows = list(csv.DictReader(open(os.path.join(d, 'videos.csv'), encoding='utf-8')))
    S = {'channel': ch.get('channel'), 'pulled_at': ch.get('pulled_at'), 'subscribers_public': ch.get('channel_follower_count'),
         'formats': {f: per_format([r for r in rows if r['format'] == f]) for f in ('long', 'short')}}
    json.dump(S, open(os.path.join(d, 'stats.json'), 'w'), indent=1, ensure_ascii=False)
    L = [f"# Measured stats: {S['channel']} (pulled {S['pulled_at']}, method: {ch.get('method')})", '',
         f"Subscribers (public, rounded): {fmt(S['subscribers_public'])}. View counts are YouTube's public figures at pull time; large numbers are rounded on the page. Views are lifetime totals, so the newest uploads (young) read low; outliers use the trailing median of older uploads.", '',
         '| Format | Pulled | Median views newest 30 | newest 100 | all | p25–p75 (all) | Max | Median length | Cadence (sample) | Like rate | Comment rate |', '|---|---|---|---|---|---|---|---|---|---|---|']
    for f, o in S['formats'].items():
        c, e = o.get('cadence', {}), o.get('engagement', {})
        L.append(f"| {f} | {o['pulled']} | {fmt(o['newest_30']['median'])} | {fmt(o['newest_100']['median'])} | {fmt(o['all']['median'])} | {fmt(o['all']['p25'])}–{fmt(o['all']['p75'])} | {fmt(o['all']['max'])} | {str(o['duration_s']['median']) + ' s' if o['duration_s']['median'] else '—'} | {c.get('per_week','—')}/wk ({c.get('sample','—')} uploads {c.get('first','')}→{c.get('last','')}) | {e.get('like_rate_median_pct','—')}% | {e.get('comment_rate_median_pct','—')}% |")
    for f, o in S['formats'].items():
        L += ['', f"## Outliers, {f} (>= 2x trailing median of next 30 older, n >= 10; ★ = >= 3x)", '', '| Title | Views | Trailing median | Ratio |', '|---|---|---|---|']
        L += [f"| {'★ ' if x['strong'] else ''}[{x['title']}]({x['url']}) | {fmt(x['views'])} | {fmt(x['trailing_median'])} | {x['ratio']}x |" for x in o['outliers'][:15]]
        if not o['outliers']: L.append('| none | | | |')
        t = o['titles']
        if t: L += ['', f"Titles ({f}, newest {t['n']}): median {t['median_words']} words / {t['median_chars']} chars; question {t['pct_question']}%, number {t['pct_number']}%, money {t['pct_money']}%, what-if/how/why {t['pct_what_if_how_why']}%, first person {t['pct_first_person']}%, superlative {t['pct_superlative']}%, hashtag {t['pct_hashtag']}%, emoji {t['pct_emoji']}%."]
        m = o.get('markers')
        if m: L += [f"Markers ({f}, detailed sample): sponsor mentions {len(m['sponsor'])}; link domains: {', '.join(m['link_domains']) or 'none'}; chapters on {m['chapters_pct']}%; median tags {m['tags_median']}."]
    open(os.path.join(d, 'stats.md'), 'w', encoding='utf-8').write('\n'.join(L) + '\n')
    print('\n'.join(L[:8]))

if __name__ == '__main__':
    main()
