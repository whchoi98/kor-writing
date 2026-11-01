# ADR-001: Single-Pass Skill with an On-Demand Rulebook

<a href="#english"><img src="https://img.shields.io/badge/lang-English-blue.svg" alt="English"></a>
<a href="#korean"><img src="https://img.shields.io/badge/lang-한국어-red.svg" alt="Korean"></a>

---

<a id="english"></a>

# English

## Status
Accepted (2026-11-01). Records the design shipped in 1.0.0.

## Context
`kor-deslop` compresses the humanize-korean v2.3.2 taxonomy and rewrite playbook (MIT). Upstream runs
as an orchestrated pipeline: a Python shim picks a route, and diagnosis, rewrite and finalize steps run
as separate subagent calls with metric scripts. `kor-writing` needed the same pattern knowledge as a
plugin that installs with no extra tools.

## Options Considered

### Option 1: Port the multi-agent pipeline
- **Pros**: Separate diagnosis and finalize passes; script-based metrics
- **Cons**: Ships agents and scripts to every installer; needs Python and more calls per run

### Option 2: One SKILL.md plus a rulebook read on demand
- **Pros**: Documentation only; nothing executes at install time; small always-on cost
- **Cons**: Self-check is judged by the model, except the optional `difflib` change-rate one-liner

## Decision
Option 2. `SKILL.md` holds the priority order, meaning-preservation rules, procedure, six self-checks and
output modes. The 79 patterns and the genre table live in `references/patterns.md`, which the skill reads
once per run. No scripts, subagents, hooks or MCP servers ship with the plugin.

## Consequences

### Positive
- Always-on cost is about 259 tokens (frontmatter only); about 2.2k tokens load per invocation
  (`claude plugin details kor-writing@kor-writing`, measured 2026-11-01)
- The installed plugin has no executable surface, which keeps the public repo low-risk
- Works anywhere Claude Code runs; Python 3 is optional

### Negative
- No deterministic metric gate; quality depends on the model applying the rulebook
- Long inputs (5,000+ characters) are processed section by section inside one context

## References
- `skills/kor-deslop/SKILL.md`, `skills/kor-deslop/references/patterns.md`, `NOTICE.md`
- humanize-korean: https://github.com/epoko77-ai/im-not-ai

---

<a id="korean"></a>

# 한국어

## 상태
승인됨 (2026-11-01). 1.0.0에 담긴 설계를 기록합니다.

## 배경
`kor-deslop`은 humanize-korean v2.3.2(MIT)의 분류 체계와 윤문 처방집을 압축한 스킬입니다. 원본은 Python shim이 경로를 고르고 진단, 윤문, 마무리 단계를 별도 하위 에이전트 호출과 지표 스크립트로 실행하는 파이프라인입니다. `kor-writing`에는 같은 패턴 지식을 추가 도구 설치 없이 쓸 수 있는 플러그인 형태가 필요했습니다.

## 검토한 옵션

### 옵션 1: 다중 에이전트 파이프라인 이식
- **장점**: 진단과 마무리 단계 분리, 스크립트 기반 지표
- **단점**: 설치하는 모든 사용자에게 에이전트와 스크립트가 배포되고, Python과 더 많은 호출이 필요합니다

### 옵션 2: SKILL.md 하나와 필요할 때 읽는 규칙집
- **장점**: 문서로만 구성되어 설치 시 실행되는 것이 없고, 상시 비용이 작습니다
- **단점**: 선택 사항인 `difflib` 변경률 한 줄 명령을 빼면 자체 점검을 모델이 판단합니다

## 결정
옵션 2를 택합니다. `SKILL.md`에는 우선순위, 의미 보존 규칙, 절차, 자체 점검 6항목, 결과 전달 방식을 둡니다. 패턴 79개와 장르 표는 `references/patterns.md`에 두고 스킬이 실행될 때 한 번 읽습니다. 플러그인에는 스크립트, 하위 에이전트, hook, MCP 서버를 넣지 않습니다.

## 영향

### 긍정적
- 상시 비용은 약 259 토큰(frontmatter만)이고, 호출할 때 약 2.2k 토큰이 로드됩니다
  (`claude plugin details kor-writing@kor-writing`, 2026-11-01 측정)
- 설치된 플러그인에 실행 가능한 부분이 없어 공개 저장소의 위험이 낮습니다
- Claude Code가 동작하는 곳이면 어디서든 쓸 수 있고 Python 3는 선택 사항입니다

### 부정적
- 결정적인 지표 게이트가 없어 품질이 모델의 규칙 적용에 달려 있습니다
- 긴 글(5,000자 이상)은 한 컨텍스트 안에서 절 단위로 나눠 처리합니다

## 참고 자료
- `skills/kor-deslop/SKILL.md`, `skills/kor-deslop/references/patterns.md`, `NOTICE.md`
- humanize-korean: https://github.com/epoko77-ai/im-not-ai
