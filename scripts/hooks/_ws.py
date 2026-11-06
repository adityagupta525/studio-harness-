"""_ws.py: where the user's workspace lives, shared by the hooks and the CLI. Stdlib only.

Order: plugin userConfig (CLAUDE_PLUGIN_OPTION_WORKSPACE_DIR) > STUDIO_HARNESS_WORKSPACE > ~/StudioHarness.
The plugin itself is read-only system; everything personal (profile, runs, memory, taste) lives in the workspace.
"""
import os, re, shutil

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))  # plugin root

def workspace():
    for k in ('CLAUDE_PLUGIN_OPTION_WORKSPACE_DIR', 'STUDIO_HARNESS_WORKSPACE'):
        v = os.environ.get(k, '').strip()
        if v:
            return os.path.expanduser(v)
    return os.path.expanduser('~/StudioHarness')

def ensure(ws):
    """Create a minimal workspace on first use (profile from the template, empty stores)."""
    for d in ('runs', 'channels', 'memory/candidates', 'memory/knowledge', 'taste'):
        os.makedirs(os.path.join(ws, d), exist_ok=True)
    prof = os.path.join(ws, 'profile.md')
    if not os.path.exists(prof):
        shutil.copy(os.path.join(ROOT, 'templates', 'workspace', 'profile.md'), prof)

def read(path):
    try:
        return open(path, encoding='utf-8').read()
    except OSError:
        return ''

def field(text, key):
    m = re.search(r'^' + re.escape(key) + r':[ \t]*(\S.*)$', text, re.M)
    v = m.group(1).strip() if m else ''
    return '' if v.startswith('[') else v  # '[your name]' = template placeholder, not a value

def section(text, name, limit=400):
    m = re.search(r'^## ' + re.escape(name) + r'\s*\n(.*?)(?=^## |\Z)', text, re.S | re.M)
    return ' '.join(m.group(1).split())[:limit] if m else ''

def active_run(ws):
    """(relative run path, STATUS.md text) or ('', '')."""
    run = read(os.path.join(ws, 'ACTIVE_RUN')).strip()
    if not run:
        return '', ''
    status = read(os.path.join(ws, run, 'STATUS.md'))
    return (run, status) if status else ('', '')
