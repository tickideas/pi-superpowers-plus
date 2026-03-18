---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

> **Related skills:** Need an isolated workspace? `/skill:using-git-worktrees`. Verify each task with `/skill:verification-before-completion`. Done? `/skill:finishing-a-development-branch`.

# Executing Plans

Load a written plan, review it critically, execute tasks in batches, and report back for review between batches.

**Core principle:** Batch execution with checkpoints for user review.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**Note:** If strong subagent support is available and the work fits that model, tell the user that `/skill:subagent-driven-development` will usually produce higher quality. Use this skill when batch execution in a separate session is the better fit.

If a tool result contains a ⚠️ workflow warning, stop immediately and address it before continuing.

## Prerequisites
- Active branch (not main/master) or user-confirmed intent to work on main
- Approved plan or clear task scope
- Ability to verify work as you go

## When to Use

Use this skill when:
- you already have a written implementation plan
- you want to execute in a separate session or with clearer human checkpoints
- tasks are tightly coupled enough that per-task subagent orchestration is less attractive
- you want review between batches rather than after every individual task

Prefer `/skill:subagent-driven-development` when:
- tasks are mostly independent
- subagents are available and reliable
- rapid same-session iteration is more important than batch checkpoints

## The Process

### Step 1: Load and Review Plan
1. Read the plan file
2. Review it critically
3. Identify any questions, ambiguities, or risks before starting
4. If concerns exist, raise them with the user before implementation
5. If no concerns exist, initialize the `plan_tracker` tool and proceed

### Step 2: Execute a Batch

**Default batch size: first 3 tasks**

For each task in the batch:
1. Mark it in progress via `plan_tracker`
2. Follow the task steps exactly
3. Run the specified verifications
4. Mark it complete via `plan_tracker`

If the plan's tasks are unusually large or unusually small, adjust batch size sensibly. The point is to create meaningful review checkpoints, not rigidly enforce the number 3.

### Step 3: Report for Review

When the batch is complete:
- summarize what was implemented
- show verification evidence
- note any important deviations or discoveries
- say: **"Ready for feedback."**

Then stop and wait for user input.

### Step 4: Continue or Adjust

Based on user feedback:
- apply requested changes if needed
- revisit the plan if assumptions changed
- execute the next batch
- repeat until all tasks are complete

### Step 5: Complete Development

After all tasks are complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use `/skill:finishing-a-development-branch`
- Follow that skill to verify tests, present options, and execute the user's choice

## When to Stop and Ask for Help

**STOP immediately when:**
- you hit a blocker mid-batch
- a dependency is missing or broken
- a test fails in a way the plan does not account for
- an instruction is unclear
- verification fails repeatedly
- the batch uncovers a hidden assumption that changes later tasks

Ask for clarification rather than guessing.

## When the Plan Is Wrong

This is different from being blocked. You're not merely stuck — you have learned something that makes the remaining plan incorrect or unsafe.

If that happens:
- stop executing immediately
- explain what you learned
- explain why the remaining tasks no longer fit reality
- propose a revised approach, or ask the user to revisit the design/plan
- do not keep executing tasks you already know are heading somewhere bad

## When to Revisit Earlier Steps

Return to review before continuing when:
- the user updates the plan
- fundamental approach needs rethinking
- task decomposition turns out to be wrong
- the current batch reveals that task order should change

Do not force progress through a plan that no longer makes sense.

## Execution Rules

- Review the plan critically before touching code
- Follow plan steps exactly unless you have explicitly stopped and discussed a needed change
- Do not skip verifications
- Reference other skills when the plan says to
- Between batches, report and wait
- Stop when blocked; do not guess
- Never start implementation on main/master without explicit user consent
- TDD is the default for production code: verify fail → implement minimal change → verify pass

## Integration

**Required workflow skills:**
- **`/skill:using-git-worktrees`** — Recommended: set up isolated workspace before starting. For small changes, branching in the current directory is acceptable with user approval.
- **`/skill:writing-plans`** — Creates the plan this skill executes
- **`/skill:finishing-a-development-branch`** — Complete development after all tasks

**Alternative workflow:**
- **`/skill:subagent-driven-development`** — Prefer this when the work is a better fit for per-task isolated subagents in the current session
