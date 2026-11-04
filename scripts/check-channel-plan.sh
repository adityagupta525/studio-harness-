#!/usr/bin/env bash
# Validate Channel Launch runs (STATUS.md front matter `route: channel-launch`) and the channel templates.
# Usage: scripts/check-channel-plan.sh                 templates + every channel-launch run
#        scripts/check-channel-plan.sh --templates     only check that the templates match this validator
#        scripts/check-channel-plan.sh runs/<run-id>   one run
# A plan marked `complete` needs: real competitor and post URLs, stated assumptions, at least three
# distinct pillars, approval records for each lock, and a measurement plan (see policies/channel-launch.yaml).
# Needs: bash, python3 (standard library only). Exit 0 = pass, 1 = errors found, 2 = cannot run.
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 2

command -v python3 >/dev/null 2>&1 || { echo "FAIL: python3 not found"; exit 2; }

exec python3 -I - "$@" <<'PY'
import csv, os, re, sys

TV, TF = "[TO VERIFY]", "[TO FILL"          # TF is a prefix on purpose: it also catches "[TO FILL: hint]"
# Thresholds: keep identical to policies/channel-launch.yaml (validate-harness.sh cross-checks them).
MIN_COMPETITORS = 3
MIN_POSTS_ANALYSED = 8
MIN_POSTS_PER_COMPETITOR = 2
MIN_ASSUMPTIONS = 3
MIN_PILLARS = 3
MAX_PILLARS = 5
MIN_FORMATS = 2
MIN_CALENDAR_POSTS = 30
MIN_HOOKS = 5
MIN_METRICS = 4
MIN_DECISION_RULES = 3
MIN_POSTS_FOR_VERDICT = 5
MIN_STRATEGY_PHASES = 3
MIN_BEATS = 3

DATE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
POST_HEADER = ("post_id,competitor,source_id,url,platform,date_published,date_accessed,views,likes,comments,"
               "metrics_note,format,duration_s,hook,shot_structure,packaging,audience_promise,"
               "retention_hypothesis,observed_facts,interpretation,unknowns,examined_how,comparative_signal").split(",")
COMP_HEADER = ["Competitor", "Profile URL", "Platform", "Role", "Why comparable", "Post ids analysed", "Last checked"]
ASSUMP_HEADER = ["ID", "Assumption", "Type", "Status", "Evidence (source ids)", "How we will test", "Test by"]
CAL_HEADER = ["#", "Planned date", "Pillar", "Format", "Audience moment", "Promise (one line)", "Hook",
              "Proof / value", "Making method", "Packaging idea", "Effort", "Risk", "Success metric", "Status"]
PHASE_HEADER = ["Phase", "Days", "Objective", "Hypothesis being tested", "Decision at end"]
HOOK_HEADER = ["Hook id", "Pattern", "Original example line", "Format ids", "Evidence (post ids)", "Status", "Result"]
PACK_HEADER = ["Element", "Rule", "Basis (post ids or hypothesis ids)", "Original example"]
METRIC_HEADER = ["Metric id", "Name", "Definition", "Source", "Cadence", "Type", "Decision it informs"]
RULE_HEADER = ["Rule id", "If", "Then", "Min posts"]
OBS_HEADER = ["Date", "Post ref", "Metric id", "Value", "Source", "Note"]
REVIEW_HEADER = ["Assumption or rule id", "Prediction", "Observed", "n", "Verdict", "Next step"]

ROLES = {"leader", "small-craft", "closest", "parallel", "outsider"}
ASSUMP_TYPES = {"audience", "category", "format", "platform", "distribution", "production", "economics"}
ASSUMP_STATUS = {"hypothesis", "unverified", "validated-external", "validated-own"}
EXAMINED = {"video-watched", "frames-viewed", "transcript-read", "user-supplied-file"}
METRIC_TYPES = {"packaging", "retention", "growth", "engagement", "production"}
EFFORT = {"S", "M", "L"}
CAL_STATUS = {"idea", "planned", "in_production", "ready", "published_by_ashish", "hold"}
HOOK_STATUS = {"hypothesis", "tested"}
VERDICTS = {"supported", "refuted", "inconclusive"}
PACK_ELEMENTS = ["Title", "Hook", "Thumbnail or cover", "Caption", "CTA"]
STAGES = ["research", "script", "treatment", "shot_spec", "make", "qa"]
LOCK_TYPES = ["lock_positioning", "lock_visual_direction", "lock_pillars", "lock_calendar"]

PILLAR_KEYS = ["pillar_id", "name", "promise", "audience_moment", "evidence", "formats", "share_of_calendar",
               "risk", "success_metric", "lock_state"]
FORMAT_KEYS = ["format_id", "name", "series_name", "pillar_ids", "platform", "length", "cadence", "structure",
               "hook_pattern", "proof_value", "making_method", "packaging_pattern", "effort", "risk",
               "success_metric", "lock_state"]
BRIEF_KEYS = ["channel_name", "platforms", "handle_status", "posts_published", "audience_data", "positioning_lock"]
CARD_KEYS = ["post_ref", "pillar_id", "format_id", "made_by", "qa_by"] + STAGES + ["paid_tools", "spend_approval_id"]
REVIEW_KEYS = ["review_id", "period_start", "period_end", "posts_in_scope", "reviewer"]
BRIEF_SECTIONS = ["Starting state", "Goal and success", "Audience and category", "Assumptions",
                  "Positioning hypothesis", "Channel promise", "Editorial voice", "Constraints and resources",
                  "Rights and licensing", "What we will not do"]
STYLE_SECTIONS = ["Derived from", "Visual direction", "Colour and type", "Thumbnail and cover system",
                  "Motion, captions and sound", "Packaging rules", "What we deliberately do not borrow",
                  "Accessibility and safety"]
