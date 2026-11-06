#!/usr/bin/env python3
"""knowledge.py: knowledge cards in the workspace (knowledge-ingester, memory-curator; P5).

usage: knowledge.py check | index | expire | use CARD_ID RUN_ID | promote | search TERMS... [--workspace DIR]
Cards live in <workspace>/memory/knowledge/cards/<domain>/<id>.md (template: templates/knowledge-card.md).
check    validate every card (fields, tag, URL, dates); exit 1 with a fix message per problem
index    write <workspace>/memory/knowledge/INDEX.md grouped by domain (fresh first)
expire   set status: expired on cards past their expires date (they stay; re-read the source to renew)
use      record that a run relied on a card (used_in); runs cite card ids in their sources
promote  list fresh cards used in >= 2 different runs: candidates for a rule, check or skill change (owner yes)
search   case-insensitive search over claims and evidence
Default expiry when writing a card: 30 days for platforms/youtube/instagram/monetization/ai-models, 90 for tools/3d/
agents, 365 for craft (motion, animation, brand, design, packaging, strategy). Stdlib only.
"""
import datetime as dt, glob, os, re, sys

DOMAINS = {'platforms', 'youtube', 'instagram', 'monetization', 'packaging', 'strategy', '3d', 'motion', 'animation', 'ai-models', 'ai-film', 'brand', 'design', 'tools', 'agents', 'creator-economy'}
POLICY = {d: 30 for d in ('platforms', 'youtube', 'instagram', 'monetization', 'ai-models', 'ai-film', 'creator-economy')}
POLICY.update({d: 90 for d in ('tools', '3d', 'agents')}); POLICY.update({d: 365 for d in ('motion', 'animation', 'brand', 'design', 'packaging', 'strategy')})
FIELDS = ['id', 'domain', 'claim', 'tag', 'source', 'source_tier', 'seen', 'expires', 'status', 'used_in']

def ws(a):
    if '--workspace' in a: return os.path.expanduser(a[a.index('--workspace') + 1])
    for k in ('CLAUDE_PLUGIN_OPTION_WORKSPACE_DIR', 'STUDIO_HARNESS_WORKSPACE'):
        if os.environ.get(k): return os.path.expanduser(os.environ[k])
    return os.path.expanduser('~/StudioHarness')

def load(path):
    t = open(path, encoding='utf-8').read()
    m = re.match(r'---\n(.*?)\n---\n?(.*)', t, re.S)
    meta = {}
    for ln in (m.group(1).splitlines() if m else []):
        k, _, v = ln.partition(':')
        meta[k.strip()] = v.strip()
    meta['_body'] = m.group(2) if m else t
    meta['_path'] = path
    return meta

def save(c):
    head = '\n'.join(f'{k}: {c.get(k, "")}' for k in FIELDS)
    open(c['_path'], 'w', encoding='utf-8').write(f'---\n{head}\n---\n{c["_body"]}')

def cards(kd):
    return [load(p) for p in sorted(glob.glob(os.path.join(kd, 'cards', '*', '*.md')))]

def used(c):
    return [x.strip() for x in c.get('used_in', '').strip('[]').split(',') if x.strip()]

