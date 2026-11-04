#!/usr/bin/env python3
"""Self-tests for the Studio Harness validators (run through scripts/test-validators.sh).

Builds a fully filled FICTIONAL channel-launch run in a temporary directory (never inside the repo),
then mutates copies of it and checks that scripts/check-channel-plan.sh and scripts/check-source-ledger.sh
accept what they should and reject what they should. All URLs and names in the fixture are test data.
"""
import csv, json, os, shutil, subprocess, sys, tempfile

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
RUN = "runs/2026-11-04-channel-fixture"
FRESH = "runs/2026-11-04-channel-fresh"

# ------------------------------------------------------------------ fixture
def build_fixture(root):
    run = os.path.join(root, RUN)
    for d in ("pillars", "formats", "post-cards", "shots"):
        os.makedirs(os.path.join(run, d), exist_ok=True)

    def w(rel, text):
        with open(os.path.join(run, rel), "w", encoding="utf-8") as fh:
            fh.write(text)

    w("STATUS.md", "---\nrun_id: 2026-11-04-channel-fixture\ncontext: studio\npractice: content\nstatus: complete\n"
                   "route: channel-launch\ndirector: Ashish\ncreated: 2026-11-04\nupdated: 2026-11-04\n---\n# STATUS\n\n"
                   "## Status\nComplete (test fixture).\n\n## Deliverables\nAll channel files.\n\n## Evidence\n9 posts, 3 competitors.\n\n"
                   "## Verification\nchecker run.\n\n## Risks\nAssumptions untested.\n\n## Next action\nNone.\n")
    w("brief.md", "# Project brief\n\n| Field | Value |\n|---|---|\n| Run | runs/2026-11-04-channel-fixture/ |\n| Context | studio |\n"
                  "| Practice | content |\n| Owner | Ashish |\n| Date | 2026-11-04 |\n\n## 1. Brief in his words\n> fixture\n")
    w("decision-log.md", "# Decision log\n\n## Decisions\n| Id | Date | Decision | Decided by | Basis | Affects |\n|---|---|---|---|---|---|\n"
                         "| D-01 | 2026-11-04 | fixture | Ashish | test | all |\n")
    w("qa-report.md", "# QA report\n\nresult: PASS\n\nreviewer differs from producer (fixture).\n")
    w("closeout.md", "# Closeout\n\nfixture\n")

    src_hdr = ("id,url_or_path,title,platform,geography,format,date_published,date_accessed,access_method,source_class,"
               "origin_tag,rights_class,signal_type,signal_value,signal_unit,n_items,uncertainty,used_for,notes")
    comps = [("Alpha Studio", "https://www.youtube.com/@alphastudio", "youtube-shorts", "leader", "yt"),
             ("Beta Craft", "https://www.youtube.com/@betacraft", "youtube-shorts", "closest", "yt"),
             ("Gamma Outsider", "https://www.instagram.com/gammaoutsider/", "instagram-reels", "outsider", "ig")]
    posts, srcs, n = [], [], 0
    for ci, (name, prof, plat, role, kind) in enumerate(comps):
        for k in range(3):
            n += 1
            url = (f"https://www.youtube.com/shorts/FIXT{ci}{k}aaaa" if kind == "yt"
                   else f"https://www.instagram.com/reel/FIXTURE{ci}{k}/")
            srcs.append(f"S-{n:03d},{url},{name} post {k+1},{plat},IN,short,2026-10-0{k+1},2026-11-04,"
                        f"{'yt-dlp-public' if kind == 'yt' else 'public-web'},OBSERVED,real,analysis-only,,,,,"
                        f"{'' if kind == 'yt' else 'public reel; no rate limit hit'},reference,{'' if kind == 'yt' else 'public'}")
            posts.append(dict(post_id=f"CP-{n:03d}", competitor=name, source_id=f"S-{n:03d}", url=url, platform=plat,
                              date_published=f"2026-10-0{k+1}", date_accessed="2026-11-04", views="unknown", likes="unknown",
                              comments="unknown", metrics_note="counts not shown on page", format="talking head with b-roll",
                              duration_s="38", hook="question over a close-up",
                              shot_structure="0-2s close-up; 2-9s b-roll; 9-30s demo; 30-38s payoff",
                              packaging="plain title, bold overlay", audience_promise="learn one trick fast",
                              retention_hypothesis="H: the demo beat holds viewers to the payoff",
                              observed_facts="OBSERVED: four beats, captions on, no music",
                              interpretation="INFERRED: format is cheap to repeat",
                              unknowns="UNKNOWN: retention and audience mix",
                              examined_how="video-watched+frames-viewed", comparative_signal="none"))
    with open(os.path.join(run, "sources.csv"), "w", encoding="utf-8") as fh:
        fh.write(src_hdr + "\n" + "\n".join(srcs) + "\n")
    hdr = ("post_id,competitor,source_id,url,platform,date_published,date_accessed,views,likes,comments,metrics_note,format,"
           "duration_s,hook,shot_structure,packaging,audience_promise,retention_hypothesis,observed_facts,interpretation,"
           "unknowns,examined_how,comparative_signal").split(",")
    with open(os.path.join(run, "competitor-posts.csv"), "w", newline="", encoding="utf-8") as fh:
        cw = csv.writer(fh)
        cw.writerow(hdr)
        for p in posts:
            cw.writerow([p[h] for h in hdr])
    shutil.copy(os.path.join(root, "templates", "asset-rights-ledger.csv"), os.path.join(run, "rights.csv"))
    appr = ["approval_id,requested_on,action_type,description,cost_quote,status,approved_on,approval_words,executed_on,result_ref"]
    for i, lt in enumerate(["lock_positioning", "lock_pillars", "lock_visual_direction", "lock_calendar"], start=1):
        appr.append(f"AP-00{i},2026-11-04,{lt},lock request,,approved,2026-11-04,yes lock it,,")
    w("approvals.csv", "\n".join(appr) + "\n")

    rows = "\n".join(f"| {nm} | {prof} | {plat} | {role} | comparable for the fixture | "
                     f"CP-{ci*3+1:03d} CP-{ci*3+2:03d} CP-{ci*3+3:03d} | 2026-11-04 |"
                     for ci, (nm, prof, plat, role, kind) in enumerate(comps))
    w("channel-competitor-map.md", "# Channel competitor map\n\n## Method and access\nPublic posts watched; Instagram public only.\n\n"
      "## Competitors\n| Competitor | Profile URL | Platform | Role | Why comparable | Post ids analysed | Last checked |\n"
      "|---|---|---|---|---|---|---|\n" + rows + "\n\n## Patterns across posts\n- INFERRED: all three lead with a close-up and a question (CP-001, CP-004, CP-007).\n\n"
      "## Whitespace and opportunities\n- Nobody shows the failure first (H-02).\n\n## Unknowns and limits\n- Retention unknown for every post.\n")
    w("channel-brief.md", """---
channel_name: Fixture Channel
platforms: youtube-shorts, instagram-reels
handle_status: unregistered
posts_published: 0
audience_data: none
positioning_lock: locked
---
# Channel brief — Fixture Channel

## Starting state
- Posts published: 0. No audience data.

## Goal and success
- Learn which of three hypotheses holds in 90 days.

## Audience and category
- Hypothesis: busy beginners open the app after work wanting one quick win.

## Assumptions
| ID | Assumption | Type | Status | Evidence (source ids) | How we will test | Test by |
|---|---|---|---|---|---|---|
| H-01 | Busy beginners want one quick win after work | audience | hypothesis | S-001 | compare first 10 posts on M1 | 2026-12-15 |
| H-02 | Showing the failure first is unclaimed | category | hypothesis | S-004 S-007 | track M1 for failure-first hooks | 2026-12-15 |
| H-03 | A four-beat format is repeatable weekly | production | unverified | S-002 | log effort per post in M4 | 2026-12-15 |

## Positioning hypothesis
For busy beginners after work, the channel shows the failure first, unlike the three studied channels.

## Channel promise
One quick win, honestly shown.

## Editorial voice
Plain, dry, never smug. Do: say what failed. Do-not: promise miracles.

## Constraints and resources
- Five hours a week; no paid tools.

## Rights and licensing
- Competitor posts are analysis-only.

## What we will not do
- Reuse any creator's footage.

## Locks needed from Ashish
All four granted in this fixture.
""")
    for i, (pid, nm, prom, mom) in enumerate([("P1", "Failure first", "See what goes wrong before the fix", "after a bad attempt"),
                                               ("P2", "One quick win", "One trick you can do tonight", "evening wind-down"),
                                               ("P3", "Tool honesty", "What the tool really does", "before buying")], start=1):
        w(f"pillars/{pid}.md", f"---\npillar_id: {pid}\nname: {nm}\npromise: {prom}\naudience_moment: {mom}\nevidence: S-00{i} H-0{i}\n"
                               f"formats: F1, F2\nshare_of_calendar: 33 percent as a hypothesis\nrisk: may feel negative\n"
                               f"success_metric: M{i if i < 3 else 1}\nlock_state: locked\n---\n# Pillar {pid}\n\n## Why this pillar\n- fixture\n")
    for fid, nm in (("F1", "Four-beat demo"), ("F2", "Failure reel")):
        w(f"formats/{fid}.md", f"---\nformat_id: {fid}\nname: {nm}\nseries_name: {nm} series\npillar_ids: P1, P2, P3\nplatform: youtube-shorts\n"
                               f"length: 30 to 40 seconds\ncadence: 2 per week\nstructure: hook; setup; demo; payoff\n"
                               f"hook_pattern: question over a close-up\nproof_value: a visible result\nmaking_method: phone camera plus ffmpeg (stage 0)\n"
                               f"packaging_pattern: plain title, bold overlay\neffort: M\nrisk: sameness\nsuccess_metric: M1\nlock_state: locked\n---\n# Format {fid}\n")
    hooks = "\n".join(f"| K-0{i} | pattern {i} | Original line number {i} | F1 | CP-00{i} | hypothesis | not tested |" for i in range(1, 6))
    w("hook-library.md", "# Hook library\n\n## Principles\n- fixture rules written fresh.\n\n## Hooks\n"
      "| Hook id | Pattern | Original example line | Format ids | Evidence (post ids) | Status | Result |\n|---|---|---|---|---|---|---|\n" + hooks + "\n")
    w("channel-style-system.md", """---
lock_state: locked
---
# Channel style system

## Derived from
Positioning H-02: failure first.

## Visual direction
Raw, daylight, handheld, no filters.

## Colour and type
Warm grey #8A8580 as ground; one signal orange #E8590C for overlays; a licensed grotesque (licence decision pending).

## Thumbnail and cover system
Subject left, one overlay word right, no faces cropped.

## Motion, captions and sound
Hard cuts, large captions, room tone only.

## Packaging rules
| Element | Rule | Basis (post ids or hypothesis ids) | Original example |
|---|---|---|---|
| Title | state the failure | H-02 | I burned the first one |
| Hook | show the failure in two seconds | CP-001 | the sink full of smoke |
| Thumbnail or cover | failure frame plus one word | H-02 | burnt toast, word OOPS |
| Caption | one sentence, no emoji pile | CP-004 | Here is what went wrong. |
| CTA | ask for their own failure | H-01 | Send me yours |

## What we deliberately do not borrow
Alpha Studio's colour grade and Beta Craft's logo animation stay theirs.

## Accessibility and safety
Contrast above 4.5, captions on every post.
""")
    cal = "\n".join(f"| {i} | TBD | {['P1', 'P2', 'P3'][i % 3]} | F{1 + i % 2} | after work | one trick {i} | hook {i} | visible result | "
                    f"phone plus ffmpeg | overlay word | S | may flop | M1 baseline | planned |" for i in range(1, 31))
    w("content-calendar.md", "---\nlock_state: locked\nstart_date: TBD\n---\n# Content calendar\n\n## Principles\n- fixture\n\n## Calendar\n"
      "| # | Planned date | Pillar | Format | Audience moment | Promise (one line) | Hook | Proof / value | Making method | Packaging idea | Effort | Risk | Success metric | Status |\n"
      "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|\n" + cal + "\n\n## Idea bank\n"
      "| # | Planned date | Pillar | Format | Audience moment | Promise (one line) | Hook | Proof / value | Making method | Packaging idea | Effort | Risk | Success metric | Status |\n"
      "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|\n\n## 90-day strategy\n"
      "| Phase | Days | Objective | Hypothesis being tested | Decision at end |\n|---|---|---|---|---|\n"
      "| 1 | 1 to 30 | ship and learn | H-01 | keep or change the hook pattern |\n| 2 | 31 to 60 | repeat what works | H-02 | double down or retire |\n"
      "| 3 | 61 to 90 | consolidate | H-03 | fix the cadence |\n")
    w("channel-metrics.md", """# Channel metrics

## Metric definitions
| Metric id | Name | Definition | Source | Cadence | Type | Decision it informs |
|---|---|---|---|---|---|---|
| M1 | Views vs own median | views divided by median of previous 10 posts | platform analytics supplied by Ashish | per post | packaging | which hooks to keep |
| M2 | Average view duration | seconds watched divided by length | owner analytics | weekly | retention | which formats to repeat |
| M3 | Follower change | net followers per week | owner analytics | weekly | growth | whether the promise lands |
| M4 | Effort per post | hours logged against S, M, L | make log | per post | production | calendar capacity |

## Comparative signal definition
An outlier is a post with views at least 2 times the median of the previous 10 posts (n of 10 or more).

## Decision rules
| Rule id | If | Then | Min posts |
|---|---|---|---|
| DR-01 | M1 below 0.5 for a hook pattern | retire the hook | 5 |
| DR-02 | M2 above the format median | repeat the format | 5 |
| DR-03 | M4 above plan twice | cut scope | 5 |

## Review cadence
After 10 posts, then every 10 posts or 30 days.

## Own-channel observations
| Date | Post ref | Metric id | Value | Source | Note |
|---|---|---|---|---|---|

## Honest limits
Retention is owner-only data.
""")

