# Execução e validação do protótipo 3D

## Requisitos
- Godot 4.3, versão padrão (sem .NET)
- Computador com suporte a OpenGL 3.3 para o renderizador Compatibility

## Como executar
1. Clone o repositório e selecione a branch `feature/farm-daily-needs-v1`.
2. Abra a pasta `godot/` no Godot 4.3 (ela contém `project.godot`).
3. Execute a cena principal com F6 ou o projeto com F5.
4. Controles atuais: setas/WASD para movimento, Shift para correr, Espaço para pular, mouse para câmera, Esc para liberar o cursor.
5. A tecla E está preparada para interações, mas não há objetos físicos com `interact()` conectados na cena.

## Critérios de aceite antes de merge
- [ ] Importação do projeto sem erros no console.
- [ ] Cena principal abre e não apresenta falhas de script.
- [ ] Jogador permanece sobre o terreno e pode caminhar/correr/pular.
- [ ] Câmera acompanha o personagem; checar clipping em objetos.
- [ ] HUD e relógio são exibidos.
- [ ] Céu e iluminação mudam com o tempo.
- [ ] Casa não apresenta telhado duplicado.
- [ ] Medir FPS em PC básico e dispositivo Android de referência.

## Limitações atuais
A casa é um bloco exterior, ainda não um interior explorável. O telhado é geometria de protótipo. Árvores, cercas e plantações ainda são objetos simples. O HUD mostra estatísticas provisórias. Não há modelo animado de fazendeiro nem veículos dirigíveis. A colisão está implementada apenas para o chão e o jogador, não para toda a arquitetura.

## Próximos marcos
1. Corrigir qualquer falha revelada pelo teste headless.
2. Fazer colisões e uma casa modular com interior e portas.
3. Implementar câmera com prevenção de clipping e animações do personagem.
4. Criar biblioteca de materiais PBR, telhas, madeira, solo, folhas e água.
5. Modelar animais, ferramentas e veículos; otimizar com LOD e instanciamento.
6. Integrar sistemas de necessidades, cultivo, inventário e missões ao HUD.
7. Testar PC e Android; somente depois revisar o PR para merge.
