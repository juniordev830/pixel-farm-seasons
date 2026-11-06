# Pixel Farm Seasons — plano de implementação

## Objetivo
Simulador de fazenda em mundo aberto, com câmera em terceira pessoa atrás do fazendeiro, ciclo de dia e noite e progressão gradual.

## Requisitos de jogabilidade
- Movimentação livre com câmera acompanhando o personagem por trás.
- Relógio avança mesmo quando o jogador fica parado, com eventos ligados aos horários.
- Refeições: ao atrasar o almoço, a fome aumenta, a energia diminui progressivamente e o personagem comenta que precisa comer.
- Liberdade para permanecer acordado à noite, com cansaço e redução gradual de velocidade.
- Casa, garagem e oficina compartilhando o mesmo edifício; acesso externo à garagem.
- Veículos familiares: Fusca azul e bicicleta Monark vermelha.
- Expansão de terrenos desbloqueável por progressão.

## Sequência técnica
1. Inventariar arquivos, engine e comandos de execução existentes.
2. Criar cena jogável com chão, personagem, câmera e colisões.
3. Implementar relógio determinístico e necessidades (fome, energia, sono).
4. Adicionar casa, garagem/oficina e veículos.
5. Criar inventário, plantio, colheita e salvamento.
6. Executar testes automatizados e validar interface visual.

## Critérios de aceite da primeira versão jogável
- O jogador se move e a câmera permanece atrás dele.
- O tempo avança em movimento e parado.
- Atrasar o almoço altera fome e energia sem travar o jogo.
- O jogador pode permanecer acordado, mas perde desempenho.
- O jogo pode ser iniciado seguindo instruções reproduzíveis.

> Este documento é planejamento, não comprovação de funcionalidades implementadas.
