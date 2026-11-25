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

## Estado do desenvolvimento

As Camadas 1 e 2 estão implementadas, incluindo a modelagem dos dados, a classificação dos times, os critérios de desempate e as estatísticas do campeonato.

A Camada 3, responsável pela leitura, validação das entradas e apresentação dos resultados, ainda está em desenvolvimento.

O executável atual apresenta a mensagem de inicialização do projeto. A demonstração completa será integrada na Camada 3.

## Testes

Os testes das Camadas 1 e 2 estão disponíveis em `tests/Testes.hs`.

A bateria contém 59 verificações, incluindo os tipos e consultas básicas, a classificação, os desempates, as estatísticas e os casos de borda.

Para compilar os testes no PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path .build\m2-tests | Out-Null

ghc --make -Wall -Werror=incomplete-patterns -isrc -outputdir .build\m2-tests -o .build\m2-tests\testes.exe tests\Testes.hs
```

Após uma compilação bem-sucedida, execute:

```powershell
.\.build\m2-tests\testes.exe
```