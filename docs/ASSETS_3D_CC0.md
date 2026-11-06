# Pixel Farm Seasons — materiais 3D gratuitos integrados

**Atualização de 06/11/2026.** Esta branch contém uma melhoria real dos modelos importados no Godot, não apenas imagens conceituais.

## Fonte e licença

- Criador original: **Kenney**, [Kenney Nature Kit](https://kenney.nl/assets/nature-kit).
- Espelho de arquivos GLB autossuficientes: [Hidencod/tge-assets](https://github.com/Hidencod/tge-assets), diretório `packs/nature-kit`.
- Licença dos modelos: **CC0 1.0** (domínio público; permitido o uso comercial). Veja `LICENSE` no repositório de origem. Crédito é opcional, mas recomendado.
- Todos os modelos importados estão em `godot/assets/kenney/nature/*.glb` e os originais têm materiais embutidos. Nenhuma dependência de CDN em tempo de execução.

## Modelos e integração

O script `godot/scripts/asset_quality_pass.gd` faz um passe visual após a montagem da cena:
- substitui as copas primitivas por seis variações de **árvores 3D reais**;
- substitui as árvores simplificadas do pomar;
- usa árvore importada e flores sobre a copa para a primavera;
- distribui **flores, pedras e arbustos em 3D** sem bloquear os caminhos;
- melhora a silhueta do **Fusca azul** com carroceria arredondada, janelas, rodas e faróis; mantém o controle original, a colisão e a posição salva;
- mantém a **horta funcional** e adiciona milho decorativo do lado externo.

Os modelos são pequenos e os materiais simples para não criar sobrecarga desnecessária em PCs modestos.

## Rodar e conferir

1. Abra `godot/project.godot` no Godot 4.3.
2. Faça a importação dos arquivos `.glb` e execute a cena com F5.
3. Para ver screenshots *reais* de como ficou, abra o workflow `.github/workflows/godot-screenshots.yml` e escolha o run desta branch.
4. Para validar em código: `godot --headless --path godot --script res://tests/asset_quality_smoke.gd`.

## O que ainda falta

Os modelos Kenney melhoram a aparência em relação aos blocos, mas continuam **low-poly**. Não estão no nível de detalhe da imagem conceitual aprovada. Ainda falta substituir casa, celeiro e personagem por malhas específicas de qualidade maior, criar materiais PBR, sombras e vegetação aprimoradas, fazer QA visual interativo e medir FPS no Windows real. A bicicleta continua decorativa. Não há edição comercial final.

Esta melhoria está isolada da `main` e deve ser revisada por PR antes da integração.
