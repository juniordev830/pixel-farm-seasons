# Consolidação das branches — 2026-11-05

## Direção aprovada

- `main`: versão oficial, **não modificada** nesta consolidação.
- `desenvolvimento-3d`: base de desenvolvimento visual e interação Godot, derivada de `feature/cozy-hud-camera-v1`.
- `sistemas-da-fazenda`: sistemas de necessidades, casa, oficina e rotina, derivada de `feature/hunger-movement-slowdown-20261105`.

## Histórico preservado

A branch `desenvolvimento-3d` contém o histórico de commits dos PRs #2, #3, #4, #5, #6, #7, #8 e #9. O protótipo Godot 2D do PR #1 foi preservado em `legacy/godot-2d/`, isolado do projeto 3D.

A branch `sistemas-da-fazenda` contém o histórico das branches que originaram os PRs #10 e #11, inclusive a penalidade de velocidade por fome e a liberdade de atravessar a noite acordado.

Os PRs antigos e suas branches são referências históricas; antes de excluir qualquer branch, confirme as integrações de código, testes e revisão. `feature/hybrid-clock-daily-agenda` e `feature/late-lunch-hunger-energy` apontavam para o mesmo commit na auditoria.

## Incompatibilidade a resolver antes de juntar os dois fluxos

As duas linhas de desenvolvimento criaram protótipos Godot distintos e ambas usam `godot/project.godot` como configuração. **Não mesclar as duas branches automaticamente em `main`**. Escolher uma cena principal, integrar as partes necessárias de fome/energia, garagem, oficina e controles ao projeto 3D e resolver caminhos e cenas duplicadas.

Critérios para integrar: abertura do projeto Godot; câmera atrás do fazendeiro; funcionamento de oficina dentro da garagem e passagem externa; relógio com dia/noite; noite sem sono forçado e perda gradual de energia; testes de plantio e necessidades; nenhuma alteração regressiva na prévia web.

As duas PRs de consolidação devem começar em **draft**. Não excluir branches históricas enquanto houver recursos não absorvidos ou testes pendentes.
