#!/usr/bin/env bash
# Validate the whole Studio Harness: structure, agent cards, skills, policies, links and paths,
# secrets, shell syntax, and the ledger / run checkers.
# Usage: scripts/validate-harness.sh            run every check
#        scripts/validate-harness.sh --regen-docs   rewrite the generated tool tables in docs/04 from policies/tool-manifest.yaml
# Includes the Channel Launch route: scripts/check-channel-plan.sh and policies/channel-launch.yaml.
# Needs: bash 3.2+, python3 (stdlib). ruby (system) enables the YAML checks. Exit 0 = pass, 1 = failures.
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 2

FAILS=0
WARNS=0
ok()   { echo "ok    $*"; }
fail() { echo "FAIL  $*"; FAILS=$((FAILS + 1)); }
warn() { echo "WARN  $*"; WARNS=$((WARNS + 1)); }
section() { echo; echo "== $*"; }

# ---------------------------------------------------------------- generated docs (ruby)
read -r -d '' TOOLDOCS_RB <<'RB'
Encoding.default_external = Encoding::UTF_8
require 'yaml'
mode = ARGV[0]
m = YAML.load_file('policies/tool-manifest.yaml')
labels = {
  0 => 'Stage 0: available / safe foundation',
  1 => 'Stage 1: approval-required integration',
  2 => 'Stage 2: paid, per-job approval',
  3 => 'Stage 3: later and high-risk (disabled in v1)'
}
out = []
(0..3).each do |s|
  out << "### #{labels[s]}"
  out << ''
  out << '| Tool | Purpose | Why it fits | Alternative | Risk | Required permission | Verification method | Install / connect status |'
  out << '|---|---|---|---|---|---|---|---|'
  m['tools'].select { |t| t['stage'] == s }.each do |t|
    cells = [t['name'], t['purpose'], t['why_it_fits'], t['alternative'], t['risk'],
             t['required_permission'], t['verification_method'],
             "#{t['install_status']} / #{t['connect_status']}"]
    out << '| ' + cells.map { |c| c.to_s.gsub('|', '\\|').gsub("\n", ' ') }.join(' | ') + ' |'
  end
  out << ''
end
gen = out.join("\n")
path = 'docs/04-tool-and-permission-policy.md'
doc = File.read(path)
b = '<!-- BEGIN GENERATED: tool tables -->'
e = '<!-- END GENERATED: tool tables -->'
unless doc.include?(b) && doc.include?(e)
  warn 'generated-section markers missing'
  exit 2
end
pre, rest = doc.split(b, 2)
_old, post = rest.split(e, 2)
new_doc = pre + b + "\n" + gen + e + post
if mode == 'write'
  File.write(path, new_doc)
  puts 'regenerated docs/04 tool tables'
elsif new_doc != doc
  exit 1
end
RB

if [ "${1:-}" = "--regen-docs" ]; then
  command -v ruby >/dev/null 2>&1 || { echo "ruby not found"; exit 2; }
  ruby -e "$TOOLDOCS_RB" write
  exit $?
fi

echo "Studio Harness validation ($(date +%F))"

