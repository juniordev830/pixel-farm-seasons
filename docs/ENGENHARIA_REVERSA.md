# Engenharia reversa e estudo — 🌾 Pixel Farm Seasons — campanha 3D para PC (beta jogável)

## Objetivo e fluxo

Simulação de fazenda, rotina, agricultura e economia em Godot. Leia project.godot e a cena inicial. Compare os controladores Godot de rotina e mundo com os módulos Python de regras e testes.

**Tecnologias identificadas** · GDScript, Godot, Python, PowerShell, JavaScript.

**Revisão de referência** · `97c5ca17706d`.

## Mapa do código

| Caminho | Papel de leitura | Símbolos selecionados |
| --- | --- | --- |
| [.github/scripts/test-windows-beta.ps1](../.github/scripts/test-windows-beta.ps1) | Implementação | — |
| [game.js](../game.js) | Implementação | `valid`, `save`, `render`, `empty`, `initial` |
| [gameplay/daily_needs.py](../gameplay/daily_needs.py) | Implementação | `Farmer`, `Farmer.clock`, `Farmer.advance`, `Farmer.movement_multiplier`, `Farmer.eat` |
| [gameplay/day_night.py](../gameplay/day_night.py) | Implementação | `Lighting`, `_mix`, `lighting_at` |
| [gameplay/house_interactions.py](../gameplay/house_interactions.py) | Implementação | `HomeState`, `HomeState.enter`, `HomeState.interact` |
| [godot/building_collision.gd](../godot/building_collision.gd) | Implementação | `wall`, `_ready` |
| [godot/day_night_controller.gd](../godot/day_night_controller.gd) | Implementação | `_ready`, `_process`, `set_clock`, `advance_to_next_morning`, `get_clock` |
| [godot/farm_environment.gd](../godot/farm_environment.gd) | Implementação | `_box`, `_ready` |
| [godot/farm_hud.gd](../godot/farm_hud.gd) | Implementação | `_ready`, `_process` |
| [godot/farm_props.gd](../godot/farm_props.gd) | Implementação | `make_box`, `make_sphere`, `_ready` |
| [godot/farm_workshop.gd](../godot/farm_workshop.gd) | Implementação | `block`, `_ready` |
| [godot/farmer_needs.gd](../godot/farmer_needs.gd) | Implementação | `_process`, `_check_meal_schedule`, `movement_multiplier`, `eat`, `sleep_until_morning` |
| [godot/farmer_visual.gd](../godot/farmer_visual.gd) | Implementação | `part`, `limb`, `_ready`, `set_movement` |
| [godot/farmhouse_details.gd](../godot/farmhouse_details.gd) | Implementação | `material`, `box_part`, `roof_slope`, `lantern`, `_ready` |
| [godot/farmhouse_interior.gd](../godot/farmhouse_interior.gd) | Implementação | `piece`, `_ready` |
| [godot/garage_door.gd](../godot/garage_door.gd) | Implementação | `_ready`, `_near_door`, `_physics_process`, `interact` |
| [godot/ground_collision.gd](../godot/ground_collision.gd) | Implementação | `_ready` |
| [godot/interactive_bed.gd](../godot/interactive_bed.gd) | Implementação | `_ready`, `interact` |
| [godot/interactive_fridge.gd](../godot/interactive_fridge.gd) | Implementação | `_ready`, `interact` |
| [godot/interactive_front_door.gd](../godot/interactive_front_door.gd) | Implementação | `_ready`, `interact`, `_physics_process` |
| [godot/player_controller.gd](../godot/player_controller.gd) | Implementação | `_ready`, `_unhandled_input`, `_physics_process` |
| [godot/scripts/asset_quality_pass.gd](../godot/scripts/asset_quality_pass.gd) | Implementação | `_ready`, `_packed`, `_place`, `_apply`, `_replace_generic_trees` |
| [godot/scripts/campaign_ending.gd](../godot/scripts/campaign_ending.gd) | Implementação | `_ready`, `_build_screen`, `show_victory`, `continue_after_victory`, `back_to_menu` |
| [godot/scripts/cozy_game_hud.gd](../godot/scripts/cozy_game_hud.gd) | Implementação | `_ready`, `_link_simulation`, `_panel`, `_text`, `_stack` |
| [godot/scripts/cozy_reference_art.gd](../godot/scripts/cozy_reference_art.gd) | Implementação | `_ready`, `_mat`, `_box`, `_ball`, `_beam` |
| [godot/scripts/environment_art_pass.gd](../godot/scripts/environment_art_pass.gd) | Implementação | `_ready`, `_ground_available`, `_make_multimesh`, `_tinted_material`, `_build_environment` |
| [godot/scripts/farm_missions.gd](../godot/scripts/farm_missions.gd) | Implementação | `next_goal`, `describe`, `completed` |
| [godot/scripts/farm_world.gd](../godot/scripts/farm_world.gd) | Implementação | `_ready`, `_material`, `_box`, `_ball`, `_cylinder` |
| [godot/scripts/farmer_art_v1.gd](../godot/scripts/farmer_art_v1.gd) | Implementação | `_ready`, `_find_animation_player`, `_choose_animation`, `_install_animated_farmer`, `_play_farm_animation` |
| [godot/scripts/farmer_controller.gd](../godot/scripts/farmer_controller.gd) | Implementação | `_ready`, `_unhandled_input`, `_mouse_motion_delta`, `_apply_mouse_look`, `_physics_process` |
| [godot/scripts/farming_system.gd](../godot/scripts/farming_system.gd) | Implementação | `_ready`, `ensure_initialized`, `_unhandled_key_input`, `tool_name`, `seed_name` |
| [godot/scripts/life_sim.gd](../godot/scripts/life_sim.gd) | Implementação | `_ready`, `_setup`, `_make_mat`, `_box`, `_sphere` |
| [godot/scripts/main_menu.gd](../godot/scripts/main_menu.gd) | Implementação | `_ready`, `_valid_save_integer`, `inspect_save`, `_inspect_save_file`, `_build_menu` |
| [godot/scripts/pause_menu.gd](../godot/scripts/pause_menu.gd) | Implementação | `_ready`, `_build_menu`, `_unhandled_key_input`, `toggle_pause`, `pause_game` |
| [godot/scripts/premium_art_pass.gd](../godot/scripts/premium_art_pass.gd) | Implementação | `_ready`, `_road_center`, `_side`, `_point`, `_tint` |
| [godot/scripts/rural_schedule.gd](../godot/scripts/rural_schedule.gd) | Implementação | `current_prompt` |
| [godot/scripts/rural_time.gd](../godot/scripts/rural_time.gd) | Implementação | `activity_minutes`, `travel_minutes`, `meal_activity`, `missed_lunch_energy_cost` |
| [godot/scripts/rural_vitals.gd](../godot/scripts/rural_vitals.gd) | Implementação | `movement_multiplier`, `advance` |
| [godot/scripts/save_store.gd](../godot/scripts/save_store.gd) | Implementação | `_read_dictionary`, `_looks_like_save`, `write_payload`, `reset_for_new_game` |
| [godot/scripts/visual_detail_pass.gd](../godot/scripts/visual_detail_pass.gd) | Implementação | `_ready`, `_mat`, `_box`, `_ball`, `_cylinder` |
| [godot/third_person_controller.gd](../godot/third_person_controller.gd) | Implementação | `_ready`, `_unhandled_input`, `_physics_process` |
| [godot/workshop_workbench.gd](../godot/workshop_workbench.gd) | Implementação | `interact` |
| [legacy/godot-2d/scripts/farm.gd](../legacy/godot-2d/scripts/farm.gd) | Implementação | `_unhandled_key_input`, `_tend_plot`, `_draw`, `_draw_crop`, `_draw_text` |
| [legacy/godot-2d/scripts/farm_rules.gd](../legacy/godot-2d/scripts/farm_rules.gd) | Implementação | `season_name`, `crop_stage`, `can_harvest`, `can_buy_seeds` |
| [godot/farm_house.tscn](../godot/farm_house.tscn) | Cena Godot versionada | — |
| [godot/main.tscn](../godot/main.tscn) | Cena Godot versionada | — |
| [godot/player.tscn](../godot/player.tscn) | Cena Godot versionada | — |
| [godot/scenes/farm_world.tscn](../godot/scenes/farm_world.tscn) | Cena Godot versionada | — |
| [godot/scenes/main_menu.tscn](../godot/scenes/main_menu.tscn) | Cena Godot versionada | — |
| [index.html](../index.html) | Marcação ou estilos da interface | — |
| [legacy/godot-2d/scenes/farm.tscn](../legacy/godot-2d/scenes/farm.tscn) | Cena Godot versionada | — |
| [preview/farm.html](../preview/farm.html) | Marcação ou estilos da interface | `color`, `rgb`, `lighting`, `rect`, `draw` |
| [style.css](../style.css) | Marcação ou estilos da interface | — |

