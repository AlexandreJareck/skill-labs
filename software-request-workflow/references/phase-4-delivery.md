# Phase 4 — Implementation, validation, and documentation

## Implementation

Inputs: approved, ready tasks. Execute only items whose dependencies are ready. Inspect the area before editing, preserve existing changes, make small changes, avoid lateral scope, and associate every change with a task, requirement, and applicable diagnosis.

Do not assume authorization to publish, create a PR, push commits, change infrastructure/production/monitors, execute a destructive migration, or expose data.

## Technical review and correction

Review the diff and behavior before broad tests. Correct findings and record every cycle. After testing and acceptance, perform a final review. Mandatory human review occurs in the PR and may reopen this cycle.

## Validation

Run tests and checks that are actually available and record command, environment, result, and limitation. For bugs/corrections, confirm when applicable: prior failure, subsequent absence, regression, adjacent scenarios, representative environment, expected signals, and treatment of the cause. If there is only a mitigation, label it and keep the permanent correction tracked.

For performance, compare equivalent conditions and record baseline, result, absolute and percentage difference, variability, functional impact, resources, cost, and target attainment. An invalid or irreproducible comparison is not success.

Build a matrix `acceptance criterion → test/check → environment → result → evidence`. Use applicable levels from `testing-and-homologation.md`. After every failure, record the observation and classification, correct the earliest affected phase, and repeat the failed test plus proportional regression. Do not finish with unexecuted criteria.

## Acceptance

Acceptance confirms complete behavior in a representative environment with safe data. It may be automated when all criteria are objective; when it involves product judgment, UX, risk, or external authorization, prepare evidence and keep `in_review` until human approval. Do not treat the executor's own approval as independent acceptance when another review is viable.

## Operational readiness and databases

For jobs, long-running processes, integrations, and migrations, apply `operational-readiness.md`. Include database scripts, order, validation, rollback, or irreversibility in the delivery package. Do not execute in production without explicit authorization.

## Security

Record the profile, applicable controls, tests, scans, specialist human review when required, findings, and residual risk according to `security.md`.

## Documentation and handoff

Update only what changed: functional/technical documentation, ADR, changelog, runbook, troubleshooting, error catalog, observability instructions, incident/RCA, limitations, or persistent knowledge. Do not change global architecture documentation without an architecture change.

Bugs, corrections, and performance work end with summary, impact, cause or inconclusive result, contributing factors, evidence, solution/mitigation, validations, residual risk, prevention, and follow-ups. Prepare objective QA instructions and a release note.

## Commit, PR, and human review

After local gates pass, and only with authorization, create the branch, commit, and PR according to `version-control-and-handoff.md`. The PR must link the work item. Keep `in_review` until human code review is approved; comments return to the correction and test loop. Merge is not implicit.

## Definition of Done

Implementation matches tasks; criteria and cause/bottleneck are covered; all applicable criteria are `passed`; reviews, tests, validation, and acceptance have evidence; security and operational readiness were assessed; there are no unexplained changes; documentation and handoff are proportional; limitations and residual risks are explicit; and the PR has approved human code review for `completed` state.