METRIC_SECTIONS = ["Metric definitions", "Comparative signal definition", "Decision rules", "Review cadence",
                   "Own-channel observations", "Honest limits"]
MAP_SECTIONS = ["Method and access", "Competitors", "Patterns across posts", "Whitespace and opportunities",
                "Unknowns and limits"]
CARD_SECTIONS = ["Research", "Script", "Treatment", "Shot specs", "Make log", "QA", "Packaging", "Rights"]

YT = re.compile(r"^https?://(www\.|m\.)?(youtube\.com/(watch\?|shorts/|live/)|youtu\.be/)")
IG = re.compile(r"^https?://(www\.)?instagram\.com/(reel|reels|p|tv)/")
TT = re.compile(r"^https?://(www\.)?tiktok\.com/@[^/]+/video/")

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
CLAIM_EXEMPT_COLS = {"post_id", "competitor", "source_id", "url"}   # names and URLs are not claims

def read(p):
    with open(p, encoding="utf-8") as fh:
        return fh.read()

def parse_fm(text):
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None
    d = {}
    for line in lines[1:]:
        if line.strip() == "---":
            return d
        m = re.match(r"^([A-Za-z0-9_]+):\s*(.*)$", line)
        if m:
            d[m.group(1)] = re.split(r"\s{2,}#", m.group(2), maxsplit=1)[0].strip()
    return None

def section(text, name):
    m = re.search(r"(?ms)^## %s[ \t]*$(.*?)(?=^## |\Z)" % re.escape(name), text)
    return m.group(1) if m else None

def table(text, name, header):
    body = section(text, name)
    if body is None:
        return None, [f"missing section '## {name}'"]
    lines = [l.strip() for l in body.splitlines() if l.strip().startswith("|")]
    if len(lines) < 2:
        return None, [f"section '## {name}' has no table"]
    def cells(l):
        return [c.strip() for c in l[1:-1].split("|")]
    if cells(lines[0]) != header:
        return None, [f"section '## {name}' table header must be: {' | '.join(header)}"]
    rows = []
    for l in lines[2:]:
        c = cells(l)
        if len(c) != len(header):
            return None, [f"section '## {name}' has a row with {len(c)} cells, expected {len(header)}"]
        if any(c):
            rows.append(c)
    return rows, []

def is_ph(v):
    return (not v) or v.startswith(TF)

def real(rows, cols):
    """Drop template placeholder rows: a row counts only if one of the data columns holds real text."""
    return [r for r in (rows or []) if any(r[i] and not r[i].startswith(TF) for i in cols)]

def words(s):
    return [x for x in re.split(r"[,\s]+", s) if x]

_tmpl_cache = {}
def template_lines(tpath, name):
    key = (tpath, name)
    if key not in _tmpl_cache:
        try:
            body = section(read(tpath), name) or ""
        except OSError:
            body = ""
        _tmpl_cache[key] = {l.strip() for l in body.splitlines()}
    return _tmpl_cache[key]

def filled(body, tpath, name):
    """True when the section holds a line that is not just the template's own guidance."""
    if body is None:
        return False
    body = re.sub(r"(?s)<!--.*?-->", "", body)
    tl = template_lines(tpath, name)
    return any(l.strip() not in tl and l.strip() not in ("", "-") for l in body.splitlines())

def post_url_ok(url, platform):
    if not re.match(r"^https?://", url):
        return False
    pl = platform.lower()
    if "youtube" in pl:
        return bool(YT.match(url))
    if "instagram" in pl:
        return bool(IG.match(url))
    if "tiktok" in pl:
        return bool(TT.match(url))
    path = re.sub(r"^https?://[^/]+", "", url).strip("/")
    return len(path.split("/")) >= 2 or "?" in path

# ---------------------------------------------------------------- templates
def check_templates():
    errs = []
    specs = {
        "templates/channel-brief.md": (BRIEF_KEYS, BRIEF_SECTIONS, {"Assumptions": ASSUMP_HEADER}),
        "templates/channel-competitor-map.md": ([], MAP_SECTIONS, {"Competitors": COMP_HEADER}),
        "templates/content-pillar.md": (PILLAR_KEYS, [], {}),
        "templates/format-card.md": (FORMAT_KEYS, [], {}),
        "templates/hook-library.md": ([], ["Principles", "Hooks"], {"Hooks": HOOK_HEADER}),
        "templates/channel-style-system.md": (["lock_state"], STYLE_SECTIONS, {"Packaging rules": PACK_HEADER}),
        "templates/content-calendar.md": (["lock_state", "start_date"],
                                          ["Principles", "Calendar", "Idea bank", "90-day strategy"],
                                          {"Calendar": CAL_HEADER, "Idea bank": CAL_HEADER, "90-day strategy": PHASE_HEADER}),
        "templates/post-production-card.md": (CARD_KEYS, CARD_SECTIONS, {}),
        "templates/channel-metrics.md": ([], METRIC_SECTIONS, {"Metric definitions": METRIC_HEADER,
                                                               "Decision rules": RULE_HEADER,
                                                               "Own-channel observations": OBS_HEADER}),
        "templates/channel-review.md": (REVIEW_KEYS, ["Data used", "Hypothesis check", "What we change",
                                                      "Approvals needed", "Learning candidates"],
                                        {"Hypothesis check": REVIEW_HEADER}),
    }
    for path, (keys, sections, tables) in specs.items():
        try:
            text = read(path)
        except OSError:
            errs.append(f"{path}: missing")
            continue
        fm = parse_fm(text) if keys else {}
        if keys and fm is None:
            errs.append(f"{path}: no front matter block")
            continue
        for k in keys:
            if k not in (fm or {}):
                errs.append(f"{path}: front matter missing '{k}'")
        for s in sections:
            if section(text, s) is None:
                errs.append(f"{path}: missing section '## {s}'")
        for s, h in tables.items():
            _, e = table(text, s, h)
            errs.extend(f"{path}: {m}" for m in e)
    try:
        with open("templates/competitor-post-ledger.csv", newline="", encoding="utf-8") as fh:
            hdr = next(csv.reader(fh), [])
        if hdr != POST_HEADER:
            errs.append("templates/competitor-post-ledger.csv: header does not match this validator")
    except OSError:
        errs.append("templates/competitor-post-ledger.csv: missing")
    return errs