## Configuração e referências

A [arquitetura](ARQUITETURA.md) detalha as responsabilidades e os vínculos do sistema.

Ambiente e dependências: [godot/project.godot](../godot/project.godot), [legacy/godot-2d/project.godot](../legacy/godot-2d/project.godot).

Referências existentes: [docs/ART_PASS_01_VISUAL_ROADMAP.md](ART_PASS_01_VISUAL_ROADMAP.md), [docs/GUIA_DE_VALIDACAO.md](GUIA_DE_VALIDACAO.md), [godot/README.md](../godot/README.md), [legacy/godot-2d/README.md](../legacy/godot-2d/README.md).

## Roteiro de estudo e desenvolvimento

1. Comece pelo fluxo descrito acima e localize seus pontos de entrada no mapa. Acompanhe uma entrada válida até a transformação ou a resposta.
2. Abra um teste relacionado ao fluxo e descreva qual regra ele protege. Compare o tratamento esperado para entradas válidas, inválidas e nos limites.
3. Ao adicionar uma regra, determine qual módulo controla o dado e cubra o caso nesse nível. Em seguida, confira o efeito no comando, na API ou na interface de entrada.

**Pergunta de entrevista**

Como definir um contrato para que o horário exibido acompanhe a rotina sem duplicar o relógio?

## Testes versionados

Arquivos para começar a leitura dos cenários de teste: [godot/tests/animated_farmer_smoke.gd](../godot/tests/animated_farmer_smoke.gd), [godot/tests/asset_quality_smoke.gd](../godot/tests/asset_quality_smoke.gd), [godot/tests/campaign_ending_smoke.gd](../godot/tests/campaign_ending_smoke.gd), [godot/tests/capture_gameplay.gd](../godot/tests/capture_gameplay.gd), [godot/tests/car_motion_smoke.gd](../godot/tests/car_motion_smoke.gd), [godot/tests/cozy_hud_smoke.gd](../godot/tests/cozy_hud_smoke.gd), [godot/tests/cozy_reference_smoke.gd](../godot/tests/cozy_reference_smoke.gd).

Os comandos e versões de runtime usados no CI ficam em [.github/workflows/godot-export-windows.yml](../.github/workflows/godot-export-windows.yml), [.github/workflows/godot-life-sim.yml](../.github/workflows/godot-life-sim.yml), [.github/workflows/godot-screenshots.yml](../.github/workflows/godot-screenshots.yml), [.github/workflows/godot-smoke.yml](../.github/workflows/godot-smoke.yml).

[Voltar ao README](../README.md).
