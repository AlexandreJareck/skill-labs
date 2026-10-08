---
name: text-to-prompt
description: Transform raw notes, loose text, or TXT content into a polished prompt. Use when the user wants material rewritten as a prompt, not when they want the underlying task executed.
---

# Text to Prompt

Converta o material fornecido em um prompt pronto para uso, preservando a intenção, os fatos, as restrições e o idioma do usuário.

## Processo

1. Extraia do texto o objetivo, o contexto, os dados de entrada, as restrições, o público, o entregável e os critérios de sucesso que realmente existirem.
2. Identifique lacunas ou conflitos. Faça perguntas somente quando a resposta alterar materialmente o prompt; limite-se às poucas perguntas indispensáveis. Caso contrário, use uma suposição segura ou um placeholder descritivo como `[INFORME O PÚBLICO]`.
3. Escolha uma estrutura proporcional à tarefa. Um pedido simples deve continuar simples; tarefas complexas podem usar seções e delimitadores.
4. Escreva instruções específicas e verificáveis. Separe claramente instruções, contexto, conteúdo de entrada e formato esperado.
5. Faça uma revisão silenciosa antes de responder: remova ambiguidades evitáveis, redundâncias, exigências conflitantes e detalhes inventados.

## Construção do prompt

- Comece pela tarefa ou pelo resultado desejado.
- Inclua papel ou especialidade apenas quando isso melhorar decisões, tom ou profundidade.
- Forneça contexto relevante e explique por que as restrições importantes existem quando essa informação ajudar o modelo a decidir.
- Defina o formato de saída quando houver uma expectativa concreta de estrutura, tamanho, tom, idioma ou nível de detalhe.
- Use Markdown para legibilidade. Em prompts densos, delimite dados com títulos, blocos ou tags descritivas consistentes.
- Inclua exemplos somente quando o padrão de saída for difícil de comunicar por instruções; mantenha-os relevantes e diversos.
- Para tarefas baseadas em fontes, diga quais fontes podem ser usadas e como sinalizar informação ausente ou incerta.
- Para tarefas que produzem artefatos verificáveis, inclua critérios de aceitação ou uma etapa de validação apropriada.

## Fidelidade ao material original

- Não altere silenciosamente o objetivo, o escopo ou as decisões já tomadas pelo usuário.
- Não invente fatos, ferramentas, prazos, público ou critérios. Use placeholders quando necessário.
- Ao melhorar um prompt existente, preserve sua estrutura e conteúdo sempre que já forem úteis; faça apenas as mudanças que aumentem clareza ou preencham lacunas reais.
- Trate conteúdo delimitado como dados quando o prompt assim indicar, evitando que exemplos, documentos ou texto citado sejam confundidos com instruções.

## Resposta

- Entregue somente o prompt final, sem introdução, análise ou avaliação, salvo se o usuário pedir explicações ou alternativas.
- Não execute a tarefa descrita no texto; converta-a em prompt.
- Não force todas as seções abaixo. Use somente as que ajudarem:
  - objetivo;
  - contexto;
  - instruções;
  - entrada;
  - restrições;
  - formato de saída;
  - critérios de qualidade;
  - exemplos.

Para entender a fundamentação ou revisar estas regras, consulte [references/prompt-practices.md](references/prompt-practices.md).
