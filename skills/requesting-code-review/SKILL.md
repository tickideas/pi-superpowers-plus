---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

Dispatch the `reviewer` subagent with the code-reviewer prompt template to catch issues before they cascade.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- Final whole-branch review in subagent-driven development (per-task reviews use that skill's task-reviewer prompt)
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git merge-base main HEAD)  # or the commit you recorded before the work — not HEAD~1, which drops all but the last commit
HEAD_SHA=$(git rev-parse HEAD)
```

For large ranges, hand the reviewer the diff as a file instead of letting it re-derive it: run `skills/subagent-driven-development/scripts/review-package BASE HEAD` and include the printed path in the dispatch.

**2. Dispatch reviewer subagent:**

Fill the template at `code-reviewer.md` in this skill directory, then dispatch a subagent with it.

**How to dispatch:**

Use the `subagent` tool with the code-reviewer template filled in and `agent: "reviewer"`:

```ts
subagent({ agent: "reviewer", model: "<most capable available for whole-branch reviews>", task: "... filled template ..." })
```

**Placeholders:**
- `[WHAT_WAS_IMPLEMENTED]` - What you just built
- `[PLAN_OR_REQUIREMENTS]` - What it should do
- `[BASE_SHA]` - Starting commit
- `[HEAD_SHA]` - Ending commit
- `[DESCRIPTION]` - Brief summary

**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)

## Example

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch reviewer subagent]
  WHAT_WAS_IMPLEMENTED: Verification and repair functions for conversation index
  PLAN_OR_REQUIREMENTS: Task 2 from docs/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## Integration with Workflows

**Subagent-Driven Development:**
- Per-task reviews use that skill's task-reviewer prompt (spec + quality in one pass)
- This skill's template is the final whole-branch review, dispatched on the most capable model
- If it returns findings, dispatch ONE fix subagent with the complete list

**Executing Plans:**
- Uses human review between batches — dispatched code review is optional
- Useful before merge if no review happened during execution

**Ad-Hoc Development:**
- Review before merge
- Review when stuck

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

See template at: `code-reviewer.md` in this skill directory
