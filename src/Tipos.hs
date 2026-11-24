module Tipos
    ( Time
    , Resultado(..)
    , Partida(..)
    , Linha(..)
    , participou
    , resultadoPara
    , times
    ) where

import Data.List (nub, sort)

type Time = String

data Resultado = Vitoria | Empate | Derrota
    deriving (Show, Eq)

data Partida = Partida
    { rodada :: Int
    , mandante :: Time
    , golsMandante :: Int
    , golsVisitante :: Int
    , visitante :: Time
    } deriving (Show, Eq)

data Linha = Linha
    { timeLinha :: Time
    , jogos :: Int
    , vitorias :: Int
    , empates :: Int
    , derrotas :: Int
    , golsPro :: Int
    , golsContra :: Int
    } deriving (Show, Eq)

participou :: Time -> Partida -> Bool
participou time partida =
    time == mandante partida || time == visitante partida

-- Retorna Nothing quando o time nao participa da partida.
resultadoPara :: Time -> Partida -> Maybe Resultado
resultadoPara time partida
    | time == mandante partida = Just (compararGols gm gv)
    | time == visitante partida = Just (compararGols gv gm)
    | otherwise = Nothing
  where
    gm = golsMandante partida
    gv = golsVisitante partida

compararGols :: Int -> Int -> Resultado
compararGols pro contra = case compare pro contra of
    GT -> Vitoria
    EQ -> Empate
    LT -> Derrota

-- Lista os times em ordem alfabetica, sem repeticoes.
times :: [Partida] -> [Time]
times = sort . nub . concatMap (\p -> [mandante p, visitante p])
