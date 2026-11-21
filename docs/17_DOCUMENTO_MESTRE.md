# PROTOCOLO ZERO — DOCUMENTO-MESTRE (GDD + BÍBLIA NARRATIVA)
**Versão 1 — 21/11/2026.** Reúne jogabilidade, história amarrada, estrutura, produção, ferramentas e marketing.
**Fonte do cânone:** `DECISOES.md` (001–080) + `docs/16_RODADA_20_PERGUNTAS.md` (081–108) + PZ-DEC-109 (abaixo). Resumo da história: `docs/15_ARCO_COMPLETO_E_REVIRAVOLTAS.md`.
**Legenda:** `[APROVADO]` decisão do dono · `[PROPOSTA]` sugestão do assistente a aprovar · `[PENDENTE]` sem decisão. Nada aqui foi implementado, desenhado ou testado. Nenhum crédito foi gasto.

---

## 0. PZ-DEC-109 — A cena do NEX antes da escolha final `[APROVADO]`
A escolha **"Deixar que ela saiba que você está vivo?"** (108) acontece numa **cena emocionante em que NEX, o robozinho que Silas ganhou do mentor, diz algo tocante** que leva o jogador à escolha e deve emocionar até dar vontade de chorar.
**`[PROPOSTA]` de como amarrar:** durante o jogo inteiro o jogador dá **comandos simples a NEX** e NEX obedece (063). Nesta cena, pela primeira vez, **NEX se recusa a obedecer**. Falas-guia (a lapidar):
> NEX: "O mentor me deu uma única ordem: cuidar de você."
> NEX: "Eu obedeci até aqui. Agora não vou decidir por você."
> NEX: "Você passou a vida cumprindo ordens. Esta é a primeira escolha que é só sua."
Em seguida, NEX toca **a última gravação do mentor** (ou mostra a lembrança que provou quem Silas era, 094) e aparece a pergunta. Isso fecha o tema do jogo: **de obedecer a escolher** (026, 106), e transforma a mecânica de comandos do NEX em parte da história (ver §7).
**`[PENDENTE]`:** falas finais, música, se é cutscene ou cena dentro do jogo (o teto de 10 cutscenes está cheio; sugestão: fazer dentro do jogo, com close nos retratos).

---

## 1. O jogo em uma frase
**Um ex-agente dado como morto foge da prisão onde o transformaram em arma e descobre que a guerra que ele defendia era um negócio — e que a IA culpada por tudo era a única que queria a paz.**

### Pilares (toda decisão de design deve servir a pelo menos um)
1. **Escolher, não obedecer.** Silas começa obedecendo ordens; o jogador termina fazendo a escolha mais difícil sozinho.
2. **Ação 2D com impacto.** Golpes com peso e efeitos estilo luta (KOF), exploração estilo Castlevania/Mega Man.
3. **Dilemas que doem e se entendem em uma frase.** Razão, coração ou lógica (097).
4. **Viradas simples que recontam o que veio antes** (082).
5. **Curto e denso:** 2–3 horas, sem enchimento (057).

## 2. Ficha técnica
| Item | Valor | Estado |
|---|---|---|
| Título | PROTOCOLO ZERO | `[APROVADO]` 081 (checar Steam) |
| Gênero | Ação 2D com exploração (metroidvania compacto) + chefes híbridos | `[APROVADO]` visão; híbrido em protótipo |
| Duração | ~2–3 h (pode crescer um pouco por causa dos 5 chefes) | `[APROVADO]` 057/097 |
| Plataformas | Steam primeiro; Play Store depois | `[APROVADO]` 080 |
| Engine | Godot 4 | `[APROVADO]` como ferramenta de estudo; versão `[PENDENTE]` |
| Preço | US$ 9,99–14,99 | `[PROPOSTA]` |
| Idiomas | PT-BR e EN no lançamento | `[PROPOSTA]` |
| Classificação | Adulto (violência, temas políticos), linguagem simples | `[APROVADO]` tom; selo `[PENDENTE]` |

---

