---
name: systematic-debugging
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
---

> **Related skills:** Write a failing test for the bug with `/skill:test-driven-development`. Verify the fix with `/skill:verification-before-completion`.

# Systematic Debugging

Random fixes waste time and create new bugs. Quick patches mask underlying issues.

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

**Violating the letter of this process is violating the spirit of debugging.**

> The workflow-monitor extension tracks your debugging: it detects fix-without-investigation and counts failed fix attempts, surfacing warnings in tool results. Use `workflow_reference` with debug topics for additional guidance.

If a tool result contains a ⚠️ workflow warning, stop immediately and address it before continuing.

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you have not completed Phase 1, you cannot propose fixes.

## When to Use

Use this for ANY technical issue:
- test failures
- bugs in production or development
- unexpected behavior
- performance problems
- build failures
- integration issues

**Use this ESPECIALLY when:**
- under time pressure
- "just one quick fix" seems obvious
- you have already tried multiple fixes
- the previous fix did not work
- you do not fully understand the issue

**Do not skip when:**
- the issue seems simple
- you are in a hurry
- someone wants it fixed immediately

Systematic debugging is faster than guess-and-check thrashing.

## The Four Phases

You MUST complete each phase before proceeding to the next.

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

1. **Read Error Messages Carefully**
   - Do not skip errors or warnings
   - Read stack traces completely
   - Note line numbers, file paths, and error codes
   - Error text often contains the clue you need

2. **Reproduce Consistently**
   - Can you trigger it reliably?
   - What exact steps cause it?
   - Does it happen every time?
   - If not reproducible, gather more data instead of guessing

3. **Check Recent Changes**
   - What changed that could cause this?
   - Inspect git diff and recent commits
   - Look for dependency, config, or environment changes

4. **Gather Evidence in Multi-Component Systems**

   When the system spans multiple boundaries (for example CI → build → signing, or API → service → database), do not jump to fixes.

   For EACH boundary:
   - log what data enters the component
   - log what data exits the component
   - verify environment/config propagation
   - inspect state at each layer

   Run once to learn WHERE the system breaks. Then investigate that specific boundary.

   **Example (multi-layer system):**
   ```bash
   # Layer 1: Workflow
   echo "=== Secrets available in workflow: ==="
   echo "IDENTITY: ${IDENTITY:+SET}${IDENTITY:-UNSET}"

   # Layer 2: Build script
   echo "=== Env vars in build script: ==="
   env | grep IDENTITY || echo "IDENTITY not in environment"

   # Layer 3: Signing script
   echo "=== Keychain state: ==="
   security list-keychains
   security find-identity -v

   # Layer 4: Actual signing
   codesign --sign "$IDENTITY" --verbose=4 "$APP"
   ```

   This reveals which boundary fails (for example: secrets → workflow ✓, workflow → build ✗).

5. **Trace Data Flow**

   When the error is deep in the stack:
   - identify where the bad value or bad state appears
   - identify what called it with that value
   - keep tracing backward until you find the source
   - fix at the source, not the symptom

   See `root-cause-tracing.md` for the complete technique.

### Phase 2: Pattern Analysis

1. **Find Working Examples**
   - Locate similar working code in the same codebase
   - Find the nearest good example before inventing your own interpretation

2. **Compare Against References**
   - Read the relevant reference or implementation COMPLETELY
   - Do not skim
   - Understand the pattern before applying it

3. **Identify Differences**
   - List every difference between working and broken behavior
   - Do not dismiss small differences without checking them

4. **Understand Dependencies**
   - What components, settings, config, and environment does this require?
   - What assumptions does the code make?

### Phase 3: Hypothesis and Testing

1. **Form a Single Hypothesis**
   - State clearly: "I think X is the root cause because Y"
   - Be specific, not vague

2. **Test Minimally**
   - Make the SMALLEST possible change to test the hypothesis
   - Change one variable at a time
   - Do not pile multiple fixes together

