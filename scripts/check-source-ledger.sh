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
        blob = " ".join(d.values()).lower()
        if re.search(r"\bviral\b", blob):
            e('the word "viral" is banned: state the measured signal instead')
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
