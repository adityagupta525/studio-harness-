#!/usr/bin/env bash
# Redact session artifacts from raw third-party captures (YouTube pages and yt-dlp metadata dumps) in place.
# Removes: signed media URLs (they carry the capturing machine's public IP and signatures), visitor / XSRF / data-sync
# values, click-tracking and continuation tokens, generic token values, and Google API keys. Public statistics stay.
# Usage: scripts/sanitize-captures.sh [dir ...]      default: every runs/*/refs
# Idempotent. Prints only counts per file, never the redacted values. Run scripts/scan-secrets.sh afterwards.
# Needs: bash, python3 (standard library only). Exit 0 always unless a directory is missing.
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 2
command -v python3 >/dev/null 2>&1 || { echo "FAIL: python3 not found"; exit 2; }
if [ "$#" -eq 0 ]; then
  set -- runs/*/refs
fi
exec python3 -I - "$@" <<'PY'
import json, os, re, sys

TEXT = (".html", ".json", ".txt", ".xml", ".vtt", ".md", ".csv")
R = "[redacted]"
URL_CH = r"(?:[^\s\"'<>\\]|\\u0026|\\/)"
RULES = [
    ("signed-media-url", re.compile(r"https?:(?:\\?/){2}" + URL_CH + r"*?googlevideo\.com" + URL_CH + r"*"), "https://googlevideo.com/[redacted-signed-media-url]"),
    ("ip-or-signature-param", re.compile(r"((?:[?&;]|\\u0026)(?:ip|ipbits|sig|lsig|signature|pot|sparams)=)[^&\"'\s\\;]*"), r"\1" + R),
    ("path-embedded-ip-or-sig", re.compile(r"(/(?:ip|sig|lsig|signature)/)[^/\"'\s\\]+/"), r"\1" + R + "/"),
    ("token-url-param", re.compile(r"((?:[?&;]|\\u0026)[A-Za-z_]*[Tt]oken=)[^&\"'\s\\;]*"), r"\1" + R),
    ("session-keys", re.compile(r"([\"']?(?:visitorData|VISITOR_DATA|visitor_data|XSRF_TOKEN|xsrf_token|DATASYNC_ID|datasyncId|DELEGATED_SESSION_ID|clickTrackingParams|continuation|ctoken|[A-Za-z_]*[Tt]oken[A-Za-z_]*|INNERTUBE_API_KEY|innertubeApiKey|apiKey)[\"']?\s*[:=]\s*[\"'])[^\"']*([\"'])"), r"\1" + R + r"\2"),
    ("google-api-key", re.compile(r"AIza[0-9A-Za-z_-]{35}"), "AIza" + R),
]

def sanitize(path):
    try:
        with open(path, encoding="utf-8") as fh:
            text = fh.read()
    except (OSError, UnicodeDecodeError):
        return None
    counts, new = {}, text
    for name, rx, rep in RULES:
        changed, n = rx.subn(rep, new)
        if changed != new:          # count only real changes, so a second run reports nothing
            counts[name] = n
            new = changed
    if new != text:
        if path.lower().endswith(".json"):
            try:
                json.loads(text)
                json.loads(new)       # a JSON file that was valid must stay valid
            except ValueError as e:
                try:
                    json.loads(text)
                    print(f"SKIP  {path}: sanitising would break the JSON ({e}); left unchanged")
                    return {}
                except ValueError:
                    pass
        with open(path, "w", encoding="utf-8") as fh:
            fh.write(new)
    return counts

missing = [d for d in sys.argv[1:] if not os.path.isdir(d)]
for d in missing:
    print(f"MISSING  {d}")
total_files = total_hits = 0
for base in [d for d in sys.argv[1:] if os.path.isdir(d)]:
    for dp, dns, fns in os.walk(base):
        for fn in fns:
            if not fn.lower().endswith(TEXT):
                continue
            p = os.path.join(dp, fn)
            c = sanitize(p)
            if c:
                total_files += 1
                total_hits += sum(c.values())
                print(f"redacted  {p}: " + ", ".join(f"{k} x{v}" for k, v in sorted(c.items())))
print(f"sanitize: {total_hits} redaction(s) in {total_files} file(s)")
sys.exit(1 if missing else 0)
PY
