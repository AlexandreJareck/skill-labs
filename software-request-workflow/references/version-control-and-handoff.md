# Version control, PR, and handoff

## Work item and branch

Every delivery intended for a PR requires a work item. Record provider, ID, title, and URL from phase 1 and carry them through the branch, commits, and PR. Never invent an ID; if it is missing, block branch, commit, and PR preparation and request it.

Use the project convention; when none exists, use:

`<type>/<source><id>-<slug>`

- `type`: `feat`, `fix`, `perf`, `refactor`, `docs`, `test`, or `chore`, consistent with the primary change;
- `source`: `az` for Azure Boards or `gt` for GitHub;
- `id`: only the work-item identifier;
- `slug`: English, lowercase, ASCII, and hyphen-separated.

Example: `feat/az12234-add-card-in-product`.

## Commit

Before each commit, review the diff, remove local artifacts, run the required tests, and perform a secret scan. Use Conventional Commits, a scope when useful, and a message that describes the outcome. Reference the work item in the footer or provider-required format. Never include a secret or sensitive data in the message.

Do not create a commit, push, or PR without authorization for that action. Do not rewrite remote history without explicit authorization.

## Pull request

Use [the PR template](../assets/templates/pull-request.md). The description must support review, QA, and future release notes without reconstructing context. Include the objective, work item, changes, decisions, acceptance criteria, tests and evidence, QA instructions, screenshots, database scripts, security, operations, rollout/rollback, residual risk, and release note.

Create the PR only after local gates pass, preferably ready for review according to project policy. The PR enters `in_review`; a person performs code review and approves it. Comments return to the correction, testing, final review, commit/push, and human-review loop. Do not merge automatically without explicit authorization and a compatible policy.

## QA and release handoff

The release note must be brief, focused on user/operational impact, and identify incompatibilities or migrations. The QA plan must list preconditions, environment, safe data, steps, expected result, negative variations, and evidence. For an external work item, prepare or publish the update only when authorized.
