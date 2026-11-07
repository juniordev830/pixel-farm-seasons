# Pixel Farm Seasons — direção de arte do mundo 3D

## Conceito: fazenda brasileira acolhedora

Visual contemporâneo, colorido e levemente estilizado. Primeira etapa low-poly (blocos modelados no próprio Godot), com transição planejada para modelos GLB/GLTF de maior qualidade. Sol intenso, grama viva, sombra suave, madeira quente e água azul-esverdeada. Não confundir essa etapa com uma renderização realista final.

## Mapa inicial

- **Oeste/noroeste:** casa de dois andares, varanda e área de descanso.
- **Nordeste:** celeiro vermelho e silo.
- **Centro/leste:** horta, 30 canteiros decorativos e cercas.
- **Sudeste:** curral com vaca e galinhas.
- **Sudoeste:** lago e árvores.
- **Centro/sul:** entrada e caminho para circulação do fazendeiro.
- Terreno inicial aproximado de 100×100 unidades Godot; 1 unidade ~= 1 metro.

## Critérios para modelar assets definitivos

1. Substituir paredes sólidas da casa por módulos individuais (entrada utilizável, portas, janelas e cômodos).
2. Fazer modelos reaproveitáveis: \`FarmHouse.glb\`, \`Barn.glb\`, \`Cow.glb\`, \`Chicken.glb\`, \`Tractor.glb\`, \`Bike.glb\`, \`Tree_Oak.glb\`.
3. Definir materiais PBR (cor, roughness, normal map e mapas de sombra) e níveis de detalhe.
4. Modelar terreno com variações de altura e trilhas; otimizar vegetação com MultiMesh.
5. Adicionar UI do jogo e interações: inspeção, inventário, plantio, rega, colheita.
6. Adicionar estação do ano dinâmica, clima, ciclo de dia/noite e sons ambientais.
7. Criar testes visuais em máquina com Godot e screenshots antes de afirmar que o jogo foi executado.

## Limites deste protótipo

Objetos como vaca, galinhas, veículo e rede são **representações estáticas**. A fazenda é navegável por fora; a casa ainda não tem interior. A horta não está ligada às regras da prévia HTML 2D.
