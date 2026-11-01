# Agent · LLM / Agent · LLM 구현 상세

<a href="#english"><img src="https://img.shields.io/badge/lang-English-blue.svg" alt="English"></a>
<a href="#korean"><img src="https://img.shields.io/badge/lang-한국어-red.svg" alt="Korean"></a>

<a id="english"></a>
## English

### 1. Overview
`kor-deslop` is a model-instruction skill: Claude Code matches requests against its `description`, loads
the SKILL.md body, and reads the pattern rulebook once. All detection, rewriting and self-checking is done
by the model in one pass; there is no script, subagent or tool call beyond reading the rulebook.

### 2. Components
| Component | Path | Purpose |
|---|---|---|
| Trigger | `skills/kor-deslop/SKILL.md` (frontmatter) | Request phrases and exclusions; loaded in every session |
| Rule priority | `skills/kor-deslop/SKILL.md` (우선순위) | User request > meaning preservation > patterns |
| Meaning preservation | `skills/kor-deslop/SKILL.md` (의미 보존 규칙) | What never changes, content anchors, 서법, 문체 등급, genre, subtract-only, local edits, deletion as a candidate |
| Procedure and self-check | `skills/kor-deslop/SKILL.md` (절차, 자체 점검) | Genre detection, anchors, severity-based fixing, six checks, 30%/50% change-rate thresholds |
| Output modes | `skills/kor-deslop/SKILL.md` (결과 전달) | Default, check-only table, already-natural |
| Rulebook | `skills/kor-deslop/references/patterns.md` | A-J 70 patterns with S1-S3, K 9 principles, genre table |

### 3. Key Decisions
- Progressive disclosure: only the frontmatter (~260 tokens) is always loaded; the body and rulebook
  (~2.2k tokens) load on invoke ([ADR-001](../decisions/ADR-001-single-pass-skill-with-on-demand-rulebook.md)).
- Rule priority puts the user's explicit format, style and scope above every pattern.
- The skill only subtracts: no new metaphors, facts or emotions; whole-sentence deletions are reported
  as candidates instead of applied.
- Repeated patterns keep one or two occurrences, so the output does not swap one uniform style for another.
- K principles apply to Claude's own explanation lines as well as to the rewritten text.

### 4. Code Pointers
- `skills/kor-deslop/SKILL.md:1-4`
- `skills/kor-deslop/SKILL.md:10-27`
- `skills/kor-deslop/SKILL.md:29-37`
- `skills/kor-deslop/SKILL.md:39-56`
- `skills/kor-deslop/references/patterns.md:1-4`
- `skills/kor-deslop/references/patterns.md:128-142`
- `skills/kor-deslop/references/patterns.md:144-152`

### 5. Cross-references
- Related modules: `skills/` (`skills/CLAUDE.md`)
- Related ADRs: [ADR-001](../decisions/ADR-001-single-pass-skill-with-on-demand-rulebook.md)
- Related runbooks: [release-plugin.md](../runbooks/release-plugin.md)

<a id="korean"></a>
## 한국어

### 1. 개요
`kor-deslop`은 모델 지시형 스킬입니다. Claude Code가 요청을 `description`과 대조하고, SKILL.md 본문을 로드한 뒤 패턴 규칙집을 한 번 읽습니다. 탐지, 윤문, 자체 점검은 모두 모델이 한 번에 처리하며, 규칙집을 읽는 것 외에 스크립트, 하위 에이전트, 도구 호출은 없습니다.

### 2. 구성요소
| 구성요소 | 경로 | 목적 |
|---|---|---|
| Trigger | `skills/kor-deslop/SKILL.md` (frontmatter) | 요청 문구와 제외 대상. 매 세션 로드 |
| Rule priority | `skills/kor-deslop/SKILL.md` (우선순위) | 사용자 요청 > 의미 보존 > 패턴 |
| Meaning preservation | `skills/kor-deslop/SKILL.md` (의미 보존 규칙) | 건드리지 않는 것, 내용 앵커, 서법, 문체 등급, 장르, 빼기 전용, 국소 수정, 삭제는 후보로 |
| Procedure and self-check | `skills/kor-deslop/SKILL.md` (절차, 자체 점검) | 장르 파악, 앵커, 심각도별 수정, 점검 6항목, 변경률 30%/50% 기준 |
| Output modes | `skills/kor-deslop/SKILL.md` (결과 전달) | 기본, 점검만(표), 이미 자연스러운 글 |
| Rulebook | `skills/kor-deslop/references/patterns.md` | S1~S3가 붙은 A~J 패턴 70개, K 원칙 9개, 장르 표 |

### 3. 주요 결정
- 점진적 공개: frontmatter(약 260 토큰)만 항상 로드되고, 본문과 규칙집(약 2.2k 토큰)은 호출할 때 로드됩니다([ADR-001](../decisions/ADR-001-single-pass-skill-with-on-demand-rulebook.md)).
- 규칙 우선순위에서 사용자가 정한 형식, 문체, 범위가 모든 패턴보다 앞섭니다.
- 스킬은 빼기만 합니다. 새 비유, 사실, 감정을 넣지 않고, 문장 전체 삭제는 직접 하지 않고 후보로 알립니다.
- 반복 패턴은 1~2회 남겨, 한 가지 균일한 문체를 다른 균일한 문체로 바꾸지 않게 합니다.
- K 원칙은 고친 글뿐 아니라 Claude가 쓰는 설명 문장에도 적용합니다.

### 4. 코드 포인터
- `skills/kor-deslop/SKILL.md:1-4`
- `skills/kor-deslop/SKILL.md:10-27`
- `skills/kor-deslop/SKILL.md:29-37`
- `skills/kor-deslop/SKILL.md:39-56`
- `skills/kor-deslop/references/patterns.md:1-4`
- `skills/kor-deslop/references/patterns.md:128-142`
- `skills/kor-deslop/references/patterns.md:144-152`

### 5. 상호 참조
- 관련 모듈: `skills/` (`skills/CLAUDE.md`)
- 관련 ADR: [ADR-001](../decisions/ADR-001-single-pass-skill-with-on-demand-rulebook.md)
- 관련 런북: [release-plugin.md](../runbooks/release-plugin.md)