# ---------------------------------------------------------------- one run
def check_run(run):
    errs, warns = [], []
    def E(f, m): errs.append(f"{f}: {m}")
    def W(f, m): warns.append(f"{f}: {m}")
    P = lambda *a: os.path.join(run, *a)
    ex = lambda *a: os.path.exists(P(*a))

    sfm = parse_fm(read(P("STATUS.md"))) if ex("STATUS.md") else None
    if not sfm:
        E("STATUS.md", "no front matter")
        return errs, warns, {}
    status = sfm.get("status", "")
    practice = sfm.get("practice", "")
    complete = status == "complete"
    intake = practice == "unknown"
    if sfm.get("route") != "channel-launch":
        W("STATUS.md", "route is not channel-launch; nothing to check")
        return errs, warns, sfm
    if practice not in {"content", "unknown"}:
        E("STATUS.md", "channel-launch runs use practice: content (or unknown while intake is open)")
    channel_paths = ["channel-brief.md", "channel-competitor-map.md", "competitor-posts.csv", "pillars", "formats",
                     "hook-library.md", "channel-style-system.md", "content-calendar.md", "channel-metrics.md",
                     "post-cards", "reviews"]
    if intake:
        for c in channel_paths:
            if ex(c):
                E(c, "exists but practice is unknown: set practice: content before the Channel Launch starts")
        return errs, warns, sfm

    # ---- approvals and sources (read tolerantly; run-completeness validates their format)
    approvals = []
    if ex("approvals.csv"):
        with open(P("approvals.csv"), newline="", encoding="utf-8") as fh:
            approvals = list(csv.DictReader(fh))
    approved = {}
    for r in approvals:
        words_ = (r.get("approval_words") or "").strip()
        if r.get("status") == "approved" and DATE.match(r.get("approved_on") or "") and words_ \
                and TV not in words_ and not words_.startswith(TF):
            approved.setdefault(r.get("action_type"), []).append(r.get("approval_id"))
    paid_rows = {r.get("approval_id") for r in approvals if r.get("action_type") == "paid_generation"
                 and r.get("status") == "approved" and r.get("executed_on")}
    src = {}
    if ex("sources.csv"):
        with open(P("sources.csv"), newline="", encoding="utf-8") as fh:
            for r in csv.DictReader(fh):
                src[(r.get("id") or "").strip()] = r
    if any((r.get("access_method") == "paid-connector-approved") for r in src.values()) and "paid_generation" not in approved:
        E("sources.csv", "a paid connector was used but approvals.csv has no approved paid_generation row")

    # ---- required files for a channel run
    if not ex("channel-brief.md"):
        E("channel-brief.md", "missing (step 1 of the Channel Launch workflow)")
        return errs, warns, sfm
    brief = read(P("channel-brief.md"))
    bfm = parse_fm(brief) or {}
    for k in BRIEF_KEYS:
        if k not in bfm or not bfm[k]:
            E("channel-brief.md", f"front matter missing '{k}'")
    posts_pub = None
    if bfm.get("posts_published", "").isdigit():
        posts_pub = int(bfm["posts_published"])
    elif "posts_published" in bfm:
        E("channel-brief.md", "posts_published must be a whole number")
    if bfm.get("audience_data") not in {"none", "own-analytics"}:
        E("channel-brief.md", "audience_data must be none or own-analytics")
    if posts_pub == 0 and bfm.get("audience_data") != "none":
        E("channel-brief.md", "a channel with zero posts has no audience data: audience_data must be none")
    if bfm.get("positioning_lock") not in {"draft", "locked"}:
        E("channel-brief.md", "positioning_lock must be draft or locked")
    L_pos = bfm.get("positioning_lock") == "locked"
    zero_posts = posts_pub == 0

    style = read(P("channel-style-system.md")) if ex("channel-style-system.md") else None
    stfm = (parse_fm(style) or {}) if style else {}
    L_vis = stfm.get("lock_state") == "locked"
    cal = read(P("content-calendar.md")) if ex("content-calendar.md") else None
    calfm = (parse_fm(cal) or {}) if cal else {}
    L_cal = calfm.get("lock_state") == "locked"
    for name, v in (("channel-style-system.md", stfm.get("lock_state")), ("content-calendar.md", calfm.get("lock_state"))):
        if v is not None and v not in {"draft", "locked"}:
            E(name, "lock_state must be draft or locked")

    def md_files(sub):
        d = P(sub)
        return sorted(f for f in os.listdir(d) if f.endswith(".md") and not f.lower().startswith("readme")) if os.path.isdir(d) else []

    pillars, formats = {}, {}
    for fn in md_files("pillars"):
        t = read(P("pillars", fn))
        f = parse_fm(t)
        if f is None:
            E(f"pillars/{fn}", "no front matter block")
            continue
        miss = [k for k in PILLAR_KEYS if k not in f]
        if miss:
            E(f"pillars/{fn}", f"missing fields: {', '.join(miss)}")
            continue
        pillars[fn] = (f, t)
    for fn in md_files("formats"):
        t = read(P("formats", fn))
        f = parse_fm(t)
        if f is None:
            E(f"formats/{fn}", "no front matter block")
            continue
        miss = [k for k in FORMAT_KEYS if k not in f]
        if miss:
            E(f"formats/{fn}", f"missing fields: {', '.join(miss)}")
            continue
        formats[fn] = (f, t)
    any_pillar_lock = any(f["lock_state"] == "locked" for f, _ in list(pillars.values()) + list(formats.values()))
    all_pillars_locked = bool(pillars) and bool(formats) and all(f["lock_state"] == "locked" for f, _ in list(pillars.values()) + list(formats.values()))

    # ---- lock consistency (human approval gates)
    def need(lock_type, what):
        if lock_type not in approved:
            E("approvals.csv", f"{what} is locked but there is no approved {lock_type} row with his words")
    if L_pos:
        need("lock_positioning", "positioning")
    if L_vis:
        need("lock_visual_direction", "visual direction")
        if not L_pos:
            E("channel-style-system.md", "visual direction cannot be locked before positioning is locked")
    if any_pillar_lock:
        need("lock_pillars", "pillars and formats")
        if not L_pos:
            E("pillars/", "pillars cannot be locked before positioning is locked")
    if L_cal:
        need("lock_calendar", "calendar")
        for ok_, label in ((L_pos, "positioning"), (L_vis, "visual direction"), (all_pillars_locked, "pillars and formats")):
            if not ok_:
                E("content-calendar.md", f"calendar cannot be locked before {label} is locked")
    if paid_rows and not (L_pos and L_vis):
        E("approvals.csv", "production spend was executed before positioning and visual direction were locked")
    if complete:
        for lt in LOCK_TYPES:
            if lt not in approved:
                E("approvals.csv", f"a complete plan needs an approved {lt} row with his words")
        if not (L_pos and L_vis and all_pillars_locked and L_cal):
            E("STATUS.md", "complete needs positioning, visual direction, pillars, formats and calendar all locked")

    # ---- competitor post ledger and competitor map
    posts, post_by_id = [], {}
    claim_units = []
    if ex("competitor-posts.csv"):
        with open(P("competitor-posts.csv"), newline="", encoding="utf-8") as fh:
            rows = list(csv.reader(fh))
        if not rows or rows[0] != POST_HEADER:
            E("competitor-posts.csv", "header does not match templates/competitor-post-ledger.csv")
        else:
            for ln, r in enumerate(rows[1:], start=2):
                if not any(c.strip() for c in r):
                    continue
                if len(r) != len(POST_HEADER):
                    E("competitor-posts.csv", f"line {ln}: {len(r)} columns, expected {len(POST_HEADER)}")
                    continue
                d = dict(zip(POST_HEADER, [c.strip() for c in r]))
                e = lambda m, d=d, ln=ln: E("competitor-posts.csv", f"line {ln} ({d['post_id'] or '?'}): {m}")
                if not re.match(r"^CP-\d{3,}$", d["post_id"]):
                    e("post_id must look like CP-001")
                elif d["post_id"] in post_by_id:
                    e("duplicate post_id")
                post_by_id[d["post_id"]] = d
                posts.append(d)
                for k in POST_HEADER:
                    if k == "metrics_note":
                        continue
                    if not d[k]:
                        e(f"{k} is empty (write unknown for a value that cannot be found)")
                    elif d[k].startswith(TF):
                        e(f"{k} is still a placeholder")
                if d["url"] and not post_url_ok(d["url"], d["platform"]):
                    e("url must be a full URL of a post or video, not a channel or profile page, and never a bare handle")
                s = src.get(d["source_id"])
                if d["source_id"] and s is None:
                    e(f"source_id {d['source_id']} not found in sources.csv")
                elif s is not None and (s.get("url_or_path") or "").strip() != d["url"]:
                    e("source_id points at a sources.csv row with a different URL")
                for k in ("views", "likes", "comments"):
                    if d[k] and not (d[k].isdigit() or d[k] == "unknown"):
                        e(f"{k} must be a whole number or the word unknown")
                if d["duration_s"] and not (re.match(r"^\d+(\.\d+)?$", d["duration_s"]) or d["duration_s"] == "unknown"):
                    e("duration_s must be a number or unknown")
                if d["date_published"] and d["date_published"] != "unknown" and not DATE.match(d["date_published"]):
                    e("date_published must be YYYY-MM-DD or unknown")
                if d["date_accessed"] and not DATE.match(d["date_accessed"]):
                    e("date_accessed must be YYYY-MM-DD")
                parts = [x for x in d["examined_how"].split("+") if x]
                if not parts or any(p not in EXAMINED for p in parts):
                    e(f"examined_how must be one or more of {sorted(EXAMINED)} joined by +: a bio, title or metadata alone is not analysis")
                for k, pre in (("observed_facts", "OBSERVED:"), ("interpretation", "INFERRED:"),
                               ("retention_hypothesis", "H:"), ("unknowns", "UNKNOWN:")):
                    if d[k] and not d[k].startswith(pre):
                        e(f"{k} must start with '{pre}' so facts, interpretation, hypothesis and unknowns stay separate")
                beats = [b for b in d["shot_structure"].split(";") if b.strip()]
                if d["shot_structure"] and len(beats) < MIN_BEATS:
                    e(f"shot_structure needs at least {MIN_BEATS} beats separated by ';' (a timed shot or slide list)")
                cs = d["comparative_signal"]
                if cs and cs != "none" and not (re.search(r"\d+(\.\d+)?\s*[x×]", cs) and re.search(r"n\s*=\s*\d+", cs)):
                    e("comparative_signal must be 'none' or a ratio against a named comparator with its sample size, for example '2.1x median of this channel's last 20 posts (n=20)'")
                claim_units.append((ln, d["post_id"], " ".join(v for k, v in d.items() if k not in CLAIM_EXEMPT_COLS)))

    comp_rows, comp_errs = [], []
    if ex("channel-competitor-map.md"):
        mtext = read(P("channel-competitor-map.md"))
        rows, e_ = table(mtext, "Competitors", COMP_HEADER)
        errs.extend(f"channel-competitor-map.md: {m}" for m in e_)
        for r in rows or []:
            if is_ph(r[0]):
                continue
            comp_rows.append(r)
    else:
        mtext = None

    def evidence_problems():
        probs = []
        if len(comp_rows) < MIN_COMPETITORS:
            probs.append(f"{len(comp_rows)} competitors mapped, need {MIN_COMPETITORS}")
        if not any(r[3] == "outsider" for r in comp_rows):
            probs.append("no competitor with role outsider")
        names = {r[0].lower() for r in comp_rows}
        for r in comp_rows:
            if not re.match(r"^https?://", r[1]):
                probs.append(f"competitor '{r[0]}' has no full profile URL")
            if r[3] not in ROLES:
                probs.append(f"competitor '{r[0]}' role must be one of {sorted(ROLES)}")
            ids = words(r[5])
            mine = [i for i in ids if i in post_by_id and post_by_id[i]["competitor"].lower() == r[0].lower()]
            if len(mine) < MIN_POSTS_PER_COMPETITOR:
                probs.append(f"competitor '{r[0]}' has {len(mine)} analysed posts, need {MIN_POSTS_PER_COMPETITOR} (a bio or title alone is not analysis)")
        for p in posts:
            if p["competitor"].lower() not in names:
                probs.append(f"post {p['post_id']} belongs to '{p['competitor']}' who is not in the competitor map")
        if len(posts) < MIN_POSTS_ANALYSED:
            probs.append(f"{len(posts)} posts analysed in total, need {MIN_POSTS_ANALYSED}")
        return probs

    locked_anything = L_pos or L_vis or any_pillar_lock or L_cal
    if complete or locked_anything:
        for pr in evidence_problems():
            E("competitor evidence", pr)
    if complete and mtext is not None:
        for s_ in ("Patterns across posts", "Whitespace and opportunities", "Unknowns and limits"):
            b = section(mtext, s_)
            if not filled(b, "templates/channel-competitor-map.md", s_) or TF in (b or ""):
                E("channel-competitor-map.md", f"section '{s_}' is empty")
    if complete and not ex("channel-competitor-map.md"):
        E("channel-competitor-map.md", "missing")

    # ---- the brief: sections, assumptions, zero-post honesty
    strict_brief = complete or L_pos
    for s_ in BRIEF_SECTIONS:
        b = section(brief, s_)
        if b is None:
            E("channel-brief.md", f"missing section '## {s_}'")
        elif strict_brief and s_ != "Assumptions" and (not filled(b, "templates/channel-brief.md", s_) or TF in b):
            E("channel-brief.md", f"section '{s_}' is empty or still a placeholder")
    arows, e_ = table(brief, "Assumptions", ASSUMP_HEADER)
    errs.extend(f"channel-brief.md: {m}" for m in e_)
    aids = set()
    arows = real(arows, [1, 2, 4, 5, 6])
    for r in arows:
        aid, text_, typ, st, ev, test, by = r
        e = lambda m, aid=aid: E("channel-brief.md", f"assumption {aid or '?'}: {m}")
        if not re.match(r"^H-\d{2,}$", aid):
            e("ID must look like H-01")
        elif aid in aids:
            e("duplicate ID")
        aids.add(aid)
        if typ not in ASSUMP_TYPES:
            e(f"Type must be one of {sorted(ASSUMP_TYPES)}")
        if st not in ASSUMP_STATUS:
            e(f"Status must be one of {sorted(ASSUMP_STATUS)}")
        if typ == "audience" and bfm.get("audience_data") == "none" and st not in {"hypothesis", "unverified"}:
            e("audience claims are hypotheses while audience_data is none")
        if st == "validated-own" and (posts_pub or 0) == 0:
            e("validated-own is impossible while posts_published is 0")
        if st == "validated-external":
            ids = words(ev)
            if not ids or any(i not in src for i in ids):
                e("validated-external needs source ids that exist in sources.csv")
        if strict_brief and (is_ph(text_) or is_ph(test) or is_ph(by)):
            e("assumption, how we will test and test by must be filled")
    if strict_brief:
        if len(arows) < MIN_ASSUMPTIONS:
            E("channel-brief.md", f"{len(arows)} assumptions stated, need {MIN_ASSUMPTIONS}")
        if not any(r[2] == "audience" for r in arows):
            E("channel-brief.md", "no assumption of Type audience: state how the audience is a hypothesis")

    # ---- metrics (measurement plan)
    metric_ids = set()
    mt = read(P("channel-metrics.md")) if ex("channel-metrics.md") else None
    strict_metrics = complete or L_cal
    if mt is None:
        if strict_metrics:
            E("channel-metrics.md", "missing: a measurement plan is required")
    else:
        for s_ in METRIC_SECTIONS:
            b = section(mt, s_)
            if b is None:
                E("channel-metrics.md", f"missing section '## {s_}'")
            elif strict_metrics and s_ not in {"Own-channel observations"} and \
                    (not filled(b, "templates/channel-metrics.md", s_) or TF in b):
                if s_ not in {"Metric definitions", "Decision rules"}:
                    E("channel-metrics.md", f"section '{s_}' is empty")
        mrows, e_ = table(mt, "Metric definitions", METRIC_HEADER)
        errs.extend(f"channel-metrics.md: {m}" for m in e_)
        mrows = real(mrows, range(1, 7))
        for r in mrows:
            mid, name, dfn, srcc, cad, typ, dec = r
            e = lambda m, mid=mid: E("channel-metrics.md", f"metric {mid or '?'}: {m}")
            if not re.match(r"^M\d+$", mid):
                e("Metric id must look like M1")
            elif mid in metric_ids:
                e("duplicate Metric id")
            metric_ids.add(mid)
            if typ not in METRIC_TYPES:
                e(f"Type must be one of {sorted(METRIC_TYPES)}")
            if any(is_ph(x) for x in (name, dfn, srcc, cad, dec)):
                e("name, definition, source, cadence and decision must all be filled")
        if strict_metrics:
            if len(mrows) < MIN_METRICS:
                E("channel-metrics.md", f"{len(mrows)} metrics defined, need {MIN_METRICS}")
            for need_t in ("packaging", "retention"):
                if not any(r[5] == need_t for r in mrows):
                    E("channel-metrics.md", f"no metric of Type {need_t}")
        rrows, e_ = table(mt, "Decision rules", RULE_HEADER)
        errs.extend(f"channel-metrics.md: {m}" for m in e_)
        rrows = real(rrows, [1, 2, 3])
        for r in rrows:
            if any(is_ph(x) for x in r) or not r[3].isdigit() or int(r[3]) < MIN_POSTS_FOR_VERDICT:
                E("channel-metrics.md", f"decision rule {r[0] or '?'}: If, Then and Min posts must be filled and Min posts must be at least {MIN_POSTS_FOR_VERDICT}")
        if strict_metrics and len(rrows) < MIN_DECISION_RULES:
            E("channel-metrics.md", f"{len(rrows)} decision rules, need {MIN_DECISION_RULES}")
        orows, e_ = table(mt, "Own-channel observations", OBS_HEADER)
        errs.extend(f"channel-metrics.md: {m}" for m in e_)
        orows = [r for r in (orows or []) if any(r)]
        if zero_posts and orows:
            E("channel-metrics.md", "own-channel observations exist but posts_published is 0: no performance data may be recorded")
        for r in orows:
            if not DATE.match(r[0]) or r[2] not in metric_ids or is_ph(r[3]) or is_ph(r[4]):
                E("channel-metrics.md", f"observation '{' | '.join(r[:3])}': needs a date, a known metric id, a value and a source")

    def has_metric(text_):
        return bool(set(re.findall(r"\bM\d+\b", text_)) & metric_ids) if metric_ids else bool(re.search(r"\bM\d+\b", text_))

    # ---- pillars and formats
    seen = {"pillar_id": {}, "name": {}, "promise": {}, "audience_moment": {}}
    for fn, (f, t) in pillars.items():
        strict = complete or f["lock_state"] == "locked"
        e = lambda m, fn=fn: E(f"pillars/{fn}", m)
        if f["lock_state"] not in {"draft", "locked"}:
            e("lock_state must be draft or locked")
        for k in seen:
            v = f[k].strip().lower()
            if not is_ph(f[k]):
                if v in seen[k]:
                    e(f"{k} duplicates pillars/{seen[k][v]}: pillars must be distinct")
                seen[k][v] = fn
        if strict:
            for k in PILLAR_KEYS:
                if is_ph(f[k]):
                    e(f"{k} is empty or still a placeholder")
            for i in words(f["evidence"]):
                if not (i in src or i in aids):
                    e(f"evidence '{i}' is neither a source id in sources.csv nor an assumption id in channel-brief.md")
            if not has_metric(f["success_metric"]):
                e("success_metric must name a metric id defined in channel-metrics.md")
    fids = {f["format_id"] for f, _ in formats.values()}
    pids = {f["pillar_id"] for f, _ in pillars.values()}
    for fn, (f, t) in pillars.items():
        if complete or f["lock_state"] == "locked":
            for i in words(f["formats"]):
                if i not in fids:
                    E(f"pillars/{fn}", f"formats lists '{i}' which has no card in formats/")
    for fn, (f, t) in formats.items():
        strict = complete or f["lock_state"] == "locked"
        e = lambda m, fn=fn: E(f"formats/{fn}", m)
        if f["lock_state"] not in {"draft", "locked"}:
            e("lock_state must be draft or locked")
        if f["effort"] not in EFFORT and not is_ph(f["effort"]):
            e("effort must be S, M or L")
        if strict:
            for k in FORMAT_KEYS:
                if is_ph(f[k]):
                    e(f"{k} is empty or still a placeholder")
            if f["effort"] not in EFFORT:
                e("effort must be S, M or L")
            if len([b for b in f["structure"].split(";") if b.strip()]) < MIN_BEATS:
                e(f"structure needs at least {MIN_BEATS} beats separated by ';'")
            for i in words(f["pillar_ids"]):
                if i not in pids:
                    e(f"pillar_ids lists '{i}' which has no file in pillars/")
            if not has_metric(f["success_metric"]):
                e("success_metric must name a metric id defined in channel-metrics.md")
    if complete:
        if not (MIN_PILLARS <= len(pillars)):
            E("pillars/", f"{len(pillars)} pillars, need at least {MIN_PILLARS} distinct pillars")
        if len(formats) < MIN_FORMATS:
            E("formats/", f"{len(formats)} format cards, need {MIN_FORMATS}")
    if len(pillars) > MAX_PILLARS:
        E("pillars/", f"{len(pillars)} pillars; a channel carries {MIN_PILLARS} to {MAX_PILLARS}")
    elif 0 < len(pillars) < MIN_PILLARS and (any_pillar_lock):
        E("pillars/", f"locking needs at least {MIN_PILLARS} distinct pillars, found {len(pillars)}")

    # ---- hook library
    hooks_ids = set()
    hl = read(P("hook-library.md")) if ex("hook-library.md") else None
    strict_h = complete or L_cal
    if hl is None:
        if complete:
            E("hook-library.md", "missing")
    else:
        hrows, e_ = table(hl, "Hooks", HOOK_HEADER)
        errs.extend(f"hook-library.md: {m}" for m in e_)
        hrows = real(hrows, [1, 2, 3, 4])
        for r in hrows:
            hid, pat, ex_, fmt, evd, st, res = r
            e = lambda m, hid=hid: E("hook-library.md", f"hook {hid or '?'}: {m}")
            if not re.match(r"^K-\d{2,}$", hid):
                e("Hook id must look like K-01")
            hooks_ids.add(hid)
            if st not in HOOK_STATUS:
                e("Status must be hypothesis or tested")
            if st == "tested" and (posts_pub or 0) == 0:
                e("tested is impossible while posts_published is 0")
            for i in words(evd):
                if i.startswith("CP-") and i not in post_by_id:
                    e(f"evidence {i} not found in competitor-posts.csv")
            if any(is_ph(x) for x in (pat, ex_, fmt, evd)):
                if strict_h:
                    e("pattern, example line, format ids and evidence must be filled")
            if strict_h:
                for i in words(fmt):
                    if i not in fids:
                        e(f"format id {i} has no card in formats/")
        if strict_h and len(hrows) < MIN_HOOKS:
            E("hook-library.md", f"{len(hrows)} hooks, need {MIN_HOOKS}")

    # ---- style system
    if style is None:
        if complete:
            E("channel-style-system.md", "missing")
    else:
        for s_ in STYLE_SECTIONS:
            b = section(style, s_)
            if b is None:
                E("channel-style-system.md", f"missing section '## {s_}'")
            elif (complete or L_vis) and s_ != "Packaging rules" and (not filled(b, "templates/channel-style-system.md", s_) or TF in b):
                E("channel-style-system.md", f"section '{s_}' is empty or still a placeholder")
        prow, e_ = table(style, "Packaging rules", PACK_HEADER)
        errs.extend(f"channel-style-system.md: {m}" for m in e_)
        if prow is not None and (complete or L_vis):
            have = {r[0].lower(): r for r in prow}
            for el in PACK_ELEMENTS:
                r = have.get(el.lower())
                if r is None or any(is_ph(x) for x in r[1:]):
                    E("channel-style-system.md", f"packaging rule for '{el}' is missing or incomplete")

    # ---- calendar and 90-day strategy
    cal_posts = 0
    if cal is None:
        if complete:
            E("content-calendar.md", "missing")
    else:
        strict_c = complete or L_cal
        pnames = {f["name"].strip().lower() for f, _ in pillars.values()} | {f["pillar_id"].lower() for f, _ in pillars.values()}
        fnames = {f["name"].strip().lower() for f, _ in formats.values()} | {f["format_id"].lower() for f, _ in formats.values()}
        used_pillars = set()
        for sec in ("Calendar", "Idea bank"):
            crows, e_ = table(cal, sec, CAL_HEADER)
            errs.extend(f"content-calendar.md: {m}" for m in e_)
            crows = real(crows, range(1, 13))
            nums = set()
            for r in crows:
                d = dict(zip(CAL_HEADER, r))
                e = lambda m, d=d, sec=sec: E("content-calendar.md", f"{sec} #{d['#'] or '?'}: {m}")
                if not d["#"].isdigit():
                    e("# must be a whole number")
                elif d["#"] in nums:
                    e("duplicate #")
                nums.add(d["#"])
                if d["Effort"] not in EFFORT:
                    e("Effort must be S, M or L")
                if d["Status"] not in CAL_STATUS:
                    e(f"Status must be one of {sorted(CAL_STATUS)}")
                if d["Status"] == "published_by_ashish" and (posts_pub or 0) == 0:
                    e("published_by_ashish is impossible while posts_published is 0")
                if d["Planned date"] != "TBD" and not DATE.match(d["Planned date"]):
                    e("Planned date must be YYYY-MM-DD or TBD")
                for k in CAL_HEADER:
                    if is_ph(d[k]):
                        e(f"'{k}' is empty: every idea needs all ten facts")
                if d["Pillar"].lower() not in pnames and pnames:
                    e(f"Pillar '{d['Pillar']}' matches no pillar file")
                else:
                    used_pillars.add(d["Pillar"].lower())
                if d["Format"].lower() not in fnames and fnames:
                    e(f"Format '{d['Format']}' matches no format card")
                if d["Success metric"] and metric_ids and not has_metric(d["Success metric"]):
                    e("Success metric must name a metric id defined in channel-metrics.md")
            if sec == "Calendar":
                cal_posts = len(crows)
        if strict_c:
            if cal_posts < MIN_CALENDAR_POSTS:
                E("content-calendar.md", f"{cal_posts} posts in the calendar, need {MIN_CALENDAR_POSTS}")
            for f, _ in pillars.values():
                if f["name"].strip().lower() not in used_pillars and f["pillar_id"].lower() not in used_pillars:
                    W("content-calendar.md", f"pillar {f['pillar_id']} is not used by any calendar post")
        phrows, e_ = table(cal, "90-day strategy", PHASE_HEADER)
        errs.extend(f"content-calendar.md: {m}" for m in e_)
        phrows = real(phrows, [2, 3, 4])
        for r in phrows:
            if strict_c and any(is_ph(x) for x in r):
                E("content-calendar.md", f"90-day strategy phase {r[0] or '?'} has empty fields")
        if strict_c and len(phrows) < MIN_STRATEGY_PHASES:
            E("content-calendar.md", f"{len(phrows)} strategy phases, need {MIN_STRATEGY_PHASES}")

    # ---- post cards
    for fn in md_files("post-cards"):
        t = read(P("post-cards", fn))
        f = parse_fm(t)
        e = lambda m, fn=fn: E(f"post-cards/{fn}", m)
        if f is None:
            e("no front matter block")
            continue
        miss = [k for k in CARD_KEYS if k not in f]
        if miss:
            e(f"missing fields: {', '.join(miss)}")
            continue
        seen_todo = False
        for s_ in STAGES:
            v = f[s_]
            if v not in {"todo", "done"}:
                e(f"{s_} must be todo or done")
            elif v == "todo":
                seen_todo = True
            elif seen_todo:
                e(f"stage {s_} is done but an earlier stage is still todo: stages run in order")
        for s_, sec in (("research", "Research"), ("script", "Script"), ("treatment", "Treatment"),
                        ("shot_spec", "Shot specs"), ("make", "Make log"), ("qa", "QA")):
            if f.get(s_) == "done" and not filled(section(t, sec), "templates/post-production-card.md", sec):
                e(f"{s_} is done but section '{sec}' is empty")
        if f["paid_tools"] not in {"yes", "no"}:
            e("paid_tools must be yes or no")
        elif f["paid_tools"] == "yes" and f["spend_approval_id"] not in approved.get("paid_generation", []):
            e("paid_tools is yes but spend_approval_id is not an approved paid_generation row")
        if f["qa"] == "done" and (is_ph(f["made_by"]) or is_ph(f["qa_by"]) or f["made_by"].lower() == f["qa_by"].lower()):
            e("qa is done: made_by and qa_by must both be filled and must be different")

    # ---- reviews cannot exist before posts exist
    for fn in md_files("reviews"):
        t = read(P("reviews", fn))
        f = parse_fm(t)
        e = lambda m, fn=fn: E(f"reviews/{fn}", m)
        if f is None or any(k not in f for k in REVIEW_KEYS):
            e("front matter must carry " + ", ".join(REVIEW_KEYS))
            continue
        if zero_posts:
            e("a review cannot exist while posts_published is 0")
        if not f["posts_in_scope"].isdigit():
            e("posts_in_scope must be a whole number")
        elif posts_pub is not None and int(f["posts_in_scope"]) > posts_pub:
            e("posts_in_scope is larger than posts_published")
        for k in ("period_start", "period_end"):
            if not DATE.match(f[k]):
                e(f"{k} must be YYYY-MM-DD")
        rrows, e_ = table(t, "Hypothesis check", REVIEW_HEADER)
        errs.extend(f"reviews/{fn}: {m}" for m in e_)
        for r in real(rrows, [1, 2, 3, 5]):
            if r[4] not in VERDICTS:
                e(f"verdict for {r[0] or '?'} must be one of {sorted(VERDICTS)}")
            elif r[4] in {"supported", "refuted"} and (not r[3].isdigit() or int(r[3]) < MIN_POSTS_FOR_VERDICT):
                e(f"{r[0] or '?'}: supported or refuted needs n of at least {MIN_POSTS_FOR_VERDICT}; otherwise write inconclusive")

    # ---- claims of virality or performance must be tagged; the literal word in a title, quote, name or URL is not a claim
    known_ids = set(src) | set(post_by_id)
    scan = ["channel-brief.md", "channel-competitor-map.md", "hook-library.md", "channel-style-system.md",
            "content-calendar.md", "channel-metrics.md"]
    for sub in ("pillars", "formats", "post-cards", "reviews"):
        scan += [os.path.join(sub, f) for f in md_files(sub)]
    def claim_report(where, unit):
        for kind, msg in claim_issues(unit, known_ids):
            (errs if kind == "E" else warns).append(f"{where}: {msg}")
    for rel in scan:
        if not ex(rel):
            continue
        for i, line in enumerate(read(P(rel)).splitlines(), start=1):
            unit = line
            if rel == "channel-competitor-map.md" and line.strip().startswith("|"):
                cells = [c.strip() for c in line.strip()[1:-1].split("|")]
                if len(cells) == len(COMP_HEADER):
                    unit = " | ".join(cells[2:])      # competitor name and profile URL are exempt
            claim_report(f"{rel}: line {i}", unit)
    for ln, pid, unit in claim_units:
        claim_report(f"competitor-posts.csv: line {ln} ({pid})", unit)
    comp_src = {p["source_id"] for p in posts}
    if ex("rights.csv"):
        with open(P("rights.csv"), newline="", encoding="utf-8") as fh:
            for r in csv.DictReader(fh):
                if (r.get("source_id") or "") in comp_src and (
                        r.get("used_as") in {"model-input", "final-deliverable"} or r.get("model_input") == "yes"
                        or r.get("delivered") == "yes"):
                    E("rights.csv", f"{r.get('asset_id')}: competitor material may be studied for structure and technique only; it cannot be model input or delivered")
    return errs, warns, sfm

