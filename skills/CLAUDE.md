# Skills Module

## Role
Shipped plugin skills. Claude Code discovers `skills/<name>/SKILL.md` and registers each as
`/kor-writing:<name>`. This file sits directly in `skills/`, so it is not part of any skill.

## Key Files
- `kor-deslop/SKILL.md` — frontmatter (`name`, `description`) is loaded in every session (~260 tokens);
  the body loads when the skill fires. Sections: 우선순위, 의미 보존 규칙, 절차, 자체 점검, 결과 전달, 출처.
- `kor-deslop/references/patterns.md` — read once per run (SKILL.md tells Claude to). Categories A-J
  (70 rows with S1-S3 severity), K writer principles (9 rows), then the genre table
  (장르별 허용과 금기). Together with the body, ~2.2k tokens on invoke.

## Rules
- Do not add `CLAUDE.md`, scripts, or other helper files inside `kor-deslop/`; everything there ships.
- `description` is the trigger: keep the quoted request phrases ("AI 티 빼줘", "윤문해줘", "점검만 해줘"
  and the rest) and the exclusions (맞춤법만, 번역, 내용 추가·삭제 재작성). Longer text raises the
  always-on cost for every user.
- Keep SKILL.md and patterns.md in 한다체. Examples in patterns.md are written in 한다체; the skill
  tells Claude to keep the original text's 문체 등급.
- Pattern IDs are permanent and A-17 stays absent (reserved upstream). Append new rows at the end of
  their category with the next free number.
- Changing the pattern count means updating README (both languages), `.claude-plugin/plugin.json` and
  `.claude-plugin/marketplace.json`; `bash tests/run-all.sh structure` checks it.
- Every change here ships: bump the version and add a CHANGELOG entry (see `docs/runbooks/release-plugin.md`).
- Trigger phrases overlap with `humanize-korean@im-not-ai`, `anthropic-skills:humanize-korean-house` and
  `human-ton`. When testing, disable the overlapping one or call `/kor-writing:kor-deslop` explicitly.