# ------------------------------------------------------------------ mutation helpers
def rd(root, rel):
    with open(os.path.join(root, RUN, rel), encoding="utf-8") as fh:
        return fh.read()

def wr(root, rel, text):
    with open(os.path.join(root, RUN, rel), "w", encoding="utf-8") as fh:
        fh.write(text)

def sub(root, rel, old, new, all_=False):
    t = rd(root, rel)
    assert old in t, (rel, old)
    wr(root, rel, t.replace(old, new) if all_ else t.replace(old, new, 1))

def drop_lines(root, rel, prefix):
    wr(root, rel, "".join(l for l in rd(root, rel).splitlines(True) if not l.startswith(prefix)))

def append(root, rel, text):
    os.makedirs(os.path.dirname(os.path.join(root, RUN, rel)), exist_ok=True)
    with open(os.path.join(root, RUN, rel), "a", encoding="utf-8") as fh:
        fh.write(text)

def tag(label="INFERRED", metric="views", basis="2.1x median of previous 20 posts", n="20",
        platform="youtube-shorts", date="2026-10-01..2026-10-28", source="CP-004"):
    parts = [label] if label is not None else []
    for k, v in (("metric", metric), ("basis", basis), ("n", n), ("platform", platform), ("date", date), ("source", source)):
        if v is not None:
            parts.append(f"{k}={v}")
    return "CLAIM[" + "; ".join(parts) + "]"

