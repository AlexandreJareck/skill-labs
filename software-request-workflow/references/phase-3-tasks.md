# Phase 3 — Technical tasks

## Contract for each task

Every task includes:

- an identifier and outcome-oriented title;
- type and origin (`requirement`, `evidence`, `root_cause`, or `architecture_decision`);
- objective and required context;
- scope and out of scope;
- areas likely affected, without inventing files before discovery;
- unambiguous instructions;
- dependencies and blockers;
- acceptance criteria;
- test and validation strategy;
- Definition of Done;
- expected evidence.

## Execution graph

Reject cycles. Distinguish sequencing from parallelism. Avoid tasks that are too large and fragmentation without benefit. Cover every requirement, cause/bottleneck, and decision. Each task must be independently verifiable when possible.

## Bug and correction

Consider separate tasks for automated reproduction, a failing test, correction, affected data, regression, observability, a representative environment, and cause/prevention documentation. When feasible, demonstrate `failure before → correction → success after`; when infeasible, record the reason and alternative evidence.

## Performance

Include baseline, implementation, representative benchmark, equivalent comparison, functional validation, regression, and documentation. No task may claim an improvement without a comparable metric.

## Definition of Done

The set passes when there is no material ambiguity, criteria are covered, the cause or bottleneck is addressed, the graph is valid, the order is feasible, and validation is objective.
