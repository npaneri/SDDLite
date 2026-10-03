# Tasks: URL Shortener

**Input**: Design documents from [plan.md](./plan.md)
**Prerequisites**: [spec.md](./spec.md), [plan.md](./plan.md)
**Tests**: Included with each task — verify by running the suite

**Format**: `[ID] [P?] [Story] Description`
`[P?]` = parallel-safe. `[Story]` = which user story this serves.

## Phase 0: Foundations

**Purpose**: scaffolding that every later phase depends on.

- **T001** Create the `Link` model (id, code with a unique index, target_url,
  visits default 0, created_at) and its migration
- **T002** Define domain errors `InvalidUrl`, `CodeTaken`, `CodeNotFound` and map
  each to exactly one HTTP status code
- **T003** Read the database URL from the environment; fail fast with a clear
  message when it is absent

**Gate**: migrations apply cleanly; importing the app does not require a live DB.

## Phase 1: Create and resolve (P1) — MVP

**Goal**: a user can shorten a URL and resolve it.
**Independent test**: submit a URL, resolve the returned code, assert the target.

- **T004** [P] Implement `generate_code()` — 6 random bytes base62-encoded, retry
  on collision — FR-001
- **T005** [P] Implement `validate_url()` — allow only `http`/`https`, require a
  host, cap length, raise `InvalidUrl` — FR-004, SC-004
- **T006** Implement `create_link()` returning an existing code when the target
  is already known instead of inserting a duplicate — FR-005
- **T007** Implement `resolve_code()` using an indexed lookup, raising
  `CodeNotFound` — FR-002, FR-003
- **T008** [P] Add `POST /links` and `GET /{code}` routes — FR-001..FR-004
- **T009** Tests — 302 with the correct `Location`; 404 for an unknown code;
  400 for empty input, a malformed URL, an unsupported scheme, and a very long
  URL — FR-001..FR-005, SC-003, SC-004

**Gate**: P1 works end-to-end and every test passes. Shippable on its own.

## Phase 2: Custom codes (P2)

**Goal**: a user can claim a memorable code.
**Independent test**: claim a code, resolve it, assert the redirect.

- **T010** Implement `claim_code()` by inserting and letting the unique
  constraint arbitrate; translate the integrity error to `CodeTaken` — FR-006
- **T011** Test that two concurrent claims of one code yield exactly one success
  and one 409 — FR-008
- **T012** Return 409 from the API for a taken code — SC-003

**Gate**: P2 demonstrable independently.

## Phase 3: Visit counting (P3)

**Goal**: a user can see how often a link was opened.
**Independent test**: resolve a link, assert the counter incremented.

- **T013** Increment the visit counter atomically during resolve — FR-007
- **T014** [P] Tests — count after 1, 3, and 0 resolves; verify the resolving
  request counts itself — FR-007

**Gate**: P3 demonstrable independently.

## Phase 4: Contract & polish

- **T015** Add contract tests asserting coverage of FR-001..FR-008 — SC-002
- **T016** Verify with `EXPLAIN` that resolve uses the `code` index rather than a
  sequential scan — NFR-001
- **T017** Write README run instructions

---

## Dependencies & Execution Order

T001 and T002 → everything. T003 → T001. T004, T005 → T006. T006, T007 → T008.
T001 → T010 → T011. T007 → T013.

## Parallel Example

```text
T001 ──┬──> T004 ──┐
       │            ├──> T006 ──┐
       └──> T005 ──┘            ├──> T008 ──> T009
T002 ────────────────────────────┘
```

## Implementation Strategy

1. **T001–T003** foundation
2. **T004–T009** P1 — **MVP checkpoint**: verify end-to-end before continuing
3. **T010–T012** P2
4. **T013–T014** P3
5. **T015–T017** contract and polish

## Notes

Every task names the requirement it serves. A task whose requirements column is
empty is speculative — delete it or justify it.