# Direção de gameplay: mundo aberto em terceira pessoa

## Visão
Pixel Farm Seasons será um simulador rural 3D com liberdade de exploração e interação contextual, inspirado na **estrutura de controles** de jogos de mundo aberto (sem copiar personagens, mapas, marcas ou assets).

## Vertical slice (primeira versão jogável)
- Personagem em terceira pessoa, câmera orbitável com mouse/analógico e colisões.
- Caminhar, correr, pular e interagir (tecla E ou botão de ação).
- Fazenda explorável: terreno, casa acessível, canteiros e celeiro.
- Interações: abrir porta, plantar, colher, comer e dormir.
- Relógio do jogo e ciclos de dia/noite; fome, energia e fadiga.
- Uma missão simples: plantar, regar e colher uma cultura.
- PC primeiro; controles touch e otimização Android depois.

## Arquitetura sugerida
- **Godot 4** para a cena 3D e exportação para PC/Android.
- `CharacterBody3D` para movimentação, `SpringArm3D` + `Camera3D` para câmera.
- `RayCast3D` para detectar objetos interativos.
- `WorldEnvironment` e `DirectionalLight3D` para iluminação.
- Recursos e cenas modulares para plantações, casa, NPCs e veículos.
- Adaptar regras existentes em `gameplay/daily_needs.py` e `gameplay/day_night.py` para GDScript ou interface equivalente.

## Critérios de aceitação
1. Jogador se movimenta livremente com câmera atrás do personagem.
2. Câmera acompanha o jogador sem atravessar paredes.
3. É possível entrar na casa e sair sem trocar de tela.
4. Interação só aparece perto de objetos alcançáveis.
5. Relógio e necessidades avançam enquanto o jogador explora.
6. Protótipo roda no PC; Android entra após perfil de desempenho definido.

## Escopo
Não há ainda movimentação 3D implementada. Este documento define o próximo trabalho, não uma funcionalidade pronta.
