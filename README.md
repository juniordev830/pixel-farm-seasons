# Pixel Farm Seasons

**Status:** primeiro MVP gráfico **2D em Godot 4**, com cenário desenhado por código, grade de plantio, quatro estações simuladas, crescimento de plantas, colheita e economia simples.

## Executar

1. Instale **Godot 4.2+**, edição padrão para GDScript.
2. Abra `project.godot` e execute o projeto com **F5**.
3. Use WASD/setas para selecionar canteiros e Espaço para plantar ou colher.

## Controles
- **WASD / setas:** mover o cursor.
- **Espaço:** plantar (se vazio) ou colher (quando madura).
- **N:** passar ao próximo dia.
- **B:** comprar cinco sementes por quatro moedas.
- **R:** reiniciar.

As plantas amadurecem após três dias e rendem três moedas por colheita. As estações mudam a cada sete dias. Todos os dados estão em memória e reiniciam ao fechar o jogo.

## Estrutura
- `project.godot` e `scenes/farm.tscn`: configuração e cena inicial.
- `scripts/farm.gd`: interface 2D, interação com canteiros e estado do jogo.
- `scripts/farm_rules.gd`: regras testáveis de crescimento e estações.
- `tests/test_farm_rules.gd`: verificações automatizadas com Godot em modo headless.

```bash
godot --headless --path . --script tests/test_farm_rules.gd
```

## Limitações e próximos incrementos
A arte é geométrica, sem sprites externos. Ainda não há animais, inventário persistente, loja visual, som ou salvamento. O motor Godot não estava disponível no ambiente de preparação, portanto o projeto precisa ser executado e validado antes de ser considerado pronto para distribuição.

Licença MIT.
