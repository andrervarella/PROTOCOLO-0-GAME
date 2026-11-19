# PROTOCOLO ZERO — GUERRA FRIA TECNOLÓGICA, INTRO E EFEITOS DE COMBATE
**19/11/2026. Documento de direção PZ-DEC-067.** Os temas e metas aqui identificados como **APROVADOS** vieram do dono; textos, cenas e técnicas marcados como **PROPOSTA** precisam de validação. Nada foi gerado ou cobrado.

## 1. Cânone de ambientação aprovado
Ano 2054. Mundo alternativo plausível organizado em **três grandes blocos de governos e interesses corporativos/políticos/industriais**, nomes existentes **HELION, NEXUS e ATLAS**. Rivalidade em moldes de **nova Guerra Fria tecnológica e cibernética**, não assumir uma guerra militar total já ocorrendo. Interesses: controle de eletricidade/energia, mineração/refino e minerais críticos, tecnologia de chips e IA, infraestruturas, ciberataques/hackers, espionagem e propaganda; benefícios e prejuízos distribuem-se desigualmente entre pessoas. Tensões inspiradas por problemas contemporâneos, mas **ficção não é previsão nem relato factual**. LIMIAR recebe acusações públicas pela crise, sem revelar o real grau de autoria logo na introdução. Referência `Mobile Suit Gundam 00`: profundidade de geopolítica, relação entre blocos e dilemas de poder, **não copiar facções, mapas, personagens ou elevadores orbitais**.

**Ainda não aprovados:** fronteiras, países componentes, descrição definitiva do sistema político de cada bloco, setores monopolizados, causa de cada ataque, nomes de líderes, existência de guerra militar declarada e culpa total ou inocência de LIMIAR.

## 2. Proposta de abertura narrada (NÃO APROVADA como roteiro final)
**Hook:** “O mundo não acabou. Ele foi dividido.”

**Texto de teste, português brasileiro:**
> O mundo não acabou. Ele foi dividido.
>
> Quando a energia, os chips e a inteligência artificial se tornaram as armas mais valiosas do planeta, governos e corporações se reorganizaram em três grandes blocos.
>
> HELION. NEXUS. ATLAS.
>
> Começou uma nova Guerra Fria. Sem precisar de uma invasão para destruir uma cidade: bastava desligar sua energia, invadir seus sistemas ou controlar o que ela podia produzir.
>
> Enquanto as máquinas substituíam trabalhadores e a riqueza se concentrava, ataques começaram a atingir o mundo inteiro.
>
> Disseram que havia um culpado: LIMIAR.
>
> Mas a verdade ainda estava longe de aparecer.

**Nota:** editar o texto para cortar qualquer linha que pareça aula ou spoiler; o último verso não deve dar certeza sobre inocência de LIMIAR. Caso se torne longo, reduzir a três mensagens: **“o mundo foi dividido”, “três blocos numa guerra fria tecnológica”, “LIMIAR foi acusada”**. Evitar revelar a responsabilidade humana completa antes da jogabilidade. Logo após, **cortar para fuga jogável em 2054**, depois flashback de missão em 2051 e retorno à fuga (040).

### Storyboard breve proposto
1. Rede elétrica, cidade e porto: progresso/dependência.
2. Mina automatizada; trabalhadores observam robôs assumirem postos.
3. Chips e data center; telas de espionagem/informações cruzadas.
4. Três blocos com identidades visuais próprias; rivalidade e protestos.
5. Apagões, notícia de ataques atribuídos a LIMIAR.
6. Corte para o corredor de ÉREBO, Silas executa plano de fuga; controle do jogador rapidamente.
**Tempo de montagem é hipótese**, aferir ritmo com storyboards estáticos antes de produzir vídeos pagos.

## 3. Como Epic Seven foi construído
**FATO de fontes oficiais:** o desenvolvedor **Super Creative** descreveu Epic Seven como jogo **2D com cel animation**, usando motor proprietário **YUNA Engine** para otimizar compactação e reprodução de desenhos/animações, desenvolvido para dispositivos móveis. **Não afirmar que a aparência anime é obtida por personagens 3D.** Alguns efeitos de profundidade podem ser simulados com camadas, escala, movimento de câmera, cortes e partículas. Esse é um **método de reprodução inspirado no resultado visual**, não afirmação sobre cada efeito individual usado no jogo.

Fontes:
- Smilegate Newsroom (2018), entrevista sobre YUNA: https://newsroom.smilegate.com/eng/Epic_Seven_YUNA_Engine_EN
- Entrevista com diretora Yuna Kim (2019): https://www.mmorpg.com/interviews/the-rpg-files-what-is-epic-seven-2000108180
- Página oficial Steam, descreve cutscenes desenhadas quadro a quadro: https://store.steampowered.com/app/5019180/Epic_Seven/