## 3. Loop de jogo
**Explorar → lutar → descobrir → escolher → evoluir.**
- **Explorar:** regiões 2D com caminhos bloqueados que só abrem com habilidades conquistadas.
- **Lutar:** inimigos comuns em ação 2D rápida; chefes com fases cinematográficas.
- **Descobrir:** cada região termina com uma virada curta (uma frase).
- **Escolher:** poupar ou não, salvar quem, perdoar quem. Cada escolha muda **aliados** e **finais**.
- **Evoluir:** cada chefe dá um poder, em forma de **implante** ou **equipamento externo** (061, 013).

## 4. Jogabilidade de Silas
### 4.1 Controles `[PROPOSTA]`
| Ação | Teclado/controle | Observação |
|---|---|---|
| Mover / pular | Direcional / A | Com "coyote time" e pulo curto para responder bem |
| Ataque | X | Combos de 3 golpes |
| Esquiva | B | Breve invencibilidade |
| Poder do chefe | Y | Um por vez, trocável no menu |
| Comando de NEX | RB | 3 comandos simples (§4.3) |
| ÉREBO OVERDRIVE | LB+RB | Barra que enche lutando; dura poucos segundos |
Celular (depois): seguir a regra do dono — botões pequenos, dois por canto inferior, centro limpo.

### 4.2 Progressão `[APROVADO]` base, `[PROPOSTA]` detalhes
| Momento | Ganho | Uso em combate | Uso na exploração |
|---|---|---|---|
| Fuga | Ferramenta de manutenção (062) | Defesa fraca | Abrir painéis, sabotar portas |
| Complexo | Lâmina industrial (065) | Arma principal | Cortar cabos e grades |
| Chefe HÉLIX | **Magnetismo** | Puxar/arremessar inimigos de metal | Grudar em trilhos, mover blocos |
| Chefe KHEIRON | **Condutor** | Atordoar com descarga | Ligar circuitos e elevadores |
| Chefe MAESTRO | **Filamentos** | Prender inimigos | Gancho para lugares altos |
| Chefe SEPHRA | **Duplicata** | Distrair inimigos | Ativar dois interruptores ao mesmo tempo |
| Chefe ROOK | **Cinético** | Golpe que quebra defesa | Quebrar paredes rachadas |
**Regra de design:** cada poder resolve **um tipo claro de obstáculo** e também serve no combate.
**Implante x externo:** o mesmo poder vem em duas versões (ex.: braço cinético implantado x luva cinética externa). O implante é mais forte e muda a aparência de Silas; o externo pode ser trocado e não altera o corpo. A **terceira opção** da regra de 3 itens continua `[PENDENTE]` (013).
**Nunca:** implante = vilão. A humanidade de Silas é tema, não punição (014).

### 4.3 NEX `[APROVADO]` papel (063), `[PROPOSTA]` comandos
Três comandos, um botão: **Hackear** (portas, torretas), **Escanear** (revela segredos e pontos fracos), **Distrair** (puxa a atenção de um inimigo). Recarga curta. NEX nunca resolve sozinho e nunca vira segundo protagonista.
**Amarração:** NEX obedece o jogo inteiro; só se recusa na cena final (109).

### 4.4 Aliados `[APROVADO]` 083/098
- **Garantidos:** NEX e o mineiro (combatente pesado, 076).
- **Possíveis:** ex-colega, prisioneiro, melhor amigo, ROOK.
- Nas lutas de chefe, Silas + **até 2 aliados** (066). Fora dos chefes, aliados aparecem em cenas e em momentos de ação pontuais, sem controle complexo.

## 5. Chefes: o combate híbrido
### 5.1 O que a pesquisa mostra
O jogo mais próximo da nossa ideia é **Indivisible** (Lab Zero): exploração em plataforma estilo Metroid e combate com cada membro do grupo ligado a um botão, misturando turnos e tempo real, além de chefes "híbridos" que alternam combate e plataforma. As críticas mais repetidas: a **transição entre os dois modos irritava** e havia **membros de grupo demais**. Lições para nós: poucos aliados (já aprovado) e transição curta e clara.

### 5.2 Proposta de protótipo `[PROPOSTA]`
Testar com **um chefe (HÉLIX)** duas versões, mantendo a mesma arte:
- **Versão A — ação pura:** chefe em tempo real, aliados como "golpes de apoio" (um botão cada, com recarga).
- **Versão B — híbrida:** luta em ação; quando a barra de **Quebra** do chefe enche, entra uma **fase tática curta** (5–10 s) estilo Epic Seven: escolher 1 especial de Silas ou de um aliado → microcutscene de ~5 s → volta à ação.
**Critério de decisão:** clareza (o jogador entende sem tutorial?), ritmo (a troca de modo cansa?), custo (quantas animações extras?) e "vontade de repetir". Decidir só depois do teste (066).

