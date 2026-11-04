# Pixel Farm Seasons — protótipo 3D em Godot 4

Este diretório inicia a migração do jogo web 2D para um projeto 3D, **sem substituir** a prévia HTML existente.

## Primeira etapa: movimentação livre
- Andar em quatro direções, correr, pular e agachar.
- Girar a câmera com mouse (visão vertical e horizontal).
- Alternar primeira/terceira pessoa.
- Colisões com o cenário via `CharacterBody3D`.

## Como montar a cena no editor Godot 4
1. Crie um projeto Godot 4 e uma cena `Farmer.tscn` com nó raiz `CharacterBody3D`.
2. Adicione `CollisionShape3D`, `Visuals` (Node3D) e `CameraPivot` (Node3D).
3. Em `CameraPivot`, adicione `SpringArm3D`; dentro dele, `Camera3D` marcada como Current.
4. Anexe `scripts/farmer_controller.gd` ao nó raiz.
5. No Input Map, configure `move_forward` (W), `move_back` (S), `move_left` (A), `move_right` (D), `jump` (Espaço), `sprint` (Shift), `crouch` (Ctrl) e `toggle_camera` (V).
6. Crie uma cena de teste com chão `StaticBody3D` e colisão. Posicione o fazendeiro acima do chão.

**Estado:** código-base inicial; ainda não é uma cena completa nem foi validado no editor Godot.

## Próximas etapas
1. Cena jogável com casa de dois andares e varanda.
2. Interações: portas, escadas, móveis e rede para recuperar energia.
3. Sistema de sono, relógio e animações.
4. Veículos: Fusca antigo, bicicleta Monark vermelha e trator.
5. Animais, tarefas diárias, XP e 30 níveis.
6. Lobos, combate e defesa com cercas e cães.

Manter a branch separada e abrir revisão antes de integrar à `main`.
