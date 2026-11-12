# 🌾 Pixel Farm Seasons — candidato a lançamento 3D para PC

Simulador de fazenda em terceira pessoa, desenvolvido em **Godot 4.3**, com fazendeiro, ambiente rural low-poly, rotina diária, agricultura, animais, economia, veículo e uma campanha curta. A versão web 2D permanece separada.

> **Estado de 07/11/2026:** candidato à compilação Windows x64 integrada; validar os workflows e o pacote da branch de lançamento antes da distribuição. **Ainda é uma versão beta:** faltam validação manual em Windows, artes/animações finais, funcionalidades de mundo aberto avançado e adaptação para Android.

## 🎮 Baixar e jogar no Windows 64 bits

1. Entre em [Actions — compilação Windows](https://github.com/juniordev830/pixel-farm-seasons/actions/workflows/godot-export-windows.yml) e abra a execução concluída com sucesso da branch `release/pixel-farm-seasons-windows-rc1-20261107`.
2. Em **Artifacts**, baixe `PixelFarmSeasons-Windows64` (pode ser necessário entrar na sua conta GitHub).
3. Extraia o ZIP externo e o ZIP interno, mantendo `PixelFarmSeasons.exe` e `PixelFarmSeasons.pck` **na mesma pasta**.
4. Abra `PixelFarmSeasons.exe`. Para salvar ou pausar, pressione **P**.

O executável não exige instalar o editor Godot. A compilação vem do projeto em `godot/`, não do protótipo 2D da raiz.

## O que você consegue fazer

- Explorar o sítio 3D com câmera fixa em terceira pessoa, sempre atrás do fazendeiro;
- Entrar na casa de dois andares e interagir com geladeira, refeições, cama, rede, TV, rádio e notebook demonstrativos;
- Cuidar de vaca e galinhas, alimentar, dar água, ordenhar e colher ovos;
- Plantar, regar e colher **30 canteiros**, com cenoura, milho e tomate;
- Dirigir o Fusca azul simplificado e consertá-lo na oficina da garagem;
- Visitar a venda da vila, comprar suprimentos e vender produção;
- Viver com dia/noite, estações, clima, lembretes de almoço e perda gradual extra de energia se atrasar a refeição após 12h;
- Evoluir até o nível 30 e concluir **seis missões** com recompensas;
- Salvar automaticamente a cada 30 segundos e manualmente pelo menu de pausa, preservando também a posição do fazendeiro.

A bicicleta Monark vermelha é um **modelo decorativo** neste beta; ainda não é dirigível.

## 🕹️ Comandos PC

| Tecla | Ação |
| --- | --- |
| WASD | Andar ou dirigir |
| Mouse | Girar câmera |
| Shift | Correr |
| Espaço | Pular |
| Ctrl | Caminhar mais devagar |
| E | Interagir com objetos, horta, animais e mercado |
| F | Trocar ferramenta da horta |
| G | Alternar semente |

| P | Abrir menu de pausa, salvar e continuar |
| Esc | Liberar cursor do mouse |

## 🧑‍🌾 Objetivos da campanha

Você começa perto da **placa de objetivos**. A campanha introduz o ciclo completo da fazenda, com missões de colheita, cuidado dos animais, leite, ovos, vendas e sobrevivência por sete dias. Ao concluir os seis objetivos, o **modo livre permanece disponível**.

## 🛠️ Abrir o código no Godot

1. Selecione a branch `release/pixel-farm-seasons-windows-rc1-20261107` e baixe o código.
2. Instale Godot 4.3 ou uma versão compatível.
3. Importe `godot/project.godot`.
4. Pressione **F5**; cena principal: `res://scenes/farm_world.tscn`.

O projeto é procedural e usa meshes low-poly temporários, reduzindo dependências de assets externos.

## ✅ Testes e manutenção

Os testes automáticos em `.github/workflows/godot-life-sim.yml` cobrem importação, plantio, relógio, visual, HUD, personagem, saciedade, experiência, campanha, menu e inicialização headless. A compilação Windows é gerada por `.github/workflows/godot-export-windows.yml`. O CI **não substitui** testes com teclado/mouse, FPS, colisões e inspeção visual no Windows real.

O desenvolvimento integrado acontece em uma branch de lançamento separada, com PR de consolidação. As branches históricas de melhorias continuam preservadas. A branch `main` não recebeu essas alterações.

## Limites atuais

Este beta **não é o jogo comercial final** nem um mundo aberto 3D realista. Animações e modelos definitivos, bicicleta pilotável, missões avançadas, combate, otimização completa e versão Android ainda são etapas futuras. A prévia 2D `index.html` continua disponível separadamente.

## Próximos incrementos e validação

Consulte o [guia técnico do projeto](docs/GUIA_DE_VALIDACAO.md) para critérios de aceitação, verificações e limites do protótipo.
