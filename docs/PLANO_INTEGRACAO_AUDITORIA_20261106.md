# Plano de integração segura — Pixel Farm Seasons

Atualizado em 2026-11-06. Este documento é um plano de revisão, não uma certificação de jogo concluído.

## Cadeia de PRs (não mesclar diretamente na main)

1. PR #12: `desenvolvimento-3d` → `main` (base do Godot 3D e legado 2D).
2. PR #14: `feature/complete-3d-gameplay-20261106` → `desenvolvimento-3d`.
3. PR #15: `feature/real-3d-nature-assets-20261106` → `feature/complete-3d-gameplay-20261106`.
4. PR #16: `feature/character-visual-rebuild-20261106` → `feature/real-3d-nature-assets-20261106`.
5. PR #17: `feature/farm-game-foundation-20261106` → `main`; documentação e protótipo alternativo, revisar sobreposição antes de integrar.

A ordem acima representa as bases atuais dos PRs, **não** uma ordem para executar merges sem testes. O código 3D mais novo está no topo da cadeia (#16). Não mudar a base ou fechar PRs sem avaliar dependências e alterações divergentes.

## Critérios para aceitar o jogo 3D

- Abrir o projeto `godot/` no Godot compatível, sem erros de importação ou parsing.
- Rodar os testes automatizados e smoke tests Godot nas branches envolvidas.
- Testar câmera em terceira pessoa atrás do fazendeiro, colisões e transições entre movimento/corrida/salto.
- Testar fome, energia, passagem de tempo parado e em movimento, dormir e alimentação.
- Conferir garagem/oficina, Fusca azul e bicicleta vermelha; verificar que modelos e licenças CC0 estão presentes.
- Validar plantio, colheita, salvamento e carregamento, e alternância de estações.
- Verificar desempenho e legibilidade do HUD em resolução baixa e média.
- Exportar build Windows e realizar teste manual do executável antes de anunciar conclusão.
- Registrar capturas reais do jogo; não apresentar renders conceituais como screenshots.

## Próxima execução sugerida

1. Rodar CI dos PRs #12, #14, #15 e #16.
2. Corrigir falhas na branch onde foram introduzidas, preservando a cadeia.
3. Comparar os arquivos do PR #17 com #12 antes de decidir se há algo novo a reaproveitar.
4. Consolidar a branch de integração somente após aprovação dos testes e revisão visual.

**Política:** nunca mesclar automaticamente na `main`.
