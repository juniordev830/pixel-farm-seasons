# Consolidação dos sistemas da fazenda — 2026-11-05

Esta branch preserva a linha de desenvolvimento dos PRs #10 e #11, que inclui o protótipo de rotina, necessidades, fome, energia, interações domésticas, garagem/oficina e perda gradual de velocidade com fome.

A base é `feature/hunger-movement-slowdown-20261105`; o histórico anterior de `feature/farm-daily-needs-v1` está incluído.

## Regra do jogo

O fazendeiro pode permanecer acordado a noite inteira. Fome elevada e energia baixa prejudicam o deslocamento, sem forçar o sono. Recuperação depende de ações do jogador.

## Integração pendente

Este projeto Godot não usa a mesma estrutura de cenas de `desenvolvimento-3d`. Antes de integrar, revisar `godot/project.godot`, `godot/main.tscn`, `godot/player_controller.gd`, `godot/third_person_controller.gd`, `godot/farmer_needs.gd` e `godot/farm_workshop.gd`, preservando a câmera atrás do personagem, oficina dentro da garagem e acesso externo.

Preservar os sistemas 3D já existentes (plantio, mercado, ciclo de tempo, HUD e arte) e executar testes Godot e Python antes de qualquer merge.

Não fazer merge automático em `main` nem excluir branches antigas antes da integração e validação.
