# Runbook: Release the Plugin

<a href="#english"><img src="https://img.shields.io/badge/lang-English-blue.svg" alt="English"></a>
<a href="#korean"><img src="https://img.shields.io/badge/lang-한국어-red.svg" alt="Korean"></a>

---

<a id="english"></a>

# English

## Overview
Publish a new version of `kor-writing` to everyone who installed it from `whchoi98/kor-writing`.

## When to Use
- Any change under `skills/` (skill text, patterns, genre table)
- A change to `.claude-plugin/*.json`, `NOTICE.md` or `LICENSE` that users should receive

Installed copies update only when `.claude-plugin/plugin.json` `version` changes.

## Prerequisites
- Push access to `github.com/whchoi98/kor-writing` (`gh auth status`)
- Claude Code CLI, `jq`, git; hooks installed (`bash scripts/setup.sh`)

## Procedure

### 1. Check the tree
```bash
git status                      # must be clean
git branch --show-current       # must be main
bash tests/run-all.sh
claude plugin validate .
```

### 2. Pick the version
```bash
git log "$(git describe --tags --abbrev=0)"..HEAD --oneline
```
- MAJOR: skill renamed or removed, pattern IDs removed, output modes changed
- MINOR: new patterns, genre rows, or skills
- PATCH: wording fixes in prescriptions or examples

### 3. Update the version everywhere
```bash
NEW=1.0.1   # example
jq --arg v "$NEW" '.version = $v' .claude-plugin/plugin.json > /tmp/plugin.json \
  && mv /tmp/plugin.json .claude-plugin/plugin.json
sed -i "s/Version-[0-9.]*-green/Version-$NEW-green/" README.md
```
Then edit `CHANGELOG.md`: move the `[Unreleased]` items into `## [$NEW] - YYYY-MM-DD` in both the
English and Korean sections and update the reference links at the bottom of both sections.
If the pattern count changed, update README (both languages), `plugin.json` and `marketplace.json`.

### 4. Verify, commit, tag, push
```bash
bash tests/run-all.sh
git add -A
git commit -m "chore: release v$NEW"
git tag -a "v$NEW" -m "Release v$NEW"
git push origin main --follow-tags
```

### 5. Refresh the installed copy
```bash
claude plugin marketplace update kor-writing
claude plugin list | grep -A3 'kor-writing@kor-writing'
# If the old version is still listed:
claude plugin update kor-writing@kor-writing
```
Then run `/reload-plugins` in open sessions (or restart them).

## Verification
- [ ] `git ls-remote --tags origin "v$NEW"` returns the tag
- [ ] `claude plugin list` shows `kor-writing@kor-writing` at `$NEW`
- [ ] `claude plugin details kor-writing@kor-writing` lists skill `kor-deslop`
- [ ] `/kor-writing:kor-deslop` runs on a short sample in a new session

## Rollback
Never force-push `main` and never reuse a published version number.
```bash
git revert <bad-sha>
# then repeat this runbook with the next PATCH version
```

## Notes
- Last verified: 2026-11-01 (first publish and `marketplace add` + `install` only; the update path in
  step 5 has not been exercised yet)

---

<a id="korean"></a>

# 한국어

## 개요
`whchoi98/kor-writing`에서 설치한 모든 사용자에게 `kor-writing` 새 버전을 배포합니다.

## 사용 시점
- `skills/` 아래 변경(스킬 본문, 패턴, 장르 표)
- 사용자에게 전달해야 하는 `.claude-plugin/*.json`, `NOTICE.md`, `LICENSE` 변경

설치된 사본은 `.claude-plugin/plugin.json`의 `version`이 바뀔 때만 갱신됩니다.

## 사전 요구 사항
- `github.com/whchoi98/kor-writing` push 권한(`gh auth status`)
- Claude Code CLI, `jq`, git, 설치된 hook(`bash scripts/setup.sh`)

## 절차

### 1. 작업 트리 확인
```bash
git status                      # must be clean
git branch --show-current       # must be main
bash tests/run-all.sh
claude plugin validate .
```

### 2. 버전 결정
```bash
git log "$(git describe --tags --abbrev=0)"..HEAD --oneline
```
- MAJOR: 스킬 이름 변경이나 삭제, 패턴 ID 삭제, 결과 전달 방식 변경
- MINOR: 패턴, 장르 행, 스킬 추가
- PATCH: 처방이나 예시 문구 수정

### 3. 모든 위치의 버전 갱신
```bash
NEW=1.0.1   # example
jq --arg v "$NEW" '.version = $v' .claude-plugin/plugin.json > /tmp/plugin.json \
  && mv /tmp/plugin.json .claude-plugin/plugin.json
sed -i "s/Version-[0-9.]*-green/Version-$NEW-green/" README.md
```
이어서 `CHANGELOG.md`를 편집합니다. 영어와 한국어 섹션 모두에서 `[Unreleased]` 항목을 `## [$NEW] - YYYY-MM-DD`로 옮기고, 두 섹션 아래의 참조 링크를 갱신합니다. 패턴 개수가 바뀌었으면 README(두 언어), `plugin.json`, `marketplace.json`도 고칩니다.

### 4. 검증, 커밋, 태그, push
```bash
bash tests/run-all.sh
git add -A
git commit -m "chore: release v$NEW"
git tag -a "v$NEW" -m "Release v$NEW"
git push origin main --follow-tags
```

### 5. 설치된 사본 갱신
```bash
claude plugin marketplace update kor-writing
claude plugin list | grep -A3 'kor-writing@kor-writing'
# If the old version is still listed:
claude plugin update kor-writing@kor-writing
```
열려 있는 세션에서는 `/reload-plugins`를 실행하거나 세션을 다시 시작합니다.

## 검증
- [ ] `git ls-remote --tags origin "v$NEW"`가 태그를 반환합니다
- [ ] `claude plugin list`에 `kor-writing@kor-writing`이 `$NEW`로 표시됩니다
- [ ] `claude plugin details kor-writing@kor-writing`에 스킬 `kor-deslop`이 있습니다
- [ ] 새 세션에서 짧은 예문으로 `/kor-writing:kor-deslop`이 실행됩니다

## 롤백
`main`에 force push하지 않고, 이미 배포한 버전 번호를 다시 쓰지 않습니다.
```bash
git revert <bad-sha>
# then repeat this runbook with the next PATCH version
```

## 참고
- 최종 검증일: 2026-11-01 (최초 배포와 `marketplace add` + `install`만 검증, 5단계 갱신 경로는 아직 실행하지 않음)
