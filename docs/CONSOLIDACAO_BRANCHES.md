# Consolidação das branches — 2026-11-05

## Estado confirmado

- `main` permaneceu inalterada.
- `desenvolvimento-3d` reúne a cadeia de commits dos antigos PRs #2–#9 e os sistemas do PR #13, mesclado **somente nesta branch**.
- `sistemas-da-fazenda` foi avançada por fast-forward até o mesmo commit integrado e pode receber novos trabalhos em sistemas.
- O PR #12, de `desenvolvimento-3d` para `main`, permanece em **draft**; nenhuma publicação oficial foi feita.
- Os PRs históricos #1–#11 foram encerrados **sem mesclar na main** e continuam disponíveis para consulta.

## Preservação do histórico

- Os PRs #2–#9 estão no histórico da branch `desenvolvimento-3d` por ancestralidade.
- Os PRs #10 e #11 estão no histórico integrado pelo PR #13.
- Os cinco arquivos do protótipo Godot 2D do PR #1 foram copiados integralmente para `legacy/godot-2d/` e verificados por conteúdo e SHA idênticos. Abrir esse diretório como projeto Godot independente.
- As antigas branches `feature/hybrid-clock-daily-agenda` e `feature/late-lunch-hunger-energy` eram idênticas na auditoria.

## Duas cenas 3D preservadas, uma entrada principal

O `godot/project.godot` de `desenvolvimento-3d` é o projeto oficial de trabalho do protótipo 3D, com `res://scenes/farm_world.tscn` como cena principal.

A configuração alternativa da linha de sistemas está preservada em `godot/project.needs-prototype.godot` e sua cena antiga permanece em `godot/main.tscn`, com os scripts de necessidades, casa e oficina. **Esses componentes ainda precisam ser conectados à cena principal e testados visualmente.** Não confundir preservação de código com funcionalidade já integrada em jogo.

## Critérios antes de publicar na main

- [ ] Conferir execução e erros no editor Godot 4.3.
- [ ] Verificar câmera atrás do fazendeiro, comandos e colisões.
- [ ] Integrar e testar oficina na garagem e passagem externa.
- [ ] Integrar fome, energia e liberdade de permanecer acordado de noite; sem forçar sono.
- [ ] Validar plantio, economia, relógio, casa, salvamento e retrocompatibilidade da prévia web.
- [ ] Verificar todos os workflows do commit final e executar testes manuais.

## Limpeza das branches antigas

As branches `feature/*` continuam existentes no remoto. Uma vez concluída a revisão, podem ser excluídas pela página de branches do GitHub, pois o histórico relevante foi preservado. **O fechamento de PRs não apaga branches automaticamente.** Manter somente `main`, `desenvolvimento-3d` e `sistemas-da-fazenda` como branches de trabalho.

A exclusão de branches é uma operação diferente da consolidação e ainda não foi executada.
