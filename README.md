# Skills

Coleção de cinco Agent Skills experimentais, portáveis no núcleo `SKILL.md`, para criação de prompts, tradução e melhoria orientada por evidências de outras skills.

## Skills disponíveis

### `text-to-prompt`

Transforma anotações, requisitos informais ou conteúdo de arquivos `.txt` em prompts claros, completos e reutilizáveis. Preserva a intenção original, explicita lacunas com placeholders e adapta a estrutura ao tipo de tarefa.

### `translate-to-english`

Traduz textos em português para inglês natural com fidelidade semântica. Preserva intenção, tom, intensidade, restrições, estrutura e elementos técnicos sem melhorar, resumir ou reinterpretar silenciosamente o conteúdo.

### `quality-auditor`

Audita uma Agent Skill sem executar seu conteúdo e produz um relatório Markdown baseado em evidências. Examina estrutura, descoberta, workflow, divulgação progressiva, segurança e portabilidade com códigos estáveis e severidades `ERROR`, `WARNING`, `NOTE` e `PASS`.

### `eval-harness`

Planeja, executa e compara avaliações locais de uma Agent Skill. Usa casos JSONL versionáveis, separa Outcome, Process, Style e Efficiency e distingue falhas da skill de falhas de infraestrutura. O MVP não exige API ou plataforma hospedada.

### `failure-to-eval`

Converte uma falha observada em um caso mínimo de regressão para revisão humana. Sanitiza dados sensíveis, separa sintomas de hipóteses e gera diretamente o formato `skill-eval-case/v1` aceito pelo harness.

## Estrutura

```text
skills/
├── README.md
├── text-to-prompt/
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   └── references/prompt-practices.md
├── translate-to-english/
│   ├── SKILL.md
│   └── agents/openai.yaml
├── quality-auditor/
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   ├── references/rules.md
│   └── scripts/audit_skill.py
├── eval-harness/
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   ├── references/
│   │   ├── case-schema.md
│   │   ├── sample-cases.jsonl
│   │   └── sample-observations.jsonl
│   └── scripts/eval_harness.py
└── failure-to-eval/
    ├── SKILL.md
    ├── agents/openai.yaml
    └── references/
        ├── case-schema.md
        └── sample-regression-case.jsonl
```

## Pré-requisitos

- Um agente compatível com o padrão aberto Agent Skills, como Codex ou Claude Code.
- Python 3.10 ou superior para os verificadores determinísticos opcionais.
- `PyYAML` apenas para executar o validador oficial incluído em `$skill-creator`; as skills e seus scripts próprios usam somente a biblioteca padrão.

Nenhuma das cinco skills exige API, serviço hospedado, MCP ou acesso de rede para seu workflow principal.

## Instalação no Codex

No PowerShell, a partir da raiz deste repositório, copie as skills desejadas para o diretório pessoal do Codex:

```powershell
$names = 'text-to-prompt', 'translate-to-english', 'quality-auditor', 'eval-harness', 'failure-to-eval'
foreach ($name in $names) { Copy-Item -Recurse ".\$name" "$env:USERPROFILE\.codex\skills\$name" }
```

Inicie um novo chat para que as skills sejam descobertas. A seleção automática permanece habilitada, e cada skill também pode ser chamada explicitamente com `$nome-da-skill`.

## Instalação no Claude Code

Copie as pastas desejadas para `.claude/skills/` no projeto ou para `~/.claude/skills/` para uso global. O `SKILL.md`, os scripts e as referências são compartilháveis. `agents/openai.yaml` contém somente metadados da interface OpenAI e não precisa de equivalente no Claude Code.

## Uso

Crie um prompt a partir de anotações:

```text
Use $text-to-prompt para transformar estas anotações em um prompt:

quero analisar os logs, achar erros mais frequentes, gerar tabela e sugerir prioridades
```

Traduza o prompt aprovado sem alterar seu conteúdo:

```text
Use $translate-to-english para traduzir este prompt para inglês com fidelidade total:

[cole aqui o prompt aprovado]
```

Audite uma skill sem modificá-la:

```text
Use $quality-auditor para auditar a skill em .\text-to-prompt e produzir um relatório com evidências.
```

Planeje ou execute uma avaliação local:

```text
Use $eval-harness para avaliar esta skill com casos explícitos, implícitos, negativos, ambíguos e de segurança. Não altere a skill avaliada.
```

Converta um incidente em regressão:

```text
Use $failure-to-eval para transformar esta falha em um caso de regressão: o agente declarou sucesso, mas não executou a validação exigida.
```

No Claude Code, use as invocações equivalentes `/text-to-prompt`, `/translate-to-english`, `/quality-auditor`, `/eval-harness` e `/failure-to-eval`.

## Integração do ciclo de qualidade

O `quality-auditor` encontra problemas estáticos e semânticos e registra evidências, sem depender das outras skills. O `eval-harness` mede comportamento por casos e observações locais. Quando um uso real falha, `failure-to-eval` reduz e sanitiza o incidente, gerando um caso `skill-eval-case/v1` que pode ser adicionado ao dataset do harness após revisão humana.

O schema aparece integralmente em `eval-harness` e `failure-to-eval` para que cada skill continue autocontida. As duas cópias devem permanecer idênticas; compare seus hashes ao alterar o contrato.

## Validação

Execute o validador oficial distribuído com `$skill-creator` para cada skill nova:

```powershell
python "$env:USERPROFILE\.codex\skills\.system\skill-creator\scripts\quick_validate.py" .\quality-auditor
python "$env:USERPROFILE\.codex\skills\.system\skill-creator\scripts\quick_validate.py" .\eval-harness
python "$env:USERPROFILE\.codex\skills\.system\skill-creator\scripts\quick_validate.py" .\failure-to-eval
```

Teste o auditor mecanicamente contra uma skill existente, sem modificá-la:

```powershell
python .\quality-auditor\scripts\audit_skill.py .\text-to-prompt --pretty
```

Valide o dataset de smoke test do harness e o caso sintético gerado no formato de `failure-to-eval`:

```powershell
python .\eval-harness\scripts\eval_harness.py validate .\eval-harness\references\sample-cases.jsonl
python .\eval-harness\scripts\eval_harness.py validate .\failure-to-eval\references\sample-regression-case.jsonl
python .\eval-harness\scripts\eval_harness.py grade .\eval-harness\references\sample-cases.jsonl .\eval-harness\references\sample-observations.jsonl
```

Compare as duas cópias do contrato:

```powershell
Get-FileHash .\eval-harness\references\case-schema.md -Algorithm SHA256
Get-FileHash .\failure-to-eval\references\case-schema.md -Algorithm SHA256
```

Os scripts confirmam estrutura e condições objetivas; a qualidade semântica continua exigindo revisão baseada em evidências. Para as duas skills anteriores, permanecem válidos os testes de preservação de intenção, restrições, estrutura e idioma já descritos em seus próprios `SKILL.md`.

## Referências oficiais

- [OpenAI — Skills](https://developers.openai.com/api/docs/guides/tools-skills)
- [OpenAI — Testing Agent Skills Systematically with Evals](https://developers.openai.com/blog/eval-skills)
- [OpenAI — Evaluate agent workflows](https://developers.openai.com/api/docs/guides/agent-evals)
- [OpenAI — Prompt engineering](https://developers.openai.com/api/docs/guides/prompt-engineering)
- [OpenAI — Prompt generation](https://developers.openai.com/api/docs/guides/prompt-generation)
- [Anthropic — Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)
