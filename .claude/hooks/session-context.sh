#!/bin/bash
# Load project context at Claude Code session start.
# SessionStart stdout is added to Claude's context, so keep it short and factual.

cd "${CLAUDE_PROJECT_DIR:-$(pwd)}" 2>/dev/null || exit 0

echo "=== Project Context ==="

NAME=$(jq -r '.name // empty' .claude-plugin/plugin.json 2>/dev/null)
VERSION=$(jq -r '.version // empty' .claude-plugin/plugin.json 2>/dev/null)
MARKET=$(jq -r '.name // empty' .claude-plugin/marketplace.json 2>/dev/null)
echo "Plugin: ${NAME:-$(basename "$(pwd)")} ${VERSION} (Claude Code plugin, install id ${NAME}@${MARKET})"

PATTERNS=skills/kor-deslop/references/patterns.md
if [ -f "$PATTERNS" ]; then
    AJ=$(grep -cE '^\| [A-J]-[0-9]+ \|' "$PATTERNS")
    K=$(grep -cE '^\| K-[0-9]+ \|' "$PATTERNS")
    echo "Skill kor-deslop: $((AJ + K)) patterns (A-J $AJ, K $K)"
fi

# Version drift between the manifest and the latest released CHANGELOG entry
RELEASED=$(grep -m1 -oP '^## \[\K[0-9]+\.[0-9]+\.[0-9]+' CHANGELOG.md 2>/dev/null)
if [ -n "$VERSION" ] && [ -n "$RELEASED" ] && [ "$VERSION" != "$RELEASED" ]; then
    echo "Note: plugin.json is $VERSION but the latest CHANGELOG release is $RELEASED"
fi

LAST_COMMIT=$(git log -1 --format="%h %s (%cr)" 2>/dev/null)
[ -n "$LAST_COMMIT" ] && echo "Last commit: $LAST_COMMIT"

BRANCH=$(git branch --show-current 2>/dev/null)
[ -n "$BRANCH" ] && echo "Branch: $BRANCH"

CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
[ "${CHANGES:-0}" -gt 0 ] && echo "Uncommitted changes: $CHANGES file(s)"

[ -x .git/hooks/pre-commit ] || echo "Warning: git hooks not installed - run: bash scripts/install-hooks.sh"

CLAUDE_COUNT=$(find . -name "CLAUDE.md" -not -path "./.git/*" 2>/dev/null | wc -l | tr -d ' ')
ADR_COUNT=$(find docs/decisions -name 'ADR-*.md' 2>/dev/null | wc -l | tr -d ' ')
echo "CLAUDE.md files: $CLAUDE_COUNT, ADRs: $ADR_COUNT"

echo "======================"
