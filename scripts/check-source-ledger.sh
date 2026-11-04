#!/usr/bin/env bash
# Validate source-ledger CSV files against policies/source-policy.yaml.
# Usage: scripts/check-source-ledger.sh [ledger.csv ...]
#   no arguments: templates/source-ledger.csv and every runs/*/sources.csv
# Needs: bash, python3 (standard library only). Exit 0 = pass, 1 = errors found, 2 = cannot run.
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 2

command -v python3 >/dev/null 2>&1 || { echo "FAIL: python3 not found"; exit 2; }

if [ "$#" -eq 0 ]; then
  set -- templates/source-ledger.csv
  for f in runs/*/sources.csv; do
    [ -e "$f" ] && set -- "$@" "$f"
  done
fi

exec python3 -I - "$@" <<'PY'
import csv, re, sys

HEADER = ("id,url_or_path,title,platform,geography,format,date_published,date_accessed,"
          "access_method,source_class,origin_tag,rights_class,signal_type,signal_value,"
          "signal_unit,n_items,uncertainty,used_for,notes").split(",")
TV = "[TO VERIFY]"
CLASSES = {"OBSERVED", "MEASURED", "SOURCE-VERIFIED", "PUBLICLY-DOCUMENTED", "OWNER-STATED",
           "INFERRED", "RECOMMENDED", "UNKNOWN"}
ORIGINS = {"real", "AI-made", "unknown"}
RIGHTS = {"own", "licensed", "public-domain", "analysis-only", "unknown"}
ACCESS = {"public-web", "browser-readonly", "yt-dlp-public", "user-supplied", "local-file",
          "connector-readonly", "paid-connector-approved", "other"}
SIGNALS = {"", "trend_signal", "packaging_signal", "retention_signal", "engagement_signal", "measurement"}
CLAIM_SIGNALS = {"trend_signal", "packaging_signal", "retention_signal", "engagement_signal"}
MIN_TREND_ITEMS = 5          # policies/source-policy.yaml: min_items_for_trend_signal
RETENTION_WORDS = ("retention", "watch time", "watch_time", "average view duration", "avd")
DISCOVERY_HOSTS = ("ads.tiktok.com/business/creativecenter", "trends.pinterest.com")
DATE = re.compile(r"^\d{4}-\d{2}-\d{2}$")

# ---- claims of virality or performance (policies/source-policy.yaml: performance_claims)
CLAIM_LABELS = {"OBSERVED", "INFERRED"}
CLAIM_FIELDS = ["metric", "basis", "n", "platform", "date", "source"]
CLAIM_SMALL_N = 5            # below this a tagged claim is accepted with a warning
URL_RE = re.compile(r"https?://\S+")
QUOTE_RE = re.compile(r'"[^"\n]*"|“[^”\n]*”')
TAG_RE = re.compile(r"CLAIM\[([^\]\n]*)\]")
CUE_RE = re.compile(r"\b(viral(?:ity)?|outperform(?:s|ed|ing)?|(?:top|high|best)[- ]performing|breakout|blew up|blow(?:s|n)? up)\b", re.I)
# "exploded" is a performance cue only when it is said of a post or its numbers; an "exploded view" is a drawing term.
EXPLODED_RE = re.compile(r"\b(?:(?:posts?|videos?|shorts?|reels?|clips?|channels?|views?|numbers?|likes?|subscribers?|account|it|this|that|they)\s+exploded\b"
                         r"|exploded\s+(?:in\s+(?:popularity|views|reach)|overnight|into\s+(?:the\s+)?(?:millions?|mainstream)|to\s+\d))", re.I)
CLAIM_DATE = re.compile(r"^\d{4}-\d{2}-\d{2}(\.\.\d{4}-\d{2}-\d{2})?$")

def claim_tag_problems(body, known_ids):
    parts = [p.strip() for p in body.split(";")]
    probs = []
    if parts[0] not in CLAIM_LABELS:
        probs.append("label must be OBSERVED or INFERRED")
    kv = {}
    for p in parts[1:]:
        if "=" in p:
            k, v = p.split("=", 1)
            kv[k.strip().lower()] = v.strip()
    for k in CLAIM_FIELDS:
        if not kv.get(k):
            probs.append(f"missing {k}")
    b = kv.get("basis", "")
    if b and not (re.search(r"\d[\d,.]*\s*/\s*\d[\d,.]*", b) or re.search(r"\d+(\.\d+)?\s*[x×]\s*[A-Za-z]", b)):
        probs.append("basis must be numerator/denominator (1200/400) or a ratio against a named baseline (2.1x median of previous 20 posts)")
    n = kv.get("n", "")
    if n and not (n.isdigit() and int(n) >= 1):
        probs.append("n must be a whole number of at least 1")
    d = kv.get("date", "")
    if d and not CLAIM_DATE.match(d):
        probs.append("date must be YYYY-MM-DD or YYYY-MM-DD..YYYY-MM-DD")
    s = kv.get("source", "")
    if s and (not re.match(r"^(S|CP)-\d{3,}$", s) or s not in known_ids):
        probs.append(f"source '{s}' is not a known source or post id")
    return probs, kv

