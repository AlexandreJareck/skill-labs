# Testing, acceptance, and delivery loop

## Risk-driven selection

First discover commands, tools, and patterns already verified in the project. Do not install a test framework or invent a command. If a required layer does not exist, record the gap, propose the smallest way to cover it, and request authorization only when installation or a material change is involved.

For **backend**, cover according to risk:

- unit tests for changed rules and branches;
- integration tests for databases, queues, filesystems, caches, and real or representative substitute services;
- contract tests for component interfaces when consumers and providers are independent;
- end-to-end tests for the critical external flow, including error and authorization;
- performance, concurrency, migration, security, or resilience when requirements or risk demand them.

A backend change that affects public behavior normally requires unit, integration, and at least one end-to-end flow. A layer may be `not_applicable` only with verifiable justification.

For **frontend**, cover according to risk:

- unit tests for isolated logic;
- component and interaction tests;
- an end-to-end flow in a real browser when the journey changes;
- screenshots at relevant states and viewports, including error, empty, loading, and success;
- browser console, network failures, accessibility, keyboard, and responsiveness when applicable;
- visual comparison against an approved baseline when supported by the project.

Prefer Playwright when already available or when the user authorizes its adoption. Otherwise, use the available browser capability and record the limitation. Screenshots must have a stable name, related criterion, viewport, environment, and date; never capture personal data, credentials, or unnecessary information.

For **full stack** changes, validate the contract and journey across layers in addition to local tests. For infrastructure, data, CLI, libraries, or mobile, derive an equivalent matrix from observable behavior and risk.

## Acceptance matrix

Each criterion receives an ID and exactly one state: `not_run`, `passed`, `failed`, `blocked`, or `not_applicable`. Record:

| Criterion | Risk | Test/check | Environment | Result | Evidence | State |
|---|---|---|---|---|---|---|

`not_applicable` requires justification. Only `passed` or justified `not_applicable` allows the gate; a request is not deliverable while any item is `not_run`, `failed`, `blocked`, or `inconclusive`.

## Observe → correct → verify loop

1. Checkpoint a consistent state and confirm that the task is ready.
2. Implement the smallest coherent change.
3. Perform technical review of the diff and correct findings.
4. Run quick deterministic checks first: formatting, compilation/typecheck, lint, and existing focused tests.
5. Run selected test layers and capture evidence.
6. Evaluate the acceptance and regression matrix.
7. Classify failures:
   - `transient`: retry with progressive delay up to the limit;
   - `product`: correct implementation or return to plan/architecture;
   - `test_defect`: reconcile the test with the requirement before changing it;
   - `flaky`: investigate and stabilize; do not mask it by repeating until it passes;
   - `environment`: block with diagnosis and required action;
   - `ambiguous`: request a human decision.
8. Rerun the failed test and proportional regression.
9. Accept the complete flow in a representative environment.
10. Perform final review, prepare commit and PR when authorized, and request human code review.
11. If review requests changes, correct and repeat tests and review; complete only after human approval and a passing matrix.

Do not use unlimited retries. Record every attempt, strategy change, and result. External effects must be idempotent or require confirmation before repetition.

## Acceptance and final evidence

The acceptance package contains version/commit when available, environment, criteria, commands, results, summarized logs, screenshots/artifacts, limitations, and required approval. Acceptance in production or with real data requires explicit authorization. An unavailable environment cannot be converted into presumed approval.
