# Pixel Farm Seasons — validação do protótipo de vida rural

## Estado
Os arquivos da branch \`feature/rural-life-simulator-v1\` foram conferidos **estaticamente** (caminhos de scripts, presença de funções e referência da cena). O protótipo **ainda não foi executado no motor Godot nesta sessão**. Esta lista orienta o primeiro teste real.

## Abrir

1. Clone o repositório e selecione a branch \`feature/rural-life-simulator-v1\`.
2. Instale Godot 4.3+ (versão Standard).
3. Importe \`godot/project.godot\`.
4. Pressione F5 (a cena é \`res://scenes/farm_world.tscn\`).
5. Caso apareça erro, abra o painel **Debugger / Errors**, copie a linha exata e corrija na branch.

## Percurso de aceitação (primeiros 15 minutos)

- [ ] A cena abre sem erros de script e exibe personagem, terreno, casa, curral e garagem.
- [ ] WASD move; mouse gira; Shift corre; Espaço pula; V alterna câmera.
- [ ] A casa pode ser acessada pela abertura frontal.
- [ ] A rampa/escada leva ao segundo pavimento sem prender o personagem.
- [ ] Próximo à geladeira, E separa ingredientes. Próximo à mesa, E faz a refeição correspondente ao horário.
- [ ] A TV liga/desliga (tela muda de cor), o rádio liga/desliga (indicador muda de cor) e o notebook exibe um aviso.
- [ ] A cama passa o relógio para 06h30 e recupera energia.
- [ ] No curral: fornecer ração, dar água, ordenhar vaca e coletar ovos (só uma vez por dia).
- [ ] Na garagem: aproximar do carro, E para entrar, WASD para dirigir, E para sair.
- [ ] Na mini oficina: gastar R$ 20 para reparar o carro.
- [ ] Na vila: entrar na estrada e encontrar o mercado; E compra 4 alimentos e 3 rações.
- [ ] Iluminação muda quando o horário passa da tarde para a noite.
- [ ] Fechar e abrir o jogo restaura o estado em \`user://pixel_farm_life_save.json\`.

## O que funciona como demonstração, não como produto completo

- TV = superfície visual com estados ligado/desligado; **sem canais ou streaming**.
- Rádio = botão e luz; **ainda sem áudio**.
- Notebook = indicação de serviços da **rede fictícia do jogo**, não acesso livre à Internet.
- Animais = modelos geométricos estáticos, sem IA ou animações.
- Ração, leite, ovos = valores da simulação; não há inventário visual de itens.
- Cozinha = preparo simplificado na geladeira + refeição na mesa; sem animação de cozinhar.
- Casa = cômodos preliminares com rampa que simula escada; falta refinamento dos ambientes, portas, escadas finais e suíte detalhada.
- Carro = controlador cinemático protótipo com colisão simples; não há suspensão, combustível, rodas com física nem câmbio.
- Vila = uma pequena área adicional com estrada e mercado; não há ainda streaming de mapa nem mundo aberto completo.

## Próximas prioridades de produção

1. Executar e depurar em Godot 4.3+, medir FPS, corrigir conflitos da câmera no interior.
2. Substituir a rampa pela escada modular com degraus e colisor contínuo.
3. Separar a arquitetura em módulos \`ClockSystem\`, \`NeedsSystem\`, \`AnimalSystem\`, \`HouseInteractables\`, \`VehicleController\` e \`SaveSystem\`.
4. Modelos 3D profissionais: personagem, casa, animais, veículo, móveis, garagem, flora.
5. Inserir animações e inventário de verdade, refeições com preparo, som original/licenciado.
6. Expandir o mundo com chunk loading, missões, NPCs, economia, clima e estações.
