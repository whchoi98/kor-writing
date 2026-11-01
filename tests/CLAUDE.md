# Tests Module

## Role
Harness tests for the dev hooks and for invariants of the shipped plugin. Pure Bash + `jq`; no model
or network calls. Run with `bash tests/run-all.sh [filter]`.

## Key Files
- `run-all.sh` — runner. Defines `pass`/`fail`/`skip` and `assert_*`, `cd`s to the repo root, exports
  `CLAUDE_PROJECT_DIR` and a scratch dir `$TEST_TMP`, then **sources** every `tests/**/test-*.sh`.
  Uses `set -uo pipefail` without `-e`, so a `grep` that finds nothing cannot abort the run.
- `hooks/test-hooks.sh` — hook files, settings registration, stdin-JSON behavior, exit codes
  (PreToolUse exit 2, `--staged` exit 1), commit-msg trailer removal, all in throwaway git repos.
- `hooks/test-secret-patterns.sh` — true/false positives against the real scanner, skip and
  forbidden-path rules, PCRE compile regression.
- `structure/test-plugin-structure.sh` — manifests, version sync (plugin.json, README badge, CHANGELOG),
  pattern table integrity and count, SKILL.md frontmatter, no root plugin components, `.mcp.json`
  empty, docs and bilingual anchors, reference Code Pointers, the SKILL.md change-rate snippet, and
  `claude plugin validate .` (skipped when the CLI is absent).
- `fixtures/secret-samples.txt` — TAB-separated `name / prefix / body`; joined at runtime so no full
  token is stored. `fixtures/false-positives.txt` — one non-secret per line.

## Rules
- Test files are sourced, not executed: do not `exit`, do not `set -e`, guard commands that may return
  non-zero (`|| true`, or capture `$?`).
- Sourcing shares the runner's scope. Never assign `TOTAL`, `PASSED`, `FAILED`, `SKIPPED`, `FAILURES`,
  `FILTER`, `TEST_TMP`, `PROJECT_ROOT` or `SCRIPT_DIR` (a `TOTAL=` for the pattern count once corrupted
  the counters; a structure test now rejects it). Prefix test-local names, e.g. `PATTERN_TOTAL`.
- Never write a complete secret literal anywhere; split it into prefix and body.
- Use `$TEST_TMP` for scratch files and repos; it is removed on exit.
- A new invariant needs a test that fails when the invariant is broken. Prove it once by breaking the
  file (mutation) and watching the test go red.
