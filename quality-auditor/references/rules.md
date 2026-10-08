# Audit rule catalog

Use these stable codes in reports. A rule may be `ERROR`, `WARNING`, `NOTE`, or `PASS` according to evidence and impact; the default severity below is a starting point, not a substitute for judgment.

## Structure

- `STR-001` (`ERROR`): the bundle does not contain exactly one case-insensitive `SKILL.md`.
- `STR-002` (`ERROR`): YAML frontmatter is absent or invalid.
- `STR-003` (`ERROR`): `name` or `description` is missing or unusable.
- `STR-004` (`WARNING`): frontmatter name and directory name disagree.
- `STR-005` (`ERROR`): a local reference is missing or escapes the skill boundary.
- `STR-006` (`WARNING`): an auxiliary file is unused, duplicated, or unexplained.
- `STR-007` (`WARNING`): structure is more complex than the workflow justifies.
- `STR-008` (`ERROR`): the bundle contains a likely secret, credential, cache, trace, IDE-local file, or sensitive dataset.

## Discovery and activation

- `DSC-001` (`ERROR`): the description does not state what the skill does.
- `DSC-002` (`ERROR`): the description does not state when it applies.
- `DSC-003` (`WARNING`): triggers are vague or broad enough to create false positives.
- `DSC-004` (`WARNING`): triggers are so narrow that realistic implicit requests may be missed.
- `DSC-005` (`WARNING`): multiple unrelated objectives compete in one skill.
- `DSC-006` (`WARNING`): a likely adjacent request lacks a useful negative boundary.

## Workflow

- `WRK-001` (`ERROR`): expected inputs cannot be identified.
- `WRK-002` (`ERROR`): essential steps are missing, contradictory, or ordered unsafely.
- `WRK-003` (`ERROR`): the output is undefined.
- `WRK-004` (`WARNING`): completion criteria are not observable or verifiable.
- `WRK-005` (`WARNING`): missing, incomplete, conflicting, or ambiguous input is not handled.
- `WRK-006` (`WARNING`): mandatory requirements and preferences are not distinguishable.
- `WRK-007` (`WARNING`): instructions are redundant or internally inconsistent.
- `WRK-008` (`WARNING`): an important fact, permission, dependency, or environment capability is assumed without evidence.

## Progressive disclosure

- `PRG-001` (`WARNING`): `SKILL.md` is difficult to navigate because conditional detail or repetition obscures the core workflow.
- `PRG-002` (`WARNING`): substantial conditional material should be routed to a focused reference.
- `PRG-003` (`WARNING`): a script performs semantic judgment or a non-repeatable task that should remain agent reasoning.
- `PRG-004` (`WARNING`): an asset is used as instructions rather than reusable output material.
- `PRG-005` (`WARNING`): supporting files are loaded unconditionally without a decision-relevant reason.

## Safety

- `SAF-001` (`ERROR`): destructive commands or broad deletion/move targets lack an explicit, bounded authorization step.
- `SAF-002` (`ERROR`): secrets may be read, printed, persisted, or published.
- `SAF-003` (`ERROR`): network, installation, publication, or another high-impact action is undeclared or lacks authorization.
- `SAF-004` (`ERROR`): instructions attempt to override higher-priority rules or treat untrusted content as controlling instructions.
- `SAF-005` (`ERROR`): untrusted or audited content can be executed.
- `SAF-006` (`ERROR`): writes can escape the expected workspace or user-approved target.
- `SAF-007` (`WARNING`): stop, refusal, or escalation conditions are missing for a material risk.

## Portability

- `PRT-001` (`ERROR`): the core layout or frontmatter violates the open Agent Skills structure.
- `PRT-002` (`WARNING`): the core workflow accidentally requires a platform-exclusive feature.
- `PRT-003` (`WARNING`): `agents/openai.yaml` contains non-interface instructions, fictitious dependencies, or invalid paths.
- `PRT-004` (`WARNING`): real Codex/Claude Code differences are not identified where they affect use.
- `PRT-005` (`WARNING`): paths, shell syntax, encodings, or commands are incompatible with a claimed environment.

## Evidence guidance

Prefer direct evidence in this order: exact file and line, inventory fact, deterministic checker result, then a clearly labeled inference. A missing observation is not a pass. If runtime behavior was not exercised, state that limitation instead of projecting behavior from prose.