def note(root, line):
    append(root, "pillars/P1.md", "\n## Notes\n- " + line + "\n")

# ------------------------------------------------------------------ tests
TESTS = []   # (name, kind, mutate, mode, expect)   mode: reject | accept ; expect: substring (reject) or warn substring/None (accept)
def reject(name, expect, kind="chan"):
    def deco(fn):
        TESTS.append((name, kind, fn, "reject", expect)); return fn
    return deco
def accept(name, warn=None, kind="chan"):
    def deco(fn):
        TESTS.append((name, kind, fn, "accept", warn)); return fn
    return deco

# --- the viral / performance claim rule: what must be ACCEPTED
@accept("literal word in a source title (ledger and plan)")
def _(r): sub(r, "sources.csv", "Alpha Studio post 1", "How to go viral in 7 days")
@accept("literal word in a source title (ledger)", kind="ledger")
def _(r): sub(r, "sources.csv", "Alpha Studio post 1", "How to go viral in 7 days")
@accept("literal word in a creator name")
def _(r):
    sub(r, "channel-competitor-map.md", "Gamma Outsider", "Going Viral Studio", all_=True)
    sub(r, "competitor-posts.csv", "Gamma Outsider", "Going Viral Studio", all_=True)
@accept("literal word in a quoted caption")
def _(r): sub(r, "competitor-posts.csv", "question over a close-up", 'caption reads "went viral overnight" over a close-up')
@accept("literal word inside an evidence URL")
def _(r):
    sub(r, "sources.csv", "https://www.youtube.com/shorts/FIXT00aaaa", "https://www.youtube.com/shorts/viral-tipsaa")
    sub(r, "competitor-posts.csv", "https://www.youtube.com/shorts/FIXT00aaaa", "https://www.youtube.com/shorts/viral-tipsaa")
