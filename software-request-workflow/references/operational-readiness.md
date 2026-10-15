# Operational readiness, background processing, and databases

## Background, scheduling, and long-running processes

When applicable, define:

- a stable execution identifier, states, and transitions;
- status queries and progress based on real units; never invent a percentage;
- timestamps, heartbeat, and criteria for a stalled execution;
- checkpointing, resumption, and safe cancellation;
- idempotency by operation and key, with documented repeat behavior;
- retries only for transient failures, with a limit, backoff, jitter, and total budget;
- timeout, concurrency, mutual exclusion, and duplicate-execution prevention;
- an endpoint, command, or administrative operation for an authorized, auditable, protected trigger/replay;
- dead-letter handling, quarantine, or compensation when an operation cannot be safely repeated;
- structured logs, metrics, correlation, actionable alerts, and a runbook;
- timezone, daylight-saving time, execution window, and post-outage behavior for scheduled routines.

A manual mechanism must not bypass authentication, authorization, validation, or the audit trail. For financial or external effects, demonstrate that retry/replay does not duplicate the effect.

## Rollout and recovery

Define only when justified by risk: feature flag, canary, progressive delivery, cross-version compatibility, post-deployment verification, rollback triggers, a tested procedure, and an operational owner. If rollback is unsafe, use roll-forward and record the irreversibility.

## Database scripts and changes

When scripts, migrations, or data transformations exist, include them in the plan, delivery package, and PR. Record:

- order, version, preconditions, permissions, and target environment;
- compatibility with the previous version and the application/code sequence;
- transaction, batching, lock, timeout, load impact, and operational window;
- idempotency or safe rerun behavior;
- backup/restore, rollback, or justification for irreversibility;
- dry run when supported and testing with representative, non-sensitive data;
- count, integrity, and reconciliation checks before and after execution;
- protection and masking of sensitive data;
- the exact verified command, owner, and evidence.

Do not execute a production script without explicit authorization. Do not claim that rollback is viable without testing it in an appropriate environment.
