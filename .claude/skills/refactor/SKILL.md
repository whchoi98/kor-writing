---
name: refactor
description: Restructure the kor-deslop skill files (SKILL.md, references/patterns.md) or the bash harness without changing behavior, verifying with tests/run-all.sh after each step. Use when asked to reorganize, deduplicate, shorten, or split the skill or harness.
---

# Refactor Skill

Improve structure without changing what the skill does or what the harness checks.

## What "behavior" means here
- **Skill**: the set of pattern IDs, their severity, their prescriptions, the rule priority, the
  meaning-preservation rules, the procedure, the six self-checks, and the output modes.
  Moving text between SKILL.md and patterns.md is a refactor; changing any of the above is not.
- **Harness**: which inputs each hook and test accepts or rejects.

## Process

### 1. Analysis
- Read root `CLAUDE.md` and `skills/CLAUDE.md`
- Identify the target and the tests covering it (`tests/structure/test-plugin-structure.sh`, `tests/hooks/*.sh`)
- Record the baseline: `bash tests/run-all.sh` and `claude plugin details kor-writing@kor-writing`
  (always-on and on-invoke token cost)

### 2. Plan
Present the plan to the user:
- What will change
- What will NOT change (pattern IDs, severities, rule priority, output modes)
- Expected effect on always-on cost (the SKILL.md `description` is loaded every session)
- Risk assessment (low/medium/high)

### 3. Execute
- Small steps; after each one run `bash tests/run-all.sh` and `claude plugin validate .`
- Keep pattern IDs and table columns exactly as they are
- Keep commits atomic

### 4. Verify
- All tests pass and the pattern count is unchanged
- `git diff --stat` touches only the intended files
- A skill-text refactor still ships to users, so bump the PATCH version (see `release` skill)
