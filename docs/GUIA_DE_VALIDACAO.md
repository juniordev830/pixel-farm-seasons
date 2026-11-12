# Roteiro de validação — Pixel Farm Seasons

O repositório contém uma implementação principal em **Godot 4.3** em `godot/`, protótipo web separado (`index.html`, `game.js`, `style.css`) e testes de lógica em `test_daily_cycle.py` e `test_house_interactions.py`. Os documentos em `docs/` incluem visão de mundo aberto, rotinas, direção visual e exportação para Windows.

## Verificação antes de distribuição

- Confirmar a versão da engine, abrir `godot/project.godot` e executar a cena inicial sem erros.
- Validar colisão do personagem, controles em terceira pessoa, câmera e resposta a diferentes FPS.
- Verificar alternância de dia/noite e eventos no relógio sem pular refeições ou tarefas.
- Testar necessidade de energia e fome em horários de café, almoço e jantar.
- Conferir interações com cama, geladeira, porta, garagem e áreas da fazenda.
- Inspecionar artefatos de exportação Windows gerados por GitHub Actions **na branch que será lançada**.
- Executar `python -m unittest` ou os comandos de teste descritos no README e registrar resultado real.

## Matriz de testes manuais

1. Abrir/salvar estado com dia diferente; relógio e necessidades devem permanecer consistentes.
2. Permanecer acordado após as 22h e verificar a regra de energia documentada.
3. Usar a casa e a varanda; atravessamento de paredes e portas deve ser bloqueado.
4. Ativar evento de animal/curral e verificar horário, objetivo e cancelamento.
5. Interromper jogo durante uma interação e retomar sem perder controle de câmera.
6. Testar escala de interface em 720p, 1080p e viewport menor.

## Restrições atuais

O README identifica uma versão beta/candidata de exportação, não uma versão comercial validada. Testes em Windows e Android, qualidade final de assets, desempenho e proteção de saves ainda devem ser comprovados antes de anunciar lançamento. Fotos ou vídeos de referência não substituem capturas reais de gameplay.

## Próxima entrega

Manter uma lista curta de bugs reproduzíveis de colisão/rotina, corrigir com teste e publicar captura/vídeo apenas do build efetivamente executado. Revisar licenças de assets em `docs/ASSETS_3D_CC0.md`.
