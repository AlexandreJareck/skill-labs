# Deterministic orchestration

## States and transitions

Available states: `draft`, `investigating`, `in_review`, `approved`, `in_progress`, `blocked`, `completed`, `invalidated`, `inconclusive`.

Allowed transitions:

| From | Destinations | Minimum condition |
|---|---|---|
| `draft` | `investigating`, `in_review`, `blocked`, `invalidated` | input recorded; investigation only when applicable |
| `investigating` | `in_review`, `blocked`, `inconclusive`, `invalidated` | plan executed or limitation recorded |
| `in_review` | `approved`, `draft`, `investigating`, `blocked`, `invalidated` | evaluation produced feedback or approval |
| `approved` | `in_progress`, `invalidated` | prior gate satisfied and dependencies ready |
| `in_progress` | `completed`, `blocked`, `in_review`, `invalidated` | execution evidence recorded |
| `blocked` | `draft`, `investigating`, `in_progress`, `invalidated` | blocker resolved or input changed |
| `inconclusive` | `investigating`, `in_review`, `invalidated` | new evidence or decision to accept limitation |
| `completed` | `invalidated` | an origin changed materially |
| `invalidated` | `draft`, `investigating` | history preserved and reason recorded |

`source` uses `completed|invalidated`; `evidence` and `hypothesis` allow investigation and conclusion; `root_cause` allows `inconclusive`; requirements and decisions use review/approval; tasks, implementation, validation, and documentation use progress/completion. The reference script checks exact combinations.

## Classification and routes

Record primary type, secondary aspects, confidence, classification evidence, alternatives, and impact. Routes:

- `feature|improvement`: intake, requirements, architecture, tasks, implementation, testing, validation, homologation, documentation.
- `bug|correction`: intake, triage, investigation, root-cause, architecture, tasks, correction, testing, validation, homologation, documentation.
- `performance`: intake, metric-definition, baseline, profiling, bottleneck-or-cause, architecture, tasks, optimization, comparison, functional-testing, homologation, documentation.
- `unknown`: intake; remaining subphases blocked.

The four macro phases do not change; the lists above are subphases activated inside them.

## Gates

The gate runs deterministic checks first and semantic evaluation second:

1. **Phase 1:** sources, classification, contradictions, scope, criteria, assumptions, and questions are explicit. For bugs/corrections: symptom is separate from cause, evidence or limitation exists, hypotheses were evaluated, reproduction was considered, and conclusion and confidence are recorded. For performance: metric, baseline, method, target, and bottleneck or inconclusive result are recorded.
2. **Phase 2:** requirements and diagnosis are covered, along with alternatives, compatibility, departures, impacts, and regression risks.
3. **Phase 3:** tasks have no material ambiguity, coverage is complete, the graph is acyclic, order is feasible, validation is objective, and documentation is included when required.
4. **Phase 4:** implementation matches tasks; technical review, corrections, and final review are recorded; every acceptance criterion links to evidence; applicable tests and regression passed; validation and acceptance are complete; security and operational readiness were assessed; changes are explained; documentation and handoff are proportional; residual risks are explicit. Final `completed` state requires a PR with approved human code review; until then, remain `in_review`.

A deterministic failure prevents semantic evaluation. Feedback must identify the artifact, rule, evidence, and expected correction.

## Attempts, blocking, and human supervision

Use `attempt_limit: 3` by default and allow configuration in the request record. Count an attempt when a version reaches evaluation. At the limit without satisfying the gate, mark `blocked` and record attempts, pending feedback, and the required human decision.

The limit applies to the same failure without a material change in hypothesis or strategy. A transient failure may retry with progressive delay; a product failure returns to implementation; a defective test requires review of test and requirement; flakiness requires investigation; an unavailable environment blocks; an ambiguous result requires human review. Never change a test merely to make it pass without demonstrating that the test contradicts an approved requirement.

Require human supervision for material ambiguity, significant risk, sensitive access, an irreversible external action, a production change, or a hard-to-reverse architecture decision. Artifact approval does not automatically authorize publication or external mutations.

## Dependencies, parallelism, and invalidation

- A task is ready only when every `depends_on` item is `approved` or `completed`, according to type.
- Reject cycles before execution.
- Parallelize only when there is no shared dependency, file, contract, environment, or decision.
- When an artifact changes, traverse dependencies forward. Mark only affected items `invalidated`, fill `invalidated_by`, preserve the prior version, and resume at the earliest affected subphase.
- If new evidence contradicts the cause, invalidate the cause and dependent decisions and return to `investigating`.

## Delivery loop

For every ready task: checkpoint → implement → technical review → correct → run quick checks → run selected tests → correct and retest until passing → evaluate criteria → acceptance → final review → prepare commit and PR when authorized → human code review. If everything passes and human review approves, document and complete. If any step fails or review requests changes, persist the observation, classify the failure, invalidate only what is necessary, and return to the earliest affected step. Record per action: summarized input, tool/command, relevant output, duration, state, and evidence. Resume from the last consistent checkpoint and avoid repeating non-idempotent external effects.
