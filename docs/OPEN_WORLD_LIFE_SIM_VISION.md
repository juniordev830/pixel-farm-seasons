# Pixel Farm Seasons — Visão de Produto: Simulador de Vida Rural em Mundo Aberto

> **Referência de arte:** colagem aprovada pelo criador nesta conversa em 04/11/2026. A composição e ambientação são metas visuais, não capturas reais do jogo.

## Fantasia central

O jogador vive como fazendeiro em um sítio brasileiro explorável. Sua vida não se limita a plantar: acorda na suíte, toma café da manhã, alimenta e ordenha os animais, dirige até uma pequena vila, faz compras, usa oficina/garagem, prepara almoço, trabalha na horta, janta, assiste à televisão, ouve rádio, usa o notebook e vai dormir. Não há horários impostos que travem a liberdade: a rotina tem consequências graduais de fome, cansaço, bem-estar dos animais e recursos econômicos.

## Referência de arquitetura e arte

- **Casa principal:** dois pavimentos, telhado cerâmico, paredes claras, madeira, varanda com rede, iluminação quente, janelas azuis. O usuário precisa **andar dentro da casa**, subir escadas e usar os cômodos.
- **Pavimento térreo:** sala com TV/sofá, cozinha com fogão/geladeira funcionais, mesa de refeições, rádio, banheiro, porta para o quintal.
- **Pavimento superior:** suíte com cama, mesa, notebook, acesso a serviços de internet fictícia do jogo; banheiro e varanda.
- **Área externa:** pastagens, curral, galinheiro, celeiro, horta, árvores, água, cercas, garagem coberta e mini oficina mecânica.
- **Veículos:** Fusca azul clássico, bicicleta Monark vermelha, trator, caminhonete e equipamentos agrícolas com progressão.
- **Mundo aberto:** acesso por estrada sem telas de carregamento dentro da área inicial; crescer em biomas, vizinhos, feiras, posto, mercado, oficinas e vilarejo. Usar streaming de regiões quando o mapa for grande.
- **Interface:** terceira pessoa com opção primeira pessoa; minimapa, dinheiro, relógio, dia/estação, saúde, energia, fome, sede, tarefas, interações por proximidade.

## Rotina diária: horários sugeridos, não obrigatórios

| Período (no jogo) | Rotina | Sistemas |
|---|---|---|
| 05h30–07h30 | Acordar e tomar café | sono, fome, geladeira, cozinha, mesa |
| 06h00–09h00 | Ordenhar vacas, dar ração e água | necessidades dos animais, leite e ovos |
| 09h00–11h30 | Plantar, colher, reparar equipamentos | plantio, inventário, oficina |
| 11h30–14h00 | Almoçar e descansar na rede | fome, saúde, energia |
| 14h00–18h00 | Explorar, fazer compras e conduzir veículos | navegação, comércio, combustível |
| 18h00–21h00 | Preparar jantar e usar TV/rádio | cozinhar, lazer, descanso |
| 21h00–06h00 | Dormir na suíte | avanço do relógio, recuperação de energia |

## Regras do simulador

1. **Tempo e estações:** o relógio avança por acontecimentos (refeições, plantio, ordenha, atividades, viagens e sono), não por um fator fixo de minutos reais. O horário resultante define luz, fome, sono e o dia do jogo; a virada de dia faz crescer as culturas regadas e renova a rotina dos animais. Estações e clima também evoluem por dias. Tempos das tarefas são referências de equilíbrio, ajustáveis conforme o desenvolvimento.
2. **Alimentação:** alimentos saem do estoque da geladeira/despensa; refeições têm horário recomendado e podem ser preparadas fora dele, com bônus de rotina ao seguir os horários.
3. **Animais:** comer, beber, descansar, adoecer e produzir; cuidados afetam produção, sem sofrimento gráfico; vaca dá leite e galinhas dão ovos quando cuidadas.
4. **Casa:** portas, escadas, andar superior e objetos interativos são sistemas reais; TV e rádio inicialmente ligam/desligam, evoluindo para conteúdo original/licenciado; notebook inicialmente permite menus internos do jogo e só no futuro serviços externos mediante APIs e segurança.
5. **Garagem/oficina:** guardar, dirigir, abastecer e consertar o carro; posteriormente bicicletas, trator, caminhonete e manutenção detalhada.
6. **Economia:** vender produção, comprar alimentos/ração, ampliar terrenos, construir e consertar.
7. **Persistência:** salvar em arquivo local e recuperar tempo, estatísticas, inventário, tarefas e posição dos veículos.
8. **Jogo livre:** não deve punir usuário por faltar a um horário específico com game over; oferecer consequências leves e escolhas.

## Marcos

### MVP A — ciclo diário jogável (em implementação)
- Relógio dia/noite, fome, energia e dinheiro
- Café/almoço/janta e preparo da refeição com geladeira
- Vaca/galinhas: alimentação, água, ordenha e ovos
- TV, rádio, cama e notebook (interações simplificadas)
- Casa com salas e entrada interior, segundo piso e acesso por rampa/escada prototipada
- Garagem, mini oficina, carro dirigível simplificado
- Pequena estrada e vila/mercado experimental
- HUD e salvamento local

### MVP B — realismo da fazenda
- Modelagem refinada PBR, rig e animações, física de portas e veículos, interior detalhado
- NPCs com horários; tarefas e contratos; itens em inventário real
- Clima, estações, plantio e colheita 3D integrados
- Comida preparada no fogão, banho, roupa e saúde/bem-estar
- TV com programas originais; rádio com trilhas próprias/licenciadas
- Notebook com apps locais (mercado, conta bancária fictícia, previsão simulada)

### MVP C — mundo aberto expandido
- Regiões carregadas sob demanda, cidade, mercado, postos, fazendas vizinhas
- Compras, entregas, emprego, dia econômico, animais com IA e reprodução
- Tratores, bicicleta, caminhonetes, combustível, tuning e conserto
- Rotina dinâmica de NPCs, ciclo anual, progressão e missões

## Critérios de aceite para declarar algo pronto

- Importar no Godot sem erros de parser.
- Jogador entra na casa, sobe ao piso superior e interage com objetos.
- Jogador alimenta os animais, coleta produção e acompanha impacto na HUD.
- Carro sai da garagem por comando do jogador, retorna e pode ser reparado.
- O relógio altera luz ambiente e rotinas, refeição restaura fome.
- Salvar/sair/abrir restaura progresso.
- A área inicial abre sem travamentos e funciona com mouse/teclado.

**Nota:** o documento descreve o projeto total. A presença no backlog não significa que está concluído. Todas as funcionalidades precisam de execução e teste real no Godot antes de serem anunciadas como jogáveis.
