# Relógio híbrido e agenda por horários — Pixel Farm Seasons

O criador definiu que o tempo deve continuar passando quando o fazendeiro está parado, **e** deve avançar mais quando ele realiza atividades. A rotina é guiada por horários, com pensamentos contextuais para café, alimentação dos animais, almoço, jantar e sono.

**Velocidade inicial configurável:** 0,5 minuto fictício por segundo real, ou 48 minutos reais por dia no jogo caso nenhuma atividade seja realizada. Cozinhar, plantar, alimentar animais, caminhar e dirigir acrescentam tempo proporcional à ação ou ao percurso. O tempo não avança com o jogo fechado.

### Compromissos do personagem

- 06h30 — Acordar, tomar café.
- 07h00 — Alimentar animais e abastecer água.
- **11h00 — “Eita, já são 11h! Tenho que almoçar!”** (se não tiver almoçado).
- 18h00 — Lembrar de preparar o jantar.
- 22h00 — “Já ficou tarde! Melhor ir dormir.”

Os lembretes dependem da hora e das tarefas pendentes; não travam o jogo nem fazem a refeição automaticamente. Os horários das refeições controlam se a mesa executa café, almoço ou jantar. Dormir adianta para 06h30 do próximo dia. Ao atravessar meia-noite, a horta avança e as tarefas diárias são renovadas.

As durações das tarefas continuam em `godot/scripts/rural_time.gd`; a agenda em `godot/scripts/rural_schedule.gd`; o relógio e HUD em `godot/scripts/life_sim.gd`. A velocidade e a ordem das rotinas podem ser balanceadas depois.

**Teste:** `godot/tests/event_clock_smoke.gd` verifica avanço parado, tarefas, lembrete das 11h, caminhada, virada de dia, agricultura e sono.
