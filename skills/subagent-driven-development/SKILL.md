---
name: subagent-driven-development
description: Use when executing implementation plans with independent tasks in the current session
---

# Subagent-Driven Development

Execute a plan by dispatching a fresh subagent per task, with two-stage review after each task: spec compliance review first, then code quality review.

**Why subagents:** You delegate tasks to specialized agents with isolated context. By precisely crafting their instructions and context, you keep them focused and effective. They should never inherit your full session history — you construct exactly what they need. This preserves your own context for orchestration and review.

**Core principle:** Fresh subagent per task + two-stage review (spec then quality) = high quality, fast iteration.

**Continuous execution:** Do not pause to check in with your human partner between tasks. Execute all tasks from the plan without stopping. The only reasons to stop are: BLOCKED status you cannot resolve, ambiguity that genuinely prevents progress, or all tasks complete. "Should I continue?" prompts and progress summaries waste their time — they asked you to execute the plan, so execute it.

If a tool result contains a ⚠️ workflow warning, stop immediately and address it before continuing.

## Prerequisites
- Active branch (not main/master) or user-confirmed intent to work on main
- Approved plan or clear task scope
- Ability to dispatch the required subagents

## When to Use

```dot
digraph when_to_use {
    "Have implementation plan?" [shape=diamond];
    "Tasks mostly independent?" [shape=diamond];
    "Stay in this session?" [shape=diamond];
    "subagent-driven-development" [shape=box];
    "executing-plans" [shape=box];
    "Manual execution or brainstorm first" [shape=box];

    "Have implementation plan?" -> "Tasks mostly independent?" [label="yes"];
    "Have implementation plan?" -> "Manual execution or brainstorm first" [label="no"];
    "Tasks mostly independent?" -> "Stay in this session?" [label="yes"];
    "Tasks mostly independent?" -> "Manual execution or brainstorm first" [label="no - tightly coupled"];
    "Stay in this session?" -> "subagent-driven-development" [label="yes"];
    "Stay in this session?" -> "executing-plans" [label="no - parallel session"];
}
```

**Use this when:**
- you already have a written implementation plan
- tasks are mostly independent or only moderately coupled
- you want to stay in the current session
- you want review after each task without stopping for a human checkpoint every time

**Prefer `/skill:executing-plans` when:**
- tasks are tightly coupled
- you want stronger human review between batches
- the work needs more in-session orchestration than isolated execution

**Dependent tasks:** Most real plans have some dependencies. For dependent tasks, include the previous task's implementation summary, files changed, and any important decisions in the next subagent's context. Track what each completed task produced so you can pass it forward.

## Model Selection

Use the least powerful model that can reliably handle each role.

- **Mechanical implementation tasks** (isolated functions, clear specs, 1-2 files): prefer a fast, cheap model
- **Integration and judgment tasks** (multi-file coordination, debugging, pattern matching): use a standard model
- **Architecture or review tasks**: use the most capable available model

**Complexity signals:**
- Touches 1-2 files with a complete spec → cheap model
- Touches multiple files with integration concerns → standard model
- Requires design judgment or broad codebase understanding → most capable model

## The Process

