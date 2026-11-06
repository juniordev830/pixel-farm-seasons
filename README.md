# Pixel Farm Seasons 🌾

Jogo de fazenda experimental em HTML5 Canvas e JavaScript, com ciclo de dia/noite, plantio, economia, necessidades do personagem e salvamento local.

> **Estado:** protótipo 2D em desenvolvimento. Ainda não é o jogo 3D final nem uma versão comercial para Android/PC.

## Jogar no navegador

1. Baixe o ZIP desta branch ou clone o repositório.
2. Abra `index.html` em um navegador moderno.
3. O jogo não exige instalação de pacotes para a versão HTML.

## Controles

| Tecla | Ação |
| --- | --- |
| WASD ou setas | Caminhar / movimentar veículo |
| F | Plantar, regar ou colher na horta |
| E | Comer |
| R | Descansar |
| B | Comprar três sementes por cinco moedas |
| V | Vender colheita |
| T | Alternar entre caminhar, Fusca e bicicleta perto da garagem |
| X | Comprar expansão de terreno |
| P | Salvar |
| L | Carregar |

Em telas pequenas, use os botões de toque. O salvamento usa o armazenamento local do navegador; limpar os dados do site pode apagar a partida.

## Verificações

Requer Node.js 18+ para os testes:

```bash
node --check game.js
node --test tests/game.test.cjs
```

O GitHub Actions foi configurado para executar essas verificações em branches de funcionalidades e pull requests. Confirme os resultados na aba **Actions** antes de integrar as alterações.

## Limitações atuais

- Renderização 2D, não mundo aberto 3D.
- Veículos representados por modos de movimentação, sem direção ou física realistas.
- Terreno expandido em limites de movimentação, ainda sem novas construções.
- Sem empacotamento Android/PC, efeitos sonoros, NPCs ou interiores.
