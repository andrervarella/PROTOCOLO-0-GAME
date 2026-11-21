# PROTOCOLO ZERO — PILOTO JOGÁVEL DA FASE 1 (GODOT 4.3, WEB)
**21/11/2026.** Primeiro código jogável do projeto. Pasta `game/` (projeto Godot separado dos docs).
**Estado:** `PROTÓTIPO` — arte, textos de diálogo e números de balanceamento são provisórios. Nada aqui vira cânone sem aprovação do dono.

## Como jogar
- **Celular (link):** ver `HANDOFF.md` (link da Vercel). Deitar o celular. Botão quadrado no canto superior direito = tela cheia.
- **Toque:** direcional deslizante à esquerda (como aprovado no ARASHI); **PULAR** e **AÇÃO** à direita; **BAIXO + PULAR** = esquiva. Centro da tela livre.
- **Teclado:** setas/WASD, ESPAÇO pula, J ação, K esquiva. Controle: A pula, X ação, B esquiva.

## O que o piloto cobre (cânone usado)
| Trecho | Base no cânone |
|---|---|
| Cartela "2054" + notícia "Silas Venn, executado por traição" | 084, 066/067 |
| Cela com Marek; Silas acha a **ferramenta de manutenção** e sabota a porta | 059, 061, 062 |
| Corredor de manutenção, laboratório do ÉREBO (mini-luta com carcereiro pesado) | 061, doc 19 lote 5 |
| Hangar: ondas de guardas → **cercados** → "Você lembra por que está aqui?" | 087 |
| Flashback **2051**: Silas forte e equipado, revolta pela troca de mineiros por máquinas, explosão provocada | 040, 041, 042, 043, 088 |
| Galeria: Silas aponta para **Baltazar** e **hesita**; captura vivo | 088, 091 |
| Volta a 2054: Marek passa a chave para **NEX** — "Cuide dele. Ele sabe o caminho." — e fica para trás | 034, 060, 089 |
| Fuga pelo pátio com NEX; NEX **hackeia** o portão (comando de NEX) | 063 |

## O que é PROPOSTA (precisa do seu OK)
- Todas as falas fora das frases já aprovadas (falas aprovadas usadas: "Primeiro a saída. Depois as perguntas.", "Você lembra por que está aqui?", "Cuide dele. Ele sabe o caminho.", "Uma ordem não é uma razão.", "Probabilidade de sucesso: baixa...").
- **Semente:** NEX diz "Ordem principal recebida: cuidar de você." — prepara a cena final (109).
- **Semente:** Silas nota que um "terrorista" na mina tem bota e arma novas demais (prepara 043/044).
- NEX desligado é carregado por Marek até o sacrifício; comando de NEX aparece só no fim (hackear portão).
- Inimigos: guarda ÉREBO (visor vermelho), drone, carcereiro pesado, sabotador mascarado, perfuratriz autônoma.
- **Regra de gênero aplicada:** encostar no inimigo não tira vida; só golpes, sempre com aviso visual (visor pisca, chão marca a área, linha de mira).
- Combo de 3 golpes com a ferramenta; em 2051, fuzil (segurar AÇÃO = rajada). Hit-stop e tremor de tela no impacto.

## Testes feitos (honesto)
- Robô de teste (`godot -- --autotest`) percorreu o piloto inteiro, do título ao "FIM DO PILOTO", **sem erros de script**. O robô é invencível e às vezes "ajuda" derrotando um inimigo quando trava: **não mede dificuldade**.
- Build web testado no Chrome em tela de celular deitado (844×390) com toque: carrega, avança diálogos, direcional move o Silas.
- **NÃO testado:** celular real, iPhone/Safari, desempenho em aparelho fraco, equilíbrio de dificuldade, controle físico.

## Trocar arte provisória pela definitiva
Toda arte é desenhada em código (`_draw`). Quando as imagens dos lotes do doc 19 forem aprovadas e virarem sprites no PixelLab, substituir por `Sprite2D`/`AnimatedSprite2D` em `player.gd`, `enemy.gd`, `props.gd` e fundos em `level_view.gd`. Os tamanhos de colisão não mudam.

## Estrutura
`game/scripts/main.gd` (roteiro, fases, câmera, efeitos) · `player.gd` (Silas) · `enemy.gd` · `props.gd` (Marek, NEX, Baltazar, portas, painéis, vapor) · `ui.gd` (HUD, diálogo, cartelas, toque) · `fx.gd` · `level_view.gd`.
**Build web:** `godot --headless --export-release "Web" ../web/index.html` (Godot 4.3, modo sem threads). O build vai no branch `web-build` (sobrescrito a cada versão), não na `dev`.

## Próximos passos sugeridos
1. Você joga no celular e diz o que sentiu (controle, ritmo, dificuldade, falas).
2. Aprovar/ajustar as falas PROPOSTA.
3. Gerar os lotes 1–2 de imagens (doc 19) → sprites do Silas e do NEX.
4. Sons e música (PixelLab/Suno) — o piloto está mudo.
