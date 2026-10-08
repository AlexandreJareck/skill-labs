# Prompt construction practices

Use this reference when reviewing or evolving the skill. It records decisions that do not need to occupy context on every invocation.

## Adopted principles

- Clearly state the task and expected outcome.
- Include only relevant context; longer prompts are not automatically better.
- Preserve requirements, examples, variables, and constraints provided by the user.
- Separate instructions from context and content by using consistent headings or delimiters.
- Define a verifiable output format when there is a concrete need.
- Use a small number of high-quality examples when the task depends on a pattern that is difficult to describe.
- Treat prompting as an iterative process: start with the simplest form that could work and refine it based on real observations or evaluations.
- In skills, keep the description short and discriminating; move conditional details to references to avoid excessive global context.

## Decisions specific to this skill

- The default output contains only the prompt, because the requested artifact should be ready to copy and use directly.
- Non-blocking gaps become visible placeholders rather than invented facts.
- There is no mandatory universal template. The structure adapts to the task's type and complexity.
- A role or persona is optional and should appear only when it influences response quality.
- The skill converts and improves the prompt but does not execute the task contained within it.

## Official sources consulted

- [OpenAI — Prompt engineering](https://developers.openai.com/api/docs/guides/prompt-engineering)
- [OpenAI — Prompt generation](https://developers.openai.com/api/docs/guides/prompt-generation)
- [OpenAI — Rethinking skills and prompts](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra)
- [Anthropic — Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)

Revalidate these sources before making significant changes, as model-specific recommendations may evolve.
