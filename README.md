# Tabela de Classificação de Campeonato — Haskell

Projeto desenvolvido para a disciplina de Programação Lógica e Funcional.

## Objetivo

Implementar um sistema de classificação de campeonato de futebol utilizando os fundamentos da programação funcional em Haskell.

O sistema será responsável por processar resultados de partidas, calcular a classificação dos times, apresentar estatísticas do campeonato e validar os dados de entrada.

## Tecnologias

- Haskell
- GHC 9.10.3
- GHCup
- Visual Studio Code
- Git e GitHub

## Organização do projeto

O desenvolvimento está dividido em três camadas:

- Camada 1: tipos e dados do campeonato.
- Camada 2: classificação e estatísticas.
- Camada 3: leitura, validação e apresentação dos resultados.

## Ambiente de desenvolvimento

O projeto utiliza o GHC instalado localmente e a biblioteca padrão do Haskell.

## Compilação

No PowerShell, a partir da raiz do repositório:

```powershell
New-Item -ItemType Directory -Force -Path .build | Out-Null
ghc -Wall -Wincomplete-patterns -isrc -outputdir .build -o .build\tabela.exe src\Main.hs
```

## Execução

```powershell
.\.build\tabela.exe
```

## Estrutura

```
src/Tipos.hs          Camada 1: tipos e consultas basicas
src/Classificacao.hs  Camada 2: classificacao com funcoes de ordem superior
src/Leitura.hs        Camada 3: leitura, validacao (Maybe/Either) e formatacao
src/Dados.hs          campeonato de teste e entrada com erros, como String
src/Main.hs           demonstracao das tres camadas
tests/Testes.hs       testes com resultado esperado
docs/decisoes.md      decisoes de modelagem e limitacoes
```

## Estado do desenvolvimento

As tres camadas estao implementadas. O `main` e o unico ponto com IO e demonstra, em sequencia: a tabela final, a tabela apos a rodada 3, as estatisticas (lider, maior goleada, media de gols), o tratamento de uma entrada com erros (`lerCampeonato` e `todosOsErros`) e o campeonato vazio.

Os dados ficam no proprio codigo (`Dados.hs`), sem `getLine`, para funcionar tambem no playground.

## Testes

Os testes das três camadas estão disponíveis em `tests/Testes.hs`.

A bateria contém 100 verificações: 25 da Camada 1, 34 da Camada 2 e 41 da Camada 3 (um teste para cada construtor de `Erro`, `todosOsErros`, `tabelaFormatada` e casos de borda).

Para compilar os testes no PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path .build\m2-tests | Out-Null

ghc --make -Wall -Werror=incomplete-patterns -isrc -outputdir .build\m2-tests -o .build\m2-tests\testes.exe tests\Testes.hs
```

Após uma compilação bem-sucedida, execute:

```powershell
.\.build\m2-tests\testes.exe
```