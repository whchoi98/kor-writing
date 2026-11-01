# Project Context

## Overview
`kor-writing` 1.0.0 is a Claude Code plugin for Korean writing. Its only skill, `kor-deslop`, removes
AI tells (번역투, AI 관용구, 기계적 구조, 균일한 리듬, 과잉 서식) from Korean text while keeping the
content, in a single pass with no scripts, subagents or MCP servers. 79 patterns: A-J 70 derived from
humanize-korean v2.3.2 (MIT, see `NOTICE.md`) plus 9 writer principles in K.

The repo root **is** the shipped plugin and its marketplace (`.claude-plugin/marketplace.json`,
`"source": "./"`). Public repo `github.com/whchoi98/kor-writing`; users install it as
`kor-writing@kor-writing` and invoke `/kor-writing:kor-deslop`.

## Tech Stack
- **Content** — Markdown skill (`skills/kor-deslop/SKILL.md`, 한다체) with an on-demand rulebook
  (`references/patterns.md`, tables)
- **Packaging** — Claude Code plugin manifests (`.claude-plugin/plugin.json`, `marketplace.json`), JSON
- **Harness** — Bash 5 hooks and tests, `jq` 1.7, Python 3 (`json.tool`, `difflib` change-rate check)
- **Tooling** — Claude Code CLI (`claude plugin validate|details|marketplace|update`), git, GitHub

## Project Structure
```
.claude-plugin/   - plugin.json (name, version) + marketplace.json (source ./)   [ships, loaded]
skills/           - Shipped skills; module doc skills/CLAUDE.md                  [ships, loaded]
  kor-deslop/     - SKILL.md (always-on description + body) and references/patterns.md
NOTICE.md         - humanize-korean MIT notice                                   [ships]
LICENSE, README.md, CHANGELOG.md                                                 [ships, inert]
.mcp.json         - Must stay empty: it is also the plugin's MCP config          [ships, loaded]
.claude/          - Dev harness: settings, hooks, project skills, commands, agents [ships, inert]
docs/             - architecture, onboarding, ADRs, runbooks, reference/         [ships, inert]
scripts/          - setup.sh, install-hooks.sh (git commit-msg + pre-commit)
tests/            - run-all.sh, hooks/, structure/, fixtures/; module doc tests/CLAUDE.md
```
"Ships" means it is copied into every installer's plugin cache. "Loaded" means Claude Code reads it as
a plugin component there. Everything under `.claude/` is only active when this repo is the working directory.

## Conventions
- **Never add plugin component paths at the root**: `hooks/`, `commands/`, `agents/`, `settings.json`,
  `bin/`, or entries in `.mcp.json`. They would run for every user. Dev-only tooling goes under `.claude/`.
  `tests/structure` enforces this.
- **Any change under `skills/` is a release**: installed copies update only when
  `.claude-plugin/plugin.json` `version` changes. Bump it, update the README badge and add a bilingual
  CHANGELOG entry (`docs/runbooks/release-plugin.md`).
- **Pattern IDs are permanent**: never renumber or reuse an ID. A-17 is intentionally absent; upstream
  reserves it for a held pattern (무정물·추상명사 '-들'). New patterns take the next free number in their
  category and are appended to that category's table.
- **Pattern rows**: A-J rows are `| ID | S1/S2/S3 | 패턴 | 처방 |`; K rows are `| ID | 패턴 | 처방 |`.
  Severity: S1 fix on first occurrence, S2 reduce density when repeated (3+), S3 only when overlapping.
- **Pattern count** appears in README (EN "79 patterns", KO "패턴 79개"), `plugin.json` and
  `marketplace.json` descriptions. Change all of them together; tests compare them to the table.
- **Skill text style**: SKILL.md and patterns.md are 한다체, terse, imperative. Rule priority is fixed:
  user request > 의미 보존 규칙 > patterns. Keep the `description` trigger phrases and exclusions.
- **Module docs**: never put `CLAUDE.md` inside `skills/<name>/`; that directory ships as the skill.
- **Attribution**: keep `NOTICE.md` intact while A-J material derives from humanize-korean.
- **Docs**: user-facing docs are bilingual (English first, `<a id="english">` / `<a id="korean">`),
  Korean sections in 합니다체, no emojis, Mermaid for diagrams.
- **Commits**: Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`). No `Co-Authored-By`
  (settings `attribution` is empty and the `commit-msg` hook strips it).

## Key Commands
```bash
bash scripts/setup.sh                     # check tools, chmod hooks, install git hooks
bash tests/run-all.sh                     # all harness tests (hooks, secret patterns, structure)
bash tests/run-all.sh structure           # only structure tests (pattern count, versions, docs)
claude plugin validate .                  # manifest + skill validation (ICON_MISSING warning is expected)
claude plugin details kor-writing@kor-writing   # components and always-on / on-invoke token cost
claude --plugin-dir .                     # session with this working tree loaded as a plugin
claude plugin marketplace update kor-writing    # after a push; then /reload-plugins
```
Change-rate check used by the skill's self-check:
```bash
python3 -c "import difflib,sys;a,b=[open(f,encoding='utf-8').read() for f in sys.argv[1:3]];print(f'{(1-difflib.SequenceMatcher(None,a,b).ratio())*100:.1f}%')" before.txt after.txt
```

## Implementation References
<!-- AUTO-MANAGED:references -->
Layer-by-layer implementation guides in `docs/reference/`. See [INDEX](docs/reference/INDEX.md).
- [Security](docs/reference/security.md)
- [Agent · LLM](docs/reference/agent-llm.md)
<!-- /AUTO-MANAGED -->

---

## Auto-Sync Rules

Rules below are applied automatically after Plan mode exit and on major changes.

### Post-Plan Mode Actions
After exiting Plan mode (`/plan`), before starting implementation:

1. **Architecture decision made** -> Update `docs/architecture.md`
2. **Technical choice/trade-off made** -> Create `docs/decisions/ADR-NNN-title.md`
3. **New module added** -> Create `CLAUDE.md` in that module directory (not inside `skills/<name>/`)
4. **Operational procedure defined** -> Create runbook in `docs/runbooks/`
5. **Changes needed in this file** -> Update relevant sections above

### Change Sync Rules
- New skill under `skills/` -> Update `skills/CLAUDE.md`, README (both languages), `docs/reference/agent-llm.md`
- Pattern added/removed -> Update the count everywhere listed in Conventions
- Anything under `skills/` changed -> Version bump + CHANGELOG `[Unreleased]` (both languages)
- Harness changed (`.claude/`, `tests/`, `scripts/`) -> Update `tests/CLAUDE.md` and `docs/reference/security.md`

### ADR Numbering
Find the highest number in `docs/decisions/ADR-*.md` and increment by 1.
Format: `ADR-NNN-concise-title.md`
