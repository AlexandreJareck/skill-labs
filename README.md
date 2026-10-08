# Skills

Coleção de skills experimentais para ampliar fluxos de trabalho no Codex e em agentes compatíveis com o formato `SKILL.md`.

## Skills disponíveis

### `text-to-prompt`

Transforma anotações, requisitos informais ou conteúdo de arquivos `.txt` em prompts claros, completos e reutilizáveis. A skill preserva a intenção original, explicita lacunas com placeholders e adapta a estrutura ao tipo de tarefa.

## Estrutura

```text
skills/
├── README.md
└── text-to-prompt/
    ├── SKILL.md
    ├── agents/
    │   └── openai.yaml
    └── references/
        └── prompt-practices.md
```

## Instalação no Codex

Copie a pasta da skill para o diretório pessoal de skills:

```powershell
Copy-Item -Recurse .\text-to-prompt "$env:USERPROFILE\.codex\skills\text-to-prompt"
```

Inicie um novo chat para que a skill seja descoberta. A seleção automática permanece habilitada, e ela também pode ser chamada explicitamente.

## Uso

Invoque a skill e forneça o texto diretamente:

```text
Use $text-to-prompt para transformar estas anotações em um prompt:

quero analisar os logs, achar erros mais frequentes, gerar tabela e sugerir prioridades
```

Ou indique um arquivo:

```text
Use $text-to-prompt para converter o arquivo requisitos.txt em um prompt pronto para uso.
```

Por padrão, a resposta contém somente o prompt final e não executa a tarefa descrita. Você pode pedir uma explicação das decisões ou solicitar uma variante específica, como um prompt para pesquisa, código, análise ou criação de conteúdo.

## Validação

Execute o validador distribuído com `skill-creator`:

```powershell
python "$env:USERPROFILE\.codex\skills\.system\skill-creator\scripts\quick_validate.py" .\text-to-prompt
```

Além da validação estrutural, teste a skill com textos curtos, requisitos ambíguos e prompts já existentes para confirmar que ela preserva intenção, restrições e idioma.

## Referências

As decisões da primeira skill foram baseadas na documentação oficial da [OpenAI sobre prompt engineering](https://developers.openai.com/api/docs/guides/prompt-engineering), na orientação de [geração de prompts](https://developers.openai.com/api/docs/guides/prompt-generation), nas recomendações da [OpenAI para skills e AGENTS.md](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra) e nas [boas práticas de prompting da Anthropic](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices).