### 5.3 Tabela dos chefes
| Ordem `[PROPOSTA]` | Chefe | Bloco | Tipo `[APROVADO]` | O dilema em uma frase |
|---|---|---|---|---|
| 1 | **HÉLIX** | HELION | Dilema | "Ele destrói cidades para manter a filha viva." (pai: `[PENDENTE]` confirmar) |
| 2 | **KHEIRON** | HELION | Mau, não poupável | "Nem todo mundo quer ser salvo." Libera a filha de HÉLIX. |
| 3 | **MAESTRO** | NEXUS | Mau, poupável | "Ele perdeu de propósito." 3 sinais obrigatórios. |
| — | *Meio do jogo: reencontro com a médica* | | | |
| 4 | **SEPHRA** | NEXUS | Dilema | "Ela é um monstro, mas é a única que pode salvar o filho do mineiro." |
| 5 | **ROOK** | ATLAS | Dilema | "É o filho do mineiro — lutar contra ele ou confiar que o pai o traz de volta?" |
| Final | **ORÁCULO** | LIMIAR | Final | LIMIAR forçada a obedecer (e, se poupado, MAESTRO ao lado) |
**Por que essa ordem:** HÉLIX antes de KHEIRON faz o jogador sentir o dilema do pai sem saber onde está a filha; vencer KHEIRON paga isso. MAESTRO cedo dá tempo para o jogador esquecer os sinais. SEPHRA antes de ROOK porque só ela pode curá-lo.

## 6. Estrutura do mundo `[PROPOSTA]`
- **Mundo como grafo de regiões** ligadas por portas que exigem habilidades ("chaves"). Cada poder de chefe abre atalhos para regiões antigas (segredos e aliados opcionais), sem obrigar a voltar muito: campanha curta.
- **Hub:** o **refúgio da resistência** (077). Lá o jogador vê quem salvou, conversa com aliados e escolhe a próxima região.
- **Regiões:** Prisão ÉREBO → Mina 2051 (flashback) → Complexo industrial → Centro de transferência + minigame de nave → Refúgio (hub) → HELION (energia) → NEXUS (laboratórios) → ATLAS (minas e logística) → Núcleo do ORÁCULO.
- **Atalhos e viagem rápida** limitados ao hub para não alongar.

## 7. História amarrada: linha do tempo jogável `[APROVADO]` eventos, `[PROPOSTA]` minutagem
| Min. | Capítulo | O que acontece | Escolha | Cutscene |
|---|---|---|---|---|
| 0–2 | Abertura | Notícia "Silas Venn, executado por traição" → Silas vivo fugindo | — | #1 |
| 2–8 | Fuga 2054 | Ferramenta de manutenção; Silas e mentor cercados | — | #2 |
| 8–18 | Mina 2051 | Silas forte e equipado; captura o mineiro e hesita | — | — |
| 18–22 | Volta a 2054 | Mentor passa a chave para NEX e morre | — | #3 |
| 22–35 | Complexo | Lâmina; máquinas querem Silas vivo; mini-chefe ex-colega | Poupar/matar | — |
| 35–45 | Transferência | Infiltração, nave roubada, minigame, "Você hesitou" | — | #4 |
| 45–52 | Refúgio | Defesa; o arquivo do Protocolo Zero; a assinatura da médica | **~30%: nave ou médica** | #5 |
| 52–65 | HELION | Chefe HÉLIX | Poupar/não | — |
| 65–78 | HELION | Chefe KHEIRON (liberta a filha) | — | — |
| 78–90 | NEXUS | Chefe MAESTRO | Poupar/não (armadilha) | — |
| 90–98 | Meio | "Prove que você ainda é você"; o amigo que traiu e tentou salvar | Perdoar/não (depois) | #6 |
| 98–110 | NEXUS | Chefe SEPHRA | Poupar/não | — |
| 110–122 | ATLAS | Chefe ROOK | Trazer de volta/não | — |
| 122–130 | Revelações | Namorado = executivo; LIMIAR queria a paz | Perdoar o amigo | #8, #9 |
| 130–140 | Comandante | "Matar é exatamente o que ele quer" | **Atirar/abaixar** | dentro do jogo |
| 140–150 | Final | ORÁCULO (+ MAESTRO se poupado); cena do NEX; decisão | **LIMIAR + gesto** | #7, #10 |
Total ~150 min. **Mundo explicado em pedaços** (084): uma frase de contexto por região ("Em 2049, os três blocos...").

