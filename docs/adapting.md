# Adapting `AGENTS.md`

The shipped file is a template. A generic one has to hedge; yours should not.
This is how to turn it into rules for *your* project.

## The rule about editing it

> **If you make the file longer, make something else shorter.**

An agent reads this once per session, competing with your prompt, tool
descriptions, and the codebase itself. Every line is a tax. A 500-line
`AGENTS.md` that nobody reads enforces nothing.

Aim for **under 200 lines**. If yours is longer, you are explaining rather than
ruling.

## The checklist

### 1. Project type — two lines

```markdown
## Project type

A <what it is> for <who>. <Current stage, e.g. greenfield or in maintenance.>
```

Gives the agent context for every judgment it makes afterward.

### 2. Real directory names

Replace every `<your source dirs>` placeholder. Agents copy your structure
literally; a placeholder is an invitation to invent one.

```text
├── src/shortener/     # Python package
├── tests/
```

### 3. Concrete test commands

This is the highest-value edit on the page. An agent that knows the exact
command does not guess, does not skip tests, and does not install a different
runner.

```markdown
| Executable tests | `cd backend && uv run pytest` | backend behaviour |
| Executable UI tests | `cd frontend && npm test` | component behaviour |
```

If your stack is undecided, say so explicitly and require the plan to decide it —
that is more honest than guessing.

### 4. The prerequisite script

```markdown
Run `python3 .specify/scripts/python/check_prerequisites.py --json --paths-only`
to confirm an active feature exists before writing code.
```

Check the real flags in your own `.specify/scripts/` — they vary by Spec Kit
version, and documenting a flag that does not exist teaches the agent to ignore
you.

### 5. Domain constraints

The section a template cannot write for you. Real examples:

> - Never call the live payments API in a test. It is rate-limited and moves real
>   money.
> - Money is stored in integer minor units. Never floats.
> - All timestamps are UTC and stored with an explicit offset.
> - Migrations must be reversible.

Each of these exists because somebody got it wrong. Write down the ones you have
actually learned the hard way — that is the content only you have.

### 6. Skills that must not be used

Check your agent's installed skills for any that duplicate Spec Kit:

```bash
opencode debug skill
```

Look for generic "write a plan" or "execute a plan" skills. They produce a plan
*outside* the feature directory — a competing source of truth that breaks
traceability. Name them explicitly and forbid them:

```markdown
`writing-plans` and `executing-plans` are off-limits here. They duplicate
`/speckit.plan` and `/speckit.implement`.
```

This section is worth keeping even when empty — it tells the agent the question
was considered.

### 7. Your constitution, in one paragraph

If `.specify/memory/constitution.md` exists, summarise its two or three
load-bearing rules. Agents do not always read it unprompted.

## Keeping it true

`AGENTS.md` drifts as the project changes. Two triggers to revisit it:

- **After your stack changes.** Test commands and paths go stale immediately.
- **When an agent disobeys a rule.** That is a signal about the rule, not the
  agent. Either make it checkable or delete it.

That second point is the useful diagnostic. If an agent keeps writing code before
specifying despite rule 1, the rule is probably buried — move it to the top.

## Anti-patterns

| Don't | Why |
| --- | --- |
| Restate the whole Spec Kit docs | Agents can read the command files. Duplication goes stale. |
| Mandate a specific test framework in the template | Other users have other stacks. Say *record it in the plan*. |
| "Write high-quality code" | Unactionable. High-quality by what measure? |
| Copy every lint rule from your config | Your linter already says them, and enforces them. |
| Include your org's internal process | Won't apply to anyone else, and buries the rules that do. |
| Leave placeholders in a real project | Agents will invent a structure to match. |

## Testing your version

Prose rules are hard to test, but not untestable. Paste them into a real session
and provoke the failure:

> "Add a health check endpoint."

If the agent starts writing code instead of proposing `/speckit.specify`, rule 1
is not doing its job. That is the whole test.