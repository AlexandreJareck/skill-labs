# Artifact contract

## Minimum structure

```text
.workflow/
├── project-context.md
└── requests/
    └── <request-id>/
        ├── 01-requirements.md
        ├── investigation.md          # bug/correction, when applicable
        ├── performance.md            # performance
        ├── 02-architecture.md
        ├── 03-tasks.md
        └── 04-delivery.md
```

Copy templates from `assets/templates/`. Separate persistent project context from request context. The former stores only verified global facts; the latter stores only sources, decisions, and results for that request.

## Common frontmatter

Use simple, readable YAML:

```yaml
---
id: "REQ-001"
artifact_type: "requirement"
state: "draft"
parents: ["DEM-001"]
depends_on: []
related: ["SRC-001"]
confidence: "medium"
invalidated_by: []
updated_at: "2026-10-14"
---
```

Required fields:

- `id`: unique within the request, with a semantic prefix;
- `artifact_type`: `source`, `demand`, `evidence`, `hypothesis`, `root_cause`, `requirement`, `architecture_decision`, `task`, `implementation`, `validation`, or `documentation`;
- `state`: a state allowed for the type;
- `parents`: direct hierarchical origin; use `[]` when absent;
- `depends_on`: artifacts that must be ready first;
- `related`: non-blocking references;
- `confidence`: `low`, `medium`, `high`, or `not_applicable`;
- `invalidated_by`: IDs that made this artifact obsolete;
- `updated_at`: local ISO date.

Use empty values, `unknown`, or `not_applicable` explicitly; never fill a gap with invented certainty.

## Identifiers and chain

Recommended prefixes: `SRC`, `DEM`, `EVD`, `HYP`, `RCA`, `REQ`, `ADR`, `TSK`, `IMP`, `VAL`, `DOC`. Preserve navigation in both directions through `parents`, `depends_on`, and `related`:

`source → demand → evidence → hypothesis → root_cause → requirement → architecture_decision → task → implementation → validation → documentation`

Not every route uses every link. Record `not_applicable` in the corresponding section and explain why. A broken reference is a gate error.

## Knowledge record

For questions, assumptions, and decisions, record: question, context, search performed, sources, answer, hypothesis or assumption, supporting and contrary evidence, impact, confirmation owner, state, and confidence. Keep this in files; do not create a knowledge agent until there is cross-repository volume, recurring investigations, or a need for programmatic queries.
