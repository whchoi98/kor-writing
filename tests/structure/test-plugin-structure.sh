#!/bin/bash
# Plugin structure and shipped-content invariants (sourced by tests/run-all.sh)

PJ=.claude-plugin/plugin.json
MJ=.claude-plugin/marketplace.json
SKILL=skills/kor-deslop/SKILL.md
PATTERNS=skills/kor-deslop/references/patterns.md

# --- Manifests ---
for f in "$PJ" "$MJ" .claude/settings.json .mcp.json; do
    assert_json_valid "$f is valid JSON" "$f"
done
NAME=$(jq -r '.name' "$PJ")
VER=$(jq -r '.version' "$PJ")
MKT=$(jq -r '.name' "$MJ")
assert_eq "plugin.json name" "kor-writing" "$NAME"
assert_eq "marketplace has exactly one plugin" "1" "$(jq '.plugins | length' "$MJ")"
assert_eq "marketplace entry name == plugin.json name" "$NAME" "$(jq -r '.plugins[0].name' "$MJ")"
assert_eq "marketplace entry source is the repo root" "./" "$(jq -r '.plugins[0].source' "$MJ")"
[[ "$VER" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] && pass "plugin.json version is semver ($VER)" \
    || fail "plugin.json version is semver" "got '$VER'"
assert_eq "plugin.json license is MIT" "MIT" "$(jq -r '.license' "$PJ")"
grep -qF "MIT License" LICENSE 2>/dev/null && pass "LICENSE is MIT" || fail "LICENSE is MIT" "LICENSE missing or not MIT"

# --- Version consistency (plugin.json, README badge, CHANGELOG both languages) ---
grep -qF "Version-${VER}-" README.md && pass "README version badge matches $VER" \
    || fail "README version badge matches $VER" "badge not found"
CL_EN=$(sed -n '/<a id="english"><\/a>/,/<a id="korean"><\/a>/p' CHANGELOG.md)
CL_KO=$(sed -n '/<a id="korean"><\/a>/,$p' CHANGELOG.md)
assert_eq "CHANGELOG (English) latest release == plugin.json" "$VER" \
    "$(printf '%s\n' "$CL_EN" | grep -m1 -oP '^## \[\K[0-9]+\.[0-9]+\.[0-9]+' || true)"
assert_eq "CHANGELOG (Korean) latest release == plugin.json" "$VER" \
    "$(printf '%s\n' "$CL_KO" | grep -m1 -oP '^## \[\K[0-9]+\.[0-9]+\.[0-9]+' || true)"
assert_eq "CHANGELOG: both languages list the same versions" \
    "$(printf '%s\n' "$CL_EN" | grep -oP '^## \[\K[^]]+' | tr '\n' ' ')" \
    "$(printf '%s\n' "$CL_KO" | grep -oP '^## \[\K[^]]+' | tr '\n' ' ')"
assert_contains "CHANGELOG: English has [Unreleased]" "$CL_EN" "## [Unreleased]"
assert_contains "CHANGELOG: Korean has [Unreleased]" "$CL_KO" "## [Unreleased]"

# --- Pattern table integrity ---
AJ=$(grep -cE '^\| [A-J]-[0-9]+ \|' "$PATTERNS" || true)
AJ_SEV=$(grep -cE '^\| [A-J]-[0-9]+ \| S[123] \|' "$PATTERNS" || true)
K=$(grep -cE '^\| K-[0-9]+ \|' "$PATTERNS" || true)
PATTERN_TOTAL=$((AJ + K))
assert_eq "every A-J pattern has severity S1-S3" "$AJ" "$AJ_SEV"
assert_eq "K principles carry no severity" "0" "$(grep -cE '^\| K-[0-9]+ \| S[123] \|' "$PATTERNS" || true)"
assert_eq "pattern IDs are unique" "" \
    "$(grep -oE '^\| [A-K]-[0-9]+ ' "$PATTERNS" | tr -d '| ' | sort | uniq -d | tr '\n' ' ')"
assert_eq "A-17 stays reserved (no row)" "0" "$(grep -cE '^\| A-17 \|' "$PATTERNS" || true)"
for cat in A B C D E F G H I J K; do
    grep -qE "^## ${cat}\. " "$PATTERNS" && pass "patterns.md: category $cat present" \
        || fail "patterns.md: category $cat present" "heading '## $cat. ' not found"
done
MISPLACED=$(awk '/^## [A-K]\. /{cat=substr($2,1,1)} /^\| [A-K]-[0-9]+ \|/{split($2,id,"-"); if (id[1]!=cat) printf "%s ", $2}' "$PATTERNS")
assert_eq "every pattern sits under its own category" "" "$MISPLACED"
grep -qF "## 장르별 허용과 금기" "$PATTERNS" && pass "patterns.md: genre table present" \
    || fail "patterns.md: genre table present" "missing"

# --- Pattern count is the same everywhere it is quoted ---
for f in "$PJ" "$MJ" README.md; do
    grep -qF "패턴 ${PATTERN_TOTAL}개" "$f" && pass "count: '패턴 ${PATTERN_TOTAL}개' in $f" \
        || fail "count: '패턴 ${PATTERN_TOTAL}개' in $f" "count in $f differs from patterns.md ($PATTERN_TOTAL)"
done
README=$(cat README.md)
assert_contains "count: README English total" "$README" "${PATTERN_TOTAL} patterns"
assert_contains "count: README English A-J" "$README" "${AJ} patterns in A-J"
assert_contains "count: README English K" "$README" "${K} writer principles in K"
assert_contains "count: README Korean A-J" "$README" "A~J ${AJ}개"
assert_contains "count: README Korean K" "$README" "K ${K}개"
assert_contains "count: CLAUDE.md" "$(cat CLAUDE.md)" "${PATTERN_TOTAL} patterns"

# --- Shipped skill ---
for dir in skills/*/; do
    skill=$(basename "$dir")
    assert_file_exists "skill $skill: SKILL.md" "$dir/SKILL.md"
    head -1 "$dir/SKILL.md" | grep -qx -- '---' && pass "skill $skill: frontmatter opens" \
        || fail "skill $skill: frontmatter opens" "first line is not ---"
    assert_eq "skill $skill: name matches directory" "$skill" \
        "$(sed -n '2,/^---$/s/^name: //p' "$dir/SKILL.md" | head -1)"
done
DESC=$(sed -n '2,/^---$/s/^description: //p' "$SKILL" | head -1)
[ "${#DESC}" -ge 50 ] && pass "kor-deslop: description present (${#DESC} chars)" \
    || fail "kor-deslop: description present" "too short"
assert_contains "kor-deslop: description keeps trigger phrase" "$DESC" "윤문해줘"
assert_contains "kor-deslop: description keeps check-only trigger" "$DESC" "점검만 해줘"
assert_contains "kor-deslop: description keeps exclusions" "$DESC" "맞춤법만"
SKILL_BODY=$(cat "$SKILL")
for section in "우선순위" "의미 보존 규칙" "절차" "자체 점검" "결과 전달" "출처"; do
    assert_contains "kor-deslop: section '$section'" "$SKILL_BODY" "## $section"
done
assert_contains "kor-deslop: points to references/patterns.md" "$SKILL_BODY" "references/patterns.md"
assert_contains "kor-deslop: points to NOTICE.md" "$SKILL_BODY" "NOTICE.md"
assert_eq "no CLAUDE.md inside shipped skill directories" "" \
    "$(find skills -mindepth 2 -name CLAUDE.md | tr '\n' ' ')"

# The change-rate one-liner in SKILL.md must actually run
SNIPPET=$(grep -m1 -oP '^\s*\Kpython3 -c ".*difflib.*" before\.txt after\.txt' "$SKILL" || true)
if [ -z "$SNIPPET" ]; then
    fail "kor-deslop: change-rate snippet found" "python3 difflib one-liner missing from SKILL.md"
else
    printf '데이터를 논의했다.\n' > "$TEST_TMP/before.txt"
    cp "$TEST_TMP/before.txt" "$TEST_TMP/after.txt"
    assert_eq "kor-deslop: change-rate snippet reports 0.0% for identical text" "0.0%" \
        "$(cd "$TEST_TMP" && bash -c "$SNIPPET" 2>&1)"
    printf '완전히 다른 문장으로 바꿨다.\n' > "$TEST_TMP/after.txt"
    RATE=$(cd "$TEST_TMP" && bash -c "$SNIPPET" 2>&1)
    [[ "$RATE" =~ ^[0-9]+\.[0-9]%$ && "$RATE" != "0.0%" ]] && pass "kor-deslop: change-rate snippet reports a change ($RATE)" \
        || fail "kor-deslop: change-rate snippet reports a change" "got '$RATE'"
fi

# --- Nothing executable ships: no plugin component paths at the root ---
for p in hooks commands agents bin output-styles settings.json; do
    [ ! -e "$p" ] && pass "root has no '$p' (would ship to every user)" \
        || fail "root has no '$p'" "'$p' is a plugin component path; move dev tooling under .claude/"
done
assert_eq ".mcp.json has only the mcpServers key" '["mcpServers"]' "$(jq -c 'keys' .mcp.json)"
assert_eq ".mcp.json declares no servers (it ships as plugin MCP config)" "0" "$(jq '.mcpServers | length' .mcp.json)"

# --- License notice for derived material ---
NOTICE=$(cat NOTICE.md)
assert_contains "NOTICE: names humanize-korean" "$NOTICE" "humanize-korean v"
assert_contains "NOTICE: keeps upstream copyright" "$NOTICE" "Copyright (c) 2026 epoko77-ai"
assert_contains "NOTICE: keeps MIT text" "$NOTICE" "Permission is hereby granted"

# --- README install commands match the manifests and the remote ---
assert_contains "README: install id" "$README" "claude plugin install ${NAME}@${MKT}"
assert_contains "README: marketplace update command" "$README" "claude plugin marketplace update ${MKT}"
REMOTE=$(git remote get-url origin 2>/dev/null | sed -E 's#(\.git)?$##; s#.*github\.com[:/]##' || true)
if [ -n "$REMOTE" ]; then
    assert_contains "README: marketplace add uses the origin repo" "$README" "claude plugin marketplace add $REMOTE"
else
    skip "README: marketplace add uses the origin repo" "no origin remote"
fi
for heading in Overview Features Prerequisites Installation Usage "Project Structure" Testing Contributing License Contact \
               "개요" "주요 기능" "사전 요구 사항" "설치 방법" "사용법" "프로젝트 구조" "테스트" "기여 방법" "라이선스" "연락처"; do
    grep -qx "## $heading" README.md && pass "README: section '$heading'" || fail "README: section '$heading'" "missing"
done

# --- File existence ---
for f in CLAUDE.md README.md CHANGELOG.md LICENSE NOTICE.md .editorconfig .env.example .gitignore .mcp.json \
         docs/architecture.md docs/onboarding.md docs/decisions/.template.md docs/runbooks/.template.md \
         docs/runbooks/release-plugin.md docs/reference/INDEX.md; do
    assert_file_exists "$f" "$f"
done
for module in skills tests; do
    assert_file_exists "Module doc: $module/CLAUDE.md" "$module/CLAUDE.md"
done

# --- .gitignore keeps secrets out ---
GITIGNORE=$(cat .gitignore)
for pattern in ".env" ".claude/settings.local.json"; do
    assert_contains ".gitignore has $pattern" "$GITIGNORE" "$pattern"
done
git check-ignore -q .env && pass ".env is ignored by git" || fail ".env is ignored by git" "not ignored"
git check-ignore -q .env.example && fail ".env.example is tracked" "ignored" || pass ".env.example is tracked"

# --- Script validation ---
for script in scripts/setup.sh scripts/install-hooks.sh tests/run-all.sh tests/hooks/*.sh tests/structure/*.sh; do
    assert_file_executable "$script is executable" "$script"
    assert_bash_syntax "$script valid bash" "$script"
done
# Test files are sourced into run-all.sh; assigning its counters corrupts the totals
CLOBBER=$(grep -nE '^\s*(TOTAL|PASSED|FAILED|SKIPPED|FAILURES|FILTER|TEST_TMP|PROJECT_ROOT|SCRIPT_DIR)\+?=' \
    tests/hooks/*.sh tests/structure/*.sh 2>/dev/null | tr '\n' ' ')
assert_eq "test files do not assign run-all.sh variables" "" "$CLOBBER"

# --- Commands, project skills, agents ---
for cmd in review test-all deploy; do
    CMD_CONTENT=$(cat ".claude/commands/$cmd.md")
    assert_contains "Command $cmd: has description" "$CMD_CONTENT" "description:"
    assert_contains "Command $cmd: has allowed-tools" "$CMD_CONTENT" "allowed-tools:"
done
DEPLOY_TOOLS=$(sed -n 's/^allowed-tools: //p' .claude/commands/deploy.md)
assert_not_contains "Command deploy: git push is not pre-allowed" "$DEPLOY_TOOLS" "git push"
assert_not_contains "Command deploy: git commit is not pre-allowed" "$DEPLOY_TOOLS" "git commit"
for skill in plugin-review refactor release sync-docs; do
    assert_eq "Project skill $skill: name matches directory" "$skill" \
        "$(sed -n '2,/^---$/s/^name: //p' ".claude/skills/$skill/SKILL.md" | head -1)"
    grep -q '^description: .\{20,\}' ".claude/skills/$skill/SKILL.md" \
        && pass "Project skill $skill: has description" || fail "Project skill $skill: has description" "missing"
done
[ ! -e .claude/skills/code-review ] && pass "no project skill shadows built-in /code-review" \
    || fail "no project skill shadows built-in /code-review" ".claude/skills/code-review exists"
for agent in code-reviewer security-auditor; do
    assert_file_exists "Agent $agent.md exists" ".claude/agents/$agent.md"
    assert_eq "Agent $agent: name matches file" "$agent" \
        "$(sed -n '2,/^---$/s/^name: //p' ".claude/agents/$agent.md" | head -1)"
done
assert_eq "no .yml agents (not loaded by Claude Code)" "" "$(find .claude/agents -name '*.yml' | tr '\n' ' ')"

# --- CLAUDE.md content ---
for section in "Overview" "Tech Stack" "Project Structure" "Conventions" "Key Commands" "Auto-Sync Rules"; do
    grep -qF "## $section" CLAUDE.md && pass "CLAUDE.md: has $section" || fail "CLAUDE.md: has $section" "not found"
done
LINES=$(wc -l < CLAUDE.md | tr -d ' ')
[ "$LINES" -le 500 ] && pass "CLAUDE.md under 500 lines ($LINES)" || fail "CLAUDE.md under 500 lines" "$LINES lines"
grep -qF "<!-- AUTO-MANAGED:references -->" CLAUDE.md \
    && pass "CLAUDE.md: has references AUTO-MANAGED block" || fail "CLAUDE.md: has references AUTO-MANAGED block" "missing"

# --- Reference docs: every linked layer exists and every Code Pointer resolves ---
for layer in $(grep -oP 'docs/reference/\K[a-z-]+(?=\.md\))' CLAUDE.md | grep -v '^INDEX$'); do
    assert_file_exists "Reference layer: $layer" "docs/reference/$layer.md"
done
BAD_POINTERS=""
for ref in docs/reference/*.md; do
    [ "$(basename "$ref")" = "INDEX.md" ] && continue
    while IFS= read -r pointer; do
        path="${pointer%%:*}"
        range="${pointer#"$path"}"; range="${range#:}"
        if [ ! -e "$path" ]; then
            BAD_POINTERS+=" $ref->$pointer"
        elif [ -n "$range" ] && [ "$(wc -l < "$path")" -lt "${range##*-}" ]; then
            BAD_POINTERS+=" $ref->$pointer(line)"
        fi
    done < <(sed -n '/^### 4\./,/^### 5\./p' "$ref" | grep -oP '^- `\K[^`]+(?=`)' | grep -E '^[A-Za-z0-9_./-]+(:[0-9-]+)?$' || true)
done
assert_eq "Reference Code Pointers resolve to existing paths and lines" "" "${BAD_POINTERS# }"

# --- Bilingual documents use ASCII anchors with sentinels ---
for doc in README.md CHANGELOG.md docs/architecture.md docs/onboarding.md docs/runbooks/release-plugin.md \
           docs/decisions/ADR-*.md docs/reference/*.md; do
    if grep -qF '<a id="english"></a>' "$doc" && grep -qF '<a id="korean"></a>' "$doc"; then
        pass "Bilingual anchors: $doc"
    else
        fail "Bilingual anchors: $doc" "missing <a id=\"english\"> or <a id=\"korean\">"
    fi
done
EMOJI=$(LC_ALL=C.UTF-8 grep -lP '[\x{1F300}-\x{1FAFF}\x{2600}-\x{27BF}]' README.md CHANGELOG.md docs/*.md docs/*/*.md 2>/dev/null | tr '\n' ' ')
assert_eq "No emojis in user-facing docs" "" "$EMOJI"

# --- Claude Code's own validation ---
if command -v claude >/dev/null 2>&1; then
    VALIDATE=$(claude plugin validate . 2>&1 || true)
    assert_contains "claude plugin validate . passes" "$VALIDATE" "Validation passed"
else
    skip "claude plugin validate . passes" "Claude Code CLI not installed"
fi
