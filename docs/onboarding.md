# Developer Onboarding

<a href="#english"><img src="https://img.shields.io/badge/lang-English-blue.svg" alt="English"></a>
<a href="#korean"><img src="https://img.shields.io/badge/lang-한국어-red.svg" alt="Korean"></a>

---

<a id="english"></a>

# English

## Quick Start

### 1. Prerequisites
- [ ] Claude Code CLI with plugin support (verified with 2.1.316)
- [ ] git, Bash 4+, `jq`
- [ ] Python 3 (tests and the optional change-rate check)
- [ ] Push access to `github.com/whchoi98/kor-writing` for releases

### 2. Setup
```bash
git clone https://github.com/whchoi98/kor-writing.git
cd kor-writing
bash scripts/setup.sh
```

### 3. Verify
```bash
bash tests/run-all.sh
claude plugin validate .
```

## Project Overview
- Read `CLAUDE.md` for conventions and what ships to users
- Read `docs/architecture.md` for the layers and the packaging table
- Read `docs/decisions/` for recorded decisions
- Read `skills/CLAUDE.md` before editing the skill

## Development Workflow
- Branch naming: `feat/`, `fix/`, `docs/`, `refactor/`
- Commit convention: Conventional Commits; no `Co-Authored-By` trailers
- Try unreleased skill changes in a session started with `claude --plugin-dir .`. The installed
  `kor-writing@kor-writing` is also enabled, so check which copy is active with `/plugin`
- Release every change under `skills/` with `docs/runbooks/release-plugin.md`

## Key Concepts
- **Severity** -- S1 is fixed on first occurrence, S2 when repeated (3+ times), S3 only when it overlaps another pattern
- **Content anchors** -- key nouns per sentence that must survive the rewrite; if they would disappear, the sentence is restored
- **Change rate** -- above 30% the skill warns; above 50% it redoes the rewrite with fewer edits
- **Output modes** -- default (rewritten text and up to three lines of notes), check-only (table of pattern ID, sentence, direction), already natural (minimal edits)
- **Pattern IDs** -- permanent; A-17 is reserved upstream

## Troubleshooting
- **Another skill answers a 윤문 request** -- `humanize-korean@im-not-ai`, `anthropic-skills:humanize-korean-house` or `human-ton` matched first. Call `/kor-writing:kor-deslop` or disable the other plugin.
- **A skill change does not show up after install** -- the version was not bumped, or the marketplace was not refreshed. Run `claude plugin marketplace update kor-writing`, then `/reload-plugins`.
- **Commit blocked by secret-scan** -- read the `[secret-scan]` lines; move the value to `.env`. Test samples go in `tests/fixtures/` split into prefix and body.

## Resources
- humanize-korean (upstream taxonomy): https://github.com/epoko77-ai/im-not-ai
- Claude Code plugins: `claude plugin --help`

---

<a id="korean"></a>

# 한국어

## 빠른 시작

### 1. 사전 요구 사항
- [ ] 플러그인을 지원하는 Claude Code CLI(2.1.316에서 검증)
- [ ] git, Bash 4 이상, `jq`
- [ ] Python 3(테스트와 선택 사항인 변경률 점검용)
- [ ] 배포하려면 `github.com/whchoi98/kor-writing` push 권한

### 2. 설정
```bash
git clone https://github.com/whchoi98/kor-writing.git
cd kor-writing
bash scripts/setup.sh
```

### 3. 확인
```bash
bash tests/run-all.sh
claude plugin validate .
```

## 프로젝트 개요
- 규칙과 사용자에게 배포되는 범위는 `CLAUDE.md`를 읽습니다
- 레이어와 패키징 표는 `docs/architecture.md`를 읽습니다
- 기록된 결정은 `docs/decisions/`를 읽습니다
- 스킬을 고치기 전에 `skills/CLAUDE.md`를 읽습니다

## 개발 흐름
- 브랜치 이름: `feat/`, `fix/`, `docs/`, `refactor/`
- 커밋 규칙: Conventional Commits, `Co-Authored-By` 트레일러 없음
- 배포 전 스킬 변경은 `claude --plugin-dir .`로 시작한 세션에서 시험합니다. 설치된 `kor-writing@kor-writing`도 켜져 있으므로 `/plugin`으로 어느 사본이 동작하는지 확인합니다
- `skills/` 아래 변경은 모두 `docs/runbooks/release-plugin.md`에 따라 배포합니다

## 핵심 개념
- **심각도** -- S1은 처음 나올 때 고치고, S2는 3회 이상 반복될 때, S3는 다른 패턴과 겹칠 때만 고칩니다
- **내용 앵커** -- 문장마다 윤문 후에도 남아야 하는 핵심 명사입니다. 사라질 것 같으면 그 문장은 원문으로 되돌립니다
- **변경률** -- 30%를 넘으면 경고하고, 50%를 넘으면 수정을 줄여 다시 만듭니다
- **결과 전달 방식** -- 기본(고친 글과 세 줄 이내 메모), 점검만(패턴 ID, 문장, 고칠 방향 표), 이미 자연스러운 글(최소 수정)
- **패턴 ID** -- 영구적입니다. A-17은 원본에서 예약된 번호입니다

## 문제 해결
- **윤문 요청에 다른 스킬이 응답함** -- `humanize-korean@im-not-ai`, `anthropic-skills:humanize-korean-house`, `human-ton` 중 하나가 먼저 매칭된 경우입니다. `/kor-writing:kor-deslop`으로 직접 부르거나 다른 플러그인을 끕니다.
- **설치 후 스킬 변경이 보이지 않음** -- 버전을 올리지 않았거나 마켓플레이스를 갱신하지 않은 경우입니다. `claude plugin marketplace update kor-writing` 후 `/reload-plugins`를 실행합니다.
- **secret-scan이 커밋을 막음** -- `[secret-scan]` 줄을 읽고 해당 값을 `.env`로 옮깁니다. 테스트 샘플은 `tests/fixtures/`에 접두어와 본문으로 나눠 둡니다.

## 참고 자료
- humanize-korean(원본 분류 체계): https://github.com/epoko77-ai/im-not-ai
- Claude Code 플러그인: `claude plugin --help`
