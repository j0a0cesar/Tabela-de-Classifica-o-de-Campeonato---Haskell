# Decisões de modelagem

## Campeonato

Futebol fictício com seis equipes, cinco rodadas e quinze partidas. A lista tipada em Dados.hs é a fonte dos placares; a entrada textual é derivada dela.

## Tipos

Resultado é um tipo soma. Partida e Linha são records. Pontos, saldo e aproveitamento são derivados dos campos de Linha, evitando armazenar valores redundantes.

## Classificação

A pontuação é 3/1/0. Para este campeonato, propomos desempatar por pontos, vitórias, saldo, gols pró (decrescentes) e nome (crescente). A especificação exige os critérios do campeonato escolhido; a ordem completa adotada é decisão do grupo. A classificação utiliza sortBy, comparing, Down e composição de comparadores.

A linha de cada time parte de um record zerado e acumula apenas suas partidas com filter e foldl. Gols são considerados pela perspectiva do time. Time ausente resulta em uma linha zerada; campeonato vazio gera classificação vazia. Aproveitamento sem jogos é zero. Maior goleada e média de gols retornam Nothing quando não há partidas; em igualdade de goleadas, conserva-se a primeira ocorrência.

## Limitações

Os construtores públicos permitem criar diretamente dados inválidos; a validação de entradas textuais é feita em Leitura.hs. A classificação presume partidas válidas. A abordagem percorre as partidas para cada time, adequada à dimensão do campeonato de exemplo; não é otimizada para grandes bases. Os números usam Int, com os limites desse tipo; percentuais usam Double. Nomes têm comparação textual sensível a maiúsculas e acentos. Não há persistência ou interface gráfica.

## Validação

As três camadas foram compiladas com GHC 9.10.3 no Windows, utilizando `-Wall` e `-Werror=incomplete-patterns`.

Os 100 testes automatizados foram aprovados, sendo 25 referentes à Camada 1, 34 à Camada 2 e 41 à Camada 3.

A classificação final e a classificação após a terceira rodada foram conferidas com os resultados das partidas do campeonato. Também foram verificados os critérios de desempate, as estatísticas e o comportamento das funções com listas vazias.

## Camada 3

**Erro.** Cinco construtores, cada um com a posição do problema: `CamposInvalidos`, `NumeroInvalido`, `PlacarNegativo` e `MesmoTime` carregam o número da linha; `TimeRepetidoNaRodada` carrega a rodada e o time. `mensagemErro` converte cada um em texto sem acentos (evita problemas de codificação no terminal do Windows).

**Numeração das linhas.** O número conta todas as linhas do texto, inclusive as em branco e os comentários (`#`), para coincidir com o que o usuário vê no editor. Linhas ignoradas são removidas só depois de numeradas.

**lerPartida** usa a notação `do` em `Either`; o primeiro `Left` interrompe a leitura. Precedência dos erros dentro de uma linha: campos, números, placar negativo, mesmo time. Espaços ao redor dos campos e `\r` (arquivos do Windows) são ignorados. Nome de time vazio é `CamposInvalidos`.

**Conversão numérica.** Usa `readMaybe`, mas antes confere que o campo só tem dígitos (com `-` opcional), porque `readMaybe` aceita formas como `"0x10"`. Rodada menor que 1 é `NumeroInvalido`. Placar negativo é `PlacarNegativo`, não `NumeroInvalido`.

**lerCampeonato** usa `traverse` sobre as linhas e depois verifica rodadas. Para no primeiro erro. Texto sem partidas (vazio ou só comentários) devolve `Right []`, e a classificação vazia é tratada com `Nothing`/tabela só com cabeçalho no `main`.

**todosOsErros** junta os erros de cada linha com `lefts` e, sobre as partidas válidas (`rights`), os erros de rodada repetida (um por par rodada/time). O primeiro elemento coincide com o `Left` de `lerCampeonato`. Um erro de rodada só aparece entre as partidas que passaram na leitura: se uma das duas linhas conflitantes for inválida, o conflito não é reportado.

**tabelaFormatada** alinha as colunas pelo maior nome de time (calculado com `foldr`, que é total) e mostra o saldo com sinal. A posição é sequencial (1, 2, 3...), mesmo quando há empate em todos os critérios numéricos; o desempate final é pelo nome.

**Núcleo puro.** Todas as funções, inclusive o relatório do `main`, são puras; `main = putStr relatorio` é o único IO. Os dados estão em `Dados.hs`, sem `getLine`, para funcionar no playground.

## Limitações da Camada 3

- Só aceita o separador `;` e exatamente 5 campos; nomes de time com `;` não são possíveis.
- Números são `Int` sem sinal `+` e sem espaços internos.
- Times diferem por maiúsculas/acentos ("Parana" e "Paraná" seriam times distintos).
- Não detecta o mesmo confronto repetido em rodadas diferentes (válido em turno e returno).
- Não há leitura de arquivo; para usar `readFile` bastaria trocar a origem do `String` no `main`.
