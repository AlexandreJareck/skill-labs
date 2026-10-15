# Delivery profiles and conditional capabilities

## Invariant core

Every delivery goes through: request understanding, planning, implementation, technical review, correction when necessary, testing, correction and retesting until no applicable failure remains, final review, commit, pull request creation, and human code review. The four macro phases and their gates remain in place; simple requests may use brief records but never skip quality controls.

Human code review occurs in the PR. Human approval is a condition for completion and merge. Actionable comments return the work to the earliest affected microphase, followed by proportional testing and review. The agent does not approve its own PR on behalf of a person.

## Profiles

- `simple`: localized change with known behavior and risk and few dependencies. Use the invariant core, focused tests, and proportional regression coverage.
- `standard`: multiple components or a public contract. Add integration testing, applicable end-to-end testing, a QA plan, and a rollout/rollback check.
- `complex`: multiple systems, migration, background processing, concurrency, high load, or relevant operational impact. Add resilience analysis, observability, recovery, data, and operational readiness.
- `critical`: high-value transactions, elevated security or safety needs, highly sensitive data, or major regulatory/operational impact. Add threat modeling, high-rigor security verification, specialist review, recovery testing, and required human approvals.

The initial profile is a hypothesis. Raise it when risks emerge; lowering it requires a recorded justification. Urgency does not lower the profile or remove gates.

## Signals that activate capabilities

| Signal | Additional capabilities |
|---|---|
| scheduled job or asynchronous consumer | idempotency, bounded retry, replay/manual trigger, concurrency, observability |
| long-running process | execution ID, queryable state, trustworthy progress, heartbeat, cancellation, and resumption |
| database or data transformation | migration, compatibility, lock/timeout, rollback or irreversibility, reconciliation |
| external integration | timeout, safe retry, circuit breaker when useful, contract, fallback, and correlation |
| visible change | real browser, screenshots, error/empty/loading states, accessibility, and responsiveness |
| sensitive data, authentication, authorization, or money | elevated security profile, threat/abuse analysis, negative testing, and specialist review |
| high rollout risk | feature flag when useful, progressive delivery, rollback, and post-deployment verification |

Do not apply patterns as a blind checklist. Record `applicable`, `not_applicable` with justification, or `blocked` with the required action.
