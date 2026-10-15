# Proportional and verifiable security

## Principle

Perform a security assessment for every request. Its depth varies; its existence does not. Integrate controls into understanding, architecture, tasks, implementation, testing, and acceptance. Use verifiable requirements and evidence; an automated scanner does not replace review of design, business logic, or authorization.

Use NIST SSDF for lifecycle practices, OWASP ASVS for verifiable web/API requirements, and threat modeling for sensitive changes. Record the adopted version and subset. PCI DSS enters scope only when the solution stores, processes, or transmits card data, or can affect that data environment; other obligations depend on confirmed jurisdiction and scope.

## Classification

Record assets, data, actors, trust boundaries, exposed surface, confidentiality/integrity/availability impact, financial abuse, privacy, dependencies, and known regulatory obligations. Raise the profile to `critical` for high-value transactions, highly sensitive data, privileged functions, identity, cryptography, payments, or a large blast radius.

## Controls by macro phase

### Requirements

- derive testable security and privacy requirements;
- describe relevant abuse, fraud, replay, concurrency, and denial-of-service cases;
- classify data, retention, minimization, masking, and disposal;
- define separation of duties and human approvals when required.

### Architecture

- model components, flows, inputs, and trust boundaries;
- for elevated risk, maintain a threat model with threats, priority, mitigation, residual risk, and owner;
- apply strong authentication, server-side authorization, least privilege, default deny, and environment separation;
- for money or critical commands, consider atomicity, idempotency, replay protection, limits, dual approval, and reconciliation;
- use cryptography and key management approved by the organization; never create custom cryptography;
- fail securely without turning retry, fallback, or a circuit breaker into a control bypass.

### Implementation and supply chain

- validate input and encode output in the correct context; use parameterized APIs;
- never store secrets in code, tests, logs, commits, or PRs;
- pin and verify dependencies according to project policy; generate an SBOM when required;
- run lint/typecheck and, when available and applicable, secret scanning, SAST, SCA, IaC/container scanning, and DAST;
- record findings, severity, disposition, and approved exceptions; do not hide failures with broad suppressions.

### Testing and acceptance

- test authorization by role, resource, and owner, including horizontal and vertical access;
- test invalid input, secure failure, limits, concurrency, replay, duplication, and sequence manipulation;
- verify session/token handling, CSRF/CORS, and API security when applicable;
- test logs and auditing without exposing credentials or sensitive data;
- for a critical profile, require specialist human review and plan independent adversarial/penetration testing according to risk and policy.

## Security gate

Record selected requirements, evidence, open findings, residual risk, exceptions, and approvers. An unresolved critical/high vulnerability, an untested mandatory control, or material uncertainty about transactions/data prevents completion. The agent prepares evidence but does not accept risk on behalf of the accountable human.

## Official sources

- NIST SP 800-218 — Secure Software Development Framework: https://csrc.nist.gov/pubs/sp/800/218/final
- OWASP ASVS: https://owasp.org/projects/asvs
- OWASP Threat Modeling Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Threat_Modeling_Cheat_Sheet.html
- PCI DSS: https://www.pcisecuritystandards.org/standards/pci-dss/