```dot
digraph process {
    rankdir=TB;

    subgraph cluster_per_task {
        label="Per Task";
        "Dispatch worker subagent" [shape=box];
        "Worker asks questions or reports status?" [shape=diamond];
        "Answer questions / provide context / re-dispatch" [shape=box];
        "Worker completes task" [shape=box];
        "Dispatch reviewer
(spec-reviewer prompt)" [shape=box];
        "Reviewer approves spec?" [shape=diamond];
        "Worker fixes spec gaps" [shape=box];
        "Dispatch reviewer
(code-reviewer prompt)" [shape=box];
        "Reviewer approves quality?" [shape=diamond];
        "Worker fixes quality issues" [shape=box];
        "Mark task complete via plan_tracker" [shape=box];
    }

    "Read plan, extract tasks, capture context, initialize plan_tracker" [shape=box];
    "More tasks remain?" [shape=diamond];
    "Summarize completion and ask user before final phase" [shape=box];
    "Use /skill:finishing-a-development-branch" [shape=box style=filled fillcolor=lightgreen];

    "Read plan, extract tasks, capture context, initialize plan_tracker" -> "Dispatch worker subagent";
    "Dispatch worker subagent" -> "Worker asks questions or reports status?";
    "Worker asks questions or reports status?" -> "Answer questions / provide context / re-dispatch" [label="needs context / blocked / has questions"];
    "Answer questions / provide context / re-dispatch" -> "Dispatch worker subagent";
    "Worker asks questions or reports status?" -> "Worker completes task" [label="done"];
    "Worker completes task" -> "Dispatch reviewer
(spec-reviewer prompt)";
    "Dispatch reviewer
(spec-reviewer prompt)" -> "Reviewer approves spec?";
    "Reviewer approves spec?" -> "Worker fixes spec gaps" [label="no"];
    "Worker fixes spec gaps" -> "Dispatch reviewer
(spec-reviewer prompt)" [label="re-review"];
    "Reviewer approves spec?" -> "Dispatch reviewer
(code-reviewer prompt)" [label="yes"];
    "Dispatch reviewer
(code-reviewer prompt)" -> "Reviewer approves quality?";
    "Reviewer approves quality?" -> "Worker fixes quality issues" [label="no"];
    "Worker fixes quality issues" -> "Dispatch reviewer
(code-reviewer prompt)" [label="re-review"];
    "Reviewer approves quality?" -> "Mark task complete via plan_tracker" [label="yes"];
    "Mark task complete via plan_tracker" -> "More tasks remain?";
    "More tasks remain?" -> "Dispatch worker subagent" [label="yes"];
    "More tasks remain?" -> "Summarize completion and ask user before final phase" [label="no"];
    "Summarize completion and ask user before final phase" -> "Use /skill:finishing-a-development-branch";
}
```

## Handling Worker Status

Worker subagents may report one of four statuses. Handle each explicitly:

**DONE**
- The task is complete
- Proceed to spec compliance review

**DONE_WITH_CONCERNS**
- The task is complete, but the worker flagged concerns
- Read the concerns before proceeding
- If the concerns affect correctness or scope, resolve them before review
- If they are observations (for example, a file is getting too large), note them and continue to review

**NEEDS_CONTEXT**
- The worker is missing information
- Provide the missing context and re-dispatch
- Do not proceed until the ambiguity is resolved

**BLOCKED**
- The worker cannot complete the task as specified
- Assess the blocker:
  1. If it is a context problem, provide more context and re-dispatch
  2. If the task needs more reasoning, re-dispatch with a stronger model
  3. If the task is too large, break it into smaller pieces
  4. If the plan is wrong, stop and escalate to the user

Never ignore an escalation or keep retrying the same setup without changing anything.

## Prompt Templates

Use the templates in this directory:
- `./implementer-prompt.md` — worker subagent implementation prompt
- `./spec-reviewer-prompt.md` — reviewer prompt for spec compliance
- `./code-quality-reviewer-prompt.md` — reviewer prompt for code quality

**How to dispatch:**

Use the `subagent` tool directly with filled prompt text:

```ts
subagent({ agent: "worker", task: "... full implementation prompt text ..." })
```

```ts
subagent({ agent: "reviewer", task: "... full review prompt text ..." })
```

```ts
subagent({ agent: "reviewer", task: "... full review prompt text ..." })
```

## Orchestrator Rules

- Read the plan once and extract all tasks before starting
- Initialize `plan_tracker` with the full task list
- Provide each subagent the exact task text plus only the context it needs
- Do not make subagents read the entire plan file if you can provide the relevant task directly
- Track outputs from completed tasks so later tasks receive the right context
- Do not skip either review stage
- Do not move to the next task while review issues remain open

## Example Workflow