3. **Verify Before Continuing**
   - If it worked, proceed to Phase 4
   - If it did not, form a NEW hypothesis
   - Do not stack more fixes on top of an unproven idea

4. **When You Do Not Know**
   - Say what you do not understand
   - Do not pretend confidence
   - Gather more evidence or ask for clarification

### Phase 4: Implementation

1. **Create a Failing Test Case**
   - Simplest possible reproduction
   - Automated test if possible
   - One-off script if no test framework exists
   - MUST exist before the fix
   - Use `/skill:test-driven-development` for proper failing-test workflow

2. **Implement a Single Fix**
   - Fix the root cause identified
   - One change at a time
   - No bundled refactoring
   - No "while I'm here" improvements

3. **Verify the Fix**
   - Does the test now pass?
   - Did other tests remain green?
   - Is the original issue actually resolved?

4. **If the Fix Does Not Work**
   - If fewer than 3 attempts: return to Phase 1 with the new evidence
   - If 3 or more attempts have failed: STOP and question the architecture

### When 3+ Fixes Fail: Question Architecture

This is not just a failed hypothesis. It may be a bad architectural assumption.

Signals:
- each fix reveals new shared state or coupling somewhere else
- the fix keeps requiring broad refactoring just to move forward
- each fix creates a new symptom elsewhere

STOP and ask:
- Is this pattern fundamentally sound?
- Are we continuing out of inertia?
- Should we redesign rather than keep patching symptoms?

Discuss this with the user before attempting more fixes.

## Red Flags — STOP and Follow the Process

If you catch yourself thinking:
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "Skip the test, I'll manually verify"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "Pattern says X but I'll adapt it differently"
- "Here are the main problems" followed immediately by fixes instead of evidence
- "One more fix attempt" after multiple failed tries
- each fix reveals a new problem in a different place

All of these mean: STOP. Return to Phase 1.

## Human Signals You're Doing It Wrong

Watch for feedback like:
- "Is that not happening?" → you assumed instead of verifying
- "Will it show us...?" → you need evidence gathering
- "Stop guessing" → you are proposing fixes without understanding
- "Ultrathink this" → question the deeper pattern, not just symptoms
- "We're stuck?" → your current approach is not producing learning

When you hear those signals, stop and return to investigation.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Issue is simple, don't need process" | Simple issues have root causes too. |
| "Emergency, no time for process" | Systematic debugging is faster than thrashing. |
| "Just try this first, then investigate" | First fix sets the tone. Investigate first. |
| "I'll write test after confirming fix works" | Untested fixes do not stick. |
| "Multiple fixes at once saves time" | You lose isolation and create new bugs. |
| "Reference too long, I'll adapt the pattern" | Partial understanding creates failures. |
| "I see the problem, let me fix it" | Seeing symptoms is not the same as knowing the cause. |
| "One more fix attempt" after repeated failures | Repeated failure suggests architectural trouble. |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Root Cause** | Read errors, reproduce, check changes, gather evidence | Understand what breaks and why |
| **2. Pattern** | Find working examples, compare, inspect dependencies | Understand differences |
| **3. Hypothesis** | Form theory, test minimally | Confirm or replace hypothesis |
| **4. Implementation** | Create failing test, fix, verify | Bug resolved, tests pass |

## When the Process Reveals "No Root Cause"

If investigation shows the issue is genuinely environmental, timing-dependent, or external:
1. document what you investigated
2. implement appropriate handling (retry, timeout, fallback, error message)
3. add monitoring/logging for future investigation

But remember: most "no root cause" claims are really incomplete investigation.

## Supporting Techniques

These techniques are part of systematic debugging and available in this directory:

- **`root-cause-tracing.md`** — Trace bugs backward through the call stack to find the original trigger
- **`defense-in-depth.md`** — Add validation at multiple layers after finding root cause
- **`condition-based-waiting.md`** — Replace arbitrary timeouts with condition polling

Use `workflow_reference` for: `debug-rationalizations`, `debug-tracing`, `debug-defense-in-depth`, `debug-condition-waiting`
