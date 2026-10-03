# The workflow

Why each stage exists, and what "done" means at each one.

```text
constitution (once)
  -> specify
     -> clarify      (optional, repeat until spec is unambiguous)
     -> plan
        -> tasks
           -> analyze   (fix anything it reports, then re-run)
           -> implement
              -> converge   (if implementation left gaps)
```

---

## constitution — once per project

Establishes principles that constrain everything after it: quality bars,
forbidden patterns, required practices.

**Done when** the constitution file is written and you actually agree with it.

This stage is skipped more than any other, and skipping it is expensive. Later
stages inherit whatever is written here. A constitution that says "prefer
simplicity, no premature abstraction, every module tested" quietly shapes every
review for the life of the repo.

---

## specify — what and why

Produces `spec.md`: user scenarios, requirements, success criteria. Deliberately
silent on implementation.

**Done when** every requirement is unambiguous and testable.

The test of a good requirement: *could a developer build the wrong thing and
still claim they met it?* "The API should be fast" fails. "p95 under 50 ms" does
not.

Two sections are mandatory and agents routinely skip them:

- **User scenarios & testing** — who wants this, and how will we know it works.
  Written *before* code so the tests are not reverse-engineered from whatever
  happened to get built.
- **Success criteria** — the measurable bar for calling the feature done.

---

## clarify — remove ambiguity

Asks targeted questions about the spec and writes answers back into it.

**Done when** no two readings of the spec are possible.

Run it as often as needed. The goal is not fewer questions, it is **no remaining
ambiguity**. If you are arguing about what a requirement means, that is a clarify
round, not an implementation detail.

---

## plan — how

Resolves technical strategy: libraries, boundaries, data flow, the build and
test commands. Contains **no implementation code** — it is a strategy, not a
draft.

**Done when** the stack is decided and justified, and the test framework plus
exact test commands are recorded.

Two things agents get wrong here:

- Choosing the stack without asking. They will pick something reasonable and you
  will inherit it.
- Putting code in the plan. A plan containing implementation has skipped
  `tasks`.

The plan also carries a **constitution check**: each principle versus how this
plan satisfies it. That table is how you catch a feature quietly violating your
own rules.

---

## tasks — the ordered, verifiable slice

Breaks the plan into dependency-ordered tasks, each independently completable,
each traceable to a requirement.

**Done when** every task names what it delivers and which requirement it serves,
and the first task produces something demonstrable.

Format is `[ID] [P?] [Story] Description`. `[P?]` marks tasks safe to run
concurrently. A task whose requirement column is empty is speculative — delete it
or justify it.

**Vertical slices, not horizontal layers.** "All the database models" is not a
milestone. "User can shorten a URL and resolve it" is. If story 1 alone does not
demo, the stories are cut wrong.

---

## analyze — the only automated cross-artifact check

Reads spec, plan, and tasks together and reports contradictions: requirements
with no task, tasks with no requirement, plan decisions the spec never mentioned.

**Done when** it reports no blocking issues.

This is the stage people skip because they just read `/speckit.tasks` and moved
on. It is the only thing mechanically checking that three documents agree, and
it catches exactly the contradictions a human reader skims past — having just
written all three.

---

## implement — execute tasks

Executes the task list, writing code and tests.

**Done when** each task is complete and its tests pass.

Only now is product code allowed. A test that fails and a task not marked done
means the task is not done, regardless of how the command exited.

---

## converge — reconcile spec against reality

Compares what was built against what was specified, and appends any unbuilt work
back into the task list.

**Done when** no unbuilt work remains, or the remainder is explicitly deferred
with a reason.

Run it when implementation revealed scope you had to trim, or when you are
unsure what actually shipped. Without it, the spec keeps claiming things the code
does not do — and that drift is what makes the spec stop being trustworthy.

---

## The loop

The workflow is not a line. It is a loop with gates:

```text
specify ⇄ clarify → plan → tasks ⇄ analyze → implement ⇄ converge
   ↑                                                          │
   └──────────────────────────────────────────────────────────┘
```

`converge` feeds back into the spec. That closing of the loop is the whole point:
the spec ends up describing the system as built, which is the only reason it can
be trusted as a source of truth next time.

## Reading the artifacts

A worked example lives in [`../examples/001-url-shortener/`](../examples/001-url-shortener/).
It is deliberately small — a URL shortener — so you can read all three documents
in five minutes and see what "done" looks like.

If your own specs don't resemble that, your specs are the problem.