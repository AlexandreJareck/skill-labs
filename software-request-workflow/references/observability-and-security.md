# Observability and evidence security

## Capability discovery

Treat Elastic, Datadog, Application Insights, Splunk, Grafana, Prometheus, Sentry, OpenTelemetry, local logs, traces, metrics, alerts, and deployment history as examples, never dependencies.

1. Discover available connectors and tools.
2. Read the documentation, scope, and permissions of the selected capability.
3. Request access only when indispensable.
4. Begin read-only and collect the minimum required.
5. Record the question, sanitized query/filter, environment, interval with timezone, correlators, result, and coverage.
6. Link evidence to the request and state limitations.

Provider-specific adaptations stay outside the portable core, in references or local project configuration.

## Actions prohibited by default

Without explicit authorization, do not change dashboards, alerts, monitors, retention, or external configuration; silence alerts; delete records; restart services; generate production load; or run a potentially harmful query.

## Data protection

- Use least privilege.
- Never store tokens, keys, passwords, cookies, or authentication headers.
- Minimize and mask personal/sensitive data.
- Prefer references and summaries over copies of confidential logs.
- Respect project retention and access rules.
- Record the limitation when evidence cannot be obtained safely.

Before versioning, review the diff and run the project's approved secret scan. A sensitive value stops commit and push; if already published, report it immediately for revocation and rotation.
