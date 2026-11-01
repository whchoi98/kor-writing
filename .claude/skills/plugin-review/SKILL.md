---
name: plugin-review
description: Review changes to the kor-writing plugin (skills/kor-deslop SKILL.md and patterns.md, .claude-plugin manifests, README, NOTICE) with confidence-based scoring, reporting only issues >= 75. Use when asked to review a diff or changes before commit or release. Named plugin-review so it does not shadow the built-in /code-review.
---

# Plugin Review Skill

Review changed files with confidence-based scoring to filter false positives.

## Review Scope

By default, review unstaged changes from `git diff`, then staged changes from `git diff --cached`.
The user may specify different files or a git ref.

## Review Criteria

### Shipped-Content Invariants (highest priority)
Everything in the repo root ships to users (`marketplace.json` has `"source": "./"`).
- `skills/kor-deslop/SKILL.md` frontmatter `name` equals the directory name; `description` keeps its trigger phrases and its exclusions (맞춤법만 고치는 요청, 번역, 내용 추가·삭제 재작성)
- Pattern IDs are stable: no renumbering, no reuse of a removed ID (the A-17 gap is intentional)
- Every A-J row has a severity `S1`/`S2`/`S3`; K rows have none
- Pattern count matches README (both languages), `plugin.json` and `marketplace.json`
- Rule priority in SKILL.md stays: user request > 의미 보존 규칙 > patterns
- Meaning-preservation rules are not weakened (proper nouns, numbers, quotes, code, URLs, 서법, 문체 등급, 빼기 전용, 삭제는 후보로)
- `NOTICE.md` keeps the humanize-korean MIT notice whenever A-J patterns derive from it
- No new executable component at the root: `hooks/`, `commands/`, `agents/`, `settings.json`; `.mcp.json` stays empty

### Release Hygiene
- Any change under `skills/` comes with a `plugin.json` version bump and a CHANGELOG `[Unreleased]` entry in both languages
- README version badge equals `plugin.json` version

### Korean Writing Quality
- Prescriptions are concrete (예시 before/after), not vague
- New prescriptions do not contradict another pattern or the genre table
- Text the skill shows users follows the K principles (no 내용 없는 도입, no 가운데점·엠대시 in plain prose)

### Harness
- Hooks read event JSON from stdin; PreToolUse blocks with exit 2; no `|| true` on PreToolUse
- Tests are not vacuous (a broken invariant must fail `bash tests/run-all.sh`)

## Confidence Scoring

Rate each issue 0-100:
- **0-24**: Likely false positive or pre-existing issue. Do not report.
- **25-49**: Might be real but possibly a nitpick. Do not report.
- **50-74**: Real issue but minor. Report only if critical.
- **75-89**: Verified real issue, important. Report with fix suggestion.
- **90-100**: Confirmed critical issue. Must report.

**Only report issues with confidence >= 75.**

## Output Format

For each issue:
### [CRITICAL|IMPORTANT] <issue title> (confidence: XX)
**File:** `path/to/file.ext:line`
**Issue:** Clear description of the problem
**Guideline:** Reference to CLAUDE.md rule or the invariant above
**Fix:** Concrete suggestion

If no high-confidence issues are found, confirm the change meets standards with a brief summary.