def claim_issues(text, known_ids):
    """Return [(kind, message)] for one line, table row or CSV row. The literal word is not a claim inside
    a URL, a quoted span, or an exempt field; a claim needs a valid CLAIM[...] tag on the same unit."""
    out = []
    plain = URL_RE.sub(" ", text)
    tags = TAG_RE.findall(plain)
    plain = QUOTE_RE.sub(" ", TAG_RE.sub(" ", plain))
    valid = 0
    for t in tags:
        probs, kv = claim_tag_problems(t, known_ids)
        if probs:
            out.append(("E", "invalid claim tag: " + "; ".join(probs)))
        else:
            valid += 1
            if int(kv["n"]) < CLAIM_SMALL_N:
                out.append(("W", f"claim rests on n={kv['n']} (fewer than {CLAIM_SMALL_N}); treat it as an observation"))
    cue = CUE_RE.search(plain) or EXPLODED_RE.search(plain)
    if cue and not valid:
        out.append(("E", f"unsupported claim of virality or performance ('{cue.group(0)}'): add a CLAIM[...] tag on the same line "
                         "(OBSERVED or INFERRED, metric, basis, n, platform, date, source), or put the word in quotes if it is part of a title, caption, name or URL"))
    return out
CLAIM_EXEMPT_COLS = {"id", "url_or_path", "title"}   # a source title or URL may contain any word
DATE_OR_RANGE = re.compile(r"^\d{4}-\d{2}-\d{2}(\.\.\d{4}-\d{2}-\d{2})?$")

