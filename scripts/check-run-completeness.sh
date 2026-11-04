#!/usr/bin/env bash
# Check that run folders carry the full reporting contract and obey the approval and rights rules.
# Usage: scripts/check-run-completeness.sh [run-dir ...]
#   no arguments: runs/_template (structure only) and every other folder in runs/
# Needs: bash, python3 (standard library only). Exit 0 = pass, 1 = errors found, 2 = cannot run.
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 2

command -v python3 >/dev/null 2>&1 || { echo "FAIL: python3 not found"; exit 2; }

if [ "$#" -eq 0 ]; then
  set -- runs/_template
  for d in runs/*/; do
    d="${d%/}"
    [ "$d" = "runs/_template" ] && continue
    [ -d "$d" ] && set -- "$@" "$d"
  done
fi

exec python3 -I - "$@" <<'PY'
import csv, os, re, subprocess, sys

TV, TF = "[TO VERIFY]", "[TO FILL]"
CONTEXT = re.compile(r"^(studio|demo|employer|client:[A-Za-z0-9._-]+)$")
PRACTICES = {"brand", "product", "web", "motion", "film", "graphic", "content", "music", "research"}
STATUSES = {"draft", "in_progress", "blocked", "awaiting_approval", "complete", "demo"}
SECTIONS = ["Status", "Deliverables", "Evidence", "Verification", "Risks", "Next action"]
REQUIRED = ["STATUS.md", "brief.md", "sources.csv", "rights.csv", "approvals.csv", "decision-log.md"]
FM_KEYS = ["run_id", "context", "practice", "status", "director", "created", "updated"]
DATE = re.compile(r"^\d{4}-\d{2}-\d{2}$")

SRC_HEADER = ("id,url_or_path,title,platform,geography,format,date_published,date_accessed,"
              "access_method,source_class,origin_tag,rights_class,signal_type,signal_value,"
              "signal_unit,n_items,uncertainty,used_for,notes").split(",")
RIGHTS_HEADER = ("asset_id,description,type,origin_tag,source_id,rights_class,licence_or_permission,"
                 "licence_decision,approval_id,used_as,model_input,delivered,status,notes").split(",")
APPROVAL_HEADER = ("approval_id,requested_on,action_type,description,cost_quote,status,approved_on,"
                   "approval_words,executed_on,result_ref").split(",")
ACTION_TYPES = {"paid_generation", "publishing", "external_communication", "login", "account_connection",
                "deletion", "deployment", "financial_or_legal_action", "licence_decision",
                "tool_install_or_update"}
APPROVAL_STATUS = {"pending", "approved", "rejected", "expired"}
ORIGINS = {"real", "AI-made", "unknown"}
RIGHTS = {"own", "licensed", "public-domain", "analysis-only", "unknown"}
USED_AS = {"reference-analysis-only", "model-input", "final-deliverable", "internal"}
LICENCE_DECISION = {"pending", "approved", "rejected", "not-needed"}
RIGHTS_STATUS = {"pending", "cleared", "blocked", "not-applicable"}
SHOT_KEYS = ["shot_id", "story_purpose", "subject", "action", "place", "camera", "lens", "movement",
             "composition", "lighting", "colour_grade", "sound", "continuity_locks", "banned_cliches",
             "reference_evidence", "selected_tool", "qa_criteria", "approval_state",
             "generation_approval_id"]
SHOT_STATES = ["draft", "approved_to_generate", "generated", "qa_passed", "rejected"]

def read_csv(path, header):
    try:
        with open(path, newline="", encoding="utf-8") as fh:
            rows = list(csv.reader(fh))
    except OSError as e:
        return None, [f"cannot read {os.path.basename(path)}: {e}"]
    if not rows or rows[0] != header:
        return None, [f"{os.path.basename(path)}: header does not match its template"]
    out = []
    for ln, r in enumerate(rows[1:], start=2):
        if not any(c.strip() for c in r):
            continue
        if len(r) != len(header):
            return None, [f"{os.path.basename(path)} line {ln}: {len(r)} columns, expected {len(header)}"]
        out.append((ln, dict(zip(header, [c.strip() for c in r]))))
    return out, []

def front_matter(path):
    try:
        lines = open(path, encoding="utf-8").read().splitlines()
    except OSError:
        return None
    if not lines or lines[0].strip() != "---":
        return None
    fm = {}
    for line in lines[1:]:
        if line.strip() == "---":
            return fm
        m = re.match(r"^([A-Za-z0-9_]+):\s*(.*)$", line)
        if m:
            fm[m.group(1)] = re.split(r"\s{2,}#", m.group(2), maxsplit=1)[0].strip()
    return None

def section(text, name):
    m = re.search(r"(?ms)^## %s[ \t]*$(.*?)(?=^## |\Z)" % re.escape(name), text)
    return m.group(1) if m else None

def has_content(s):
    s = re.sub(r"(?s)<!--.*?-->", "", s or "")
    return any(l.strip() for l in s.splitlines())

def check_run(run, template):
    errs, warns = [], []
    err = errs.append
    name = os.path.basename(run.rstrip("/"))
    for f in REQUIRED:
        if not os.path.isfile(os.path.join(run, f)):
            err(f"missing {f}")
    if errs:
        return errs, warns, {}
    status_path = os.path.join(run, "STATUS.md")
    fm = front_matter(status_path)
    text = open(status_path, encoding="utf-8").read()
    if fm is None:
        err("STATUS.md has no front matter block")
        return errs, warns, {}
    for k in FM_KEYS:
        if k not in fm or not fm[k]:
            err(f"STATUS.md front matter missing {k}")
    if errs:
        return errs, warns, fm
    status, context = fm["status"], fm["context"]
    if fm["run_id"] != name:
        err(f"run_id '{fm['run_id']}' must equal the folder name '{name}'")
    if not CONTEXT.match(context):
        err("context must be studio, employer, demo or client:<name>")
    if fm["practice"] not in PRACTICES:
        err(f"practice must be one of {sorted(PRACTICES)}")
    if status not in STATUSES:
        err(f"status must be one of {sorted(STATUSES)}")
    if not template:
        for k in ("created", "updated"):
            if not DATE.match(fm[k]):
                err(f"{k} must be YYYY-MM-DD")
        if DATE.match(fm["created"]) and DATE.match(fm["updated"]) and fm["created"] > fm["updated"]:
            err("created is later than updated")
    bodies = {}
    for s in SECTIONS:
        bodies[s] = section(text, s)
        if bodies[s] is None:
            err(f"STATUS.md missing section '## {s}'")
    pos = [text.find(f"## {s}") for s in SECTIONS]
    if all(p >= 0 for p in pos) and pos != sorted(pos):
        err("STATUS.md sections are out of order")
    live = (not template) and status not in {"draft", "demo"}
    if live:
        for s in SECTIONS:
            if bodies[s] is not None and not has_content(bodies[s]):
                err(f"STATUS.md section '{s}' is empty")
        if TF in text:
            err(f"STATUS.md still contains {TF}")
    if not template and status == "demo":
        if context != "demo":
            err("status demo requires context demo")
        if "FICTIONAL" not in text:
            err("a demo run must say FICTIONAL in STATUS.md")

    # approvals
    approvals, e = read_csv(os.path.join(run, "approvals.csv"), APPROVAL_HEADER)
    errs.extend(e)
    approved_ids, approval_type, seen = set(), {}, set()
    for ln, d in (approvals or []):
        w = lambda m: err(f"approvals.csv line {ln} ({d['approval_id'] or '?'}): {m}")
        if not re.match(r"^AP-\d{3,}$", d["approval_id"]):
            w("approval_id must look like AP-001")
        elif d["approval_id"] in seen:
            w("duplicate approval_id")
        seen.add(d["approval_id"])
        if d["action_type"] not in ACTION_TYPES:
            w(f"action_type must be one of {sorted(ACTION_TYPES)}")
        if d["status"] not in APPROVAL_STATUS:
            w("status must be pending, approved, rejected or expired")
        if not DATE.match(d["requested_on"]):
            w("requested_on must be YYYY-MM-DD")
        approval_type[d["approval_id"]] = d["action_type"]
        if d["status"] == "approved":
            approved_ids.add(d["approval_id"])
            if not DATE.match(d["approved_on"]):
                w("approved rows need approved_on as YYYY-MM-DD")
            if not d["approval_words"] or TV in d["approval_words"] or TF in d["approval_words"]:
                w("approved rows need Ashish's actual words in approval_words")
            if d["action_type"] in {"paid_generation", "financial_or_legal_action"} and not d["cost_quote"]:
                w("paid_generation and financial_or_legal_action rows need a cost_quote")
        if d["executed_on"]:
            if d["status"] != "approved":
                w("executed without an approved status: no gated action may complete without approval")
            elif not DATE.match(d["executed_on"]):
                w("executed_on must be YYYY-MM-DD")
            elif DATE.match(d["approved_on"]) and d["approved_on"] > d["executed_on"]:
                w("approved_on is later than executed_on")
    if status == "awaiting_approval" and not any(d["status"] == "pending" for _, d in (approvals or [])):
        err("status awaiting_approval needs at least one pending row in approvals.csv")

    # sources (ids) and the ledger checker
    src_ids = set()
    sources, e = read_csv(os.path.join(run, "sources.csv"), SRC_HEADER)
    errs.extend(e)
    for _, d in (sources or []):
        src_ids.add(d["id"])
    rc = subprocess.run(["bash", "scripts/check-source-ledger.sh", os.path.join(run, "sources.csv")],
                        capture_output=True, text=True)
    for line in rc.stdout.splitlines():
        if line.startswith("WARN"):
            warns.append(line[6:].strip())
    if rc.returncode != 0:
        err("sources.csv fails scripts/check-source-ledger.sh (run it for details)")

    # rights
    rights, e = read_csv(os.path.join(run, "rights.csv"), RIGHTS_HEADER)
    errs.extend(e)
    seen = set()
    delivered_uncleared = []
    for ln, d in (rights or []):
        w = lambda m: err(f"rights.csv line {ln} ({d['asset_id'] or '?'}): {m}")
        if not re.match(r"^A-\d{3,}$", d["asset_id"]):
            w("asset_id must look like A-001")
        elif d["asset_id"] in seen:
            w("duplicate asset_id")
        seen.add(d["asset_id"])
        if d["origin_tag"] not in ORIGINS:
            w("origin_tag must be real, AI-made or unknown")
        if d["rights_class"] not in RIGHTS:
            w("rights_class must be own, licensed, public-domain, analysis-only or unknown")
        if d["used_as"] not in USED_AS:
            w(f"used_as must be one of {sorted(USED_AS)}")
        if d["licence_decision"] not in LICENCE_DECISION:
            w(f"licence_decision must be one of {sorted(LICENCE_DECISION)}")
        if d["status"] not in RIGHTS_STATUS:
            w(f"status must be one of {sorted(RIGHTS_STATUS)}")
        if d["model_input"] not in {"yes", "no"} or d["delivered"] not in {"yes", "no"}:
            w("model_input and delivered must be yes or no")
        model_in = d["model_input"] == "yes" or d["used_as"] == "model-input"
        delivered = d["delivered"] == "yes" or d["used_as"] == "final-deliverable"
        if TV in " ".join(d.values()) and (model_in or delivered):
            w(f"{TV} is allowed only on assets that are neither model input nor delivered")
        if d["rights_class"] == "analysis-only" and (model_in or delivered or d["used_as"] != "reference-analysis-only"):
            w("analysis-only references must stay reference-analysis-only: never model input, never delivered")
        if model_in:
            if d["rights_class"] not in {"own", "licensed", "public-domain"}:
                w("model input must be own, licensed or public-domain: never unlicensed third-party imagery")
            if d["licence_decision"] not in {"approved", "not-needed"} or d["status"] != "cleared":
                w("model input needs a cleared status and an approved (or not-needed) licence decision")
            if not d["licence_or_permission"]:
                w("model input needs licence_or_permission filled")
        if delivered and d["status"] != "cleared":
            w("a delivered asset must be cleared")
            delivered_uncleared.append(d["asset_id"])
        if d["licence_decision"] == "approved" and not d["approval_id"]:
            w("an approved licence decision needs its approval_id")
        if d["approval_id"]:
            if d["approval_id"] not in approval_type:
                w(f"approval_id {d['approval_id']} not found in approvals.csv")
            elif d["licence_decision"] == "approved" and (d["approval_id"] not in approved_ids or
                                                          approval_type[d["approval_id"]] != "licence_decision"):
                w("licence approval must point to an approved licence_decision row")
        if d["source_id"] and d["source_id"] != "none" and d["source_id"] not in src_ids:
            w(f"source_id {d['source_id']} not found in sources.csv")

    # shots
    shots_dir = os.path.join(run, "shots")
    shot_states = []
    if os.path.isdir(shots_dir):
        for fn in sorted(os.listdir(shots_dir)):
            if not fn.endswith(".md") or fn.lower().startswith("readme"):
                continue
            p = os.path.join(shots_dir, fn)
            sfm = front_matter(p)
            w = lambda m: err(f"shots/{fn}: {m}")
            if sfm is None:
                w("no front matter block")
                continue
            miss = [k for k in SHOT_KEYS if k not in sfm]
            if miss:
                w(f"missing fields: {', '.join(miss)}")
                continue
            state = sfm["approval_state"]
            if state not in SHOT_STATES:
                w(f"approval_state must be one of {SHOT_STATES}")
                continue
            shot_states.append(state)
            if sfm["shot_id"] != fn[:-3]:
                w(f"shot_id '{sfm['shot_id']}' must equal the file name '{fn[:-3]}'")
            unfilled = [k for k in SHOT_KEYS if k != "generation_approval_id" and (not sfm[k] or TF in sfm[k])]
            unknown = [k for k in SHOT_KEYS if TV in sfm[k]]
            if state == "draft":
                if unfilled:
                    warns.append(f"shots/{fn}: draft with unfilled fields: {', '.join(unfilled)}")
            else:
                if unfilled:
                    w(f"state {state} but empty fields: {', '.join(unfilled)}")
                if unknown:
                    w(f"state {state} but [TO VERIFY] remains in: {', '.join(unknown)}")
                ids = [x for x in re.split(r"[,\s]+", sfm["reference_evidence"]) if x]
                if not ids or ids == ["none"]:
                    w("past draft a shot must cite at least one source id in reference_evidence")
                for x in ids:
                    if x != "none" and x not in src_ids:
                        w(f"reference_evidence {x} not found in sources.csv")
                if sfm["selected_tool"].lower().startswith("none"):
                    w("past draft a shot needs a selected_tool")
            if state in {"approved_to_generate", "generated", "qa_passed"}:
                gid = sfm["generation_approval_id"]
                if gid not in approved_ids or approval_type.get(gid) != "paid_generation":
                    w("needs generation_approval_id pointing to an approved paid_generation row in approvals.csv")
                else:
                    pass

    # status-specific rules
    if not template and status == "complete":
        qa = os.path.join(run, "qa-report.md")
        if not os.path.isfile(qa):
            err("complete run needs qa-report.md")
        elif not re.search(r"(?im)^result:\s*PASS\b", open(qa, encoding="utf-8").read()):
            err("complete run needs 'result: PASS' in qa-report.md")
        if not os.path.isfile(os.path.join(run, "closeout.md")):
            err("complete run needs closeout.md")
        if any(s != "qa_passed" for s in shot_states):
            err("complete run: every shot must be qa_passed")
        for root_, _, files in os.walk(run):
            for fn in files:
                if fn.endswith(".md") and TF in open(os.path.join(root_, fn), encoding="utf-8").read():
                    err(f"complete run still contains {TF} in {os.path.relpath(os.path.join(root_, fn), run)}")

    # context separation hint
    if not template and context != "employer":
        for root_, _, files in os.walk(run):
            if os.sep + "refs" in root_:
                continue
            for fn in files:
                if fn.endswith((".md", ".csv")):
                    if re.search(r"\bCentricity\b", open(os.path.join(root_, fn), encoding="utf-8").read()):
                        warns.append(f"{os.path.relpath(os.path.join(root_, fn), run)} mentions Centricity in a non-employer context: check context separation")
    return errs, warns, fm

bad = 0
for run in sys.argv[1:]:
    template = os.path.basename(run.rstrip("/")) == "_template"
    errs, warns, fm = check_run(run, template)
    label = "template" if template else f"status {fm.get('status', '?')}, context {fm.get('context', '?')}"
    print(f"== {run} ({label})")
    for w_ in warns:
        print(f"   WARN  {w_}")
    for e_ in errs:
        print(f"   ERROR {e_}")
    print(f"   {'FAIL' if errs else 'ok  '}  {len(errs)} error(s), {len(warns)} warning(s)")
    bad += 1 if errs else 0
sys.exit(1 if bad else 0)
PY
