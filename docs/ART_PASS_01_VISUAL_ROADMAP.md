# Pixel Farm Seasons — Evolução visual da fazenda (Art Pass 01)

## Objetivo

Aproximar **a cena real de Godot** da identidade visual do conceito aprovado pelo criador: fazenda brasileira acolhedora, telhas cerâmicas, varanda de madeira, janelas azuis, iluminação quente, plantas, árvores frutíferas, horta e celeiro.

**A imagem de referência é uma proposta artística; não representa a qualidade gráfica atual da engine.** Não substituir capturas do Godot por imagens geradas por IA quando mostrar o progresso real.

## O que foi implementado nesta branch

A cena `godot/scenes/farm_world.tscn` carrega `godot/scripts/visual_detail_pass.gd`, que adiciona:

- **Telhado:** telhas cerâmicas separadas por fileiras, usando `MultiMeshInstance3D` para reduzir chamadas de desenho.
- **Casa:** venezianas azuis, ripas, acabamento de madeira na sacada e na varanda.
- **Iluminação:** cinco lanternas com luz amarelada para a casa e garagem (iluminação visual prototipada).
- **Paisagismo:** vasos de terracota, flores, pomar de pequenas árvores, arbustos e pedras do caminho.
- **Celeiro:** molduras claras e sinalização de madeira.

A camada de detalhes é isolada do sistema de rotina, casa explorável, carro, comércio e agricultura. Não traz dependências externas e não usa assets de terceiros.

## Como testar de verdade

1. Selecione a branch `feature/visual-art-pass-farm` no GitHub.
2. Importe `godot/project.godot` no **Godot 4.3+**.
3. Pressione F5 e inspecione casa, varanda, pomar e celeiro.
4. Compare enquadramento, aparência, colisões, sombras, FPS e escala com a referência artística.
5. Execute os testes automáticos `godot/tests/visual_detail_smoke.gd` e `godot/tests/event_clock_smoke.gd`.

Os testes headless validam estrutura e inicialização, **não a beleza visual final**.

## O que ainda separa o jogo do conceito realista

1. Modelos GLB/GLTF refinados para a casa e seus cômodos, personagem, animais, veículos e ferramentas.
2. Materiais PBR com normal maps e texturas de telhas, madeira, reboco, terra, vegetação e piso.
3. Vegetação otimizada por instâncias, terreno orgânico, mundo maior e streaming de regiões.
4. Câmera com composição, personagens rigados, ações animadas e equipamentos que se movimentam.
5. Ambiente atmosférico: sol, exposição, neblina leve, sombras e clima por estação.
6. HUD com inventário e rotinas sem cobrir o cenário ou atrapalhar a navegação.
7. Testes de desempenho em PCs modestos e, futuramente, Android.

## Vídeo-conceito

O trailer de referência foi produzido à parte como **animação de imagens conceituais**, não captura do Godot. Não deve ser usado como prova de funcionalidades renderizadas.

**Fluxo:** revisar PR no GitHub e não fazer merge automático na `main` sem confirmação.