def main():
    a = sys.argv[1:]
    if not a: print(__doc__); sys.exit(2)
    kd = os.path.join(ws(a), 'memory', 'knowledge'); os.makedirs(os.path.join(kd, 'cards'), exist_ok=True)
    cs, cmd, today = cards(kd), a[0], dt.date.today()
    if cmd == 'check':
        bad = []
        for c in cs:
            n = os.path.relpath(c['_path'], kd)
            for f in FIELDS:
                if f not in c: bad.append(f'{n}: missing "{f}"')
            if c.get('tag') not in ('V', 'W', 'U'): bad.append(f'{n}: tag must be V, W or U')
            if not c.get('source', '').startswith('http'): bad.append(f'{n}: source must be a full URL')
            if c.get('status') not in ('fresh', 'expired', 'promoted', 'rejected'): bad.append(f'{n}: status must be fresh/expired/promoted/rejected')
            if c.get('domain') not in DOMAINS: bad.append(f'{n}: domain must be one of the template list')
            if c.get('source_tier') not in ('1', '2', '3'): bad.append(f'{n}: source_tier must be 1, 2 or 3')
            try:
                se, ex = dt.date.fromisoformat(c.get('seen', '')), dt.date.fromisoformat(c.get('expires', ''))
                if ex < se: bad.append(f'{n}: expires is before seen')
                if (ex - se).days > POLICY.get(c.get('domain'), 30): bad.append(f'{n}: expiry longer than the {POLICY.get(c.get("domain"), 30)}-day policy for {c.get("domain")}')
                if c.get('status') == 'fresh' and ex < today: bad.append(f'{n}: past expiry but still fresh -> run knowledge.py expire, or re-read the source and renew')
            except ValueError:
                bad.append(f'{n}: seen and expires must be YYYY-MM-DD')
            if os.path.basename(c['_path'])[:-3] != c.get('id'): bad.append(f'{n}: file name must equal id')
            if not all(k in c['_body'] for k in ('**Evidence:**', '**Changes how we work:**', '**Contradicts:**')): bad.append(f'{n}: body needs Evidence, Changes how we work and Contradicts')
        for b in bad: print('FAIL', b)
        print(f'{len(cs)} card(s): ' + ('PASS' if not bad else f'{len(bad)} FAIL')); sys.exit(1 if bad else 0)
    if cmd == 'expire':
        n = 0
        for c in cs:
            if c.get('status') == 'fresh' and c.get('expires', '9999') < today.isoformat():
                c['status'] = 'expired'; save(c); n += 1
        print(f'{n} card(s) expired')
    elif cmd == 'use':
        cid, run = a[1], a[2]
        for c in cs:
            if c.get('id') == cid:
                u = used(c)
                if run not in u: u.append(run)
                c['used_in'] = '[' + ', '.join(u) + ']'; save(c); print(f'{cid}: used_in {c["used_in"]}'); break
        else:
            print(f'no card {cid}'); sys.exit(1)
    elif cmd == 'promote':
        cand = [c for c in cs if c.get('status') == 'fresh' and len(set(used(c))) >= 2]
        for c in cand: print(f"{c['id']} ({c['domain']}): {c['claim']} — used in {', '.join(used(c))}")
        print(f'{len(cand)} promotion candidate(s): memory-curator proposes the rule/check/skill change; the owner says yes')
    elif cmd == 'search':
        q = [t.lower() for t in (a[1:a.index('--workspace')] + a[a.index('--workspace') + 2:] if '--workspace' in a else a[1:]) if not t.startswith('--')]
        for c in cs:
            txt = (c.get('claim', '') + c['_body']).lower()
            if all(t in txt for t in q): print(f"{c['id']} [{c['tag']}, {c['status']}, seen {c['seen']}] {c['claim']} — {c['source']}")
    elif cmd == 'index':
        dom = {}
        for c in cs: dom.setdefault(c.get('domain', '?'), []).append(c)
        L = [f'# Knowledge index ({today})', '', f'{len(cs)} card(s). Fresh cards may be quoted with their tag; expired cards must be re-read at the source first.', '']
        for d in sorted(dom):
            L += [f'## {d}', '', '| Card | Claim | Tag | Seen | Expires | Status | Used in |', '|---|---|---|---|---|---|---|']
            for c in sorted(sorted(dom[d], key=lambda c: c.get('seen', ''), reverse=True), key=lambda c: c.get('status') != 'fresh'):
                cl = c['claim'][:110].replace('|', '/').replace('[', '(').replace(']', ')')
                L.append(f"| {c['id']} | [{cl}]({c['source']}) | {c['tag']} | {c['seen']} | {c['expires']} | {c['status']} | {len(used(c))} |")
            L.append('')
        open(os.path.join(kd, 'INDEX.md'), 'w', encoding='utf-8').write('\n'.join(L))
        print(f'index: {len(cs)} card(s), {len(dom)} domain(s) -> {os.path.join(kd, "INDEX.md")}')
    else:
        print(__doc__); sys.exit(2)

if __name__ == '__main__':
    main()
