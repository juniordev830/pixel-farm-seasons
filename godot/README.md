# Pixel Farm Seasons — primeira fazenda 3D (Godot 4.3+)

## Novidade: simulador de vida rural — primeira versao (branch de desenvolvimento)

A cena 3D agora carrega automaticamente `scripts/life_sim.gd`, um prototipo dos sistemas de vida rural:
- Casa de dois andares com abertura para entrar, escada/rampa, sala, cozinha e suite.
- Geladeira + mesa: preparar e realizar cafe da manha, almoco e jantar.
- HUD com relogio, dinheiro, fome e energia; iluminacao de dia e de noite.
- Vaca e galinhas: alimentar, colocar agua, ordenhar e recolher ovos.
- TV e radio ligam/desligam visualmente; notebook mostra informacoes da rede ficticia do jogo.
- Garagem, bancada de oficina, carro que pode ser dirigido e consertado.
- Estrada para uma pequena vila rural com mercado de mantimentos.
- Gravacao local automatica em `user://pixel_farm_life_save.json`.

**Controles adicionais:** aproxime-se do objeto e pressione **E** para interagir. Dentro do carro, **WASD** dirige e **E** sai.

**Importante:** a interatividade e simplificada e os modelos sao low-poly temporarios. TV e radio ainda nao reproduzem midia; notebook nao acessa a Internet real. Os arquivos ainda exigem teste no motor Godot.

Documentos de referencia: `docs/OPEN_WORLD_LIFE_SIM_VISION.md` e `docs/LIFE_SIM_TEST_PLAN.md` (na raiz do repositório).

---


A pasta `godot/` é um projeto Godot independente, separado da prévia web 2D.

## O que foi criado

- Terreno 3D explorável com caminho, grama, vegetação e nuvens.
- Casa de dois andares, telhado, janelas, varanda, banco e rede ilustrativa.
- Celeiro vermelho, silo, horta com 30 canteiros, cercas e plantações decorativas.
- Curral com vaca e galinhas estáticas, lago, árvores e carro azul provisório.
- Personagem com câmera em terceira/primeira pessoa, pulo e corrida.
- Luz do sol, sombras e colisão no chão e nos edifícios.

Todos os modelos são formas geométricas procedurais do Godot (arte low-poly provisória).

## Como executar

1. Baixe ou clone a branch `feature/farm-3d-environment-v1`.
2. Instale Godot **4.3 ou superior**.
3. Abra Godot > **Importar** > selecione `godot/project.godot`.
4. Execute o projeto (F5). A cena principal é `godot/scenes/farm_world.tscn`.
5. O script `godot/scripts/farm_world.gd` monta os modelos ao iniciar.

## Controles

| Tecla | Ação |
| --- | --- |
| WASD | Caminhar |
| Mouse | Girar câmera |
| Shift | Correr |
| Ctrl | Deslocar lentamente |
| Espaço | Pular |
| V | Primeira / terceira pessoa |
| Esc | Soltar o mouse; clique na janela para recapturar |

## O que ainda não está pronto

A casa é sólida e não tem interior. Os animais, plantas, carro e rede ainda são modelos estáticos. Não existem no cenário 3D sistemas de plantio, colheita, direção, clima ou missões. Eles permanecem planejados; o protótipo web 2D continua disponível na raiz.

**Validação:** a cena foi construída em código, mas ainda não foi aberta/testada em uma instalação real do Godot nesta sessão. A próxima etapa é executar no editor e corrigir qualquer problema de renderização ou física.

Consulte `docs/FARM_3D_ART_DIRECTION.md` para o planejamento visual. Nenhum arquivo de jogo da branch `main` foi substituído.
