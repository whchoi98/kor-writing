# kor-writing

한국어 글쓰기용 Claude Code 플러그인입니다.

| skill | 내용 |
|---|---|
| `kor-deslop` | 한국어 글의 AI 티(번역투, AI 관용구, 기계적 구조, 균일한 리듬, 과잉 서식)를 찾아 내용은 그대로 두고 문체만 고칩니다. 패턴 79개, 스크립트와 하위 에이전트 없이 단일 패스 |

## 설치

```bash
claude plugin marketplace add whchoi98/kor-writing
claude plugin install kor-writing@kor-writing
```

호출은 `/kor-writing:kor-deslop`이며, "AI 티 빼줘", "윤문해줘", "점검만 해줘" 같은 요청에도 자동으로 불립니다. 별도 도구 설치는 필요 없습니다.

## 구성

| 파일 | 내용 |
|---|---|
| `skills/kor-deslop/SKILL.md` | 우선순위, 의미 보존 규칙, 절차, 자체 점검, 결과 전달 |
| `skills/kor-deslop/references/patterns.md` | 패턴 79개(A~J 70개, 작성자 원칙 K 9개)와 장르 표 |
| `NOTICE.md` | humanize-korean(MIT) 라이선스 고지 |

humanize-korean-house나 humanize-korean과 트리거 문구가 겹치므로 한 환경에서는 하나만 켜 두는 편이 좋습니다.

## 갱신

수정 후 `.claude-plugin/plugin.json`의 `version`을 올리고 push합니다. 설치된 쪽은 `claude plugin marketplace update kor-writing` 후 `/reload-plugins`로 반영합니다.
