module Classificacao
    ( pontos
    , linhaDoTime
    , pontosLinha
    , saldo
    , aproveitamento
    , classificacao
    , ateRodada
    , maiorGoleada
    , mediaGols
    ) where

import Data.List (sortBy)
import Data.Ord (Down(..), comparing)
import Tipos

pontos :: Resultado -> Int
pontos Vitoria = 3
pontos Empate = 1
pontos Derrota = 0

linhaDoTime :: [Partida] -> Time -> Linha
linhaDoTime partidas time =
    foldl acumular (Linha time 0 0 0 0 0 0) (filter (participou time) partidas)

-- Acumula os gols na perspectiva do time da linha.
acumular :: Linha -> Partida -> Linha
acumular linha partida = case resultadoPara (timeLinha linha) partida of
    Nothing -> linha
    Just resultado -> linha
        { jogos = jogos linha + 1
        , vitorias = vitorias linha + if resultado == Vitoria then 1 else 0
        , empates = empates linha + if resultado == Empate then 1 else 0
        , derrotas = derrotas linha + if resultado == Derrota then 1 else 0
        , golsPro = golsPro linha + pro
        , golsContra = golsContra linha + contra
        }
  where
    (pro, contra)
        | timeLinha linha == mandante partida = (golsMandante partida, golsVisitante partida)
        | otherwise = (golsVisitante partida, golsMandante partida)

pontosLinha :: Linha -> Int
pontosLinha linha = vitorias linha * pontos Vitoria + empates linha * pontos Empate

saldo :: Linha -> Int
saldo linha = golsPro linha - golsContra linha

aproveitamento :: Linha -> Double
aproveitamento linha
    | jogos linha == 0 = 0
    | otherwise = 100 * fromIntegral (pontosLinha linha) / (3 * fromIntegral (jogos linha))

classificacao :: [Partida] -> [Linha]
classificacao partidas = ordenar (map (linhaDoTime partidas) (times partidas))
  where
    ordenar = sortBy (comparing (Down . pontosLinha)
                   <> comparing (Down . vitorias)
                   <> comparing (Down . saldo)
                   <> comparing (Down . golsPro)
                   <> comparing timeLinha)

ateRodada :: Int -> [Partida] -> [Partida]
ateRodada limite = filter ((<= limite) . rodada)

diferencaGols :: Partida -> Int
diferencaGols partida = abs (golsMandante partida - golsVisitante partida)

-- Mantem a primeira partida quando a diferenca de gols empata.
maiorGoleada :: [Partida] -> Maybe Partida
maiorGoleada = foldl escolher Nothing
  where
    escolher Nothing partida = Just partida
    escolher (Just melhor) partida
        | diferencaGols partida > diferencaGols melhor = Just partida
        | otherwise = Just melhor

mediaGols :: [Partida] -> Maybe Double
mediaGols [] = Nothing
mediaGols partidas = Just (fromIntegral total / fromIntegral (length partidas))
  where
    total = sum (map (\p -> golsMandante p + golsVisitante p) partidas)
