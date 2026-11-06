# Pixel Farm Seasons — direção visual aprovada em 06/11/2026

## Identidade visual

O objetivo é aproximar os gráficos do conceito ilustrado aprovado na conversa de 06/11/2026: **um simulador rural 3D aconchegante, colorido e detalhado**, com identidade própria. Referência de estilo e composição, **não uma captura do jogo atual**. Não substituir o cenário interativo por uma imagem estática.

### Composição central

- **Câmera:** terceira pessoa atrás do fazendeiro, levemente acima dos ombros; jogador visível em primeiro plano.
- **Casa:** dois pavimentos, paredes em tom creme, telhado cerâmico terracota, varanda de madeira, janela com iluminação quente, vasos e flores.
- **Garagem:** pergolado de madeira com trepadeiras e cachos floridos; Fusca azul e Monark vermelha.
- **Horta:** canteiros elevados com bordas de madeira, culturas visíveis, cercas rústicas, ferramentas e caixas de produtos.
- **Celeiro:** vermelho com detalhes brancos e portas em X, silo metálico ao lado.
- **Terreno:** gramado irregular, pequenas flores, terra com variações de textura, pedras discretas, árvores volumosas e exemplares floridos na primavera.
- **Luz:** manhã ensolarada, luz levemente dourada e sombras suaves; mudança de dia/noite continua funcional.
- **HUD:** calendário/estação à esquerda, saciedade e energia, dinheiro à direita, barra compacta de ferramentas embaixo.

### Paleta-base

| Elemento | Direção |
|---|---|
| Paredes da casa | Creme quente e madeira natural |
| Telhado | Terracota avermelhada |
| Gramado | Verdes orgânicos, sem neons |
| Celeiro | Vermelho rural com guarnições brancas |
| Flores de primavera | Rosa claro, rosa antigo, lilás |
| Luz | Ouro claro de manhã / âmbar suave de noite |
| HUD | Verde profundo fosco, dourado suave e tipografia legível |

## Implementação já iniciada no Godot

- `scripts/cozy_reference_art.gd`: fachadas, floreiras, canteiros elevados, celeiro, garagem decorada, árvores floridas e paisagem ao longe.
- `shaders/grass_stylized.gdshader` e `shaders/soil_stylized.gdshader`: variações de cor sobre o terreno jogável.
- `scripts/cozy_game_hud.gd`: barra de ferramentas compacta adicional.
- `scripts/environment_art_pass.gd`: capim pontiagudo, cascalho e pequenas flores instanciados.
- `scripts/visual_detail_pass.gd`: cerâmica, madeira, vegetação e iluminação arquitetônica.

**O que ainda não está pronto:** equivalência gráfica à imagem conceito, modelos 3D detalhados/rigados, texturas artísticas definitivas, animações de alta qualidade, refinamento visual do Fusca/Monark e efeito de iluminação cinematográfica em hardware real. Essa referência deve orientar os próximos lotes sem prejudicar jogabilidade ou desempenho.

## Critérios de revisão

1. Mostrar **capturas reais geradas pelo Godot**, não uma imagem gerada por IA apresentada como gameplay.
2. Manter a horta interativa, física, navegação e relógio híbrido sem regressões.
3. Preservar suporte inicial a PCs modestos (vegetação instanciada e materiais econômicos) e prever níveis de qualidade.
4. Trabalhar em branch separada e abrir PR antes de integrar à `main`.
5. Fazer testes visuais reais antes de prometer qualidade comercial ou versão Android.
