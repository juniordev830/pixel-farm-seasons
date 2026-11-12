# Checklist de validação — Windows beta

Este documento descreve verificações manuais para o pacote Windows do Pixel Farm Seasons. **Não representa testes já executados.**

## Preparação

- [ ] Confirmar que o workflow de exportação Windows terminou com sucesso na branch que será distribuída.
- [ ] Baixar o artefato da execução correta e registrar o SHA do commit.
- [ ] Extrair todos os arquivos e manter o executável e o arquivo `.pck` na mesma pasta.
- [ ] Testar em uma máquina Windows x64 limpa, sem depender do editor Godot.

## Primeira execução

- [ ] Iniciar o executável e registrar eventuais mensagens de erro.
- [ ] Verificar se o cenário e a interface aparecem sem elementos ausentes.
- [ ] Conferir movimentação WASD, câmera com mouse, corrida, pulo e interação com E.
- [ ] Abrir e fechar o menu de pausa com P; testar liberação do cursor com Esc.

## Ciclo de jogo

- [ ] Plantar, regar e colher pelo menos um canteiro.
- [ ] Interagir com os animais e verificar coleta de produtos.
- [ ] Comprar e vender itens, conferindo o saldo antes e depois.
- [ ] Verificar passagem do tempo, refeições e consumo de energia.
- [ ] Testar entrada na casa e interações disponíveis.

## Persistência

- [ ] Salvar manualmente, encerrar e reabrir o jogo.
- [ ] Conferir posição, inventário, dinheiro, progresso e horário após carregar.
- [ ] Aguardar mais de 30 segundos, reiniciar e verificar o salvamento automático.
- [ ] Repetir o teste após uma mudança de missão.

## Qualidade e distribuição

- [ ] Registrar resolução, sistema operacional, hardware e FPS observado.
- [ ] Procurar colisões problemáticas, travamentos e erros visuais.
- [ ] Conferir que nenhum arquivo secreto, credencial ou configuração local está no pacote.
- [ ] Atualizar o README com a branch e o artefato realmente validados.
- [ ] Marcar a versão como beta até concluir a validação manual.

## Registro de resultados

| Data | Commit SHA | Windows / hardware | Cenário | Resultado | Evidência / issue |
| --- | --- | --- | --- | --- | --- |
| A preencher | A preencher | A preencher | A preencher | Pendente | A preencher |

Em caso de falha, abra uma issue com passos de reprodução, comportamento esperado, comportamento observado e logs sem dados pessoais.
