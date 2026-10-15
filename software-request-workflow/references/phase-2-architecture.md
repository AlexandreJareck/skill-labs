# Phase 2 — Architecture and solution

## Executor responsibility

Inputs: approved requirements, applicable evidence and diagnosis, persistent context, and project instructions. Output: a traceable architecture decision, alternatives, and validation strategy. Definition of Done: phase 2 gate satisfied.

Classify the context as a new project, existing project, hybrid change, or integration.

## Existing project

Inspect only relevant structure, code, tests, configuration, and decisions. Identify patterns actually in use and distinguish mandatory conventions from historical accidents. Preserve the architecture when it meets the request.

A departure records: current pattern, problem in this case, alternatives, proposal, benefits, costs, risks, operations, compatibility, migration, consequences, and evidence. Agent preference is not justification.

## New project

Begin with the minimum architecture derived from requirements and constraints. Avoid premature abstractions. Record significant decisions in an ADR-like format without imposing a technology.

## Bug and correction

Link the cause to the code path, locate where the behavior arose, choose the smallest safe correction point, search for equivalent occurrences, and assess compatibility, affected data, and regression. Distinguish correction, mitigation, and prevention. Propose an architectural change only when a local correction is insufficient, and explain why.

## Performance

Link the solution to the demonstrated bottleneck. Compare latency, throughput, cost, memory, consistency, and complexity; assess bottleneck displacement, operational impact, rollout, before/after comparison, and rollback.

## Evaluation

Confirm coverage of requirements and diagnosis; alternatives and trade-offs; security, data, observability, operations, testing, and maintenance; evidence linking cause to solution; compatibility and regression risk. Return actionable feedback when a material item is missing.
