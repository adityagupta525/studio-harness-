#!/usr/bin/env python3
"""check-brand-assets.py: ban-list lint for a brand run (brand-identity B5).

usage: check-brand-assets.py RUN_DIR
Reads RUN_DIR/ban-list.txt (one term per line; '#' comments; 'term => reason' allowed) and scans every prompt,
route and spec text in the run (*.md, *.txt, *.json, *.html, file names), except brand-core.md, ban-list.txt,
decision-log.md, brief.md and research/ (where the owner's words and evidence may quote banned terms).
Exit 1 with a fix message per hit. Stdlib only.
"""
import os, re, sys

EXEMPT = {'brand-core.md', 'ban-list.txt', 'decision-log.md', 'brief.md', 'PLAN.md', 'STATUS.md', 'approvals.csv', 'sources.csv'}

def main():
    run = sys.argv[1]
    rules = []
    for line in open(os.path.join(run, 'ban-list.txt'), encoding='utf-8'):
        line = line.split('#', 1)[0].strip()
        if not line: continue
        term, _, why = line.partition('=>')
        rules.append((term.strip().lower(), why.strip() or 'banned in brand-core.md'))
    hits = []
    for d, dirs, files in os.walk(run):
        dirs[:] = [x for x in dirs if x not in ('research', 'img', '.git')]
        for f in files:
            p = os.path.join(d, f); rel = os.path.relpath(p, run)
            for term, why in rules:
                if term in f.lower(): hits.append(f'{rel}: file name has "{term}" ({why})')
            if f in EXEMPT or not f.endswith(('.md', '.txt', '.json', '.html')): continue
            text = open(p, encoding='utf-8', errors='ignore').read().lower()
            for term, why in rules:
                for m in re.finditer(r'(?<![a-z])' + re.escape(term) + r'(?![a-z])', text):
                    if re.search(r'\b(no|not|never|avoid|without)\b[\s\w/,-]{0,28}$', text[max(0, m.start() - 40):m.start()]):
                        continue  # a negative rule ("no blue, no magenta/pink") is allowed
                    ln = text.count('\n', 0, m.start()) + 1
                    hits.append(f'{rel}:{ln}: "{term}" → remove it ({why})')
    for h in hits: print('FAIL', h)
    print('PASS' if not hits else f'{len(hits)} FAIL')
    sys.exit(1 if hits else 0)

if __name__ == '__main__':
    main()
