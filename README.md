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

Estrutura inicial configurada. As funcionalidades das três camadas serão implementadas progressivamente.