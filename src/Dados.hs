module Dados (partidasExemplo, dadosCampeonato) where

import Data.List (intercalate)
import Tipos (Partida(..))

-- Campeonato de seis times e cinco rodadas.
partidasExemplo :: [Partida]
partidasExemplo =
    [ Partida 1 "Coritiba" 0 0 "Maringa"
    , Partida 1 "Athletico" 4 0 "Londrina"
    , Partida 1 "Parana" 1 0 "Operario"
    , Partida 2 "Coritiba" 2 1 "Londrina"
    , Partida 2 "Maringa" 1 2 "Operario"
    , Partida 2 "Athletico" 1 1 "Parana"
    , Partida 3 "Coritiba" 1 3 "Operario"
    , Partida 3 "Londrina" 1 1 "Parana"
    , Partida 3 "Maringa" 0 2 "Athletico"
    , Partida 4 "Coritiba" 3 2 "Parana"
    , Partida 4 "Operario" 0 0 "Athletico"
    , Partida 4 "Londrina" 2 0 "Maringa"
    , Partida 5 "Coritiba" 0 2 "Athletico"
    , Partida 5 "Parana" 1 0 "Maringa"
    , Partida 5 "Operario" 2 2 "Londrina"
    ]

-- Gera a entrada textual a partir das partidas de exemplo.
dadosCampeonato :: String
dadosCampeonato = unlines
    ("# rodada;mandante;golsMandante;golsVisitante;visitante"
        : map formatarPartida partidasExemplo)

formatarPartida :: Partida -> String
formatarPartida p = intercalate ";"
    [ show (rodada p)
    , mandante p
    , show (golsMandante p)
    , show (golsVisitante p)
    , visitante p
    ]
