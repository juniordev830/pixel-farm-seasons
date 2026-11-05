# Pixel Farm Seasons — fome e movimento

Esta etapa aproxima o sistema jogável em Godot das regras de rotina do simulador Python. O fazendeiro continua podendo ficar acordado e caminhar durante toda a noite: **não há sono forçado**, somente consequências graduais.

## Regras aplicadas

| Condição | Multiplicador de velocidade |
|---|---:|
| Energia acima de 40 e fome abaixo de 65 | 100% |
| Fome de 65 até abaixo de 90 | 88% do fator da energia |
| Fome a partir de 90 | 76% do fator da energia |
| Energia entre 20 e 40 | 82% |
| Energia entre 5 e 20 | 62% |
| Energia até 5 | 48% |

Os fatores de fome e energia são combinados por multiplicação. Por exemplo, com energia 10 e fome 95, a velocidade passa a `0,62 × 0,76 = 47,12%` da velocidade normal. O personagem **não fica imobilizado**.

A fome (65 ou mais) também gera um custo energético adicional por minuto de jogo em Godot. Preparar uma refeição e comer reduz a fome; a penalidade de velocidade desaparece quando ela volta a ficar abaixo de 65, desde que o personagem tenha energia suficiente. As mensagens de fome e almoço continuam sendo geradas pelo relógio/necessidades já existentes.

## Testes

```bash
python3 -m unittest -v test_daily_cycle
godot --headless --path godot --editor --import --quit
godot --headless --path godot --script res://tests/needs_smoke.gd
```

O workflow agora executa **as duas suítes**. O código do Python é independente do renderizador; a redução real de velocidade é aplicada em Godot por `third_person_controller.gd`, que já consome `FarmerNeeds.movement_multiplier()`.

**Escopo:** estes ajustes não afirmam que a qualidade gráfica do jogo já alcançou a imagem-conceito nem que a integração PC/Android está finalizada. Os PRs de visual, câmera e oficina continuam separados e dependentes da sua ordem de integração.
