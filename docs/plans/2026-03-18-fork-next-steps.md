# pi-superpowers-plus Fork — Next Steps

Date: 2026-03-18
Repo: `/home/bryan/workspace/pi-res/pi-superpowers-plus`
Fork: `https://github.com/tickideas/pi-superpowers-plus`

## What was completed in this session

### Workflow skill updates
The following skills were selectively synced/improved while keeping pi-specific behavior:

- `skills/brainstorming/SKILL.md`
- `skills/writing-plans/SKILL.md`
- `skills/subagent-driven-development/SKILL.md`
- `skills/executing-plans/SKILL.md`
- `skills/systematic-debugging/SKILL.md`
- `skills/verification-before-completion/SKILL.md`

### Subagent naming alignment
Workflow docs/prompts were updated to match the actual pi subagent names in use:

- implementation work → `worker`
- spec review → `reviewer`
- code review → `reviewer`

Prompt templates remain the specialization layer.

### Fork metadata cleanup
Updated fork-specific metadata and links:

- `package.json`
- `README.md`
- `CONTRIBUTING.md`
- `ROADMAP.md`
- `.github/ISSUE_TEMPLATE/*`
- `CHANGELOG.md`

### Current pushed commits from this session

- `c76c601` — `docs(brainstorming): sync workflow guidance with upstream`
- `f664e38` — `docs(writing-plans): strengthen planning workflow`
- `55eeffc` — `docs(subagents): refine orchestration workflow`
- `b26a232` — `docs(executing-plans): clarify batch execution flow`
- `0c4d294` — `docs(debugging): strengthen investigation guidance`
- `c6614b2` — `docs(verification): tighten evidence requirements`
- `e1da311` — `docs(package): point metadata to fork`
- `2b09161` — `docs(subagents): align agent names with pi`
- `9995291` — `docs(metadata): point support links to fork`
- `fd34cea` — `docs(changelog): summarize fork workflow updates`

## Current state

- Local repo is clean
- Changes were pushed to `origin/main`
- pi is installed against the local fork path
- pi reload was performed during validation
- quick validation confirmed the workflow now uses:
  - `worker`
  - `reviewer`

## Recommended next steps

### 1. Use the fork normally for a few real sessions
Do this before more refactoring.

Best validation scenarios:
- brainstorm a modest feature
- write an implementation plan
- run one `subagent-driven-development` flow
- run one `requesting-code-review` flow
- hit one debugging situation and one verification checkpoint

What to watch for:
- does brainstorming feel too heavy?
- does planning feel clearer?
- does worker/reviewer naming stay consistent?
- do any old agent names still leak into behavior or prompts?
- do the runtime monitors and updated skill text feel aligned?

### 2. Decide whether to touch `test-driven-development`
This was intentionally deferred.

Reason:
- your fork already has a deliberate three-scenario TDD model
- runtime enforcement and agent behavior are tied to it
- upstream TDD wording is more rigid and ideological

Before changing `skills/test-driven-development/SKILL.md`, decide which policy you want:

#### Option A — keep current fork policy
- new feature → full TDD
- modifying tested code → run existing tests before/after
- trivial change → judgment

#### Option B — move closer to upstream strictness
- stronger test-first language everywhere
- more aggressive anti-rationalization wording

Recommendation: only do this after a few real sessions with the current fork.

### 3. Consider whether agent definition files should be renamed/refactored
Not done yet:
- `agents/implementer.md`
- `agents/code-reviewer.md`
- `agents/spec-reviewer.md`

These were left alone on purpose.

Questions to answer before changing them:
- Are they still intentionally part of the package’s bundled agent system?
- Do you want full fork rebranding/runtime renaming, or only docs/workflow alignment?
- Do tests depend on those file names/agent names?

Recommendation: leave these alone until you intentionally refactor the runtime/agent-discovery layer.

### 4. Review remaining stale references only if you want a deeper cleanup
Still mostly okay to leave alone for now:
- historical docs under `docs/plans/`
- tests that intentionally reference legacy names
- attribution text referencing upstream history

Recommendation: only clean these if you want the repo to read as a polished public fork.

## Suggested test checklist

Use this after future changes:

### Skill/doc validation
- Ask pi which subagent names it will use for implementation/spec review/code review
- Confirm it says `worker` and `reviewer`
- Ask pi to show the exact `subagent(...)` calls it would make

### Workflow validation
- Trigger `/skill:brainstorming`
- Trigger `/skill:writing-plans`
- Trigger `/skill:subagent-driven-development`
- Trigger `/skill:requesting-code-review`

### Expected behavior
- implementation calls use `agent: "worker"`
- review calls use `agent: "reviewer"`
- prompt text specializes the role
- no accidental reversion to `implementer`, `spec-reviewer`, or `code-reviewer` as live agent names

## Suggested priorities if continuing work later

### Low-risk/high-value
1. real-world testing in pi
2. light README polish
3. optional release notes / tagged release

### Medium-risk
4. `test-driven-development` policy pass
5. stronger README explanation of worker/reviewer prompt specialization

### Higher-risk
6. rename/refactor bundled agent definition files
7. update tests/runtime assumptions around legacy agent names

## Notes for future you

If you come back later and want to continue safely, start with:

```bash
cd /home/bryan/workspace/pi-res/pi-superpowers-plus
git status -sb
git log --oneline -12
```

Then in pi:

```text
/reload
```

Then run one quick validation prompt like:

```text
Pretend we are about to execute a plan with subagent-driven-development. Show me the exact subagent calls you would make for implementation, spec compliance review, and code quality review. Do not execute them.
```

Expected result:
- implementation → `worker`
- spec review → `reviewer`
- code review → `reviewer`

## Bottom line recommendation

The fork is in a good state now.

Best next move is not more editing — it is real usage.

Use it for a few real sessions, collect friction points, then decide whether to:
- stop here,
- refine rough edges,
- or do a deliberate TDD policy update.