# ---------------------------------------------------------------- main
def route_of(run):
    try:
        fm = parse_fm(read(os.path.join(run, "STATUS.md"))) or {}
    except OSError:
        return None
    return fm.get("route")

args = sys.argv[1:]
only_templates = "--templates" in args
runs = [a for a in args if not a.startswith("--")]
bad = 0
if not runs and not only_templates:
    for d in sorted(os.listdir("runs")):
        p = os.path.join("runs", d)
        if d != "_template" and os.path.isdir(p) and route_of(p) == "channel-launch":
            runs.append(p)
if only_templates or not args:
    errs = check_templates()
    print("== channel templates")
    for e_ in errs:
        print(f"   ERROR {e_}")
    print(f"   {'FAIL' if errs else 'ok  '}  {len(errs)} error(s), 0 warning(s)")
    bad += 1 if errs else 0
if not only_templates:
    if not runs:
        print("== channel-launch runs: none yet")
    for run in runs:
        errs, warns, fm = check_run(run.rstrip("/"))
        print(f"== {run} (status {fm.get('status', '?')}, route {fm.get('route', '?')})")
        for w_ in warns:
            print(f"   WARN  {w_}")
        for e_ in errs:
            print(f"   ERROR {e_}")
        print(f"   {'FAIL' if errs else 'ok  '}  {len(errs)} error(s), {len(warns)} warning(s)")
        bad += 1 if errs else 0
sys.exit(1 if bad else 0)
PY
