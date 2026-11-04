#!/usr/bin/env bash
# Scan every text file under a root (default: the repo, INCLUDING runs/*/refs/ raw captures) for secrets and
# session artifacts, then check file names for credential-like files. Values are never printed.
# Usage: scripts/scan-secrets.sh [root]
# Classes: api keys and tokens (sk-, AKIA, gh*_, xox*-, private keys, Google AIza keys, key/secret/token/password = value),
#          session artifacts (visitor data, XSRF tokens, data-sync ids, auth cookie values, Cookie headers, IP-bearing signed URLs).
# Narrow allowlist (documented in policies/secret-scan-allowlist.yaml, tested in scripts/tests/validator_tests.py):
#   A1 signature-bytes       an AIza-looking string INSIDE a sig/lsig/signature URL parameter value (random base64, not a key)
#   A2 public-web-client-key the public Google web-client key given as INNERTUBE_API_KEY / innertubeApiKey / apiKey, only in a raw
#                            capture (.html or .json) under runs/*/refs/
# Everything else is a finding. To clean raw captures, run scripts/sanitize-captures.sh first.
# Needs: bash, python3 (standard library only). Exit 0 = clean, 1 = findings, 2 = cannot run.
set -u
ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$ROOT" || exit 2
command -v python3 >/dev/null 2>&1 || { echo "FAIL: python3 not found"; exit 2; }

exec python3 -I - <<'PY'
import os, re, sys

SKIP_DIRS = {".git", "node_modules", "__pycache__"}
SKIP_SUFFIX = (".mp4", ".mov", ".m4v", ".mkv", ".webm", ".wav", ".mp3", ".jpg", ".jpeg", ".png", ".webp", ".gif", ".pdf",
               ".zip", ".gz", ".woff", ".woff2", ".ttf", ".otf", ".ico", ".psd", ".exr", ".blend", ".sqlite")
SECRET = [
    ("api-key:sk-", re.compile(r"sk-[A-Za-z0-9_-]{20,}")),
    ("api-key:aws", re.compile(r"AKIA[0-9A-Z]{16}")),
    ("api-key:github", re.compile(r"gh[pousr]_[A-Za-z0-9]{30,}")),
    ("api-key:slack", re.compile(r"xox[baprs]-[A-Za-z0-9-]{10,}")),
    ("private-key", re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----")),
    ("api-key:google", re.compile(r"AIza[0-9A-Za-z_-]{35}")),
    ("generic-key-value", re.compile(r"(api[_-]?key|secret|token|password)[\"']?[ \t]*[:=][ \t]*[\"']?([A-Za-z0-9/+_=%.-]{16,})", re.I)),
]
SESSION = [
    ("session:visitor-or-xsrf", re.compile(r"[\"']?(visitorData|VISITOR_DATA|visitor_data|XSRF_TOKEN|xsrf_token|DATASYNC_ID|datasyncId|DELEGATED_SESSION_ID)[\"']?\s*[:=]\s*[\"']?([A-Za-z0-9%_=\-]{8,})")),
    ("session:ip-bearing-url", re.compile(r"(?:[?&;]|\\u0026)ip=[0-9A-Fa-f:.]{7,}|/ip/[0-9A-Fa-f:.]{7,}/")),
    ("session:auth-cookie", re.compile(r"\b(SAPISID|APISID|HSID|SSID|SID|LOGIN_INFO|__Secure-[A-Z0-9]+)=[^;\s\"']{8,}")),
    ("session:cookie-header", re.compile(r"(?im)^\s*(set-)?cookie:\s*[A-Za-z0-9_.-]+=\S{6,}")),
]
FILE_NAMES = ("*.pem", "*.key", "*.p12", "auth.json", ".env", ".netrc")
SIG_CONTEXT = re.compile(r"(?:[?&;]|\\u0026)(?:l?sig|signature)=[A-Za-z0-9%_\-]*$")
KEY_FIELD = re.compile(r"(?:INNERTUBE_API_KEY|innertubeApiKey|apiKey)[\"']?\s*[:=]\s*[\"']?$")

def in_refs_capture(path):
    parts = path.replace("\\", "/").split("/")
    return "refs" in parts and path.lower().endswith((".html", ".json"))

def allowed(path, text, start, value):
    """Return the allowlist rule id that covers this match, or None."""
    if value.startswith("AIza"):
        ctx = text[max(0, start - 80):start]
        if SIG_CONTEXT.search(ctx):
            return "A1"
        if in_refs_capture(path) and KEY_FIELD.search(ctx):
            return "A2"
    return None

hits, allowed_n = {}, {"A1": 0, "A2": 0}      # (path, class) -> [count, first line]
for dp, dns, fns in os.walk("."):
    dns[:] = [d for d in dns if d not in SKIP_DIRS]
    for fn in fns:
        p = os.path.join(dp, fn)[2:]
        if fn.lower().endswith(SKIP_SUFFIX) or fn == ".DS_Store":
            continue
        try:
            if os.path.getsize(p) > 80 * 1024 * 1024:
                continue
            with open(p, encoding="utf-8", errors="ignore") as fh:
                text = fh.read()
        except OSError:
            continue
        for cls, rx in SECRET + SESSION:
            for m in rx.finditer(text):
                value = m.group(2) if cls == "generic-key-value" else m.group(0)
                if value.lower().startswith("[redacted"):
                    continue
                vstart = m.start(2) if cls == "generic-key-value" else m.start()
                rule = allowed(p, text, vstart, value)
                if rule:
                    allowed_n[rule] += 1
                    continue
                key = (p, cls)
                if key in hits:
                    hits[key][0] += 1
                else:
                    hits[key] = [1, text.count("\n", 0, m.start()) + 1]      # line number computed once per file and class
names = []
import fnmatch
for dp, dns, fns in os.walk("."):
    dns[:] = [d for d in dns if d not in SKIP_DIRS]
    for fn in fns:
        low = fn.lower()
        if any(fnmatch.fnmatch(low, pat) for pat in FILE_NAMES) or "cookie" in low or low.startswith(".env") or low.endswith((".sqlite", ".sqlite-shm", ".sqlite-wal")):
            names.append(os.path.join(dp, fn)[2:])
for (p, cls), (n, line) in sorted(hits.items()):
    print(f"FOUND  {p}: {cls} x{n} (first at line {line}; value not shown)")
for p in names:
    print(f"FOUND  {p}: credential-like file name")
total = sum(v[0] for v in hits.values())
print(f"scan: {total} content finding(s) in {len(hits)} file/class group(s), {len(names)} file-name finding(s); allowlisted A1={allowed_n['A1']} A2={allowed_n['A2']}")
sys.exit(1 if hits or names else 0)
PY
