# 🌾 Pixel Farm Seasons — projeto Godot 4.3

Este diretório contém a versão 3D **beta para PC**. Consulte o [README principal](../README.md) para baixar o ZIP Windows, ler os controles e entender as funcionalidades.

## Abrir no editor

1. Baixe a branch `feature/complete-3d-gameplay-20261106`.
2. No Godot 4.3, importe `project.godot` deste diretório.
3. Pressione **F5** para iniciar `res://scenes/farm_world.tscn`.

## Arquitetura principal

- `scenes/farm_world.tscn`: cena 3D de entrada;
- `scripts/farm_world.gd`: cenário procedural (casa, celeiro, terreno, árvores);
- `scripts/life_sim.gd`: rotina, interações, garagem, carro, animais, salvamento e economia;
- `scripts/farming_system.gd`: trinta canteiros, plantio, rega, colheita;
- `scripts/rural_time.gd`, `scripts/rural_schedule.gd`: relógio e lembretes;
- `scripts/rural_vitals.gd`: penalidades de saciedade e energia;
- `scripts/farm_missions.gd`: campanha de seis objetivos, recompensas e conclusão;
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
godot --headless --path godot --script res://tests/farm_missions_smoke.gd
godot --headless --path godot --script res://tests/pause_menu_smoke.gd
```

## Estado real

Prototipo testado automaticamente e compilado para Windows. Grafismo low-poly provisório; bicicleta decorativa; telas de TV/rádio/notebook demonstrativas. Não afirmar que há versão Android pronta ou que o jogo foi inspecionado visualmente em hardware Windows. A `main` permanece sem merge.