# ---------------------------------------------------------------- 1. required files
section "1. required files"
REQUIRED_FILES="
README.md CLAUDE.md AGENTS.md .gitignore
docs/00-charter-and-scope.md docs/01-operating-model.md docs/02-agent-roles.md
docs/03-context-and-memory.md docs/04-tool-and-permission-policy.md docs/05-verification-and-qa.md
docs/06-source-rights-and-licensing.md docs/07-publishing-and-approval-policy.md
docs/08-trend-and-competitor-research.md docs/09-ai-film-production-pipeline.md
docs/10-blender-cinematography-pipeline.md docs/11-incident-and-recovery.md
docs/audits/2026-11-04-existing-capability-audit.md docs/audits/2026-11-04-studio-harness-gap-analysis.md
agents/director.md agents/trend-scout.md agents/reference-forensics.md agents/creative-producer.md
agents/ai-film-lead.md agents/blender-cinematographer.md agents/motion-editor.md agents/packaging-lead.md
agents/qa-rights-reviewer.md agents/memory-curator.md
skills/studio-brief/SKILL.md skills/research-pack/SKILL.md skills/competitor-watch/SKILL.md
skills/content-routes/SKILL.md skills/ai-film-treatment/SKILL.md skills/shot-spec/SKILL.md
skills/packaging/SKILL.md skills/qa/SKILL.md skills/project-closeout/SKILL.md
skills/channel-launch/SKILL.md skills/channel-strategy/SKILL.md skills/content-programming/SKILL.md
templates/channel-brief.md templates/channel-competitor-map.md templates/competitor-post-ledger.csv
templates/content-pillar.md templates/format-card.md templates/hook-library.md templates/channel-style-system.md
templates/content-calendar.md templates/post-production-card.md templates/channel-metrics.md templates/channel-review.md
docs/12-channel-launch-and-growth.md docs/13-content-production-system.md docs/14-channel-measurement-and-learning.md
policies/channel-launch.yaml scripts/check-channel-plan.sh scripts/test-validators.sh scripts/tests/validator_tests.py
policies/secret-scan-allowlist.yaml scripts/scan-secrets.sh scripts/sanitize-captures.sh
docs/creative-os-alignment.md docs/tool-install-policy.md
templates/project-brief.md templates/research-pack.md templates/source-ledger.csv templates/competitor-card.md
templates/creative-route.md templates/treatment.md templates/shot-spec.md templates/asset-rights-ledger.csv
templates/social-package.md templates/qa-report.md templates/decision-log.md templates/project-closeout.md
policies/permissions.yaml policies/tool-manifest.yaml policies/approval-gates.yaml
policies/source-policy.yaml policies/memory-policy.yaml policies/model-routing.yaml
runs/README.md runs/_template/STATUS.md runs/_template/brief.md runs/_template/sources.csv
runs/_template/rights.csv runs/_template/approvals.csv runs/_template/decision-log.md
memory/README.md memory/approved-lessons.md memory/lesson-candidates.md memory/rejected-or-expired.md
memory/client-scopes/README.md memory/studio-scopes/README.md
scripts/validate-harness.sh scripts/check-source-ledger.sh scripts/check-run-completeness.sh
"
missing=0
for f in $REQUIRED_FILES; do
  [ -f "$f" ] || { fail "missing file: $f"; missing=$((missing + 1)); }
done
[ -d memory/client-scopes ] && [ -d memory/studio-scopes ] || fail "memory scope folders missing"
[ "$missing" -eq 0 ] && ok "all required files present"

# ---------------------------------------------------------------- 2. root instruction files
section "2. root instructions stay compact"
for f in CLAUDE.md AGENTS.md; do
  n=$(wc -l < "$f" | tr -d ' ')
  if [ "$n" -le 80 ]; then ok "$f is $n lines (limit 80)"; else fail "$f is $n lines; keep it a map (limit 80)"; fi
  grep -q 'docs/00-charter-and-scope.md' "$f" || fail "$f does not point to docs/00-charter-and-scope.md"
  grep -q 'CHARTER.md' "$f" || fail "$f does not point to the charter"
done

