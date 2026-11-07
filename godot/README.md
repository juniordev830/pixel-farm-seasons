# 🌾 Pixel Farm Seasons — projeto Godot 4.3

Este diretório contém a versão 3D **beta para PC**. Consulte o [README principal](../README.md) para baixar o ZIP Windows, ler os controles e entender as funcionalidades.

## Abrir no editor

1. Baixe a versão atual da `main` (ou a branch de desenvolvimento a testar).
2. No Godot 4.3, importe `project.godot` deste diretório.
3. Pressione **F5** para abrir o menu `res://scenes/main_menu.tscn`; o mundo 3D está em `res://scenes/farm_world.tscn`.

## Arquitetura principal

- `scenes/main_menu.tscn` e `scripts/main_menu.gd`: continuar, iniciar com confirmacao e backup local do save;
- `scenes/farm_world.tscn`: cena 3D do jogo;
- `scripts/farm_world.gd`: cenário procedural (casa, celeiro, terreno, árvores);
- `scripts/life_sim.gd`: rotina, interações, garagem, carro, animais, salvamento e economia;
- `scripts/farming_system.gd`: trinta canteiros, plantio, rega, colheita;
- `scripts/rural_time.gd`, `scripts/rural_schedule.gd`: relógio e lembretes;
- `scripts/rural_vitals.gd`: penalidades de saciedade e energia;
- `scripts/farm_missions.gd` e `scripts/campaign_ending.gd`: campanha de seis objetivos, tela de vitoria e modo livre;
- `scripts/farmer_controller.gd`: movimento e câmera;
- `scripts/cozy_game_hud.gd`: HUD;
- `scripts/pause_menu.gd`: pausar, retomar e salvar;
- `tests/`: testes automatizados;
- `export_presets.cfg`: preset Windows x64.

## Validação

```sh
godot --headless --path godot --editor --quit
godot --headless --path godot --script res://tests/farming_smoke.gd
godot --headless --path godot --script res://tests/event_clock_smoke.gd
godot --headless --path godot --script res://tests/rural_vitals_smoke.gd
godot --headless --path godot --script res://tests/main_menu_smoke.gd
godot --headless --path godot --script res://tests/farm_missions_smoke.gd
godot --headless --path godot --script res://tests/pause_menu_smoke.gd
```

## Estado real

Prototipo testado automaticamente e compilado para Windows. Grafismo low-poly provisório; bicicleta decorativa; telas de TV/rádio/notebook demonstrativas. Não afirmar que há versão Android pronta ou que o jogo foi inspecionado visualmente em hardware Windows. A RC1 3D foi integrada a `main` pelo PR #23; novas alteracoes passam por branches e revisao.
