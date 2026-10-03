# Feature Specification: URL Shortener

**Feature Branch**: `001-url-shortener`
**Created**: 2026-10-03
**Status**: Draft
**Input**: "I want a URL shortener. Long links are ugly and I want short ones I can share."

## User Scenarios & Testing *(mandatory)*

### Priority 1 — Create and resolve a short link

**As a** user who found a long URL
**I want** to paste it and get a short link back
**So that** I can share something that fits in a message.

**Independent test**: Submit a URL, read the short code from the response, `GET`
it, and assert the redirect target matches the submitted URL. This story alone
delivers a usable product.

**Acceptance scenarios**:

1. **Given** a valid `https://example.com/a/very/long/path?q=1&r=2`
   **When** the user submits it
   **Then** a 200 with a short code is returned
   **And** resolving that code returns a 302 to the original URL
2. **Given** the same URL submitted twice
   **When** the user submits it
   **Then** the same short code is returned *(idempotent — no orphan rows)*
3. **Given** an unsupported scheme (`ftp://`, `javascript:`)
   **When** the user submits it
   **Then** a 400 with a human-readable reason
4. **Given** an input that is not a URL at all
   **When** the user submits it
   **Then** a 400, not a 500

---

### Priority 2 — Custom short codes

**As a** user who wants a memorable link
**I want** to choose my own code
**So that** the link is recognisable.

**Independent test**: Request a custom code, resolve it, assert the redirect.
Fails until P1 works, so it is sequenced after.

**Acceptance scenarios**:

1. **Given** an available custom code `my-link`
   **When** the user claims it
   **Then** 201, and the code resolves to its target
2. **Given** a code already in use
   **When** another user claims it
   **Then** 409 — never silently reassigned

---

### Priority 3 — Visit counting

**As a** user sharing links
**I want** to see how many times each link was opened
**So that** I know whether it is worth sharing again.

**Independent test**: Resolve a link, assert the counter incremented by one.
Purely additive — the product still works without it.

**Acceptance scenarios**:

1. **Given** a link with 0 visits
   **When** it is resolved 3 times
   **Then** its visit count is 3
2. **Given** a link is resolved
   **When** the count is read
   **Then** the resolving request itself is included in the total

---

## Requirements *(mandatory)*

**FR-001**: The system MUST accept a full URL and return a short code.
**FR-002**: The system MUST issue a `302 Found` redirect when a valid code is resolved.
**FR-003**: The system MUST return `404` for an unknown code.
**FR-004**: The system MUST reject non-HTTP(S) schemes with `400`.
**FR-005**: The system MUST return the same code for the same target URL.
**FR-006**: The system MUST allow a user to claim a custom code, rejecting
taken codes with `409`.
**FR-007**: The system MUST increment a per-link visit counter on each resolve.
**FR-008**: The system MUST reject duplicate claims atomically, even under
concurrent requests.

### Non-functional

- **NFR-001**: Resolve latency p95 < 50 ms (it is a redirect on the hot path).
- **NFR-002**: No request may reach a third-party network service. Resolution is
  a single indexed lookup.

## Success Criteria *(mandatory)*

- **SC-001**: P1 demonstrable end-to-end via automated test alone.
- **SC-002**: All 8 functional requirements have at least one test.
- **SC-003**: Contract tests cover 400 / 404 / 409 and the 302 success path.
- **SC-004**: Edge cases — empty input, malformed URL, very long URL, unicode
  host — return 4xx and never 5xx.

## Assumptions

- "Short" means ≤ 7 characters, achievable with a base62 alphabet over 6 random
  bytes.
- Codes are case-**sensitive**. (Trade-off: better entropy per character, but
  users who retype a code may mistype case. Accepted for v1.)
- Anonymous usage; no accounts or auth in scope. Revisit if abuse appears.

## Out of scope

- Analytics dashboard, link expiry, QR codes, custom domains, rate limiting.

## Future ideas

- Expiring links; per-link expiry timestamps.
- Bulk import/export.