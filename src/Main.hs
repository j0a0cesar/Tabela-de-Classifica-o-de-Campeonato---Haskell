module Main (main) where

import Data.Maybe (listToMaybe)
import Classificacao
import Dados (dadosCampeonato, dadosComErros)
import Leitura
import Tipos

-- Unico ponto com IO: tudo o que e impresso vem de funcoes puras
main :: IO ()
main = putStr relatorio

relatorio :: String
relatorio = unlines
    [ titulo "Campeonato valido (lido do texto em Dados.hs)"
    , either mensagemErro demonstracao (lerCampeonato dadosCampeonato)
    , titulo "Entrada com erros"
    , relatorioErros dadosComErros
    , titulo "Campeonato vazio"
    , either mensagemErro demonstracao (lerCampeonato "# nenhuma partida\n")
    ]

titulo :: String -> String
titulo texto = "=== " ++ texto ++ " ==="

-- Camada 2 aplicada a partidas ja validadas
demonstracao :: [Partida] -> String
demonstracao partidas = unlines (concat
    [ ["Tabela final:"]
    , lines (tabelaFormatada (classificacao partidas))
    , ["", "Tabela apos a rodada 3:"]
    , lines (tabelaFormatada (classificacao (ateRodada 3 partidas)))
    , ["", "Estatisticas:"]
    , ["  Lider: " ++ maybe "sem lider" descreverLider (listToMaybe (classificacao partidas))]
    , ["  Maior goleada: " ++ maybe "sem partidas" descreverPartida (maiorGoleada partidas)]
    , ["  Media de gols por partida: " ++ maybe "sem partidas" duasCasas (mediaGols partidas)]
    ])

descreverLider :: Linha -> String
descreverLider l = timeLinha l ++ " com " ++ show (pontosLinha l) ++ " pontos ("
    ++ duasCasas (aproveitamento l) ++ "% de aproveitamento)"

descreverPartida :: Partida -> String
descreverPartida p = mandante p ++ " " ++ show (golsMandante p) ++ " x "
    ++ show (golsVisitante p) ++ " " ++ visitante p ++ " (rodada " ++ show (rodada p) ++ ")"

duasCasas :: Double -> String
duasCasas x = show (fromIntegral (round (x * 100) :: Int) / 100 :: Double)

relatorioErros :: String -> String
relatorioErros texto = unlines
    (  [ "lerCampeonato (para no primeiro erro):"
       , "  " ++ either mensagemErro (const "sem erros") (lerCampeonato texto)
       , "todosOsErros (" ++ show (length erros) ++ " erros):"
       ]
    ++ map (("  - " ++) . mensagemErro) erros )
  where
    erros = todosOsErros texto