@accept("literal word inside a URL on a prose line")
def _(r): note(r, "see https://example.com/how-to-go-viral for the creator's own wording")
@accept("literal word in a double-quoted span on a prose line")
def _(r): note(r, 'Their title says "viral hack" but this channel makes no such claim.')
@accept("quoted word plus a curly-quoted span")
def _(r): note(r, "Their caption “went viral” is theirs, not our claim.")
@accept("valid tagged claim (ratio basis, n=20)", warn=None)
def _(r): note(r, "CP-004 outperformed its own channel baseline " + tag())
@accept("valid tagged claim (numerator/denominator basis)")
def _(r): note(r, "CP-007 went viral by this measure " + tag(basis="1200/400", metric="likes per view", source="S-003", label="OBSERVED"))
@accept("valid tagged claim with n=3 passes with a warning", warn="fewer than 5")
def _(r): note(r, "CP-004 blew up " + tag(n="3"))
@accept("valid tagged claim inside the competitor ledger")
def _(r): sub(r, "competitor-posts.csv", "INFERRED: format is cheap to repeat", "INFERRED: top-performing against peers " + tag(), )
@accept("valid tagged claim in a table row of the calendar")
def _(r): sub(r, "content-calendar.md", "visible result | phone plus ffmpeg | overlay word | S | may flop | M1 baseline | planned |\n| 2 |",
              "breakout style proof " + tag() + " | phone plus ffmpeg | overlay word | S | may flop | M1 baseline | planned |\n| 2 |")
@accept("valid tagged claim in the source ledger", kind="ledger")
def _(r): sub(r, "sources.csv", "reference,\n", "reference,this post went viral " + tag(source="S-004") + "\n")

# --- what must be REJECTED
@reject("untagged claim that a post went viral", "unsupported claim")
def _(r): sub(r, "content-calendar.md", "hook 3 ", "went viral hook ")
@reject("untagged outperforms", "unsupported claim")
def _(r): note(r, "Alpha outperforms everyone")
@reject("untagged virality", "unsupported claim")
def _(r): note(r, "the virality of this format is obvious")
@reject("untagged top-performing", "unsupported claim")
def _(r): note(r, "a top-performing post")
@reject("untagged breakout", "unsupported claim")
def _(r): note(r, "a breakout hit")
@reject("tag without a label", "label must be OBSERVED or INFERRED")
def _(r): note(r, "went viral " + tag(label=None))
@reject("tag with label RECOMMENDED", "label must be OBSERVED or INFERRED")
def _(r): note(r, "went viral " + tag(label="RECOMMENDED"))
@reject("tag without metric", "missing metric")
def _(r): note(r, "went viral " + tag(metric=None))
@reject("tag with a basis that is not a ratio", "basis must be")
def _(r): note(r, "went viral " + tag(basis="huge"))
@reject("tag without n", "missing n")
def _(r): note(r, "went viral " + tag(n=None))
@reject("tag with n of zero", "n must be a whole number of at least 1")
def _(r): note(r, "went viral " + tag(n="0"))
@reject("tag with n not a number", "n must be a whole number of at least 1")
def _(r): note(r, "went viral " + tag(n="many"))
@reject("tag without platform", "missing platform")
def _(r): note(r, "went viral " + tag(platform=None))
@reject("tag without date", "missing date")
def _(r): note(r, "went viral " + tag(date=None))
@reject("tag with a bad date", "date must be")
def _(r): note(r, "went viral " + tag(date="last week"))
@reject("tag with an unknown source id", "not a known source or post id")
def _(r): note(r, "went viral " + tag(source="CP-099"))
@reject("tag without a source", "missing source")
def _(r): note(r, "went viral " + tag(source=None))
@reject("tag on a different line from the claim", "unsupported claim")
def _(r): append(r, "pillars/P1.md", "\n## Notes\n- CP-004 went viral\n- " + tag() + "\n")
@reject("quoted word on the line does not excuse a second, unquoted claim", "unsupported claim")
def _(r): note(r, '"viral hack" is their title but this post went viral')
@reject("unclosed tag does not count", "unsupported claim")
def _(r): note(r, "went viral CLAIM[INFERRED; metric=views; basis=2x median of 10; n=10")
@reject("untagged claim in the competitor ledger", "unsupported claim")
def _(r): sub(r, "competitor-posts.csv", "INFERRED: format is cheap to repeat", "INFERRED: this post went viral")
@reject("tag with a bad field inside the competitor ledger", "invalid claim tag")
def _(r): sub(r, "competitor-posts.csv", "INFERRED: format is cheap to repeat", "INFERRED: outperformed " + tag(n="0"))
@reject("untagged claim in the source ledger notes", "unsupported claim", kind="ledger")
def _(r): sub(r, "sources.csv", "reference,\n", "reference,this post went viral\n")
@reject("source ledger tag citing an id that is not in the ledger", "not a known source or post id", kind="ledger")
def _(r): sub(r, "sources.csv", "reference,\n", "reference,went viral " + tag(source="CP-004") + "\n")

