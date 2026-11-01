# Security / 보안 구현 상세

<a href="#english"><img src="https://img.shields.io/badge/lang-English-blue.svg" alt="English"></a>
<a href="#korean"><img src="https://img.shields.io/badge/lang-한국어-red.svg" alt="Korean"></a>

<a id="english"></a>
## English

### 1. Overview
The repo is public and its root is the installed plugin, so the security goals are: nothing secret is
ever committed, nothing executable ships to installers, and the dev harness cannot be bypassed silently.

### 2. Components
| Component | Path | Purpose |
|---|---|---|
| Secret scanner | `.claude/hooks/secret-scan.sh` | PreToolUse on `git commit` (exit 2), git pre-commit (`--staged`, exit 1), manual `--files` |
| Git hook installer | `scripts/install-hooks.sh` | Installs `pre-commit` (secret scan) and `commit-msg` (strips `Co-Authored-By`) |
| Claude settings | `.claude/settings.json` | Deny list, `Read(./.env)` denied, empty commit/PR attribution, hook registration |
| Ignore rules | `.gitignore` | `.env`, `.claude/settings.local.json`, source archives |
| Shipped MCP config | `.mcp.json` | Must stay `{"mcpServers": {}}`; read as the plugin's MCP config by installers |
| License notice | `NOTICE.md`, `LICENSE` | MIT notice for humanize-korean; MIT license for this plugin |
| Structure tests | `tests/structure/test-plugin-structure.sh` | Fails on root `hooks/`, `commands/`, `agents/`, `settings.json`, `bin/`, or a non-empty `.mcp.json` |

### 3. Key Decisions
- Markdown is scanned. The project-init template skips `*.md`, which would leave this repo almost unscanned.
- PreToolUse blocks with exit 2 and has no `|| true`; exit 1 would only warn.
- The PreToolUse scan also covers modified and untracked files when the command contains `git add` or
  `commit -a`, because staging happens after the hook runs. The git pre-commit hook covers commits made
  outside Claude Code.
- The plugin ships documentation only ([ADR-001](../decisions/ADR-001-single-pass-skill-with-on-demand-rulebook.md)),
  so an installer runs no code from this repo.

### 4. Code Pointers
- `.claude/hooks/secret-scan.sh`
- `.claude/settings.json`
- `scripts/install-hooks.sh`
- `tests/hooks/test-secret-patterns.sh`
- `tests/structure/test-plugin-structure.sh`

### 5. Cross-references
- Related modules: `tests/` (`tests/CLAUDE.md`)
- Related ADRs: [ADR-001](../decisions/ADR-001-single-pass-skill-with-on-demand-rulebook.md)
- Related runbooks: [release-plugin.md](../runbooks/release-plugin.md)

<a id="korean"></a>
## 한국어

### 1. 개요
이 저장소는 공개되어 있고 루트가 곧 설치되는 플러그인입니다. 그래서 보안 목표는 비밀값을 절대 커밋하지 않고, 설치하는 사용자에게 실행 가능한 것을 배포하지 않으며, 개발 하네스가 조용히 우회되지 않게 하는 것입니다.

### 2. 구성요소
| 구성요소 | 경로 | 목적 |
|---|---|---|
| Secret scanner | `.claude/hooks/secret-scan.sh` | `git commit`에 대한 PreToolUse(exit 2), git pre-commit(`--staged`, exit 1), 수동 `--files` |
| Git hook installer | `scripts/install-hooks.sh` | `pre-commit`(비밀값 검사)과 `commit-msg`(`Co-Authored-By` 제거) 설치 |
| Claude settings | `.claude/settings.json` | 거부 목록, `Read(./.env)` 거부, 빈 커밋/PR attribution, hook 등록 |
| Ignore rules | `.gitignore` | `.env`, `.claude/settings.local.json`, 원본 압축 파일 |
| Shipped MCP config | `.mcp.json` | `{"mcpServers": {}}`로 유지. 설치한 사용자 환경에서 플러그인 MCP 설정으로 읽힘 |
| License notice | `NOTICE.md`, `LICENSE` | humanize-korean MIT 고지, 이 플러그인의 MIT 라이선스 |
| Structure tests | `tests/structure/test-plugin-structure.sh` | 루트 `hooks/`, `commands/`, `agents/`, `settings.json`, `bin/` 또는 비어 있지 않은 `.mcp.json`이 있으면 실패 |

### 3. 주요 결정
- Markdown도 검사합니다. project-init 템플릿은 `*.md`를 건너뛰는데, 그대로 두면 이 저장소는 거의 검사되지 않습니다.
- PreToolUse는 exit 2로 차단하고 `|| true`를 붙이지 않습니다. exit 1은 경고만 합니다.
- 명령에 `git add`나 `commit -a`가 있으면 PreToolUse 검사가 수정된 파일과 추적되지 않은 파일도 봅니다. staging이 hook 실행 뒤에 일어나기 때문입니다. Claude Code 밖에서 만든 커밋은 git pre-commit hook이 검사합니다.
- 플러그인은 문서만 배포합니다([ADR-001](../decisions/ADR-001-single-pass-skill-with-on-demand-rulebook.md)). 설치한 사용자는 이 저장소의 코드를 실행하지 않습니다.

### 4. 코드 포인터
- `.claude/hooks/secret-scan.sh`
- `.claude/settings.json`
- `scripts/install-hooks.sh`
- `tests/hooks/test-secret-patterns.sh`
- `tests/structure/test-plugin-structure.sh`

### 5. 상호 참조
- 관련 모듈: `tests/` (`tests/CLAUDE.md`)
- 관련 ADR: [ADR-001](../decisions/ADR-001-single-pass-skill-with-on-demand-rulebook.md)
- 관련 런북: [release-plugin.md](../runbooks/release-plugin.md)
