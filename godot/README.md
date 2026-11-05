# Pixel Farm Seasons — simulador de vida rural 3D (Godot 4.3+)

> **Protótipo em desenvolvimento:** modelos low-poly provisórios; não é ainda o jogo realista da colagem de referência. A versão web 2D na raiz do repositório continua separada.

## Como executar

1. Clone ou baixe a branch `feature/event-driven-game-clock`.
2. Abra o **Godot 4.3+** e importe `godot/project.godot`.
3. Execute com F5: cena `res://scenes/farm_world.tscn`.

## Funcionalidades implementadas no protótipo

- Casa rural explorável, dois andares, cozinha, sala, suíte, varanda e rede (interiores provisórios).
- Fome, energia, dinheiro, refeições, relógio e iluminação entre dia e noite.
- Vaca e galinhas em modelos estáticos; tarefas de ração, água, ordenha e coleta de ovos.
- Garagem, mini oficina, carro dirigível com física simplificada e venda rural.
- Horta com 30 canteiros de cenoura, milho e tomate: plantar, regar e colher após três dias regados.
- Mercado da vila para comprar mantimentos/ração/sementes e vender a colheita.
- TV, rádio e notebook com interações **demonstrativas**; sem conteúdo real de mídia nem navegação na internet.
- Progresso gravado em `user://pixel_farm_life_save.json`.

## Relógio híbrido e compromissos

A hora **avança naturalmente, mesmo parado**, à velocidade inicial de 0,5 minuto do jogo por segundo real. Plantar, trabalhar, comer e dirigir acrescentam tempo, de acordo com as tarefas e distâncias. A velocidade é configurável.

O fazendeiro acorda às 06h30, pode tomar café e cuidar dos animais. Quando chegam as **11h** e ainda não almoçou, ele pensa: **“Eita, já são 11h! Tenho que almoçar!”**. Às 18h lembra do jantar; à noite, do sono. Dormir leva até 06h30 do próximo dia. Os lembretes não forçam ações.

Veja `docs/EVENT_CLOCK_DESIGN.md`, `scripts/rural_time.gd` e `scripts/rural_schedule.gd`.

## Controles

| Controle | Ação |
| --- | --- |
| WASD | Andar; ao dirigir, controlar o carro |
| Mouse | Girar câmera |
| E | Interagir com objetos, horta, animais, mercado ou sair do carro |
| F | Trocar ferramenta da horta: plantar, regar ou colher |
| G | Trocar semente: cenoura, milho ou tomate |
| Shift | Correr |
| Ctrl | Caminhar lentamente |
| Espaço | Pular |
| V | Alternar câmera de primeira e terceira pessoa |
| Esc | Liberar o cursor |

## Desenvolvimento e testes

- `scripts/farm_world.gd`: cenário 3D procedural.
- `scripts/life_sim.gd`: rotina, casa, animais, garagem, carro, dinheiro, HUD e salvamento.
- `scripts/farming_system.gd`: horta, culturas, rega e colheita.
- `scripts/rural_time.gd`: durações de tarefas e deslocamento (relógio por eventos).
- `tests/farming_smoke.gd`: integração das culturas e salvamento.
- `tests/event_clock_smoke.gd`: tempo parado, tarefas, caminhada, virada do dia e sono.

O workflow `.github/workflows/godot-life-sim.yml` importa o projeto, executa a cena e os testes headless. Passar nesses testes **não substitui** a inspeção de gráficos, câmera, colisões, ergonomia e jogabilidade em um editor 3D real.

## Próximas melhorias

Substituir placeholders por modelos de qualidade, melhorar o interior da casa e personagem, animar animais, construir um inventário completo, preparar refeições de forma interativa e ampliar a vila sem perder performance.

Para o escopo completo do mundo aberto, consulte `docs/OPEN_WORLD_LIFE_SIM_VISION.md`.
