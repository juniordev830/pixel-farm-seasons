# Relógio por acontecimentos — Pixel Farm Seasons

## Escolha de design

O criador definiu: **a hora do jogo deve evoluir conforme as coisas forem acontecendo**, e não de acordo com o relógio do computador nem com uma escala fixa de 24/48/60 minutos reais por dia.

O sistema implementado **não soma minutos automaticamente a cada segundo do mundo real**. Os eventos concretos consomem tempo fictício; deslocamentos contam a distância do personagem.

### Exemplo (valores iniciais ajustáveis)

| Acontecimento | Minutos do jogo |
| --- | ---: |
| Preparar refeição na geladeira | 10 |
| Tomar café | 20 |
| Almoçar | 35 |
| Jantar | 30 |
| Alimentar vacas e galinhas | 25 |
| Colocar água no curral | 12 |
| Ordenhar vaca | 30 |
| Recolher ovos | 12 |
| Plantar um canteiro | 9 |
| Regar um canteiro | 5 |
| Colher um canteiro | 12 |
| Manutenção do carro | 70 |
| Comprar ou vender no mercado | 25 |
| Assistir TV (demonstrativo) | 35 |
| Usar notebook (demonstrativo) | 25 |
| Descansar na rede | 45 |
| Caminhar 80 metros | 1 |
| Dirigir 500 metros | 1 |
| Dormir | Avança para 06h30 do dia seguinte |

**Apenas ações bem-sucedidas** avançam o relógio: tentar ordenhar sem alimentar a vaca, por exemplo, não faz o horário andar. Ligar e desligar o rádio não avança o tempo nesta versão, pois pode ser usado em segundo plano.

## Virada do dia

Ao completar 24 horas fictícias acumuladas, o relógio volta a 00h00 e o dia aumenta. A horta regada pode crescer, as tarefas com animais e refeições são renovadas e o HUD atualiza o céu. Ao dormir, a passagem do tempo é tratada como um salto para a manhã seguinte.

## Decisões pendentes de jogabilidade

- Ajustar a duração realista das tarefas após testar se a rotina fica agradável.
- Planejar eventos longos: viagens entre cidades, reuniões, eventos especiais, chuva prolongada.
- Adicionar agenda de NPCs, comércio com horário de abertura, compromissos e consequências leves de atrasos.
- Definir se algumas atividades (tomar banho, cozinhar receitas, cuidar de uma horta grande) terão minijogos e tempo variável.
- Aperfeiçoar animações e efeitos visuais entre manhã, tarde e noite.

## Arquivos e testes

Implementação: `godot/scripts/rural_time.gd` e `godot/scripts/life_sim.gd`.

Teste automático: `godot/tests/event_clock_smoke.gd`, executado no GitHub Actions. Ele deve confirmar inatividade sem avanço, custos de tarefas, tempo por caminhada, travessia da meia-noite, crescimento da horta e sono até 06h30.

**Nota:** o tempo por eventos é uma decisão de design do protótipo, não uma afirmação de que os demais sistemas realistas do jogo já estão finalizados.