```
You: I'm using Subagent-Driven Development to execute this plan.

[Read plan file once: docs/plans/feature-plan.md]
[Extract all 5 tasks with full text and context]
[Initialize plan_tracker tool with all tasks]

Task 1: Hook installation script

[Get Task 1 text and context]
[Dispatch `worker` subagent with full task text + context]

Worker: "Before I begin - should the hook be installed at user or system level?"

You: "User level (~/.config/superpowers/hooks/)"

Worker: "Got it. Implementing now..."
[Later] Worker:
  - Status: DONE
  - Implemented install-hook command
  - Added tests, 5/5 passing
  - Self-review: Found I missed --force flag, added it
  - Committed

[Dispatch `reviewer` subagent with the spec-reviewer prompt]
Reviewer: ✅ Spec compliant - all requirements met, nothing extra

[Dispatch `reviewer` subagent with the code-reviewer prompt]
Reviewer: Strengths: Good test coverage, clean. Issues: None. Approved.

[Mark Task 1 complete]

Task 2: Recovery modes

[Dispatch `worker` subagent with full task text + context]

Worker:
  - Status: DONE_WITH_CONCERNS
  - Added verify/repair modes
  - 8/8 tests passing
  - Concern: progress reporting may need a constant

[Dispatch `reviewer` subagent with the spec-reviewer prompt]
Reviewer: ❌ Issues:
  - Missing: Progress reporting (spec says "report every 100 items")
  - Extra: Added --json flag (not requested)

[Worker fixes issues]
[Reviewer re-checks spec compliance]
Reviewer: ✅ Spec compliant now

[Dispatch `reviewer` subagent with the code-reviewer prompt]
Reviewer: Strengths: Solid. Issues (Important): Magic number (100)

[Worker fixes]
[Reviewer re-checks code quality]
Reviewer: ✅ Approved

[Mark Task 2 complete]
```

## Red Flags

**Never:**
- Start implementation on main/master branch without explicit user consent
- Skip reviews (spec compliance OR code quality)
- Proceed with unfixed issues
- Dispatch multiple implementation subagents in parallel against the same changing codebase
- Make a subagent read the full plan when you can provide the relevant task directly
- Skip scene-setting context
- Ignore subagent questions
- Accept "close enough" on spec compliance
- Start code quality review before spec compliance is ✅
- Move to next task while either review has open issues
- Write code yourself to rescue a failed worker task unless the workflow has explicitly changed

## When a Subagent Fails

You are the orchestrator. You do NOT write code as a shortcut around the process.

If a worker subagent fails, errors out, or produces incomplete work:

1. **Attempt 1:** Dispatch a NEW fix subagent with specific instructions about what went wrong. Include the original task text and the error output.
2. **Attempt 2:** If that also fails, dispatch one more with a changed approach, more context, or a stronger model.
3. **After 2 failed attempts:** STOP. Report the failure to the user and ask how to proceed. The task likely needs redesign or replanning.

**Never:**
- patch the work inline "just to finish it"
- silently skip the failed task
- reduce quality gates because the task is almost done

## After All Tasks Complete

When all tasks are done and reviewed:

1. Summarize what was implemented
   - tasks completed
   - important files changed
   - tests run / counts if available
2. Ask: **"All tasks complete. Ready for final review and finishing?"**
3. Wait for user confirmation before proceeding

Do NOT automatically dispatch final review or start the finishing skill without user confirmation.

## Integration

**Required workflow skills:**
- **`/skill:using-git-worktrees`** — Recommended: set up isolated workspace before starting. For small changes, branching in the current directory is acceptable with user approval.
- **`/skill:writing-plans`** — Creates the plan this skill executes
- **`/skill:requesting-code-review`** — Review template and review expectations
- **`/skill:finishing-a-development-branch`** — Complete development after all tasks

**Subagents follow by default:**
- **TDD** — Runtime warnings on source-before-test patterns. Worker subagents used for implementation receive three-scenario TDD instructions via agent profiles and prompt templates: new feature (full TDD), modifying tested code (run existing tests), trivial change (judgment call).

**Alternative workflow:**
- **`/skill:executing-plans`** — Use for a parallel session instead of same-session orchestration
