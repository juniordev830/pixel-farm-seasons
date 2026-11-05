# Protótipo Godot 2D preservado

Este diretório guarda, sem alterações de conteúdo, o protótipo do PR #1 (`feature/godot-pixel-farm-mvp`). O jogo 3D principal continua em `godot/`.

## Abrir e testar

Use Godot 4.2 ou superior e importe `legacy/godot-2d/project.godot` como um projeto **separado**. Ao executar F5, abre `scenes/farm.tscn` deste protótipo.

Para executar as regras via terminal (com Godot instalado):

```bash
godot --headless --path legacy/godot-2d --script res://tests/test_farm_rules.gd
```

O protótipo 2D é uma referência histórica, não a cena principal do jogo 3D. Não há garantia de teste em editor Godot nesta consolidação.

Arquivos originais preservados: `project.godot`, `scenes/farm.tscn`, `scripts/farm.gd`, `scripts/farm_rules.gd` e `tests/test_farm_rules.gd`.
