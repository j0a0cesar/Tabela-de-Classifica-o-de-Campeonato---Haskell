module Main where

import Data.List (nub, sort)
import Dados (dadosCampeonato, partidasExemplo)
import Tipos

-- Compara o resultado obtido com o esperado.
testar :: (Eq a, Show a) => String -> a -> a -> IO Bool
testar nome obtido esperado = do
    if obtido == esperado
        then putStrLn ("OK      " ++ nome)
        else putStrLn ("FALHOU  " ++ nome ++ ": obtido " ++ show obtido
                       ++ "; esperado " ++ show esperado)
    pure (obtido == esperado)

semRepeticao :: Eq a => [a] -> Bool
semRepeticao xs = length xs == length (nub xs)

main :: IO ()
main = do
    let vitoriaCasa = Partida 1 "A" 2 1 "B"
        vitoriaFora = Partida 2 "A" 0 3 "B"
        empate = Partida 3 "A" 0 0 "B"
        partidas = partidasExemplo
        equipes = ["Athletico", "Coritiba", "Londrina", "Maringa", "Operario", "Parana"]
        rodadas = [1 .. 5]
        participacoes = concatMap (\p -> [(rodada p, mandante p),
                                          (rodada p, visitante p)]) partidas
        confrontos = map (\p -> sort [mandante p, visitante p]) partidas
        jogosPorRodada = map (\r -> length (filter ((== r) . rodada) partidas)) rodadas
        textoEsperado =
            [ "# rodada;mandante;golsMandante;golsVisitante;visitante"
            , "1;Coritiba;0;0;Maringa"
            , "1;Athletico;4;0;Londrina"
            , "1;Parana;1;0;Operario"
            , "2;Coritiba;2;1;Londrina"
            , "2;Maringa;1;2;Operario"
            , "2;Athletico;1;1;Parana"
            , "3;Coritiba;1;3;Operario"
            , "3;Londrina;1;1;Parana"
            , "3;Maringa;0;2;Athletico"
            , "4;Coritiba;3;2;Parana"
            , "4;Operario;0;0;Athletico"
            , "4;Londrina;2;0;Maringa"
            , "5;Coritiba;0;2;Athletico"
            , "5;Parana;1;0;Maringa"
            , "5;Operario;2;2;Londrina"
            ]
    resultados <- sequence
        [ testar "participou: mandante" (participou "A" vitoriaCasa) True
        , testar "participou: visitante" (participou "B" vitoriaCasa) True
        , testar "participou: terceiro time" (participou "C" vitoriaCasa) False
        , testar "resultado: vitoria mandante" (resultadoPara "A" vitoriaCasa) (Just Vitoria)
        , testar "resultado: derrota visitante" (resultadoPara "B" vitoriaCasa) (Just Derrota)
        , testar "resultado: derrota mandante" (resultadoPara "A" vitoriaFora) (Just Derrota)
        , testar "resultado: vitoria visitante" (resultadoPara "B" vitoriaFora) (Just Vitoria)
        , testar "resultado: empate mandante" (resultadoPara "A" empate) (Just Empate)
        , testar "resultado: empate visitante" (resultadoPara "B" empate) (Just Empate)
        , testar "resultado: terceiro time" (resultadoPara "C" vitoriaCasa) Nothing
        , testar "times: repeticao" (times [vitoriaCasa, vitoriaFora, empate]) ["A", "B"]
        , testar "times: ordem alfabetica" (times [Partida 1 "Z" 1 0 "A"]) ["A", "Z"]
        , testar "times: lista vazia" (times []) []
        , testar "campeonato: equipes" (times partidas) equipes
        , testar "campeonato: rodadas" (sort (nub (map rodada partidas))) rodadas
        , testar "campeonato: total de partidas" (length partidas) 15
        , testar "campeonato: tres jogos por rodada" jogosPorRodada [3, 3, 3, 3, 3]
        , testar "campeonato: sem time repetido na rodada" (semRepeticao participacoes) True
        , testar "campeonato: turno sem confrontos repetidos" (semRepeticao confrontos) True
        , testar "campeonato: sem jogo contra si" (all (\p -> mandante p /= visitante p) partidas) True
        , testar "campeonato: placares nao negativos" (all (\p -> golsMandante p >= 0 && golsVisitante p >= 0) partidas) True
        , testar "campeonato: dois empates em 0 x 0" (length (filter (\p -> golsMandante p == 0 && golsVisitante p == 0) partidas)) 2
        , testar "campeonato: goleada de quatro gols" (any (\p -> abs (golsMandante p - golsVisitante p) == 4) partidas) True
        , testar "campeonato: total de gols" (sum (map (\p -> golsMandante p + golsVisitante p) partidas)) 35
        , testar "campeonato: formato textual" (lines dadosCampeonato) textoEsperado
        ]
    let aprovados = length (filter id resultados)
    putStrLn ("\nTestes aprovados: " ++ show aprovados ++ "/" ++ show (length resultados))
    if and resultados
        then pure ()
        else fail "Existem testes com falha."
