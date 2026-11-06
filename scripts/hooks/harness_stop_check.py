#!/usr/bin/env python3
"""harness_stop_check.py: Stop hook. If files in the active run changed after STATUS.md was last updated,
ask Claude (once) to update STATUS.md and decision-log.md before ending the turn. Uses stop_hook_active to
avoid loops; any error exits 0. Stdlib only.
"""
import json, os, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _ws

SKIP = {'STATUS.md', 'decision-log.md', 'approvals.csv', '.DS_Store'}

def main():
    data = json.load(sys.stdin)
    if data.get('stop_hook_active'):
        return
    ws = _ws.workspace()
    run, _ = _ws.active_run(ws)
    if not run:
        return
    root = os.path.join(ws, run)
    st = os.path.getmtime(os.path.join(root, 'STATUS.md'))
    newest, path = 0, ''
    for d, _, files in os.walk(root):
        for f in files:
            if f in SKIP:
                continue
            p = os.path.join(d, f)
            m = os.path.getmtime(p)
            if m > newest:
                newest, path = m, p
    # 120 s grace: STATUS is usually written at the end of a batch of edits
    if newest - st > 120 and time.time() - newest < 6 * 3600:
        msg = (f'HARNESS: {os.path.relpath(path, root)} changed after STATUS.md was last updated. '
               f'Update {root}/STATUS.md (updated, gate, deliverables, next action) and log any decision '
               'in decision-log.md, then finish.')
        print(json.dumps({'decision': 'block', 'reason': msg}))

if __name__ == '__main__':
    try:
        main()
    except Exception:
        sys.exit(0)
