# Checking obra/superpowers for upstream changes

This fork tracks `obra/superpowers` selectively. Most upstream commits do not
apply (Codex plugin tooling, brainstorm server scripts we don't ship, the
`writing-skills` / `using-superpowers` skills we don't ship, fork metadata,
release notes, etc.).

## One-time setup

If the `obra` remote isn't already configured (e.g. a fresh clone):

```bash
git remote add obra https://github.com/obra/superpowers.git
```

Verify:

```bash
git remote -v | grep obra
# obra	https://github.com/obra/superpowers.git (fetch)
# obra	https://github.com/obra/superpowers.git (push)
```

## Routine check

```bash
git fetch obra --quiet
git log obra/main --oneline --since="<date-of-last-sync>"
```

The current "last sync" anchor is the **upstream commit** `f2cbfbe`
(`obra/superpowers` Release v5.1.0). That was `obra/main` HEAD during the
2026-05 mirror, which brought in the worktree rototill (PRI-974), the SDD
continuous-execution fix, the root-cause-tracing path placeholder, and
removal of deprecated `> Related skills:` callouts / `## Integration`
sections from skills.

After bringing in upstream changes, bump the anchor in two places:

- the comment near the top of this section, and
- `DEFAULT_ANCHOR` in `scripts/check-upstream.sh`.

The anchor must always be an `obra/main` commit, never a fork commit;
otherwise the `ANCHOR..obra/main` range will include all upstream history.

## Filter to relevant commits only

To list only upstream commits that touch files which actually exist in this
fork (skills/, agents/, extensions/), use:

```bash
scripts/check-upstream.sh
```

See `scripts/check-upstream.sh` for the implementation.

## What we generally ignore from upstream

- `.codex-plugin/`, `.claude-plugin/`, `.cursor-plugin/`, `.opencode/`
  — packaging for other agent platforms; this fork targets pi.
- `skills/brainstorming/scripts/` — the brainstorm web server. Our
  `skills/brainstorming/SKILL.md` does not invoke it.
- `skills/writing-skills/`, `skills/using-superpowers/` — not bundled here.
- `RELEASE-NOTES.md`, `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, marketplace
  metadata — platform-specific or upstream-release docs.
- `commands/*.md` — slash command shims for other platforms.
- Discord / Funding / contributor guideline edits — we have our own.

## What we DO want to mirror

- Workflow improvements in:
  - `skills/brainstorming/SKILL.md`
  - `skills/writing-plans/SKILL.md`
  - `skills/executing-plans/SKILL.md`
  - `skills/subagent-driven-development/SKILL.md`
  - `skills/systematic-debugging/SKILL.md`
  - `skills/verification-before-completion/SKILL.md`
  - `skills/test-driven-development/SKILL.md` (carefully — we keep our
    three-scenario policy; see `docs/plans/2026-03-18-fork-next-steps.md`)
  - `skills/requesting-code-review/SKILL.md`
  - `skills/receiving-code-review/SKILL.md`
  - `skills/finishing-a-development-branch/SKILL.md`
  - `skills/dispatching-parallel-agents/SKILL.md`
  - `skills/using-git-worktrees/SKILL.md`
- Prompt template improvements under `skills/*/`-prompt.md.

When mirroring, preserve fork-specific details:

- subagent names: `worker` (implementation), `reviewer` (spec + code review)
- TDD policy: three scenarios (new feature → full TDD; modifying tested
  code → run tests before/after; trivial change → judgment)

## After mirroring

1. `npm test`
2. `pi reload` and run the validation prompt from
   `docs/plans/2026-03-18-fork-next-steps.md` ("Bottom line recommendation"
   section) to confirm `worker` / `reviewer` naming still holds.
3. Add a CHANGELOG entry under `## [Unreleased]`.
4. Update the "last sync" anchor at the top of this file.