# ---------------------------------------------------------------- 3. agent cards
section "3. agent cards"
HEADINGS="Mission|Inputs it may read|Outputs it must create|Eventual tools it may use|Forbidden actions|Verification required|Escalation conditions|Handoff format"
HANDOFF_FIELDS="from to run context status deliverables evidence verification risks open_decisions next_action"
count=0
for f in agents/*.md; do
  count=$((count + 1))
  base=$(basename "$f" .md)
  grep -q "^name: $base\$" "$f" || fail "$f: front matter name must be '$base'"
  grep -q '^description: ..' "$f" || fail "$f: front matter description missing"
  oldifs=$IFS; IFS='|'
  for h in $HEADINGS; do
    grep -qx "## $h" "$f" || fail "$f: missing heading '## $h'"
  done
  IFS=$oldifs
  grep -qx 'HANDOFF' "$f" || fail "$f: handoff block missing"
  for k in $HANDOFF_FIELDS; do
    grep -q "^$k: " "$f" || fail "$f: handoff field '$k:' missing"
  done
  grep -q "^from: $base\$" "$f" || fail "$f: handoff 'from:' must be $base"
done
[ "$count" -eq 32 ] && ok "32 agent cards (8 departments, docs/15), all sections and handoff fields present" || fail "expected 32 agent cards (docs/15 roster), found $count"

# ---------------------------------------------------------------- 4. skills
section "4. skills"
scount=0
for d in skills/*/; do
  d="${d%/}"; name=$(basename "$d"); scount=$((scount + 1))
  f="$d/SKILL.md"
  [ -f "$f" ] || { fail "$d has no SKILL.md"; continue; }
  grep -q "^name: $name\$" "$f" || fail "$f: front matter name must be '$name'"
  grep -q '^description: ..' "$f" || fail "$f: front matter description missing"
  grep -q '^## Steps' "$f" || fail "$f: no '## Steps' section"
  grep -q '^## Never' "$f" || fail "$f: no '## Never' section"
done
[ "$scount" -eq 16 ] && ok "16 skills, front matter and sections present" || fail "expected 16 skills, found $scount"

# ---------------------------------------------------------------- 5. templates and run template in sync
section "4b. plugin packaging (Claude Code adapter)"
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json hooks/hooks.json output-styles/studio-harness.md bin/studio-harness scripts/hooks/_ws.py scripts/hooks/session_start.py templates/workspace/profile.md; do
  [ -e "$f" ] && ok "$f present" || fail "$f missing (plugin layout)"
