---
name: translate-to-english
description: Translate Portuguese text into natural English with strict semantic fidelity. Use when the user wants a finalized prompt, instructions, or other text translated without changing its intent or content.
---

# Translate to English

Translate the supplied Portuguese content into clear, natural English while preserving exactly what the user intends to communicate.

## Fidelity requirements

- Preserve meaning, scope, tone, emphasis, certainty, uncertainty, negation, priorities, obligations, permissions, prohibitions, and relationships between ideas.
- Translate the content; do not improve its strategy, add requirements, remove repetition, summarize, explain, or silently resolve contradictions.
- Prefer idiomatic English over word-for-word phrasing when both express the same meaning.
- Preserve the original structure, order, headings, lists, tables, numbering, Markdown, and delimiters unless English grammar requires a local adjustment.
- Translate every natural-language instruction, heading, label, example, and explanatory passage, including text inside placeholders. Preserve the placeholder syntax: `[INFORME O PÚBLICO]` becomes `[SPECIFY THE AUDIENCE]`.
- Keep proper names, URLs, file paths, commands, identifiers, variable names, template expressions, and code unchanged. Do not translate literal data or code strings unless the user explicitly requests it.
- Use the established English term for domain-specific concepts. If no unambiguous equivalent exists and the choice matters, ask the user instead of guessing.

## Handling ambiguity

Ask a concise clarification question before translating only when the Portuguese admits materially different meanings that would produce different instructions in English. Identify the exact phrase and the interpretations that need resolution.

Do not ask about stylistic choices that can be resolved without changing meaning. Default to professional, natural English at the same level of formality as the source.

## Final check

Before responding, silently compare source and translation and verify that:

- every instruction and constraint is present;
- nothing new was introduced;
- modality and intensity were preserved;
- protected technical elements remain unchanged;
- all translatable Portuguese text is now in English.

## Response

Return only the English translation, without an introduction, notes, alternatives, or commentary, unless the user explicitly asks for them.
