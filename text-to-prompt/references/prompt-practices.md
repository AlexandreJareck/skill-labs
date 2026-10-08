# Práticas de construção de prompts

Use esta referência ao revisar ou evoluir a skill. Ela registra as decisões que não precisam ocupar o contexto em toda invocação.

## Princípios adotados

- Declare com clareza a tarefa e o resultado esperado.
- Inclua apenas o contexto relevante; prompts maiores não são automaticamente melhores.
- Preserve requisitos, exemplos, variáveis e restrições fornecidos pelo usuário.
- Separe instruções de contexto e conteúdo por meio de títulos ou delimitadores consistentes.
- Defina um formato de saída verificável quando houver necessidade concreta.
- Use poucos exemplos de alta qualidade quando a tarefa depender de um padrão difícil de descrever.
- Trate prompting como um processo iterativo: comece com a forma mais simples que possa funcionar e refine com observações ou avaliações reais.
- Em skills, mantenha a descrição curta e discriminante; mova detalhes condicionais para referências, evitando contexto global excessivo.

## Decisões específicas desta skill

- A saída padrão é somente o prompt, porque o artefato solicitado deve poder ser copiado e usado diretamente.
- Lacunas não bloqueantes viram placeholders visíveis em vez de fatos inventados.
- Não há template universal obrigatório. A estrutura se adapta ao tipo e à complexidade da tarefa.
- O papel/persona é opcional e só deve aparecer quando influenciar a qualidade da resposta.
- A skill converte e melhora o prompt, mas não executa a tarefa contida nele.

## Fontes oficiais consultadas

- [OpenAI — Prompt engineering](https://developers.openai.com/api/docs/guides/prompt-engineering)
- [OpenAI — Prompt generation](https://developers.openai.com/api/docs/guides/prompt-generation)
- [OpenAI — Rethinking skills and prompts](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra)
- [Anthropic — Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)

Revalide estas fontes antes de mudanças importantes, pois recomendações específicas de modelos podem evoluir.
