#!/usr/bin/env python3
"""check-dossier.py: gate for a Channel Dossier (skill channel-dossier). Exit 1 with a fix message per problem.

usage: check-dossier.py DOSSIER.md
Checks: all required sections present and non-empty; >= 5 competitor URLs; every money figure in the monetization
section sits on a line that says estimate/range/method or carries an evidence tag; >= 8 full source URLs; a
pull date; 'Could not examine' not empty (write 'nothing' if truly nothing). Stdlib only.
"""
import re, sys

REQ = ['Snapshot', 'Biography and timeline', 'Formats and series', 'Performance', 'Packaging patterns', 'Competitor map',
       'Monetization and earning points', 'Risks', 'What to learn (style, not theft)', 'Sources', 'Could not examine']

def sec(t, name):
    m = re.search(r'^## ' + re.escape(name) + r'\s*\n(.*?)(?=^## |\Z)', t, re.S | re.M)
    return m.group(1).strip() if m else None

def main():
    t = open(sys.argv[1], encoding='utf-8').read()
    bad = []
    for s in REQ:
        body = sec(t, s)
        if body is None: bad.append(f'missing section "## {s}": add it (skill channel-dossier lists the order)')
        elif len(body) < 20: bad.append(f'section "## {s}" is empty: fill it or say why it cannot be filled')
    comp = sec(t, 'Competitor map') or ''
    nc = len(set(re.findall(r'https?://(?:www\.)?youtube\.com/[@\w./-]+', comp)))
    if nc < 5: bad.append(f'competitor map has {nc} channel URLs: need >= 5 full youtube.com URLs')
    money = sec(t, 'Monetization and earning points') or ''
    for ln in money.splitlines():
        if re.search(r'[$₹€£]\s?\d|\d\s?(k|K|M|million|lakh|crore)\b.*(per|/)\s?(month|year|video)', ln) and not re.search(r'estimate|range|method|\[(V|W|U)\]|RPM', ln, re.I):
            bad.append(f'money figure without method or tag: "{ln.strip()[:80]}" -> label it an estimate with method and range, or tag [V]/[W]/[U]')
    srcs = len(set(re.findall(r'https?://\S+', sec(t, 'Sources') or '')))
    if srcs < 8: bad.append(f'Sources has {srcs} URLs: need >= 8 full URLs')
    if not re.search(r'20\d\d-\d\d-\d\d', sec(t, 'Snapshot') or ''): bad.append('Snapshot has no pull date (YYYY-MM-DD)')
    for b in bad: print('FAIL', b)
    print('PASS' if not bad else f'{len(bad)} FAIL')
    sys.exit(1 if bad else 0)

if __name__ == '__main__':
    main()