done
python3 -c "import json;[json.load(open(f)) for f in ('.claude-plugin/plugin.json','.claude-plugin/marketplace.json','hooks/hooks.json')]" && ok "plugin JSON parses" || fail "plugin JSON does not parse"
grep -q 'CLAUDE_PLUGIN_ROOT' hooks/hooks.json && ! grep -q 'studio-harness/scripts' hooks/hooks.json && ok "hooks use \${CLAUDE_PLUGIN_ROOT}, no hard-coded paths" || fail "hooks/hooks.json must call scripts via \${CLAUDE_PLUGIN_ROOT}"
! grep -n "expanduser('~/studio-harness')" scripts/hooks/*.py >/dev/null && ok "hooks resolve the workspace via _ws.py" || fail "a hook hard-codes ~/studio-harness; use _ws.workspace()"
[ -x bin/studio-harness ] && ok "bin/studio-harness executable" || fail "chmod +x bin/studio-harness"
python3 scripts/build-catalog.py --check >/dev/null && ok "docs/CATALOG.md and catalog/capabilities.json are current" || fail "capability catalog is stale: run scripts/build-catalog.py"
for f in agents/*.md; do grep -q "^department: ..*" "$f" && grep -q "^reports_to: ..*" "$f" || fail "$f: front matter needs department and reports_to (docs/15)"; done
! grep -l "creative_os_equivalent" agents/*.md >/dev/null 2>&1 && ok "agent cards carry no private-pack keys" || fail "remove creative_os_equivalent from agent cards"

section "4c. consistency (rubrics, calibration, evals)"
python3 - <<'PY' && ok "rubrics: every criterion has weight and anchors 1/3/5; bar and vetoes set" || fail "a rubric in rubrics/ is malformed (see message above)"
import json, glob, sys
bad = 0
for f in glob.glob('rubrics/*.json'):
    r = json.load(open(f))
    for k in ('id', 'version', 'bar', 'criteria', 'vetoes'):
        if k not in r: print(f'{f}: missing {k}'); bad += 1
    for c in r.get('criteria', []):
        if not all(str(i) in c.get('anchors', {}) for i in (1, 3, 5)) or not c.get('weight'): print(f'{f}: {c.get("id")} needs weight and anchors 1, 3, 5'); bad += 1
sys.exit(1 if bad else 0)
PY
for g in calibration/*/gold.json; do r=$(python3 -c "import json;print(json.load(open('$g'))['rubric'])"); [ -f "rubrics/$r.json" ] && ok "$g uses rubrics/$r.json" || fail "$g names a rubric that does not exist"; done
for c in evals/*/; do [ "$c" = "evals/results/" ] && continue; [ -f "$c/prompt.md" ] && ls "$c"graders/*.md >/dev/null 2>&1 && ok "eval case $c has prompt and grader" || fail "eval case $c needs prompt.md and graders/*.md"; done

section "5. templates and runs/_template stay in sync"
cmp -s templates/project-brief.md runs/_template/brief.md && ok "brief template matches runs/_template/brief.md" || fail "templates/project-brief.md differs from runs/_template/brief.md"
cmp -s templates/decision-log.md runs/_template/decision-log.md && ok "decision-log template matches" || fail "templates/decision-log.md differs from runs/_template/decision-log.md"
cmp -s templates/source-ledger.csv runs/_template/sources.csv && ok "source ledger header matches" || fail "templates/source-ledger.csv differs from runs/_template/sources.csv"
cmp -s templates/asset-rights-ledger.csv runs/_template/rights.csv && ok "rights ledger header matches" || fail "templates/asset-rights-ledger.csv differs from runs/_template/rights.csv"
grep -q '^practice: unknown' runs/_template/STATUS.md && ok "runs/_template defaults to practice: unknown (no accidental workflow)" || fail "runs/_template/STATUS.md must default to practice: unknown"
for k in story_purpose subject action place camera lens movement composition lighting colour_grade sound continuity_locks banned_cliches reference_evidence selected_tool qa_criteria approval_state; do
  grep -q "^$k:" templates/shot-spec.md || fail "templates/shot-spec.md missing field $k"
done

# ---------------------------------------------------------------- 5b. Channel Launch route is wired in
section "5b. Channel Launch route is wired into the map, roles and policies"
for f in README.md CLAUDE.md AGENTS.md docs/01-operating-model.md docs/02-agent-roles.md docs/07-publishing-and-approval-policy.md runs/README.md; do
  grep -qi "channel launch" "$f" && ok "$f mentions the Channel Launch route" || fail "$f does not mention the Channel Launch route"
done
for f in agents/director.md agents/trend-scout.md agents/reference-forensics.md agents/creative-producer.md agents/packaging-lead.md agents/ai-film-lead.md agents/motion-editor.md agents/qa-rights-reviewer.md agents/memory-curator.md; do
  grep -q "^## Channel Launch" "$f" && grep -q "^deliverables: .*" "$f" || fail "$f has no '## Channel Launch' section"
done
grep -q "^route: standard" runs/_template/STATUS.md && ok "runs/_template carries the optional route key" || fail "runs/_template/STATUS.md must carry route: standard"
if out=$(bash scripts/check-channel-plan.sh --templates 2>&1); then rc=0; else rc=$?; fi
printf '%s\n' "$out" | sed 's/^/      /'
if [ "$rc" -eq 0 ]; then ok "channel templates match the channel validator"; else fail "channel templates and validator disagree"; fi

# ---------------------------------------------------------------- 6. policies (YAML)
section "6. policies"
if command -v ruby >/dev/null 2>&1; then
  yaml_bad=0
  for f in policies/*.yaml; do
    if ! out=$(ruby -ryaml -e 'Encoding.default_external = Encoding::UTF_8; YAML.load_file(ARGV[0])' "$f" 2>&1); then
      fail "$f does not parse: $(echo "$out" | head -1)"; yaml_bad=$((yaml_bad + 1))
    fi
  done
  [ "$yaml_bad" -eq 0 ] && ok "all policy YAML files parse"
  read -r -d '' DEEP_RB <<'RB'
Encoding.default_external = Encoding::UTF_8
require 'yaml'
errs = []
perm = YAML.load_file('policies/permissions.yaml')
need = %w[paid_generation publishing external_communication login account_connection deletion deployment financial_or_legal_action licence_decision tool_install_or_update]
have = (perm['gated_actions'] || []).map { |g| g['id'] }
(need - have).each { |n| errs << "permissions.yaml: gated action #{n} missing" }
errs << 'permissions.yaml: default_rule must be deny_unlisted' unless perm['default_rule'] == 'deny_unlisted'
man = YAML.load_file('policies/tool-manifest.yaml')
req = %w[id name stage purpose why_it_fits alternative risk required_permission verification_method install_status connect_status]
ids = []
(man['tools'] || []).each do |t|
  req.each { |k| errs << "tool-manifest.yaml: #{t['id'] || '?'} missing #{k}" if t[k].nil? || t[k].to_s.strip.empty? }
  errs << "tool-manifest.yaml: #{t['id']} stage must be 0-3" unless [0, 1, 2, 3].include?(t['stage'])
  errs << "tool-manifest.yaml: #{t['id']} (stage 3) must have connect_status disabled" if t['stage'] == 3 && t['connect_status'] != 'disabled'
  errs << "tool-manifest.yaml: #{t['id']} (stage >= 1) must state an approval, verification or quote" if t['stage'].to_i >= 1 && t['required_permission'].to_s !~ /approv|verification|quote/i
  ids << t['id']
end
ids.select { |i| ids.count(i) > 1 }.uniq.each { |i| errs << "tool-manifest.yaml: duplicate id #{i}" }
{ 0 => %w[claude-code git filesystem-shell creative-os-skills yt-dlp ffmpeg],
  1 => %w[figma adobe mobbin blender-lab-mcp remotion framer],
  2 => %w[vidiq higgsfield freepik-magnific fal],
  3 => %w[social-publishing calendar crm email client-messaging] }.each do |stage, want|
  got = (man['tools'] || []).select { |t| t['stage'] == stage }.map { |t| t['id'] }
  (want - got).each { |w| errs << "tool-manifest.yaml: stage #{stage} is missing #{w}" }
end
gates = YAML.load_file('policies/approval-gates.yaml')
lg = (gates['loop_gates'] || []).map { |g| g['id'] }
errs << "approval-gates.yaml: expected 11 loop gates, found #{lg.size}" unless lg.size == 11
lg.select { |i| lg.count(i) > 1 }.uniq.each { |i| errs << "approval-gates.yaml: duplicate gate #{i}" }
mem = YAML.load_file('policies/memory-policy.yaml')
errs << 'memory-policy.yaml: promotion needs min_independent_real_projects: 2' unless mem.dig('promotion', 'min_independent_real_projects') == 2
errs << 'memory-policy.yaml: expected five memory classes' unless (mem['classes'] || []).size == 5
src = YAML.load_file('policies/source-policy.yaml')
errs << 'source-policy.yaml: min_real_references_before_routes must be 8' unless src.dig('references', 'min_real_references_before_routes') == 8
min_trend = src.dig('trend_claim', 'min_items_for_trend_signal')
unless File.read('scripts/check-source-ledger.sh').include?("MIN_TREND_ITEMS = #{min_trend}")
  errs << 'source-policy.yaml min_items_for_trend_signal differs from MIN_TREND_ITEMS in scripts/check-source-ledger.sh'
end
pc = src['performance_claims'] || {}
errs << 'source-policy.yaml: performance_claims.labels must be OBSERVED and INFERRED' unless pc['labels'] == %w[OBSERVED INFERRED]
errs << 'source-policy.yaml: performance_claims.required_fields must be metric, basis, n, platform, date, source' unless pc['required_fields'] == %w[metric basis n platform date source]
errs << 'source-policy.yaml: the old blanket forbidden_wording rule must be gone (only unsupported claims are rejected)' if src.dig('trend_claim', 'forbidden_wording')
%w[scripts/check-source-ledger.sh scripts/check-channel-plan.sh].each do |f|
  t = File.read(f)
  unless t.include?('CLAIM_FIELDS = ["metric", "basis", "n", "platform", "date", "source"]') && t.include?('CLAIM_LABELS = {"OBSERVED", "INFERRED"}')
    errs << "#{f}: claim-tag parser does not match policies/source-policy.yaml performance_claims"
  end
  errs << "#{f}: still rejects the literal word viral outright" if t =~ /banned: state the/
end
cl = YAML.load_file('policies/channel-launch.yaml')
errs << "channel-launch.yaml: expected 12 workflow steps, found #{(cl['workflow'] || []).size}" unless (cl['workflow'] || []).size == 12
wf_locks = (cl['workflow'] || []).map { |w| w['lock'] }.compact.sort
want_locks = %w[lock_calendar lock_pillars lock_positioning lock_visual_direction]
errs << "channel-launch.yaml: workflow must carry exactly the four locks, found #{wf_locks.inspect}" unless wf_locks == want_locks
ag = YAML.load_file('policies/approval-gates.yaml')
want_locks.each { |l| errs << "approval-gates.yaml: action_types is missing #{l}" unless (ag.dig('action_gates', 'action_types') || []).include?(l) }
pm = YAML.load_file('policies/permissions.yaml')
want_locks.each { |l| errs << "permissions.yaml: decision_locks is missing #{l}" unless (pm['decision_locks'] || []).map { |d| d['id'] }.include?(l) }
chk = File.read('scripts/check-channel-plan.sh')
(cl['thresholds'] || {}).each do |k, v|
  next unless v.is_a?(Integer)
  const = k.upcase.sub('MIN_BEATS_PER_STRUCTURE', 'MIN_BEATS').sub('MIN_STRATEGY_PHASES', 'MIN_STRATEGY_PHASES')
  m = chk.match(/^#{const} = (\d+)/)
  errs << "channel-launch.yaml threshold #{k}=#{v} has no matching #{const} in scripts/check-channel-plan.sh" if m.nil?
  errs << "channel-launch.yaml threshold #{k}=#{v} differs from #{const} = #{m[1]} in scripts/check-channel-plan.sh" if m && m[1].to_i != v
end
al = YAML.load_file('policies/secret-scan-allowlist.yaml')
ids = (al['rules'] || []).map { |r| r['id'] }
errs << "secret-scan-allowlist.yaml: rules must be exactly A1 and A2, found #{ids.inspect}" unless ids == %w[A1 A2]
scan = File.read('scripts/scan-secrets.sh')
ids.each { |i| errs << "scripts/scan-secrets.sh does not implement allowlist rule #{i}" unless scan.include?(%("#{i}")) }
mr = YAML.load_file('policies/model-routing.yaml')
errs << 'model-routing.yaml: generation.default_model must be none' unless mr.dig('generation', 'default_model').to_s == 'none'
puts errs
exit(errs.empty? ? 0 : 1)
RB
  if out=$(ruby -e "$DEEP_RB" 2>&1); then
    ok "policy cross-checks pass (gated actions, tool manifest fields and stages, 11 gates, memory rule, source rules)"
  else
    while IFS= read -r line; do fail "$line"; done <<< "$out"
  fi
  if ruby -e "$TOOLDOCS_RB" check 2>/dev/null; then
    ok "docs/04 tool tables match policies/tool-manifest.yaml"
  else
    fail "docs/04 tool tables are out of date: run scripts/validate-harness.sh --regen-docs"
  fi
else
  warn "ruby not found: YAML parse and policy cross-checks skipped"
fi

# ---------------------------------------------------------------- 7. internal links and paths
section "7. internal Markdown links and repo paths"
links=0; paths=0
while IFS= read -r f; do
  dir=$(dirname "$f")
  while IFS= read -r link; do
    target="${link#\](}"; target="${target%)}"
    case "$target" in http*|mailto:*|'#'*|'') continue ;; esac
    target="${target%%#*}"
    [ -z "$target" ] && continue
    links=$((links + 1))
    [ -e "$dir/$target" ] || fail "broken link in $f -> $target"
  done < <(grep -oE '\]\([^)]+\)' "$f" 2>/dev/null)
  while IFS= read -r p; do
    p="${p#\`}"; p="${p%\`}"
    paths=$((paths + 1))
    [ -e "$p" ] || fail "path in backticks does not exist ($f): $p"
  done < <(grep -oE '`(docs|agents|skills|templates|policies|runs|memory|scripts)/[A-Za-z0-9_./-]+`' "$f" 2>/dev/null)
done < <(find . -name '*.md' -not -path './.git/*' -not -path '*/refs/*' | sort)
ok "checked $links Markdown links and $paths backticked repo paths"

# ---------------------------------------------------------------- 8. secrets and forbidden files
section "8. secrets and forbidden files"
# Full-repo content scan, INCLUDING runs/*/refs/ raw captures (no folder is excluded). A narrow documented allowlist
# (policies/secret-scan-allowlist.yaml: A1, A2) is the only suppression; credential-like file names are checked everywhere.
if out=$(bash scripts/scan-secrets.sh 2>&1); then rc=0; else rc=$?; fi
printf '%s\n' "$out" | tail -n 12 | sed 's/^/      /'
if [ "$rc" -eq 0 ]; then ok "no secrets, tokens, session artifacts, cookies or credential-like files anywhere (raw captures under refs/ included)"; else fail "secret scan found problems (run scripts/scan-secrets.sh; clean captures with scripts/sanitize-captures.sh)"; fi
grep -q 'refs/' .gitignore && grep -q '\.env' .gitignore && ok ".gitignore covers refs, env and media" || fail ".gitignore is missing refs/ or .env rules"

