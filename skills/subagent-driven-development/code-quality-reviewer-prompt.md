# Code Quality Reviewer Prompt Template

Use this template when dispatching the `reviewer` subagent for code quality review.

**Purpose:** Verify implementation is well-built (clean, tested, maintainable)

**Only dispatch after spec compliance review passes.**

```
Dispatch the `reviewer` subagent with the code-reviewer template:
  Use the template at ./code-reviewer.md (in the requesting-code-review skill directory)

  WHAT_WAS_IMPLEMENTED: [from worker's implementation report]
  PLAN_OR_REQUIREMENTS: Task N from [plan-file]
  BASE_SHA: [commit before task]
  HEAD_SHA: [current commit]
  DESCRIPTION: [task summary]
```

**Code reviewer returns:** Strengths, Issues (Critical/Important/Minor), Assessment