# --- "exploded": a drawing term is never a claim; said of a post or its numbers it is a performance claim
@accept("exploded view is a drawing term, not a claim")
def _(r): note(r, "The cutaway opens with an exploded view of the gearbox.")
@accept("exploded steps and exploded diagram in prose")
def _(r): note(r, "Frame 3 shows exploded steps; frame 5 is an exploded diagram of the step chain.")
@accept("exploded view in the competitor ledger")
def _(r): sub(r, "competitor-posts.csv", "INFERRED: format is cheap to repeat", "INFERRED: the exploded view makes the mechanism readable")
@accept("exploded view in the source ledger", kind="ledger")
def _(r): sub(r, "sources.csv", "reference,\n", "reference,blueprint-grid exploded view of an assembly\n")
@accept("a tagged claim that the post exploded is accepted")
def _(r): note(r, "CP-004 exploded in views " + tag() + " compared with its own baseline")
@reject("unsupported: the post exploded", "unsupported claim")
def _(r): note(r, "The post exploded.")
@reject("unsupported: views exploded overnight", "unsupported claim")
def _(r): note(r, "Its views exploded overnight.")
@reject("unsupported: it exploded in popularity", "unsupported claim")
def _(r): note(r, "After the repost it exploded in popularity.")
@reject("unsupported: this video exploded (competitor ledger)", "unsupported claim")
def _(r): sub(r, "competitor-posts.csv", "INFERRED: format is cheap to repeat", "INFERRED: this video exploded")
@reject("unsupported: this short exploded (source ledger)", "unsupported claim", kind="ledger")
def _(r): sub(r, "sources.csv", "reference,\n", "reference,this short exploded\n")
@reject("invalid tag next to an exploded claim", "invalid claim tag")
def _(r): note(r, "The post exploded " + tag(n="0"))

# --- every other Channel Launch gate stays enforced (carried over unchanged)
@reject("drop lock_calendar approval", "approved lock_calendar")
def _(r): drop_lines(r, "approvals.csv", "AP-004")
@reject("lock_positioning approval only pending", "no approved lock_positioning")
def _(r): sub(r, "approvals.csv", "AP-001,2026-11-04,lock_positioning,lock request,,approved,2026-11-04,yes lock it,,", "AP-001,2026-11-04,lock_positioning,lock request,,pending,,,,")
@reject("lock approval without his words", "no approved lock_positioning")
def _(r): sub(r, "approvals.csv", "approved,2026-11-04,yes lock it,,\nAP-002", "approved,2026-11-04,,,\nAP-002")
@reject("only two pillars", "need at least 3 distinct pillars")
def _(r): os.remove(os.path.join(r, RUN, "pillars", "P3.md"))
@reject("duplicate pillar promise", "must be distinct")
def _(r): sub(r, "pillars/P2.md", "promise: One trick you can do tonight", "promise: See what goes wrong before the fix")
@reject("competitor URL is a profile page", "not a channel or profile page")
def _(r): sub(r, "competitor-posts.csv", "https://www.youtube.com/shorts/FIXT00aaaa", "https://www.youtube.com/@alphastudio")
@reject("bio or title-only examination", "examined_how")
def _(r): sub(r, "competitor-posts.csv", "video-watched+frames-viewed", "title-only")
@reject("only two assumptions", "need 3")
def _(r): drop_lines(r, "channel-brief.md", "| H-03")
@reject("fewer than 4 metrics", "metrics defined, need 4")
def _(r):
    drop_lines(r, "channel-metrics.md", "| M3"); drop_lines(r, "channel-metrics.md", "| M4")
@reject("observation at zero posts", "own-channel observations exist")
def _(r): sub(r, "channel-metrics.md", "|---|---|---|---|---|---|\n\n## Honest limits", "|---|---|---|---|---|---|\n| 2026-11-05 | 1 | M1 | 1200 | analytics | n |\n\n## Honest limits")
@reject("review at zero posts", "cannot exist while posts_published is 0")
def _(r): append(r, "reviews/R-01.md", "---\nreview_id: R-01\nperiod_start: 2026-11-05\nperiod_end: 2026-11-30\nposts_in_scope: 3\nreviewer: x\n---\n# r\n\n## Hypothesis check\n| Assumption or rule id | Prediction | Observed | n | Verdict | Next step |\n|---|---|---|---|---|---|\n| H-01 | a | b | 3 | supported | c |\n")
@reject("hook marked tested at zero posts", "tested is impossible")
def _(r): sub(r, "hook-library.md", "| K-01 | pattern 1 | Original line number 1 | F1 | CP-001 | hypothesis | not tested |", "| K-01 | pattern 1 | Original line number 1 | F1 | CP-001 | tested | worked |")
@reject("own-analytics at zero posts", "audience_data must be none")
def _(r): sub(r, "channel-brief.md", "audience_data: none", "audience_data: own-analytics")
@reject("29 calendar rows", "29 posts in the calendar")
def _(r): drop_lines(r, "content-calendar.md", "| 30 |")
@reject("calendar row missing a fact", "'Risk' is empty")
def _(r): sub(r, "content-calendar.md", "may flop | M1 baseline | planned |\n| 2 |", " | M1 baseline | planned |\n| 2 |")
@reject("competitor with a single analysed post", "analysed posts, need 2")
def _(r):
    drop_lines(r, "competitor-posts.csv", "CP-002,"); drop_lines(r, "competitor-posts.csv", "CP-003,")
