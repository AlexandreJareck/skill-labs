# Skills

Coleção de skills experimentais para ampliar fluxos de trabalho no Codex e em agentes compatíveis com o formato `SKILL.md`.

## Skills disponíveis

### `text-to-prompt`

Transforma anotações, requisitos informais ou conteúdo de arquivos `.txt` em prompts claros, completos e reutilizáveis. A skill preserva a intenção original, explicita lacunas com placeholders e adapta a estrutura ao tipo de tarefa.

### `translate-to-english`

Traduz textos em português para inglês natural com fidelidade semântica. Preserva intenção, tom, intensidade, restrições, estrutura e elementos técnicos sem melhorar, resumir ou reinterpretar silenciosamente o conteúdo.

## Estrutura

```text
skills/
├── README.md
├── text-to-prompt/
│   ├── SKILL.md
│   ├── agents/
│   │   └── openai.yaml
│   └── references/
│       └── prompt-practices.md
└── translate-to-english/
    ├── SKILL.md
    └── agents/
        └── openai.yaml
```

## Instalação no Codex

Copie a pasta da skill para o diretório pessoal de skills:

```powershell
Copy-Item -Recurse .\text-to-prompt "$env:USERPROFILE\.codex\skills\text-to-prompt"
```

Inicie um novo chat para que a skill seja descoberta. A seleção automática permanece habilitada, e ela também pode ser chamada explicitamente.

Para instalar a segunda skill:

```powershell
Copy-Item -Recurse .\translate-to-english "$env:USERPROFILE\.codex\skills\translate-to-english"
```

No Claude Code, copie as pastas para `.claude/skills/` no projeto ou para `~/.claude/skills/` para uso global. O arquivo `SKILL.md` e os recursos associados são portáveis; `agents/openai.yaml` contém apenas metadados específicos da interface OpenAI.

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

Depois de revisar e aprovar o prompt em português, traduza a versão final sem alterar seu conteúdo:

```text
Use $translate-to-english para traduzir este prompt para inglês com fidelidade total:

[cole aqui o prompt aprovado]
```

No Claude Code, use a invocação equivalente:

```text
/translate-to-english [cole aqui o texto em português]
```

A skill traduz todas as instruções e partes textuais, inclusive títulos e o conteúdo de placeholders. Código, comandos, URLs, caminhos, identificadores e expressões de template permanecem intactos. Se uma ambiguidade em português puder mudar materialmente o significado, a skill pergunta antes de traduzir.

## Validação

Execute o validador distribuído com `skill-creator`:

```powershell
python "$env:USERPROFILE\.codex\skills\.system\skill-creator\scripts\quick_validate.py" .\text-to-prompt
```

Além da validação estrutural, teste a skill com textos curtos, requisitos ambíguos e prompts já existentes para confirmar que ela preserva intenção, restrições e idioma.

Valide também a segunda skill:

```powershell
python "$env:USERPROFILE\.codex\skills\.system\skill-creator\scripts\quick_validate.py" .\translate-to-english
```

## Referências

As decisões da primeira skill foram baseadas na documentação oficial da [OpenAI sobre prompt engineering](https://developers.openai.com/api/docs/guides/prompt-engineering), na orientação de [geração de prompts](https://developers.openai.com/api/docs/guides/prompt-generation), nas recomendações da [OpenAI para skills e AGENTS.md](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra) e nas [boas práticas de prompting da Anthropic](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices).