### 7.1 Sementes e colheitas (o que amarra tudo) `[PROPOSTA]` exceto onde indicado
| Semente (plantar antes) | Colheita (pagar depois) |
|---|---|
| Notícia falsa da morte na abertura | A mesma notícia no final épico; "não acreditei nem na segunda" `[APROVADO]` |
| Silas hesita com o mineiro | "Você hesitou. Eu vi." e a aliança `[APROVADO]` |
| NEX obedece comandos o jogo todo | NEX se recusa a decidir por Silas na cena final (109) |
| A chave do mentor em NEX | Libertar LIMIAR no final `[APROVADO]` |
| Máquinas querem Silas vivo | O comandante precisa dele vivo para o show final (provar que a "arma" existe) |
| Assinatura do executivo nas transferências | O executivo é o namorado `[APROVADO]` |
| Ataques culpados em LIMIAR | Executados por KHEIRON; LIMIAR queria a paz `[APROVADO]` |
| MAESTRO se rende fácil, sorri, pergunta sobre NEX | Volta com a chave ao lado do ORÁCULO `[APROVADO]` |
| Ex-colega poupado | Ele algema o comandante `[APROVADO]` |
| SEPHRA poupada | ROOK pode ser salvo `[APROVADO]` |
| A lembrança que prova quem Silas é (094) | Reaparece na cena do NEX antes da escolha final |
| Uma frase do mentor na fuga ("Uma ordem não é uma razão") | NEX repete na cena final |

## 8. Escolhas e memória do jogo (flags) `[PROPOSTA]`
Modelo **por estados**: uma história principal com variações guardadas em variáveis, que convergem para poucos finais. É o modelo mais barato e coerente para um jogo curto.
| Variável | Quando | Efeito |
|---|---|---|
| `ex_colega_poupado` | Após mini-chefe | +1 aliado; prende o comandante |
| `salvou_nave` | ~30% | +1 aliado (prisioneiro) |
| `helix_poupado` | Chefe 1 | Ajuda na batalha final |
| `maestro_poupado` | Chefe 3 | Volta como inimigo no final |
| `sephra_poupada` | Chefe 4 | Libera a opção de salvar ROOK; mineiro fica furioso |
| `rook_salvo` | Chefe 5 (só se `sephra_poupada`) | +1 aliado |
| `amigo_perdoado` | Perto do final | +1 aliado |
| `atirou_comandante` | Final, etapa 1 | Limita as opções da etapa 2 |
| `decisao_limiar` | Final, etapa 2 | Escolhe o final |
| `gesto_final` | Cena do NEX | Épico com retorno x solitário |
**Aliados suficientes** para o épico: **2 ou mais dos 4 possíveis** `[PROPOSTA]`.
**Regra de clareza:** toda escolha mostra, em uma frase, o custo imediato. Consequências distantes podem ser surpresa, mas sempre com pista antes.

## 9. Finais `[APROVADO]` 107/108
| Final | Caminho | A médica |
|---|---|---|
| **Épico com retorno** | Abaixa a arma → devolve o mundo às pessoas → "Sim" → aliados suficientes | Volta no pós-créditos |
| **Épico solitário** | Mesmo caminho → "Não" | Segue a vida; ele salvou o mundo sozinho |
| **Equilibrado** | Abaixa a arma → LIMIAR aconselha, as pessoas decidem | Vive feliz com ela |
| **Trágico** | Destrói LIMIAR, ou caminho bom sem aliados suficientes | Fica; o mundo continua em guerra |
| **Mau** | Usa LIMIAR para mandar no mundo | Perde a médica |
Cada final: cena curta (30–90 s) + texto de epílogo com o destino dos aliados conforme as flags.

