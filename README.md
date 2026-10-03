# SDDLite

**Opinionated agent rules for Spec-Driven Development, as a drop-in file.**

An AI coding agent will happily write you code that does the wrong thing, fast,
confidently, and without asking. Spec-driven development (SDD) fixes that by
making the specification the thing you actually build — and an agent is much
easier to keep honest when the rules are written down.

`SDDLite` is a single `AGENTS.md` plus a validator. Point your agent at it and it
will refuse to write code before a spec exists, refuse to plan an ambiguous spec,
and refuse to implement before the artifacts agree with each other.

Built on [GitHub Spec Kit](https://github.com/github/spec-kit). Works with any
agent integration that reads `AGENTS.md`.

---

## Why

Most teams adopting SDD hit the same three walls:

1. **The agent skips steps.** It reads a vague request, decides it understands,
   and writes 800 lines of code against a requirement nobody agreed to.
2. **Nobody notices the spec and the code disagree.** Three weeks later, nobody
   knows which one is right.
3. **The plan lives in a chat transcript.** The reasoning that shaped the
   architecture evaporates when the session ends.

This file attacks all three directly. The rules are short, numbered, and
checkable — deliberately. A 500-line `AGENTS.md` that nobody reads enforces
nothing.

---

## Install

### 1. Bootstrap Spec Kit

```bash
pip install -r requirements.txt      # or: uv tool install specify-cli
specify init my-project --integration <your-agent>
cd my-project
```

### 2. Drop in the rules

```bash
cp path/to/SDDLite/AGENTS.md my-project/
```

That is the whole integration. `AGENTS.md` is a convention every major coding
agent already reads.

### 3. Tell your agent to use it

Agents read `AGENTS.md` automatically, but be explicit in your first message:

> Read `AGENTS.md` before doing anything. Follow the step gates.

### 4. Start the workflow

```text
/speckit.constitution   # project principles, once
/speckit.specify <feature description>
```

---

## What the rules actually do

### The core rule

> **The specification is the source of truth — not the code, and not the chat
> conversation.**

Everything else follows from taking that literally.

### Step gates

Every command has a precondition, and an agent is told to name the failed gate
rather than run the command anyway:

```text
constitution (once)
  -> specify
     -> clarify      (optional, repeat until spec is unambiguous)
     -> plan
        -> tasks
           -> analyze   (fix anything it reports, then re-run)
           -> implement
              -> converge
```

The file names the four skips that actually happen — code before specify,
planning an ambiguous spec, implementing without running analyze, and coding
straight from a plan with no task list — because a rule that doesn't name the
real failure modes doesn't prevent them.

### Validation gates

It distinguishes things agents routinely conflate:

| Artifact | What a checkmark means |
| --- | --- |
| Requirements checklist | the *requirement* is well-specified — **not** that it's built |
| Analyze report | artifacts are mutually consistent |
| Converge report | what got built vs what was specified |

### Validation tooling is framework-agnostic

The rules do **not** mandate a test stack. They require that you *record* the
choice in the plan, and they encode two universal laws:

- **No wall-clock sleeps.** Use fake timers.
- **Fake timers are often a global switch.** Never combine them with concurrent
  tests.

Plus the trap that catches everyone: a third-party API must never be called
from a test, because it is rate-limited and often operates live data.

---

## What's in the box

```text
SDDLite/
├── AGENTS.md                    # the artifact — generic agent rules
├── README.md                    # this file
├── requirements.txt             # Spec Kit CLI + its script dependency
├── pyproject.toml               # tooling config for this repo itself
├── scripts/
│   └── check_sdd.sh             # validator: is this repo following SDD?
├── docs/
│   ├── getting-started.md
│   ├── workflow.md              # the method, explained
│   └── adapting.md              # tailoring the rules to your project
├── examples/
│   └── 001-url-shortener/       # a complete, tiny worked example
└── .github/                     # CI, issue + PR templates, dependabot
```

---

## The validator

Point it at any project to see whether the discipline is holding:

```bash
./scripts/check_sdd.sh path/to/project
```

It checks for the structural signals that correlate with specs and code drifting
apart:

- Spec Kit machinery present and its integration status clean
- An active feature directory exists
- Each feature spec carries the mandatory sections
- Product code exists without any feature spec — **the big red flag**
- A task list exists without a plan
- Commits land on a feature branch rather than straight to main
- Secrets aren't committed

Exit code is non-zero on failure, so it drops straight into CI:

```yaml
- run: ./scripts/check_sdd.sh .
```

> `check_sdd.sh` inspects structure, not semantics. It cannot tell you whether
> your spec is *good*. It can tell you whether you have one.

---

## Worked example

`examples/001-url-shortener/` is a complete, deliberately small feature — spec,
plan, and tasks — so you can see what "done" looks like before adapting it. It is
a URL shortener: enough to be real, small enough to read in five minutes.

Read it to calibrate. If your own specs look nothing like that, the specs are
probably the problem.

---

## Who this is for

- Teams using an AI coding agent who want the agent to follow a process
  instead of improvising
- Solo developers tired of vibe-coding into an unmaintainable repo
- Anyone who wants Spec Kit's structure without hand-writing the rules

**Not for:** projects that will never touch an agent. The overhead is real, and
for a human-only team a lighter checklist beats a mandate.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Short version: open an issue before a
large change, keep the rules short and testable, and never make the file longer
without removing something.

## Using this in your own project

Take the whole file or just the parts that apply — copy it in, then work through
the [adaptation checklist](docs/adapting.md):

1. Replace the `<your source dirs>` placeholders with your real layout
2. Put your concrete test commands in §5
3. Add your domain constraints — the rules only you could have written
4. Cut anything that does not apply; aim for under 200 lines

`AGENTS.md` is MIT-licensed. Copy it, adapt it, delete it, ship it inside a
proprietary codebase — no attribution required. If it helped, a link back is
appreciated.

## License

[MIT](LICENSE) © npaneri