def check(path):
    errs, warns, n = [], [], 0
    try:
        with open(path, newline="", encoding="utf-8") as fh:
            rows = list(csv.reader(fh))
    except OSError as e:
        return [f"cannot read: {e}"], warns, 0
    if not rows:
        return ["empty file (header required)"], warns, 0
    if rows[0] != HEADER:
        return ["header does not match templates/source-ledger.csv"], warns, 0
    seen = set()
    all_ids = {r[0].strip() for r in rows[1:] if r and r[0].strip()}
    for ln, r in enumerate(rows[1:], start=2):
        if not any(c.strip() for c in r):
            continue
        if len(r) != len(HEADER):
            errs.append(f"line {ln}: {len(r)} columns, expected {len(HEADER)}")
            continue
        d = dict(zip(HEADER, [c.strip() for c in r]))
        n += 1
        e = lambda m: errs.append(f"line {ln} ({d['id'] or '?'}): {m}")
        if not re.match(r"^S-\d{3,}$", d["id"]):
            e("id must look like S-001")
        elif d["id"] in seen:
            e("duplicate id")
        seen.add(d["id"])
        url = d["url_or_path"]
        placeholder = TV in (url, d["title"], d["date_accessed"])
        if not url:
            e("url_or_path is empty")
        elif url != TV:
            if not (re.match(r"^https?://", url) or "/" in url or url.startswith("~")):
                e("url_or_path must be a full URL or a file path, not a bare ID or handle")
        if placeholder:
            warns.append(f"line {ln} ({d['id']}): contains {TV}, not yet a real source")
        if not d["title"]:
            e("title is empty")
        if d["date_accessed"] != TV and not DATE.match(d["date_accessed"]):
            e("date_accessed must be YYYY-MM-DD")
        if d["source_class"] not in CLASSES:
            e(f"source_class must be one of {sorted(CLASSES)}")
        if d["origin_tag"] not in ORIGINS:
            e("origin_tag must be real, AI-made or unknown")
        if d["rights_class"] not in RIGHTS:
            e("rights_class must be own, licensed, public-domain, analysis-only or unknown")
        if d["access_method"] not in ACCESS:
            e(f"access_method must be one of {sorted(ACCESS)}")
        if d["signal_type"] not in SIGNALS:
            e(f"signal_type must be one of {sorted(SIGNALS - {''})} or empty")
        unit = " ".join(v for k, v in d.items() if k not in CLAIM_EXEMPT_COLS)
        for kind, msg in claim_issues(unit, all_ids):
            if kind == "E":
                e(msg)
            else:
                warns.append(f"line {ln} ({d['id']}): {msg}")
        st = d["signal_type"]
        if st in CLAIM_SIGNALS:
            for k in ("platform", "geography", "format", "signal_value", "signal_unit", "uncertainty"):
                if not d[k]:
                    e(f"{st} requires {k}")
            if not DATE_OR_RANGE.match(d["date_published"]):
                e(f"{st} requires date_published as YYYY-MM-DD or YYYY-MM-DD..YYYY-MM-DD")
            if not d["n_items"].isdigit() or int(d["n_items"]) < 1:
                e(f"{st} requires n_items as a whole number >= 1")
            elif st == "trend_signal" and int(d["n_items"]) < MIN_TREND_ITEMS:
                e(f"trend_signal needs n_items >= {MIN_TREND_ITEMS}; fewer is an observation, use engagement_signal or packaging_signal")
        if st == "packaging_signal" and any(w in d["signal_unit"].lower() for w in RETENTION_WORDS):
            e("a packaging_signal cannot carry a retention or watch-time unit; use retention_signal with owner analytics")
        if st == "retention_signal" and d["source_class"] not in {"MEASURED", "OWNER-STATED", "PUBLICLY-DOCUMENTED"}:
            e("retention_signal needs MEASURED, OWNER-STATED or PUBLICLY-DOCUMENTED evidence, never inference from views")
        if "instagram" in (d["platform"] + url).lower():
            if d["access_method"] not in {"public-web", "yt-dlp-public", "browser-readonly", "user-supplied"}:
                e("Instagram rows must use public-web, yt-dlp-public, browser-readonly or user-supplied access")
            if not re.search(r"public|private|rate", (d["uncertainty"] + " " + d["notes"]).lower()):
                e("Instagram rows must state the public / private / rate-limit constraint in uncertainty or notes")
        if any(h in (url + " " + d["platform"]).lower() for h in DISCOVERY_HOSTS) or \
           "creative center" in d["platform"].lower() or "pinterest trends" in d["platform"].lower():
            if "discovery" not in d["used_for"].lower():
                e("TikTok Creative Center and Pinterest Trends are discovery signals: used_for must say discovery")
            if d["source_class"] in {"MEASURED"}:
                e("a discovery-only source cannot be MEASURED proof")
        if d["access_method"] == "paid-connector-approved":
            warns.append(f"line {ln} ({d['id']}): paid connector used; make sure an approved row exists in approvals.csv")
    return errs, warns, n

bad = 0
for p in sys.argv[1:]:
    errs, warns, n = check(p)
    for w in warns:
        print(f"WARN  {p}: {w}")
    for er in errs:
        print(f"ERROR {p}: {er}")
    status = "FAIL" if errs else "ok  "
    print(f"{status}  {p} ({n} row{'s' if n != 1 else ''}, {len(errs)} error(s), {len(warns)} warning(s))")
    bad += 1 if errs else 0
sys.exit(1 if bad else 0)
PY