## 10. Personagens
### 10.1 Regras de identidade `[APROVADO]` 085, `[PROPOSTA]` método
Cada personagem precisa passar em 4 testes antes de virar prompt de imagem:
1. **Silhueta:** reconhecível só pela sombra.
2. **Um traço marcante no rosto** (cicatriz, olhos, nariz quebrado, sobrancelha cortada etc.).
3. **Paleta própria** ligada ao bloco ou à função.
4. **Jeito de falar** em uma linha (ex.: frases curtas; pergunta sempre; humor seco).
### 10.2 Elenco
| Personagem | Função | Estado |
|---|---|---|
| Silas Venn | Protagonista | Visual aprovado (cabelo preto curto, barba) |
| NEX | Robô bípede, legado do mentor | Ficha visual `[PENDENTE]` |
| Mentor | Criador de LIMIAR/ÉREBO | Nome e visual `[PENDENTE]` |
| Médica | Ex-companheira, investigadora | Nome e visual `[PENDENTE]` |
| Namorado / executivo NEXUS | Cúmplice por amor | Nome, visual e destino `[PENDENTE]` |
| Melhor amigo | Traiu e tentou salvar | `[PENDENTE]` |
| Comandante | Antagonista humano | `[PENDENTE]` |
| Mineiro (ex-líder) | Aliado garantido, pesado | `[PENDENTE]` |
| Ex-colega | Mini-chefe / aliado | `[PENDENTE]` |
| Prisioneiro | Aliado possível | Quem é: `[PENDENTE]` |
| 5 chefes + ORÁCULO | Ver §5.3 | Visuais `[PENDENTE]` |
| Filha de HÉLIX | Refém | `[PENDENTE]` |

## 11. Direção de arte e cutscenes
- **Estilo recomendado** `[PROPOSTA]`: **pixel art detalhada no jogo** (PixelLab + Godot) e **retratos e cutscenes em anime adulto**. É uma combinação comum e evita prometer anime HD em cada sprite.
- **VFX:** golpes com rastros, faíscas e "hit-stop" (pausa de 2–4 quadros no impacto) estilo jogos de luta.
- **Cutscenes:** 10 no total, 10–20 s cada (086). Lista no doc 16. Microcutscenes de especiais: uma por especial, ~5 s.
- **Consistência de rosto:** gerar primeiro uma **folha de referência** de cada personagem e usar sempre como referência nas gerações seguintes.

## 12. Áudio `[PROPOSTA]`
- **Tema do mentor/NEX** (melodia simples) que aparece na fuga, em mensagens do mentor e na cena final do NEX. Repetir a melodia é o que faz o final emocionar.
- Um tema por bloco (HELION elétrico, NEXUS frio, ATLAS pesado/industrial).
- Vozes: só em cutscenes e falas-chave (custo). Ferramenta a avaliar: ElevenLabs.

## 13. Produção
### 13.1 Etapas `[PROPOSTA]`
1. **Protótipo cinza (sem arte final):** movimento de Silas, lâmina, 1 comando de NEX, 1 sala, mini-chefe, HÉLIX nas versões A e B (§5.2).
2. **Fatia vertical:** prólogo completo (fuga + mina + mentor) com arte final. Vira a **demo**.
3. **Página na Steam** assim que a fatia vertical tiver imagens boas.
4. **Produção:** regiões e chefes em ordem.
5. **Polimento, finais e testes** com jogadores de fora.
### 13.2 Se atrasar, cortar nesta ordem `[PROPOSTA]`
1. Fase tática dos chefes (fica só ação). 2. Vozes. 3. Segredos opcionais. 4. Minigame da nave vira cutscene. **Nunca cortar:** as escolhas, os finais e as cenas do NEX.
### 13.3 Riscos
| Risco | Como reduzir |
|---|---|
| Sistema híbrido confuso | Protótipo A/B antes de produzir |
| Rostos diferentes entre gerações de IA | Folha de referência fixa por personagem |
| Escopo grande para 2–3 h | Lista de cortes (§13.2) |
| Escolhas que parecem inúteis | Mostrar consequências no epílogo e no hub |
| Chefe mau poupado parecer injusto | 3 sinais obrigatórios (099) |

