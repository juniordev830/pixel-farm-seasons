# Agricultura 3D: plantio, rega, colheita e mercado

Implementação incremental no projeto Godot 4.3+ (`godot/project.godot`) da branch `feature/agriculture-and-seasonal-routine`.

## Controles

| Tecla | Ação |
|---|---|
| WASD | Andar pela propriedade |
| E | Interagir com canteiro/objetos/mercado |
| F | Alternar ferramenta: **Plantar → Regar → Colher** |
| G | Selecionar tipo: **Cenoura → Milho → Tomate** |
| V | Alternar primeira/terceira pessoa |
| Esc | Liberar o mouse |

## Ciclo de agricultura

1. Aproxime-se de um dos **30 canteiros** junto ao celeiro.
2. Com **Plantar** selecionado, escolha o tipo de cultura com **G** e pressione **E**. Consome uma semente.
3. Alterne para **Regar** usando **F**; pressione **E** no canteiro.
4. A planta cresce um estágio ao final de cada dia em que foi regada; demora **3 dias regados** para amadurecer. Em dias de chuva (cada 5º dia nesta versão), a rega é automática.
5. Alterne para **Colher** com **F**; pressione **E** no canteiro maduro. Cada colheita rende 3 produtos para vender.
6. Dirija ou caminhe até o mercado do vilarejo e pressione **E**. Caso haja produtos, vende primeiro por **R$5 por unidade**. Na interação seguinte pode comprar **4 alimentos, 3 rações e 8 sementes por R$30**.
7. O inventário e o estado de cada canteiro são armazenados em `user://pixel_farm_life_save.json` juntamente com o resto da fazenda.

## Clima e estações

O HUD mostra estação do ano (muda a cada 7 dias) e o clima do dia. Nesta fase, os dias de chuva seguem uma agenda determinística simples; faltam efeitos visuais de gotas, nuvens dinâmicas e sazonalidade avançada por tipo de cultivo.

## Testes

O GitHub Actions realiza importação Godot 4.3, inicia a cena 3D e roda `godot/tests/farming_smoke.gd` para testar:
- 30 canteiros inicializados;
- plantio com consumo de semente;
- rega e evolução de 3 fases;
- colheita com atualização de estoque;
- salvamento e restauração.

Ainda é necessário um teste manual no editor para conferir ergonomia, posição das plantações, controles e circulação. A arte 3D é um protótipo low-poly e **não representa ainda a fidelidade visual da imagem de referência**.

## Próximas etapas

- Animais com deslocamento e animações (vaca e galinhas).
- Inventário de itens separado por cultura e comércio com menus.
- Sistema de irrigação automático, estufa e ferramentas com custo/energia.
- Solo e clima dinâmicos, crescimento conforme estação e fertilizantes.
- Refino visual de personagens, casa e áreas externas.
