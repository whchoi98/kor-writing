---
name: release
description: Cut a semver release of the kor-writing plugin - bump .claude-plugin/plugin.json, update the bilingual CHANGELOG.md and README badge, tag vX.Y.Z, and refresh the installed copy. Use when asked to release, bump the version, or publish skill changes to users.
---

# Release Skill

Installed copies of this plugin update only when `plugin.json` `version` changes, so every change
under `skills/` needs a release. Full procedure: `docs/runbooks/release-plugin.md`.

## Procedure

### 1. Pre-release Checks
- Working tree is clean: `git status`
- On `main`: `git branch --show-current`
- Tests pass: `bash tests/run-all.sh` and `claude plugin validate .`

### 2. Determine Version
- Review changes since the last tag:
  `git log $(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)..HEAD --oneline`
- Apply semver for a skill plugin:
  - MAJOR: invocation changes (skill renamed, `/kor-writing:kor-deslop` removed), pattern IDs removed, output modes changed
  - MINOR: new patterns, new genre rows, new skill
  - PATCH: wording fixes in prescriptions or examples, doc-only changes that ship

### 3. Update Files
- `.claude-plugin/plugin.json` `version`
- README version badge (`Version-X.Y.Z-green`)
- `CHANGELOG.md`: move `## [Unreleased]` items to `## [X.Y.Z] - YYYY-MM-DD` in BOTH the English and
  Korean sections; categories stay in English; English entries imperative, Korean entries 명사형 종결;
  update the reference links at the bottom of both sections
- If the pattern count changed: README (both languages), `plugin.json` and `marketplace.json` descriptions

### 4. Commit and Tag
- `git commit -m "chore: release vX.Y.Z"`
- `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
- Pushing `main` and the tag is outward-facing (public repo): ask the user before
  `git push origin main --follow-tags`

### 5. Refresh and Summarize
- `claude plugin marketplace update kor-writing`, then `/reload-plugins`
- If `claude plugin list` still shows the old version: `claude plugin update kor-writing@kor-writing`
- Display the version bump, key changes, and anything not yet pushed
