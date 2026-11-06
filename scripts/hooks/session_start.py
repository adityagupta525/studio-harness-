#!/usr/bin/env python3
"""session_start.py: SessionStart hook (startup, resume, clear, compact). Loads the operating contract summary,
the owner profile, the active run and a capability probe into context, so the harness is on without any slash
command. Creates the workspace on first use. Never blocks; any error exits 0. Stdlib only.
"""
import json, os, shutil, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _ws

TOOLS = ('yt-dlp', 'ffmpeg', 'ffprobe', 'node', 'npx', 'blender', 'git', 'gh')
KEYS = ('YOUTUBE_API_KEY', 'CLAUDE_PLUGIN_OPTION_YOUTUBE_API_KEY')

def probe():
    have = [t for t in TOOLS if shutil.which(t)]
    miss = [t for t in TOOLS if t not in have]
    if os.path.isdir('/Applications/Blender.app') and 'blender' not in have:
        have.append('Blender.app'); miss.remove('blender')
    yt = any(os.environ.get(k) for k in KEYS)
    return (f"Tools on this machine: {', '.join(have) or 'none'}; missing: {', '.join(miss) or 'none'}. "
            f"YouTube Data API key: {'set' if yt else 'not set (public data via yt-dlp only)'}. "
            'Connectors and MCP servers belong to the account: test one before promising it.')

def main():
    ws = _ws.workspace()
    _ws.ensure(ws)
    prof = _ws.read(os.path.join(ws, 'profile.md'))
    owner = _ws.field(prof, 'owner')
    lang = _ws.field(prof, 'reply_language') or 'the language the owner writes in'
    packs = _ws.field(prof, 'private_packs')
    run, status = _ws.active_run(ws)
    out = [
        'Studio Harness (plugin) is active. It runs every creative, channel or growth job like an agency: '
        'one director thread, departments with an owner and a monitor per task, gates, blind critics, mechanical checks, logged decisions.',
        f'Workspace: {ws} (profile.md, runs/, channels/, memory/, taste/). Owner: {owner or "not set"}. Replies: {lang}, short, answer first, tables.',
        'The loop: brief -> research with real evidence -> 3 divergent routes -> blind critic panel -> owner pick -> build -> QA checks -> approval -> closeout -> memory. '
        'Plan before build: PLAN.md and the owner\'s yes in approvals.csv come before any generation. Paid tools, publishing, account connections and deletions need the owner\'s yes each time.',
        "Decisions that belong to the owner (brand, money, publishing, licences, accounts) are asked, never assumed. The owner's exact words go to decision-log.md and taste/picks.jsonl when they reply.",
        probe(),
    ]
    if not owner:
        out.append(f'First run: profile.md is not filled. Before the first job, ask the owner for name, reply language, studio or channel name and channels, and write them into {ws}/profile.md.')
    if packs:
        out.append(f'Private packs on top of the harness: {packs} (read their map files when a job needs them).')
    if run:
        out.append(f'Active run: {os.path.join(ws, run)} | Gate: {_ws.section(status, "Status", 300)} | Next action: {_ws.section(status, "Next action", 300)}')
    else:
        out.append('No active run. A job starts with `studio-harness new <slug>` (bin on PATH) or skill `operating-loop`.')
    print(json.dumps({'hookSpecificOutput': {'hookEventName': 'SessionStart', 'additionalContext': '\n'.join(out)[:9000]}}, ensure_ascii=False))

if __name__ == '__main__':
    try:
        main()
    except Exception:
        sys.exit(0)
