#!/usr/bin/env python3
"""harness_context.py: UserPromptSubmit hook. Adds the active run's gate and next action to the context on
every prompt, so the loop cannot silently drop. Never blocks; any error exits 0. Stdlib only.
"""
import json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _ws

def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        data = {}
    if (data.get('prompt') or '').lstrip().startswith('<task-notification>'):
        return
    ws = _ws.workspace()
    run, status = _ws.active_run(ws)
    lines = ['Studio Harness is on: this task runs inside a harness run (skill `operating-loop`).']
    if run:
        lines.append(f'Active run: {os.path.join(ws, run)}')
        for label, sec in (('Gate', 'Status'), ('Next action', 'Next action')):
            v = _ws.section(status, sec)
            if v:
                lines.append(f'{label}: {v}')
        lines.append('A turn that changes run files ends with STATUS.md updated (updated date, gate, next action) and the owner\'s words logged.')
    else:
        lines.append('No active run. New job: `studio-harness new <slug>`; continuing one: `studio-harness use <run>`. A quick question needs no run.')
    print(json.dumps({'hookSpecificOutput': {'hookEventName': 'UserPromptSubmit', 'additionalContext': '\n'.join(lines)}}, ensure_ascii=False))

if __name__ == '__main__':
    try:
        main()
    except Exception:
        sys.exit(0)
