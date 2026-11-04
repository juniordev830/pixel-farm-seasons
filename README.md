# 🌾 Pixel Farm Seasons

Simulador de vida rural com agricultura, animais, exploração e aventuras. **Projeto em desenvolvimento**.

## 🎮 Estado atual
- **Prévia web 2D jogável:** `index.html`, `style.css`, `game.js`.
- **Protótipo 3D Godot 4:** controlador inicial em `godot/scripts/farmer_controller.gd`. Ainda não há uma cena 3D completa nem jogo 3D testado.
- **Conceitos visuais:** casa de dois andares com varanda e rede, fazendeiro(a), veículos e fazenda low-poly. Imagens de referência serão adicionadas em `docs/concept-art/` quando seus arquivos estiverem disponíveis.

## ▶️ Como jogar a prévia web
1. Baixe o repositório ou abra `index.html` em um navegador.
2. Selecione um dos 16 terrenos.
3. Clique em **Plantar** (custa 2 moedas) e **Regar**.
4. Avance um dia; regue novamente e avance mais um dia.
5. Clique em **Colher** (recebe 6 moedas). As estações mudam a cada 7 dias.
6. O progresso é salvo no navegador via `localStorage`.

## 🕹️ Controles planejados para o 3D
- **W/A/S/D:** caminhar; **mouse:** girar a câmera livremente.
- **Shift:** correr; **Espaço:** pular; **Ctrl:** agachar.
- **V:** alternar entre primeira e terceira pessoa.
- **Esc:** liberar cursor.
- Controles para celular, veículos e interação com objetos ainda serão desenvolvidos.

## 🏡 Visão do jogo 3D
O jogador escolhe fazendeiro ou fazendeira e começa com casa de dois andares, varanda e espaço para rede, um carro antigo e bicicleta Monark vermelha. A casa terá cômodos exploráveis, escadas, móveis interativos, descanso e reformas. A fazenda terá plantio, ordenha diária, animais com necessidades, clima, estações, construção e defesa contra lobos (combate e cercas/cães). Trator, cortador de grama, caminhonete e outros equipamentos serão adquiridos com a progressão.

### Rotina viva
Comprar uma vaca gera tarefas como alimentação e ordenha às 6h. À noite o personagem demonstra sono; o jogador decide quando dormir. Descansar na rede recupera parte da energia. Saúde e energia serão indicadores distintos.

### Evolução
Planejamento de 30 níveis iniciais, XP por trabalho, exploração, missões e proteção da propriedade; desbloqueios graduais e recompensas especiais a cada 5 níveis. Desbloquear não significa receber automaticamente todo equipamento.

## 🧰 Tecnologias
| Camada | Tecnologia | Uso |
| --- | --- | --- |
| Prévia web | HTML5 | Estrutura e botões |
| Prévia web | CSS3 | Aparência e layout responsivo |
| Prévia web | JavaScript | Plantio, rega, colheita, tempo e moedas |
| Salvamento web | localStorage | Persistência local |
| Protótipo 3D | Godot 4 | Engine planejada para mundo 3D |
| Scripts 3D | GDScript | Movimento, física e câmera |

## 📁 Estrutura
```text
index.html                 # interface web
style.css                  # estilos web
game.js                    # regras da prévia web
godot/
  README.md                # configuração inicial do Godot
  scripts/
    farmer_controller.gd   # controle de personagem 3D
docs/
  GAME_DESIGN.md           # sistemas e etapas de implementação
```

## 🛠️ Etapas de desenvolvimento
1. Controlador 3D e câmera livre (código inicial adicionado; cena pendente).
2. Cena com terreno, casa de dois andares, varanda, escadas e rede.
3. Relógio, sono, energia e interações com móveis.
4. Animais, curral e tarefas de rotina.
5. Veículos dirigíveis e manutenção.
6. Lobos, combate, cães e proteção.
7. Missões, inventário, economia e 30 níveis.
8. Otimização e controles para Android.

**Nota:** a prévia web não implementa ainda os sistemas 3D descritos. A documentação distingue recursos existentes de recursos planejados.

## 🤝 Desenvolvimento
Alterações em branch separada, revisadas por Pull Request antes de chegar à `main`.
