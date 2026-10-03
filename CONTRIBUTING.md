# Contributing to SDDLite

Thanks for considering it. This file is short on purpose.

## The one rule

**If you make the file longer, make something else shorter.**

`AGENTS.md` only works because agents read it. Every line added is a line that
competes for attention with a rule that already prevents a real failure. A PR
that grows the file from 400 to 500 lines needs a very good reason.

## Before you start

Open an issue for anything beyond a typo fix. It's cheaper to agree on an
approach than to rewrite a rule that three people already depend on.

## What makes a good change

**Good:** replaces a vague instruction with a checkable one.

> Before: "Write good tests."
> After: "No wall-clock sleeps. Use fake timers — a test that sleeps to
> simulate a delay will be skipped in CI."

**Bad:** adds a new section nobody asked for.

**Also bad:** hardcodes a specific stack as if it were universal. This file is
used by projects with different languages, test runners, and directory layouts.
If a rule is genuinely stack-specific, say so and frame it as an example.

## Style

- Imperative voice: "Run analyze", not "you should probably run analyze"
- Number the rules — they're referenced by number elsewhere
- Justify non-obvious rules with *why*, in one line. A rule with no rationale
  gets deleted by the next person who doesn't understand it
- British or American spelling, but pick one per file
- Wrap prose at 80 columns; leave tables and code blocks alone

## Testing changes

The rules are prose, so test them the only way that means anything:

```bash
# does it still lint clean?
shellcheck scripts/check_sdd.sh
bash -n scripts/check_sdd.sh

# does it still catch a broken project?
./scripts/check_sdd.sh examples/          # should pass
./scripts/check_sdd.sh /tmp/not-a-project # should fail gracefully
```

Then, and more importantly: **paste the rule into a real agent session against a
real project and see whether it complies.** A rule that reads well and changes no
behaviour is a rule to cut.

## Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```text
docs: name the implement-before-analyze skip explicitly
fix: validator should not fail when specs/ is empty
feat: add validation tooling matrix to section 5
```

## Reporting a problem

The most useful bug reports include what the agent actually did:

> Rule 1 said not to write code before specify. I asked for a login endpoint,
> the agent wrote `src/auth.py`, and never mentioned a spec.

That's a fixable rule. "The agent ignored AGENTS.md" is not.

## Code of Conduct

Be decent. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).