@reject("no outsider", "no competitor with role outsider")
def _(r): sub(r, "channel-competitor-map.md", "| outsider |", "| parallel |")
@reject("outlier comparative signal without sample size", "comparative_signal")
def _(r): sub(r, "competitor-posts.csv", ",none\n", ",3x better than others\n")
@reject("observed facts without OBSERVED prefix", "must start with 'OBSERVED:'")
def _(r): sub(r, "competitor-posts.csv", "OBSERVED: four beats", "four beats")
@reject("views not a number", "whole number or the word unknown")
def _(r): sub(r, "competitor-posts.csv", ",unknown,unknown,unknown,", ",1.2k,unknown,unknown,")
@reject("practice unknown with channel files", "practice is unknown")
def _(r): sub(r, "STATUS.md", "practice: content", "practice: unknown"); sub(r, "STATUS.md", "status: complete", "status: blocked")
@reject("spend before locks", "production spend was executed")
def _(r):
    sub(r, "channel-brief.md", "positioning_lock: locked", "positioning_lock: draft")
    append(r, "approvals.csv", "AP-005,2026-11-04,paid_generation,gen,10 credits [U] 2026-11-04,approved,2026-11-04,go,2026-11-04,out\n")
@reject("paid connector used without approval", "paid connector was used")
def _(r): sub(r, "sources.csv", "yt-dlp-public", "paid-connector-approved")
@reject("competitor material used as model input", "competitor material may be studied")
def _(r): append(r, "rights.csv", "A-001,frame,still,real,S-001,licensed,x,approved,AP-001,model-input,yes,no,cleared,\n")
@reject("pillar cites an unknown id", "neither a source id")
def _(r): sub(r, "pillars/P1.md", "evidence: S-001 H-01", "evidence: S-099 H-01")
@reject("success metric without a metric id", "metric id")
def _(r): sub(r, "content-calendar.md", "M1 baseline | planned |\n| 2 |", "baseline | planned |\n| 2 |")
@reject("post card stages out of order", "stages run in order")
def _(r): append(r, "post-cards/01.md", "---\npost_ref: 01\npillar_id: P1\nformat_id: F1\nmade_by: a\nqa_by: b\nresearch: todo\nscript: done\ntreatment: todo\nshot_spec: todo\nmake: todo\nqa: todo\npaid_tools: no\nspend_approval_id: none\n---\n# c\n\n## Script\nwords\n")
@reject("post card QA by the maker", "must be different")
def _(r): append(r, "post-cards/02.md", "---\npost_ref: 02\npillar_id: P1\nformat_id: F1\nmade_by: a\nqa_by: a\nresearch: done\nscript: done\ntreatment: done\nshot_spec: done\nmake: done\nqa: done\npaid_tools: no\nspend_approval_id: none\n---\n# c\n\n## Research\nr1\n\n## Script\ns1\n\n## Treatment\nt1\n\n## Shot specs\nx1\n\n## Make log\nm1\n\n## QA\nq1\n")
@reject("post card paid tools without approval", "spend_approval_id")
def _(r): append(r, "post-cards/03.md", "---\npost_ref: 03\npillar_id: P1\nformat_id: F1\nmade_by: a\nqa_by: b\nresearch: todo\nscript: todo\ntreatment: todo\nshot_spec: todo\nmake: todo\nqa: todo\npaid_tools: yes\nspend_approval_id: AP-099\n---\n# c\n")
@reject("source row URL differs from post URL", "different URL")
def _(r): sub(r, "sources.csv", "https://www.youtube.com/shorts/FIXT00aaaa", "https://www.youtube.com/shorts/OTHERaaaaaa")
@reject("complete but calendar still draft", "all locked")
def _(r): sub(r, "content-calendar.md", "lock_state: locked", "lock_state: draft")
@reject("calendar locked before pillars", "calendar cannot be locked before pillars")
def _(r): sub(r, "pillars/P1.md", "lock_state: locked", "lock_state: draft")
@reject("validated-own at zero posts", "validated-own is impossible")
def _(r): sub(r, "channel-brief.md", "| H-03 | A four-beat format is repeatable weekly | production | unverified |", "| H-03 | A four-beat format is repeatable weekly | production | validated-own |")
@reject("audience assumption stated as validated", "audience claims are hypotheses")
def _(r): sub(r, "channel-brief.md", "| audience | hypothesis | S-001 |", "| audience | validated-external | S-001 |")
@reject("only 7 posts analysed in total", "posts analysed in total")
def _(r):
    drop_lines(r, "competitor-posts.csv", "CP-003,"); drop_lines(r, "competitor-posts.csv", "CP-006,")