## 14. Marketing Steam `[PROPOSTA]` (com base em dados públicos)
- Abrir a **página "em breve"** cedo e lançar a **demo meses antes** do Steam Next Fest, não no próprio festival.
- Usar o **último Next Fest antes do lançamento**; dados indicam pouco ganho com menos de **~2.000 listas de desejo** antes do festival.
- Clipes curtos para redes: a notícia da morte, "Você hesitou. Eu vi.", o MAESTRO voltando, um especial com microcutscene.
- Qualidade das listas de desejo vale mais que quantidade.

## 15. Ferramentas, skills e conectores
### 15.1 Já conectados nesta conta
GitHub (repositório), PixelLab (sprites, VFX, música e efeitos), Google Drive (acervo), Figma e Canva (telas e página), OpusClip/HyperFrames (clipes de divulgação), Fenaky (imagem/vídeo), Notion.
### 15.2 Sugeridos para conectar
- **Higgsfield:** cutscenes (já iniciado, conexão incompleta).
- **ElevenLabs:** vozes de NEX, narração e personagens (conexão incompleta).
### 15.3 Skills e repositórios públicos úteis (para o Claude Code / Codex no computador do dono)
| Recurso | Para quê |
|---|---|
| `htdt/godogen` | Skills que geram projetos Godot 4 a partir de descrição (bom para o protótipo cinza) |
| `jame581/godotprompter` | Conjunto de skills de Godot 4 (GDScript, cenas, padrões) |
| `wshobson/agents` → `godot-gdscript-patterns` | Padrões de GDScript |
| `Randroids-Dojo/Godot-Claude-Skills` | Skill de Godot com testes (GdUnit4) |
| `Donchitos/Claude-Code-Game-Studios` | Modelo de organização de projeto de jogo com agentes |
| `tomyud1/godot-mcp` (MCP) | Liga o Claude ao editor Godot aberto (precisa rodar no computador do dono) |
**Atenção:** não foram instalados nem testados. Revisar licença e código antes de usar. Instalar sempre numa pasta separada do projeto, como o dono pediu.

## 16. Pendências (próximas perguntas, uma por vez)
1. Nomes e fichas de todos os personagens (começar pela médica).
2. Confirmar HÉLIX como pai da refém.
3. Falas finais da cena do NEX (109).
4. A lembrança que prova quem Silas é.
5. Destino do namorado.
6. Quem é o prisioneiro aliado.
7. Terceira categoria de item.
8. Ordem dos chefes (proposta em §5.3).
9. Resultado do protótipo híbrido.
10. Conflito do nome na Steam.

## 17. Fontes da pesquisa (21/11/2026)
- Indivisible, combate híbrido: https://wccftech.com/indivisible-interview-e3-2018 · https://www.gamespot.com/reviews/indivisible-review-bahala-na/1900-6417329/ · https://twinfinite.net/2019/10/indivisible-review-untapped-potential/ · https://www.commonsensemedia.org/game-reviews/indivisible
- Metroidvania, ritmo e travas: https://itch.io/devlog/87273/the-pacing-of-metroidvania-games.amp · https://seanking11.github.io/gamebootcamp/modules/14-metroidvania · https://www.positioniseverything.net/how-metroidvania-style-progression-works-in-open-world-games/
- Escolhas e finais: https://pvliesdonk.github.io/if-craft-corpus/corpus-docs/narrative-structure/branching_narrative_craft · https://www.pcgamer.com/narrative-choice-is-one-of-the-most-misunderstood-promises-of-the-decade
- Narrativa integrada à jogabilidade: https://www.vgchartz.com/article/444421/defined-design-katana-zeros-surprising-story/
- Marketing Steam: https://howtomarketagame.com/2025/03/26/benchmarks-how-many-wishlists-can-i-get-from-steam-next-fest/ · https://automaton-media.com/en/?p=49243 · https://alineaanalytics.substack.com/p/wishlist-to-buyer-conversions-for
- Skills e MCP de Godot: https://awesome.ecosyste.ms/projects/github.com%2Fhtdt%2Fgodogen · https://awesome.ecosyste.ms/projects/github.com%2Fjame581%2Fgodotprompter · https://github.com/tomyud1/godot-mcp · https://github.com/Randroids-Dojo/Godot-Claude-Skills
