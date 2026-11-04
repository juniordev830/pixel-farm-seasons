# Documento de design — Pixel Farm Seasons

## Conceito
Simulador de vida rural 3D low-poly, exploração em terceira pessoa com câmera livre e opção de primeira pessoa. O jogador controla fazendeiro(a) e escolhe livremente a rotina.

## Personagem
Movimentação em todas as direções, correr, agachar, pular, olhar para cima/baixo e girar a câmera. Câmera adaptável em interiores. Indicadores independentes de saúde e energia.

## Casa
Dois andares desde o início, varanda com rede interativa, sala, cozinha, banheiro, quartos, escadas, portas e móveis. Descansar na rede recupera parte da energia. Sono opcional, bocejos após 22h, perda gradual de energia e consequências da exaustão.

## Animais e tarefas
Comprar animal cria rotinas contextuais. Vaca: alimentação, água e ordenha pela manhã (ex.: 6h). Galinhas: alimentação e ovos. Personalidade, saúde e bem-estar afetam produção.

## Defesa
Lobos podem atacar ocasionalmente; jogador pode lutar ou investir em cães, cercas, iluminação e vigias. Combate com saúde, energia, esquiva e comportamento de fuga dos lobos. Ataques não devem ocorrer toda noite.

## Veículos
Iniciais: carro clássico estilo Fusca azul-claro e bicicleta Monark vermelha. Desbloqueáveis: trator, cortador de grama, caminhonete, colheitadeira, caminhão e implementos. Interações para entrar/sair, condução e manutenção.

## Progressão
30 níveis; XP por agricultura, animais, construção, exploração, missões e defesa. Desbloqueios graduais, marcos a cada 5 níveis; compras usam moeda do jogo.

## Arte e apresentação
3D low-poly colorido, casa rural de dois pavimentos com varanda e rede, fazenda com curral, árvores e plantações. Guardar imagens aprovadas em `docs/concept-art/` e identificar se são conceitos ou capturas reais.

## Implementação incremental
MVP 1: cena 3D + controle + câmera + colisão.
MVP 2: casa navegável + rede + sono/energia.
MVP 3: vaca + ordenha + relógio + inventário.
MVP 4: veículos + proteção + lobo.
MVP 5: níveis + economia + expansões.

**Status:** especificação de design, não declaração de recursos implementados.