## 4. Ferramentas e limites confirmados
| Necessidade | Ferramenta/abordagem | Evidência e limite |
|---|---|---|
| Sprites, ataques básicos, pixel art | **PixelLab** | Geração/anim. de sprites e recursos de games; estilo principal é pixel art, checar compatibilidade com anime adulto ilustrado. https://www.pixellab.ai/ |
| Energia, aura, explosão, corte, choque | **PixelLab VFX Creator** | Gera efeito pixel art; exporta **GIF, APNG, spritesheet PNG e ZIP**; permite aplicar efeito a sprite, ajustar velocidade/cor e direção. Contas gratuitas usam artista Lite, planos pagos também podem usar Pro; limites do plano do dono **não verificados**. https://www.pixellab.ai/pixel-art-vfx-generator |
| Montagem no jogo | **Godot** | GPUParticles2D, AnimatedSprite2D/AnimationPlayer, shaders, sprite sheets e camadas; performance precisa ser testada no dispositivo. https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html |
| Falso 3D/3D pontual | **Godot** | Escala/parallax/perspectiva simulada; 3D em cena 2D por **SubViewport** com câmera 3D e composição de textura, se necessário. https://docs.godotengine.org/en/stable/classes/class_subviewport.html |
| Especial cinematográfico | **Animação 2D curta**, Higgsfield sob avaliação | Priorizar animação em sprite/engine quando puder; reservar video pre-renderizado para momento raro; garantir mesma aparência dos sprites e possibilidade de pular. **Nenhum custo/gasto aprovado**. |

**Avaliação:** a assinatura PixelLab do dono é relatada como plano pago ~R$ 100+, mas o sistema não verificou o nome, limites ou saldo. O criador VFX é anunciado para todas as contas com Lite e planos pagos podem usar Pro. **Não afirmar inclusão ilimitada nem custo por geração**, verificar no painel antes de consumir.

## 5. Guia de VFX: tecnologia em vez de magia
- **Golpes normais:** arco da lâmina industrial + rastro luminoso curto, pequenos choques metálicos e faíscas, micro pausa de impacto e movimento de câmera restrito. Referência sensorial a The King of Fighters, sem copiar animações.
- **Habilidades cibernéticas:** pulso elétrico, descarga de campo, escudo de energia, distorção visual/sobreposição HUD, pequenos fragmentos e partículas; cada poder deve ter **função jogável clara**.
- **Especial raro de chefe:** breve pausa/close, duas ou três camadas em profundidade, 2D anime de ação com efeito pontual e retorno rápido ao controle. Testar câmera e legibilidade; **não acionar vídeo em cada ataque normal**.
- **Falso 3D barato:** parallax, escala, rotação controlada de sprite, sombras deslocadas, câmera e distorção shader.
- **3D localizado opcional:** modelar apenas uma peça mecânica ou cenário de corte e renderizar com SubViewport; testar custo de desempenho no celular.
- **PixelLab é pixel art:** se os personagens forem ilustração não pixelada, avaliar adaptar os efeitos ou gerá-los em outra técnica para evitar choque estético.

## 6. Protótipo mínimo recomendado — sem implementação aprovada
1. **Uma sala** do complexo industrial abandonado (064).
2. **Silas com lâmina industrial** (065), dois golpes comuns e um golpe energético simples a demonstrar; NEX com um comando contextual para sistema e um suporte limitado.
3. **Dois efeitos experimentais:** rastro/faísca do PixelLab + partículas/shader no Godot; especial de 2–4 segundos numa montagem 2D estilo anime (não gerar vídeo pago antes de cotação).
4. **Um encontro principal:** versão toda em ação 2D e versão alternativa tática com Silas + 2 aliados provisórios, apenas para comparar clareza e custo. Não fechar nomes de aliados ou sistema até aprovação.
5. Avaliar **legibilidade no celular, comandos, transição do modo, performance, consistência artística, repetição de animações e diversão sem cutscene**.
6. Confirmar **saldo/limite do PixelLab e custo no Higgsfield** antes de qualquer chamada de geração.

## 7. Continuidade
A **35ª pergunta narrativa**, relativa à primeira reviravolta no complexo, está **ABERTA**. Alternativas oferecidas: A operação militar clandestina; B máquinas reconhecem Silas e querem capturá-lo vivo; C ligação da fábrica às máquinas que substituíram mineiros em 2051; D gravação de NEX expõe mentor como cocriador de ÉREBO. **Não inferir escolha de “concordo com tudo” ou das preferências do assistente.** Retomar pergunta brevemente e avançar a trama.