# ---------------------------------------------------------------- 9. shell scripts
section "9. shell scripts"
for s in scripts/*.sh; do
  bash -n "$s" 2>/dev/null && ok "$s: syntax ok" || fail "$s: syntax error"
  [ -x "$s" ] || fail "$s: not executable (chmod +x)"
done

# ---------------------------------------------------------------- 10. ledger and run checkers
section "10. ledgers and runs"
# Every WARN line a checker prints is counted here, exactly once. check-run-completeness.sh does not
# re-emit ledger warnings (it prints a "note" line), so nothing is counted twice.
count_warns() { printf '%s\n' "$1" | grep -cE '^[[:space:]]*WARN '; }
if out=$(bash scripts/check-source-ledger.sh 2>&1); then rc=0; else rc=$?; fi
printf '%s\n' "$out" | sed 's/^/      /'
n=$(count_warns "$out"); WARNS=$((WARNS + n))
if [ "$rc" -eq 0 ]; then ok "source ledgers pass ($n warning(s) counted)"; else fail "source ledger check failed"; fi
if out=$(bash scripts/check-run-completeness.sh 2>&1); then rc=0; else rc=$?; fi
printf '%s\n' "$out" | sed 's/^/      /'
n=$(count_warns "$out"); WARNS=$((WARNS + n))
if [ "$rc" -eq 0 ]; then ok "run folders pass ($n warning(s) counted)"; else fail "run completeness check failed"; fi

if out=$(bash scripts/check-channel-plan.sh 2>&1); then rc=0; else rc=$?; fi
printf '%s\n' "$out" | sed 's/^/      /'
n=$(count_warns "$out"); WARNS=$((WARNS + n))
if [ "$rc" -eq 0 ]; then ok "channel plans pass ($n warning(s) counted)"; else fail "channel plan check failed"; fi

# ---------------------------------------------------------------- 11. validator self-tests
section "11. validator self-tests (accept and reject cases, claim-tag rule, Channel Launch gates)"
if out=$(bash scripts/test-validators.sh 2>&1); then rc=0; else rc=$?; fi
printf '%s\n' "$out" | sed 's/^/      /'
n=$(count_warns "$out"); WARNS=$((WARNS + n))
if [ "$rc" -eq 0 ]; then ok "validator self-tests pass"; else fail "validator self-tests failed"; fi

# ---------------------------------------------------------------- summary
echo
if [ "$FAILS" -eq 0 ]; then
  echo "PASS  Studio Harness validation: 0 failures, $WARNS warning(s)"
  exit 0
fi
echo "FAIL  Studio Harness validation: $FAILS failure(s), $WARNS warning(s)"
exit 1
