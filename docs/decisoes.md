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

As Camadas 1 e 2 foram compiladas com GHC 9.10.3 no Windows, utilizando `-Wall` e `-Werror=incomplete-patterns`.

Os 59 testes automatizados foram aprovados, sendo 25 referentes à Camada 1 e 34 referentes à Camada 2.

A classificação final e a classificação após a terceira rodada foram conferidas com os resultados das partidas do campeonato. Também foram verificados os critérios de desempate, as estatísticas e o comportamento das funções com listas vazias.

## Camada 3

A leitura e a validação dos dados textuais ainda estão em desenvolvimento.

As partidas recebidas deverão ser validadas antes de serem utilizadas pelas funções de classificação. As decisões sobre tratamento dos campos, numeração das linhas, duplicação de times por rodada e precedência dos erros serão registradas após a implementação.