@reject("measurement plan missing", "measurement plan is required")
def _(r): os.remove(os.path.join(r, RUN, "channel-metrics.md"))
@reject("decision rule below minimum posts", "Min posts must be at least 5")
def _(r): sub(r, "channel-metrics.md", "| retire the hook | 5 |", "| retire the hook | 1 |")
@reject("hook cites unknown competitor post", "not found in competitor-posts.csv")
def _(r): sub(r, "hook-library.md", "| F1 | CP-001 |", "| F1 | CP-099 |")

# --- a fresh draft run built from the templates must still pass (template guidance must not trip the claim rule)
def fresh_run(root):
    r = os.path.join(root, FRESH)
    shutil.copytree(os.path.join(root, "runs", "_template"), r)
    st = open(os.path.join(r, "STATUS.md"), encoding="utf-8").read()
    st = (st.replace("run_id: _template", "run_id: 2026-11-04-channel-fresh").replace("practice: unknown", "practice: content")
          .replace("route: standard", "route: channel-launch").replace("YYYY-MM-DD", "2026-11-04"))
    open(os.path.join(r, "STATUS.md"), "w", encoding="utf-8").write(st)
    t = os.path.join(root, "templates")
    for f in ("channel-brief.md", "channel-competitor-map.md", "hook-library.md", "channel-style-system.md",
              "content-calendar.md", "channel-metrics.md"):
        shutil.copy(os.path.join(t, f), os.path.join(r, f))
    shutil.copy(os.path.join(t, "competitor-post-ledger.csv"), os.path.join(r, "competitor-posts.csv"))
    for sub_, f in (("pillars", "content-pillar.md"), ("formats", "format-card.md"), ("post-cards", "post-production-card.md")):
        os.makedirs(os.path.join(r, sub_)); shutil.copy(os.path.join(t, f), os.path.join(r, sub_, "x.md"))
    return r


# ------------------------------------------------------------------ secret scan, allowlist and sanitizer tests
# Synthetic values are assembled from fragments so this file never contains a secret-shaped string itself.
def _g():  return "AI" + "za" + "SyD3adbeef0123456789abcdefghijklmnop"[:35]
def _vis(): return "visitor" + "Data"
def _ip():  return "i" + "p=203.0.113." + "7"
def _scan(base, root):
    p = subprocess.run(["bash", os.path.join(base, "scripts", "scan-secrets.sh"), root], capture_output=True, text=True)
    return p.returncode, p.stdout + p.stderr
def _san(base, root, *dirs):
    p = subprocess.run(["bash", os.path.join(base, "scripts", "sanitize-captures.sh"), *[os.path.join(root, d) for d in dirs]],
                       capture_output=True, text=True)
    return p.returncode, p.stdout + p.stderr
