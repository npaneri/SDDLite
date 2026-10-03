# Getting started

Ten minutes from nothing to a running spec-driven workflow with agent rules.

## 1. Install the Spec Kit CLI

Requires **Python 3.11 or newer**.

```bash
# isolated, recommended
uv tool install specify-cli

# or plain pip
pip install -r requirements.txt
```

Verify:

```bash
specify version
```

## 2. Create a project

```bash
specify init my-project --integration <agent>
cd my-project
```

`<agent>` is whatever your coding agent is called — `opencode`, `claude`,
`copilot`, `cursor-agent`, and so on. This generates `.specify/` plus a
directory of slash commands (`.opencode/commands/`, `.claude/commands/`, …).

> Run `specify init --help` for the full list of integrations. It prints the
> command names each one exposes, which vary slightly by agent.

## 3. Add the rules

```bash
cp /path/to/SDDLite/AGENTS.md my-project/
```

That is the entire integration. `AGENTS.md` is a convention every major coding
agent already reads, so no plugin or hook is required.

## 4. Tell your agent

Agents read `AGENTS.md` automatically, but state the intent in your first
message — it materially changes behaviour:

> Read `AGENTS.md` before doing anything. Follow the step gates.

## 5. Run the workflow

```text
/speckit.constitution    # once — establish project principles
```

Answer the questions about principles. If the agent proposes principles you
disagree with, push back now; everything downstream inherits them.

Then start the first feature:

```text
/speckit.specify A URL shortener with custom codes and visit counts
```

## 6. Check the discipline is holding

```bash
./scripts/check_sdd.sh path/to/my-project
```

Run it in CI if you like — it exits non-zero on failure.

---

## What you'll see

| Stage | Produces | You should be able to answer |
| --- | --- | --- |
| `specify` | `specs/001-<slug>/spec.md` | "What counts as done, precisely?" |
| `clarify` | amendments to `spec.md` | "Could two people read this differently?" |
| `plan` | `plan.md` | "Why this stack and not the obvious alternative?" |
| `tasks` | `tasks.md` | "What is the first slice I can ship?" |
| `analyze` | a report | "Do these three documents actually agree?" |
| `implement` | code + tests | "Does each task trace to a requirement?" |

If you cannot answer the question in that column, that stage has not done its
job yet. Say so rather than moving on.

## Common first-time mistakes

**Moving on because the command returned.** A workflow command finishing is not
the same as the artifact being good. Read the generated file.

**Accepting an ambiguous spec.** If two readings of `spec.md` are possible,
planning will encode the ambiguity into code. Run `clarify` first.

**Treating a requirements checklist as a progress board.** Checking an item means
the *requirement* is well-specified, not that it is built. This confuses
everyone once.

**Letting the agent pick the stack.** Stack choices belong in the plan, argued
for explicitly. Agents will happily pick a reasonable one and you will inherit
it.

## Next

- [workflow.md](workflow.md) — the method, and why each stage exists
- [adapting.md](adapting.md) — tailoring `AGENTS.md` to your project