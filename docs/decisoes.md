# Decisões de modelagem

## Campeonato

Futebol fictício com seis equipes, cinco rodadas e quinze partidas. A lista tipada em Dados.hs é a fonte dos placares; a entrada textual é derivada dela.

## Tipos

Resultado é um tipo soma. Partida e Linha são records. Pontos, saldo e aproveitamento são derivados dos campos de Linha, evitando armazenar valores redundantes.

## Classificação

A pontuação é 3/1/0. Para este campeonato, propomos desempatar por pontos, vitórias, saldo, gols pró (decrescentes) e nome (crescente). A especificação exige os critérios do campeonato escolhido; a ordem completa adotada é decisão do grupo. A classificação utiliza sortBy, comparing, Down e composição de comparadores.

A linha de cada time parte de um record zerado e acumula apenas suas partidas com filter e foldl. Gols são considerados pela perspectiva do time. Time ausente resulta em uma linha zerada; campeonato vazio gera classificação vazia. Aproveitamento sem jogos é zero. Maior goleada e média de gols retornam Nothing quando não há partidas; em igualdade de goleadas, conserva-se a primeira ocorrência.

## Limitações

Os construtores públicos permitem criar diretamente dados inválidos; a validação de entradas textuais será feita em Leitura.hs. A classificação presume partidas válidas. A abordagem percorre as partidas para cada time, adequada à dimensão do campeonato de exemplo; não é otimizada para grandes bases. Os números usam Int, com os limites desse tipo; percentuais usam Double. Nomes têm comparação textual sensível a maiúsculas e acentos. Não há persistência ou interface gráfica.

## Validação

Camada 1: 25 testes aprovados com GHC 9.10.3 no Windows. Camada 2: registrar aqui o resultado real da compilação com -Wall e dos testes após executá-los. A equipe deve revisar os critérios antes da entrega.

## Camada 3

A complementar pela equipe responsável após a implementação: tratamento de campos, precedência dos erros, duplicações por rodada, linhas em branco e comentários, limitações e resultados de testes.
