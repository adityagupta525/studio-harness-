#!/usr/bin/env python3
"""harness_context.py: UserPromptSubmit hook. Puts HARNESS MODE + the active run's gate and next action in
Claude's context on every prompt, so harness work cannot silently drop (Ashish, 6 Nov 2026). Never blocks;
any error exits 0 so the prompt still goes through. Stdlib only.
"""
import json, os, re, sys

HARNESS = os.path.expanduser('~/studio-harness')

def section(text, name):
    m = re.search(r'^## ' + name + r'\s*\n(.*?)(?=^## |\Z)', text, re.S | re.M)
    return ' '.join(m.group(1).split())[:400] if m else ''

def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        data = {}
    prompt = (data.get('prompt') or '').strip()
    if prompt.startswith('<task-notification>'):
        return
    run = ''
    try:
        run = open(os.path.join(HARNESS, 'ACTIVE_RUN'), encoding='utf-8').read().strip()
    except OSError:
        pass
    status = ''
    if run:
        try:
            status = open(os.path.join(HARNESS, run, 'STATUS.md'), encoding='utf-8').read()
        except OSError:
            status = ''
    lines = ['HARNESS MODE (mandatory, Ashish 6 Nov 2026: no work outside ~/studio-harness). Load the `studio-harness` skill and follow its loop.']
    if run and status:
        lines.append(f'Active run: ~/studio-harness/{run}')
        st = section(status, 'Status')
        nx = section(status, 'Next action')
        if st: lines.append('Gate: ' + st)
        if nx: lines.append('Next action: ' + nx)
        lines.append('Before ending the turn: log his words, update STATUS.md (updated date, gate, next action).')
    else:
        lines.append('No active run: open one with ~/studio-harness/scripts/harness-run.sh new <slug> before any work.')
    print(json.dumps({'hookSpecificOutput': {'hookEventName': 'UserPromptSubmit', 'additionalContext': '\n'.join(lines)}}, ensure_ascii=False))

if __name__ == '__main__':
    try:
        main()
    except Exception:
        sys.exit(0)
