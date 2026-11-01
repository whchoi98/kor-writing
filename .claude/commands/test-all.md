---
description: Run the harness tests and plugin manifest validation, then report results
allowed-tools: Read, Glob, Bash(bash tests/run-all.sh:*), Bash(claude plugin validate:*), Bash(bash -n:*)
---

# Test All

Run every check for this repo. None of them call a model or the network.

## Step 1: Run Tests

Run both and keep going if one fails, so the report covers all of them:

```bash
# Hooks, secret patterns, plugin structure (pattern count, versions, manifests, docs)
bash tests/run-all.sh

# Claude Code's own manifest and skill validation
claude plugin validate .
```

If $ARGUMENTS is given, pass it to the runner as a filter (`hooks`, `secret`, `structure`).

## Step 2: Report

Present:
- Total, passed, failed, skipped
- Failed test names with the expected and actual values
- The likely fix when the cause is apparent

`claude plugin validate .` reports one `ICON_MISSING` warning; it only matters for the public plugin
directory listing and does not fail validation.

## Error Recovery

### If the runner itself fails
```bash
bash -n tests/run-all.sh
ls -la tests/*/*.sh
```

### Common failure categories

| Failure Pattern | Likely Cause | Fix |
|---|---|---|
| Pattern count mismatch | Row added or removed in `patterns.md` | Update README (both languages), `plugin.json`, `marketplace.json` |
| Version mismatch | `plugin.json` bumped without README badge or CHANGELOG | Follow `docs/runbooks/release-plugin.md` |
| Duplicate pattern ID | Copy-pasted row | Give the new row an unused ID; never renumber |
| `.mcp.json` not empty | Dev-only MCP server added | Move it to user scope (`claude mcp add -s user`) |
| "invalid JSON" | Malformed manifest or settings | `python3 -m json.tool <file>` |
| "not executable" | Permission lost | `chmod +x` on the file |