def _put(root, rel, text):
    path = os.path.join(root, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(text)

def run_scan_tests(base, tmp):
    results = []
    def case(name, rc_want, text_want, root_fn):
        root = os.path.join(tmp, "scan_%03d" % (len(results) + 1))
        os.makedirs(root)
        root_fn(root)
        rc, out = _scan(base, root)
        ok = rc == rc_want and (text_want is None or text_want in out)
        results.append((name, ok, out))
    sig_ctx = "https://example.test/v?expire=1&sig=AE0s"
    # clean and allowlisted
    case("clean tree passes", 0, None, lambda r: _put(r, "docs/a.md", "nothing secret here\n"))
    case("A1: AIza-looking bytes inside a sig parameter are allowlisted", 0, "A1=1",
         lambda r: _put(r, "runs/x/refs/c/meta.json", '{"u": "' + sig_ctx + _g()[4:].join(["AI" + "za", ""]) + '"}'))
    case("A2: public web-client key as INNERTUBE_API_KEY in a refs capture is allowlisted (one key is matched by two scanner classes)", 0, "A2=2",
         lambda r: _put(r, "runs/x/refs/c/about.html", '<script>{"INNERTUBE_API_KEY":"' + _g() + '"}</script>'))
    case("redacted placeholders are not findings", 0, None,
         lambda r: _put(r, "runs/x/refs/c/about.html", '{"' + _vis() + '":"[redacted]","token":"[redacted]"}'))
    # the allowlist stays narrow
    case("A2 does not apply outside a refs capture", 1, "api-key:google",
         lambda r: _put(r, "docs/about.html", '{"INNERTUBE_API_KEY":"' + _g() + '"}'))
    case("A2 does not cover another field name", 1, "api-key:google",
         lambda r: _put(r, "runs/x/refs/c/about.html", '{"someField":"' + _g() + '"}'))
    case("A1 does not cover a plain key parameter", 1, "api-key:google",
         lambda r: _put(r, "runs/x/refs/c/meta.json", '{"u": "https://example.test/v?key=' + _g() + '"}'))
    case("a Google key in a document is a finding", 1, "api-key:google", lambda r: _put(r, "docs/k.md", "key " + _g() + "\n"))
    # raw captures are scanned, not skipped
    case("visitor data in a refs capture is a finding", 1, "session:visitor-or-xsrf",
         lambda r: _put(r, "runs/x/refs/c/about.html", '{"' + _vis() + '":"CgtAbCdEfGhIjKlMnOpQrStUv"}'))
    case("an IP-bearing signed URL in a refs dump is a finding", 1, "session:ip-bearing-url",
         lambda r: _put(r, "runs/x/refs/c/meta.json", '{"u":"https://rr1.example.test/videoplayback?expire=1&' + _ip() + '&sig=ABCDEFG"}'))
    case("an auth cookie value is a finding", 1, "session:auth-cookie",
         lambda r: _put(r, "runs/x/refs/c/h.txt", "SAP" + "ISID=abcdefghijklmnopqr\n"))
    case("a Cookie header with a value is a finding", 1, "session:cookie-header",
         lambda r: _put(r, "runs/x/refs/c/h.txt", "Set-" + "Cookie: NAME=abcdefghijk\n"))
    case("a generic token value is a finding", 1, "generic-key-value",
         lambda r: _put(r, "runs/x/refs/c/about.html", '{"token":"' + "Q" * 24 + '"}'))
    case("an sk- style key is a finding", 1, "api-key:sk-", lambda r: _put(r, "docs/k.md", "sk" + "-" + "A" * 24 + "\n"))
    for nm in ("cookies.txt", ".env", "auth.json", "id.pem"):
        case(f"credential-like file name {nm} is a finding", 1, "credential-like file name", lambda r, nm=nm: _put(r, f"runs/x/refs/c/{nm}", "x\n"))
    # sanitizer round trip
    root = os.path.join(tmp, "san_1"); os.makedirs(root)
    dirty = ('{"' + _vis() + '":"CgtAbCdEfGhIjKlMnOpQrStUv","clickTrackingParams":"CAEQxyz12345678",'
             '"u":"https://rr1.example.test/videoplayback?expire=1&' + _ip() + '&sig=ABCDEFG&redir_' + 'token=QUFFabc' + 'def123456",'
             '"k":"' + _g() + '","token":"' + "Q" * 24 + '"}')
    _put(root, "runs/x/refs/c/meta.json", dirty)
    rc0, _ = _scan(base, root)
    _san(base, root, "runs/x/refs")
    rc1, out1 = _scan(base, root)
    try:
        json.loads(open(os.path.join(root, "runs/x/refs/c/meta.json"), encoding="utf-8").read()); valid = True
    except ValueError:
        valid = False
    results.append(("sanitizer: dirty capture is found, cleaned, still valid JSON, and then scans clean", rc0 == 1 and rc1 == 0 and valid, out1))
    rcs, outs = _san(base, root, "runs/x/refs")
    results.append(("sanitizer is idempotent (second run redacts nothing)", rcs == 0 and "0 redaction(s)" in outs, outs))
    return results

# ------------------------------------------------------------------ runner
def run_check(root, kind, run=RUN):
    if kind == "ledger":
        cmd = ["bash", "scripts/check-source-ledger.sh", f"{run}/sources.csv"]
    else:
        cmd = ["bash", "scripts/check-channel-plan.sh", run]
    p = subprocess.run(cmd, cwd=root, capture_output=True, text=True)
    return p.returncode, p.stdout + p.stderr

def main():
    verbose = "-v" in sys.argv
    with tempfile.TemporaryDirectory(prefix="studio-harness-tests-") as tmp:
        base = os.path.join(tmp, "base")
        os.makedirs(os.path.join(base, "runs"))
        shutil.copytree(os.path.join(REPO, "scripts"), os.path.join(base, "scripts"), ignore=shutil.ignore_patterns("__pycache__"))
        shutil.copytree(os.path.join(REPO, "templates"), os.path.join(base, "templates"))
        shutil.copytree(os.path.join(REPO, "runs", "_template"), os.path.join(base, "runs", "_template"))
        build_fixture(base)
        misses, total = [], 0

        rc, out = run_check(base, "chan")
        total += 1
        if rc != 0 or "ERROR" in out:
            misses.append(("baseline fixture must pass the channel validator", out))
        rc, out = run_check(base, "ledger")
        total += 1
        if rc != 0 or "ERROR" in out:
            misses.append(("baseline fixture must pass the source-ledger validator", out))

        fresh_base = os.path.join(tmp, "fresh")
        shutil.copytree(base, fresh_base)
        fresh_run(fresh_base)
        rc, out = run_check(fresh_base, "chan", FRESH)
        total += 1
        if rc != 0 or "ERROR" in out:
            misses.append(("a fresh draft run from the templates must pass", out))

        for i, (name, kind, fn, mode, expect) in enumerate(TESTS, start=1):
            total += 1
            dst = os.path.join(tmp, f"t{i:03d}")
            shutil.copytree(base, dst)
            fn(dst)
            rc, out = run_check(dst, kind)
            low = out.lower()
            if mode == "reject":
                ok = rc == 1 and expect.lower() in low
            else:
                # "ERROR" in capitals marks an error line; "0 error(s)" in the summary is not one.
                ok = rc == 0 and "ERROR" not in out and (("WARN" not in out) if expect is None else expect.lower() in low)
            if not ok:
                misses.append((f"[{mode}/{kind}] {name} (expected {'substring ' + repr(expect) if expect else 'clean pass'}, rc={rc})", out))
            elif verbose:
                print(f"ok  [{mode}/{kind}] {name}")
        for name, ok, out in run_scan_tests(base, tmp):
            total += 1
            if not ok:
                misses.append((f"[scan] {name}", out))
            elif verbose:
                print(f"ok  [scan] {name}")
        for name, out in misses:
            print(f"MISS  {name}")
            for line in [l for l in out.splitlines() if l.strip()][:5]:
                print("      " + line[:200])
        print(f"{total - len(misses)} of {total} validator tests behaved as expected "
              f"({len(TESTS)} mutation cases, the scanner and sanitizer cases, and 3 baselines)")
        return 1 if misses else 0

if __name__ == "__main__":
    sys.exit(main())
