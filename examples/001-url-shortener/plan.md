# Implementation Plan: URL Shortener

**Branch**: `001-url-shortener` | **Date**: 2026-10-03 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from the specify command

## Summary

Build a URL shortener as three independently shippable vertical slices: create
and resolve (P1), custom codes (P2), visit counting (P3). Primary technical
approach: an HTTP service over a relational table with a unique index on the
short code, using collision-resistant random codes with retry.

## Technical Context

**Language/Version**: Python 3.11+
**Dependencies**: Web framework, ORM, PostgreSQL driver, test runner
**Storage**: PostgreSQL (durable) — Redis rejected, see Rationale
**Testing**: pytest for integration; faker/temp DB for isolation; fake timers not
required (no time-dependent logic in v1)
**Target Platform**: Linux server, containerised
**Project Type**: single service
**Performance Goals**: p95 resolve < 50 ms (NFR-001)
**Constraints**: NFR-002 — no third-party network calls at runtime
**Scale/Unknowns**: unbounded reads; write volume low

## Constitution Check

| Principle | Complies | Notes |
| --- | --- | --- |
| Spec before code | ✅ | Every FR maps to a task below |
| Vertical slices | ✅ | P1/P2/P3 are each independently shippable |
| No placeholder implementations | ✅ | No TODOs in any task |
| Test-first for logic | ✅ | Every task carries its own test |
| Traceability | ✅ | FR-nnn appears in task text |

GATE: All principles satisfied — proceed.

## Project Structure

```text
src/shortener/
├── api.py            # HTTP layer: routes, status codes, error mapping
├── service.py        # business logic: create, resolve, claim
├── models.py         # persistence schema
├── codes.py          # code generation and validation
└── errors.py         # domain error types
tests/
├── test_codes.py
├── test_service.py
└── test_api.py
```

## Rationale

Rejected alternatives, recorded so the next person does not re-litigate them.

| Choice | Rejected alternative | Why |
| --- | --- | --- |
| PostgreSQL | Redis for the link table | Links are durable and the working set is unbounded. Redis is a cache; making it the source of truth means losing data on eviction. |
| Random 6-byte base62 code | Sequential or hash-of-URL codes | Sequential codes leak volume and are guessable; hashing long URLs exceeds the code length budget and leaks the target. |
| Case-sensitive codes | Case-insensitive | Half the alphabet, so fewer bits per character. Accepted for v1; revisit if users mistype often. |
| Single service | Service split (API + worker) | v1 has no async work — creating a link is a write, resolving is a read. Splitting now is speculative. |

## Complexity Tracking

| Component | Risk | Mitigation |
| --- | --- | --- |
| Code collision | Low | Unique index + retry loop; collision test with seeded RNG |
| Concurrent custom-code claim | Medium | DB unique constraint as arbiter, not a read-then-write check |

---

## Phase 0: Foundations

Traceability: enables FR-001..FR-008.

- **T001** Persistence schema: `Link` (id, code UNIQUE, target_url, visits,
  created_at) + migration.
- **T002** Domain errors (`InvalidUrl`, `CodeTaken`, `CodeNotFound`) mapped to
  HTTP status codes in one place.
- **T003** Config for the database URL, read from the environment.

## Phase 1: Create and resolve (P1) — MVP

Traceability: FR-001, FR-002, FR-003, FR-004, FR-005; SC-001, SC-003, SC-004.

- **T004** `generate_code()` — 6 random bytes, base62-encoded, retry on
  collision. *(FR-001)*
- **T005** `validate_url()` — scheme allow-list, host present, length cap;
  raises `InvalidUrl`. *(FR-004, SC-004)*
- **T006** `create_link()` — returns an existing code for a known target rather
  than inserting a duplicate. *(FR-005)*
- **T007** `resolve_code()` — indexed lookup, raises `CodeNotFound`. *(FR-002, FR-003)*
- **T008** `POST /links` and `GET /{code}` routes. *(FR-001..FR-004)*
- **T009** Tests: 302 success, 404 unknown, 400 for four malformed inputs.

**Gate**: P1 demonstrable end-to-end. This alone is a usable product.

## Phase 2: Custom codes (P2)

Traceability: FR-006, FR-008; SC-003.

- **T010** `claim_code()` — insert relying on the unique constraint; translate
  the integrity error to `CodeTaken`. *(FR-006)*
- **T011** Concurrency test: two simultaneous claims of the same code — exactly
  one wins. *(FR-008)*
- **T012** 409 response. *(SC-003)*

**Gate**: P2 demonstrable independently.

## Phase 3: Visit counting (P3)

Traceability: FR-007.

- **T013** Atomic increment on resolve.
- **T014** Tests: count after 1, 3, and 0 resolves; verify the resolving request
  counts itself. *(FR-007)*

## Phase 4: Contract & polish

Traceability: SC-002, NFR-001.

- **T015** Contract tests asserting one test exists per FR-001..FR-008.
- **T016** Index check on `code`; verify with `EXPLAIN` that resolve uses it
  rather than a sequential scan. *(NFR-001)*
- **T017** README with run instructions.

## Dependencies

T001 → all. T002 → T008. T004,T005 → T006. T006,T007 → T008.
T001 → T010 → T011. T007 → T013.

## Parallel opportunities

T004 and T005 are independent. T010 and T013 are independent of each other.

## Risks

| Risk | Mitigation |
| --- | --- |
| Base62 codes leak character-usage patterns to attackers | Out of scope for v1; note for a future entropy audit |
| Visit counter becomes a write hotspot | Atomic increment now; batch or move to a counter table if measurements justify it |

## Assumptions / Skipped Steps

None — the full workflow ran. Had we skipped clarify, the case-sensitivity
trade-off in the spec's Assumptions would have been decided silently instead of
recorded.