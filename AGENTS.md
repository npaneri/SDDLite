# AGENTS.md

Operating rules for AI coding agents working in a **spec-driven development**
repository managed by [GitHub Spec Kit](https://github.com/github/spec-kit).

> **The specification is the source of truth — not the code, and not the chat
> conversation.** If intent is not written into a feature spec, it does not
> exist for this project.

This file is the single place an agent looks to learn *how* to work here. If you
are an agent: read all of it before touching anything.

---

## 1. Non-negotiable: spec-driven discipline

These rules override the usual agent instinct to just start coding.

1. **Never write product code in response to a feature request.** If asked to
   "build", "add", "implement", or "fix" a *product behaviour*, stop and run
   `/speckit.specify` first.
2. **Check for an active feature before writing code.** If the project has a
   prerequisite script, run it (see §6). If it reports no active feature, you are
   not allowed to write product code — propose `/speckit.specify` instead.
3. **Behaviour changes go spec-first.** If asked to change behaviour while a task
   list exists, update the spec first (via `/speckit.clarify` or an explicit
   amendment), then re-run `/speckit.tasks`. Do not silently diverge.
4. **Never invent requirements.** If something is unspecified, ask or run
   `/speckit.clarify`. An assumption written into code is a defect.
5. **Bug fixes inside an existing feature** may proceed against the existing spec
   — but if the fix reveals the spec was *wrong or incomplete*, stop and amend
   the spec rather than encoding the new behaviour only in code.
6. **Non-product work is exempt.** Editing docs, running tests, linting,
   answering questions, or fixing typos needs no spec.

When a request sits on the boundary, **state in one line which rule applies.**
Do not silently comply and do not silently refuse.

### What is and isn't product code

| Counts as product code | Does not |
| --- | --- |
| Application source in `src/`, `app/`, or a package dir | Test harness / tooling config |
| Features, endpoints, business logic, UI components | Linting, formatting, type-checking |
| Database schema migrations | CI config, `.gitignore`, editor config |
| | README / docs / changelogs |

Tooling and test scaffolding may be set up early — but only *framework*
configuration. Which test framework, and how the code is structured, is a
technical decision that belongs in the plan.

---

## 2. Repository structure

The canonical Spec Kit layout. Adapt names to your ecosystem, but preserve the
**separation between inputs, generated artifacts, and code.**

```text
my-project/
├── AGENTS.md              # this file — agent operating rules
├── docs/
│   └── inputs/            # hand-authored source material (inputs)
├── specs/                 # GENERATED per feature by /speckit.specify
│   └── 001-<feature-slug>/
│       ├── spec.md        # what & why — the source of truth
│       ├── plan.md        # how — technical strategy
│       ├── tasks.md       # ordered, verifiable work items
│       ├── research.md    # unknowns resolved during /speckit.plan
│       └── checklists/    # from /speckit.checklist
├── <your source dirs>/    # created by /speckit.implement
├── <your test dirs>/
├── .specify/              # Spec Kit machinery — never hand-edit
│   ├── scripts/
│   ├── templates/
│   ├── memory/constitution.md
│   └── integration.json
└── <agent command dirs>/  # e.g. .opencode/commands/, .claude/commands/
```

### Ownership

| Path | Owner | Rule |
| --- | --- | --- |
| `docs/inputs/` | **Human / agent** | Raw material that *feeds* a spec. Never edit to paper over a spec mismatch. |
| `specs/*/` | **Spec Kit** | Generated. Read and extend; treat `spec.md` as authoritative. |
| `.specify/` | **Spec Kit** | Never hand-edit. Regenerate, don't patch. |
| agent command dirs | **Spec Kit** | Managed files. See your integration's upgrade path. |
| source / test dirs | **Agent** | Only written during `/speckit.implement`. |

> **Why inputs live outside `specs/`:** `specs/` is regenerated and numbered per
> feature. Inputs are timeless reference material that many features may draw on.
> Keeping them apart stops hand-written prose being clobbered by a re-run of
> `/speckit.specify`.

### Multi-package projects

If the project has more than one deployable unit (e.g. a backend and a frontend),
use one top-level directory per unit with its own manifest:

```text
├── backend/       # pyproject.toml, src/, tests/
└── frontend/      # package.json, src/, tests/
```

Each keeps its own test command. Do not merge them into a single root manifest
just to reduce file count — independent lockfiles catch dependency conflicts
earlier.

---

## 3. Key principles of spec-driven development

1. **Artifacts over conversation.** Intent lives in files that outlive the chat
   session. A decision made in a transcript and never written down is lost.
2. **Spec before code.** Understanding precedes implementation. The expensive
   mistake is building the wrong thing, not building it slowly.
3. **Vertical slices, not horizontal layers.** Each user story must be
   *independently testable and demonstrable*. Ship story 1 alone and you should
   have something usable — never deliver "all the database models" as a milestone.
4. **Definition of done is written before the work.** Acceptance criteria and
   test scenarios are part of the spec, not an afterthought during implementation.
5. **Traceability.** Every requirement maps to a story, a task, and a test. If you
   cannot name the requirement a task serves, the task is speculative — remove it
   or justify it.
6. **The plan resolves strategy, not syntax.** The plan decides libraries,
   boundaries, and data flow. It does not contain implementation code.
7. **Tasks are dependency-ordered and independently verifiable.** Each task is
   completable and checkable on its own.
8. **The constitution outranks convenience.** Project principles constrain every
   artifact. If an artifact conflicts with them, fix the artifact.
9. **Ambiguity is a defect, not a detail.** If two readings of the spec are
   possible, it is not ready for a plan. Use `/speckit.clarify`.

---

## 4. Workflow

### Commands

Spec Kit exposes its workflow as slash commands (the exact prefix depends on your
agent integration — `speckit.<name>`, `/speckit-<name>`, etc.).

```bash
/speckit.constitution   # one-time: project principles
/speckit.specify        # write the feature spec
/speckit.clarify        # resolve underspecified areas in the spec
/speckit.plan           # technical plan and design artifacts
/speckit.tasks          # dependency-ordered task list
/speckit.analyze        # cross-artifact consistency check
/speckit.implement      # execute the tasks
/speckit.converge       # append unbuilt work back into tasks
```

Side commands, usable at any point:

```bash
/speckit.checklist      # generate a requirements checklist
/speckit.taskstoissues  # convert tasks into tracker issues
```

### Canonical order

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

Skip `/speckit.constitution` only if the user declines it. Do not skip the rest.

### Step gates — do not skip steps

SDD fails *quietly* when steps are skipped, not loudly. Each command has a
precondition. **Never run a command whose precondition is unmet.** Name the gate
that failed and the command that should run instead.

| # | Step | Precondition | Verify with |
| --- | --- | --- | --- |
| 1 | `/speckit.constitution` | none — once per project | the constitution file exists |
| 2 | requirements interrogation (optional) | input material exists | read `docs/inputs/` first |
| 3 | `/speckit.specify` | requirements settled, or user declined | see §4.1 |
| 4 | `/speckit.clarify` | `spec.md` exists | the spec file is present |
| 5 | `/speckit.plan` | `spec.md` exists and has no unresolved ambiguity | the spec file is present |
| 6 | `/speckit.tasks` | `plan.md` exists | the plan file is present |
| 7 | `/speckit.analyze` | `tasks.md` exists | the tasks file is present |
| 8 | `/speckit.implement` | `tasks.md` exists **and** analyze reported no blocking issues | tasks file + analyze report |
| 9 | `/speckit.converge` | code exists | tasks marked complete |

Where the project's prerequisite script supports it, prefer it over eyeballing
paths — it is the same script Spec Kit itself uses.

#### The four tempting skips

1. **Code before `/speckit.specify`.** Covered by rule 1. The most common and the
   most damaging.
2. **`/speckit.plan` while the spec still has unresolved ambiguity.** If two
   readings of the spec are possible, go back to `/speckit.clarify`. A plan built
   on an ambiguous spec encodes the ambiguity in code.
3. **`/speckit.implement` straight from `/speckit.tasks`, skipping
   `/speckit.analyze`.** Analyze is what catches spec↔plan↔task contradictions a
   human reader skims past. It is the only automated cross-artifact check.
4. **Coding from the plan without ever generating `tasks.md`.** The task list is
   what makes progress dependency-ordered and per-task verifiable. Code written
   outside it cannot be traced back to a requirement.

#### When the user asks to skip

They have the final say, but the skip must be explicit and recorded:

1. State which steps are being skipped and the concrete risk.
2. Record the decision in the plan under **Assumptions** so it survives the session.
3. Do not silently comply, and do not silently refuse either.

#### Completion is not "the command returned"

A command is done when its own checklist is satisfied. A command that exited 0
with unchecked items is **not** complete, and the next gate stays shut. The
per-command criteria are listed in §7.

### 4.1 Requirements interrogation (optional but recommended)

Greenfield projects fail at the spec stage, not the coding stage — because
requirements that live only in someone's head cannot be written down. Before
`/speckit.specify`, and again after `/speckit.plan`, it is worth running a
structured interrogation to turn a vague intention into an explicit decision set.

If a Socratic-interview skill is available in your environment (e.g. a
`grill-me` / `interrogate` style skill), use it. The rules that matter:

- **Read the source material first.** Never ask a question that reading the files
  would answer.
- **One question per turn.** Never dump a numbered questionnaire and ask the user
  to answer all of it at once. Sequential interrogation is the point.
- **Always attach a recommendation** with reasoning. The user is deciding, not
  filling in a form.
- **Use multiple choice** where options genuinely exist, with your recommendation
  first. Reserve open questions for genuine unknowns — do not manufacture false
  choices.
- **Exhaust one thread before opening another.**
- **Push back.** "It should be fine" is not an answer.
- **Close with a summary** — decisions confirmed, decisions changed, open
  questions, risks needing mitigation.

Cycle through these decision types rather than clumping them: scope,
dependencies, failure modes, rejected alternatives, success criteria,
reversibility, ownership.

**Do not start `/speckit.specify` until this closes.** Carry the resolved
decisions across explicitly rather than letting them evaporate into paraphrase.
Per rule 4, a requirement the user never actually stated must not appear in the
spec as though they had.

#### How this differs from `/speckit.clarify`

They are not substitutes — one runs *before* the artifact exists, the other edits
an artifact that already does.

| | Interrogation | `/speckit.clarify` |
| --- | --- | --- |
| Runs | before specify, before plan | after `spec.md` exists |
| Scope | the whole idea, open-ended | one spec, bounded |
| Output | a decision set in conversation | amendments written into the spec |
| Trigger | explicit request | part of the SDD command chain |

They compose: interrogate first, write the spec from the answers, then let
`/speckit.clarify` catch whatever was missed.

---

## 5. Validation & testing

### The gates

| Gate | Mechanism | Validates |
| --- | --- | --- |
| Requirements quality | `/speckit.checklist` | spec completeness & clarity |
| Cross-artifact consistency | `/speckit.analyze` | spec ↔ plan ↔ task contradictions |
| Spec ↔ built code | `/speckit.converge` | what was built vs what was specified |
| Acceptance criteria | spec → **Success Criteria** | whether the feature actually works |
| Test scenarios | spec → **User Scenarios & Testing** | behavioural coverage before code exists |
| Per-task verification | tasks → `[ID] [P?] [Story]` | each task completable alone |
| Executable tests | the project's test command | behaviour, mechanically |

Two distinctions agents get wrong:

- A **requirements checklist is not a progress tracker.** `[x]` means the
  *requirements-quality* criterion was reviewed and satisfied — **not** that
  implementation is complete.
- **`/speckit.analyze` is advisory but gating.** It must report no blocking
  issues before `/speckit.implement`.

### Choosing a test stack

Record the choice in the plan's **Technical Context**, not in code and not in
advance of the spec. Test tooling is cheap to swap early and expensive to swap
late. The matrix below is a starting point, not a mandate.

| Layer | Typical choice | Notes |
| --- | --- | --- |
| Unit / integration | the ecosystem's default runner | Prefer the runner your build tool already uses |
| HTTP mocking | the client's transport-layer mock | Never call a real third-party API in a test — it is rate-limited and often operates live data |
| Time control | the ecosystem's fake-clock library | **Required** for any time-dependent logic |
| Property-based | a fuzzing/property library | For decision tables and branch-heavy logic |
| UI components | Testing Library (or equivalent) | Query by role/text, never by CSS selector or test id |
| End-to-end | a real-browser driver | Reserve for critical user journeys |
| Contract testing | an OpenAPI/consumer-driven tool | For third-party APIs you don't control |
| Load / performance | a load-testing tool | Before go-live, not before the first feature |

### Two hard rules for writing tests

1. **No wall-clock sleeps.** Use fake timers to simulate a delay. A test that
   sleeps to simulate a long interval is a test that gets skipped in CI.
2. **Respect fake-timer isolation.** In Vitest, `vi.useFakeTimers()` is a *global*
   switch — never combine it with `test.concurrent` in the same suite, or mocked
   time leaks between concurrent tests
   ([vitest#5750](https://github.com/vitest-dev/vitest/issues/5750)).

### Coverage

Enable coverage, but treat `--cov-fail-under` as a ratchet: set it low initially
and **raise it deliberately in the plan**. A threshold set to 100% on day one
gets disabled by day two.

---

## 6. Scripts

Spec Kit's commands shell out to helper scripts (Python or shell, depending on
`init`). They resolve paths relative to the repository root, and commands run
there by default.

| Script | Used by |
| --- | --- |
| `check_prerequisites` | most commands, to locate the active feature |
| `resolve_template` | template lookup |
| `setup_plan` | the plan command |
| `setup_tasks` | the tasks command |

Look them up under `.specify/scripts/` and invoke with the interpreter your
project selected. If your environment has a prerequisite script, **prefer it**
over manual path checks — it is the same script Spec Kit uses internally.

---

## 7. Required agent behaviour

Most agent integrations do not support Spec Kit's `handoffs` frontmatter, so
there are no automatic "next step" buttons between commands. Compensate:

1. **Verify completion before suggesting the next step.** A command is finished
   when its own criteria are met. Locate them per command — Spec Kit commands
   carry either a **Done When** or a **Post-Execution Checks** section, and
   report-style commands (`analyze`, `converge`) instead emit a findings report
   you must actually read.
2. **Do not just report findings — resolve or explicitly defer them** before
   moving on.
3. **End your reply with the exact next command to run**, including arguments
   carried over from the command you just completed. Use this shape:
   `Next: /speckit.plan <summary>`
4. **Do not chain automatically.** Let the user run the next command.
5. **Never suggest `implement` while `analyze` reports blocking issues.**

If your integration *does* support handoffs, the command files declare them; no
extra work needed.

---

## 8. Skills

Before non-trivial work, check which skills are available and **proactively
propose the ones that fit.** Do not ignore a relevant skill, and do not force an
ill-fitting one.

**Useful categories for SDD work:**

| Category | Example uses |
| --- | --- |
| Ideation | exploring requirements before specify |
| Interrogation | stress-testing a spec or plan before committing |
| Architecture | challenging a design before it is locked into a plan |
| Diagrams | architecture and state-machine visuals |
| Research | pulling external docs into the plan's research notes |
| Documents | ingesting specs/PDFs/spreadsheets as input material |

**Rules:**

- Propose, then wait. Do not invoke a heavy skill mid-implementation unprompted.
- A skill may produce *input* to a command (research, diagrams), but it never
  substitutes for the artifact. Diagrams belong in the plan or research notes.
- Never let a skill's output silently become product code without a task.

> **Watch for skill/tool overlap.** Some ecosystems ship generic
> "write a plan" and "execute a plan" skills that duplicate Spec Kit's plan and
> implement commands. Using them produces a plan document *outside* the feature
> directory — a competing source of truth that breaks traceability. In this
> repo, prefer the Spec Kit commands. If you find such a skill installed,
> **document it as off-limits in this file** so future agents don't reach for it.

---

## 9. Adapting this file

This is a template. On adopting it for a real project, fill in:

- [ ] **Project type** — one line on what the project is
- [ ] **Repository structure** — replace `<your source dirs>` with real names
- [ ] **Test commands** — add the concrete `cd <pkg> && <runner>` invocations
- [ ] **Prerequisite script path** — so agents stop guessing
- [ ] **Skills that must not be used** — any that collide with Spec Kit
- [ ] **Domain constraints** — e.g. "never call the live payments API in tests"

Keep it short. A 500-line `AGENTS.md` that nobody reads enforces nothing.

---

## 10. Versioning

These command names, gates, and section markers track **Spec Kit**. When you
upgrade Spec Kit, re-check §4 and §7 against the installed command files, and
update this file if the contract changed.

```bash
specify integration status      # what is installed
specify integration upgrade <key>  # regenerate managed files
```