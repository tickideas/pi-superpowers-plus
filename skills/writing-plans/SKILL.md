---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

> **Related skills:** Did you `/skill:brainstorming` first? Ready to implement? Use `/skill:executing-plans` or `/skill:subagent-driven-development`.

# Writing Plans

Write comprehensive implementation plans assuming the engineer has zero context for the codebase and questionable taste. Document everything they need: which files to touch, what each file is responsible for, complete code where needed, tests to write, commands to run, and how to verify success. Plans should be DRY, YAGNI, TDD-oriented, and broken into bite-sized tasks.

Assume the worker executing the plan is capable, but lacks project context and may not make good decomposition or testing decisions without explicit guidance.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** This should be run in a dedicated worktree or isolated branch prepared during brainstorming.

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`
- User preferences for plan location override this default

## Boundaries
- Read code and docs: yes
- Write to `docs/plans/`: yes
- Edit or create any other files: no

If a tool result contains a ⚠️ workflow warning, stop immediately and address it before continuing.

## Checklist

You MUST complete these in order:

1. **Confirm prerequisites** — approved spec or clear requirements, isolated workspace, no unresolved scope confusion
2. **Check scope** — if the spec contains multiple independent subsystems, split into separate plans
3. **Map file structure** — decide which files will be created/modified and what each file is responsible for
4. **Decompose into tasks** — each task should be small, testable, and logically self-contained
5. **Write task steps** — exact file paths, code, commands, and expected outputs
6. **Write plan header and architecture summary** — clear enough for a fresh worker to execute
7. **Review the written plan** — dispatch `reviewer` with the spec-reviewer prompt and focused plan-review context only
8. **Offer execution handoff** — `/skill:subagent-driven-development` or `/skill:executing-plans`

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it was not, stop and suggest splitting it into separate plans — one plan per subsystem.

Each plan should produce working, testable software on its own.

Do not create giant plans that mix unrelated concerns just because they were mentioned in the same conversation.

## File Structure First

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces
- Each file should have one clear responsibility
- Prefer smaller, focused files over large files that mix responsibilities
- Files that change together should live together
- Split by responsibility, not by technical layer alone
- In existing codebases, follow established patterns unless those patterns directly block the work
- If a file you must touch has become unwieldy, including a focused split in the plan is reasonable

This structure informs task decomposition. Each task should produce changes that make sense independently and can be reviewed without reconstructing the whole system in memory.

## Bite-Sized Task Granularity

**Each step is one action (roughly 2-5 minutes):**
- Write the failing test
- Run it to make sure it fails
- Implement the minimal code to make the test pass
- Run the tests and make sure they pass
- Commit

If a task would take much longer, split it.

If the plan exceeds roughly 8 substantial tasks, consider splitting into phases with a checkpoint between them.

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **REQUIRED SUB-SKILL:** Use `/skill:subagent-driven-development` (recommended) or `/skill:executing-plans` to implement this plan task-by-task.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about the approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

```markdown
### Task N: [Component Name]

**TDD scenario:** [New feature — full TDD cycle | Modifying tested code — run existing tests first | Trivial change — use judgment]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Why this task exists:** [One short paragraph describing the responsibility and how it fits the whole plan]

**Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

**Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
```

## Planning Rules

- Exact file paths always
- Complete code in the plan, not vague instructions like "add validation"
- Exact commands with expected output
- Reference relevant skills with `/skill:` syntax
- Order tasks so each task's dependencies are completed by earlier tasks
- Favor plans that preserve good boundaries and testability
- Be explicit about migrations, rollout sequencing, or data backfills when relevant
- Avoid speculative work — YAGNI applies to plans too

## Plan Review Loop

After writing the complete plan:

1. Dispatch the `reviewer` subagent with the spec-reviewer prompt and focused review context only
2. Provide:
   - path to the plan document
   - path to the spec/design document
   - what the plan is intended to implement
   - any specific concerns to scrutinize
3. Do NOT pass your session history
4. If issues are found:
   - fix the plan
   - re-dispatch reviewer for the whole plan
5. If the review loop exceeds 3 iterations, stop and surface the issue to the user

Reviewers are advisory. If you disagree with feedback, explain why instead of silently ignoring it.

## Execution Handoff

After saving the plan, mark the planning phase complete: call `plan_tracker` with `{action: "update", status: "complete"}` for the current phase.

Then offer execution choice:

**"Plan complete and saved to `docs/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (recommended, this session)** — Fresh subagent per task with two-stage review. Better for plans with many independent or moderately-coupled tasks.

**2. Parallel Session (separate)** — Execute in a separate session using checkpoints. Better when tasks are tightly coupled or you want stronger human review between batches.

**Which approach?"**

### If Subagent-Driven is chosen
- **REQUIRED SUB-SKILL:** Use `/skill:subagent-driven-development`
- Stay in this session
- Fresh subagent per task + spec review + code review

### If Parallel Session is chosen
- Guide the user to open a new session in the worktree or branch
- **REQUIRED SUB-SKILL:** New session uses `/skill:executing-plans`
- Execute in batches with review checkpoints

## Key Principles

- **Plan before implementation**
- **Design file structure before task lists**
- **Make tasks small enough to execute reliably**
- **Use TDD framing explicitly**
- **Provide exact paths, commands, and expected results**
- **Optimize for isolated, reviewable changes**
- **Keep the plan readable by someone with no project context**
