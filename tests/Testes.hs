module Main where

import Data.List (isInfixOf, nub, sort)
import Classificacao
import Dados (dadosCampeonato, dadosComErros, partidasExemplo)
import Leitura
import Tipos

-- Compara o resultado obtido com o esperado.
testar :: (Eq a, Show a) => String -> a -> a -> IO Bool
testar nome obtido esperado = do
    if obtido == esperado
        then putStrLn ("OK      " ++ nome)
        else putStrLn ("FALHOU  " ++ nome ++ ": obtido " ++ show obtido
                       ++ "; esperado " ++ show esperado)
    pure (obtido == esperado)

listToMaybeErro :: [Erro] -> Maybe Erro
listToMaybeErro []      = Nothing
listToMaybeErro (e : _) = Just e

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
    let tabelaFinal =
            [ Linha "Athletico" 5 3 2 0 9 1
            , Linha "Operario" 5 2 2 1 7 5
            , Linha "Parana" 5 2 2 1 6 5
            , Linha "Coritiba" 5 2 1 2 6 8
            , Linha "Londrina" 5 1 2 2 6 9
            , Linha "Maringa" 5 0 1 4 1 7
            ]
        tabelaRodada3 =
            [ Linha "Athletico" 3 2 1 0 7 1
            , Linha "Operario" 3 2 0 1 5 3
            , Linha "Parana" 3 1 2 0 3 2
            , Linha "Coritiba" 3 1 1 1 3 4
            , Linha "Maringa" 3 0 1 2 1 4
            , Linha "Londrina" 3 0 1 2 2 7
            ]
        linhaMista = Linha "A" 3 1 1 1 2 4
        linhaVazia = Linha "Z" 0 0 0 0 0 0
        goleada = Partida 1 "Athletico" 4 0 "Londrina"
        empateGoleada = Partida 2 "C" 0 4 "D"
        porPontos = [Partida 1 "Z" 1 0 "A"]
        porVitorias = [Partida 1 "Z" 1 0 "B", Partida 1 "A" 4 4 "C"
                      , Partida 2 "A" 4 4 "D", Partida 3 "A" 4 4 "E"]
        porGols = [Partida 1 "A" 1 0 "B", Partida 1 "Z" 3 2 "C"]
        porNome = [Partida 1 "Z" 1 0 "B", Partida 1 "A" 1 0 "C"]
        ordemAZ = map timeLinha . filter (\l -> timeLinha l `elem` ["A", "Z"]) . classificacao
        ordemOP = filter (`elem` ["Operario", "Parana"]) (map timeLinha (classificacao partidas))
    resultadosM2 <- sequence
        [ testar "pontos: vitoria" (pontos Vitoria) 3
        , testar "pontos: empate" (pontos Empate) 1
        , testar "pontos: derrota" (pontos Derrota) 0
        , testar "linha: mandante" (linhaDoTime [vitoriaCasa] "A") (Linha "A" 1 1 0 0 2 1)
        , testar "linha: visitante" (linhaDoTime [vitoriaCasa] "B") (Linha "B" 1 0 0 1 1 2)
        , testar "linha: ignora outros times" (linhaDoTime [vitoriaCasa, Partida 2 "C" 5 0 "D"] "A") (Linha "A" 1 1 0 0 2 1)
        , testar "linha: lista vazia" (linhaDoTime [] "Z") linhaVazia
        , testar "linha: time ausente" (linhaDoTime partidas "Z") linhaVazia
        , testar "linha: acumula resultados" (linhaDoTime [vitoriaCasa, vitoriaFora, empate] "A") linhaMista
        , testar "pontosLinha" (pontosLinha linhaMista) 4
        , testar "saldo negativo" (saldo linhaMista) (-2)
        , testar "aproveitamento fracionario" (abs (aproveitamento linhaMista - 400 / 9) < 1e-9) True
        , testar "aproveitamento sem jogos" (aproveitamento linhaVazia) 0
        , testar "aproveitamento 100%" (aproveitamento (Linha "A" 2 2 0 0 2 0)) 100
        , testar "classificacao final completa" (classificacao partidas) tabelaFinal
        , testar "classificacao vazia" (classificacao []) []
        , testar "desempate: pontos" (ordemAZ porPontos) ["Z", "A"]
        , testar "desempate: vitorias" (ordemAZ porVitorias) ["Z", "A"]
        , testar "desempate: saldo" ordemOP ["Operario", "Parana"]
        , testar "desempate: gols pro" (ordemAZ porGols) ["Z", "A"]
        , testar "desempate: nome" (ordemAZ porNome) ["A", "Z"]
        , testar "ateRodada: nove jogos" (length (ateRodada 3 partidas)) 9
        , testar "ateRodada: limite zero" (ateRodada 0 partidas) []
        , testar "ateRodada: limite inclusivo" (ateRodada 3 partidas) (take 9 partidas)
        , testar "classificacao terceira rodada" (classificacao (ateRodada 3 partidas)) tabelaRodada3
        , testar "classificacao parcial diferente" (classificacao (ateRodada 3 partidas) /= classificacao partidas) True
        , testar "maiorGoleada: vazia" (maiorGoleada []) Nothing
        , testar "maiorGoleada: campeonato" (maiorGoleada partidas) (Just goleada)
        , testar "maiorGoleada: empate mantem primeira" (maiorGoleada [goleada, empateGoleada]) (Just goleada)
        , testar "maiorGoleada: vitoria visitante" (maiorGoleada [vitoriaCasa, empateGoleada]) (Just empateGoleada)
        , testar "maiorGoleada: so empate" (maiorGoleada [empate]) (Just empate)
        , testar "mediaGols: vazia" (mediaGols []) Nothing
        , testar "mediaGols: campeonato" (maybe False (\m -> abs (m - 35 / 15) < 1e-9) (mediaGols partidas)) True
        , testar "mediaGols: empate sem gols" (mediaGols [empate]) (Just 0)
        ]
    let valida = "1;A;1;0;B\n1;C;2;2;D\n2;A;0;0;C\n"
        tabelaMini = [Linha "Athletico" 2 1 1 0 3 1, Linha "Coritiba" 2 0 1 1 1 2]
        tabelaMiniTexto =
            [ "Pos Time      Pts  J  V  E  D  SG"
            , "  1 Athletico   4  2  1  1  0  +2"
            , "  2 Coritiba    1  2  0  1  1  -1"
            ]
        tabelaVaziaTexto = ["Pos Time Pts  J  V  E  D  SG"]
        primeiroErro = either Just (const Nothing) . lerCampeonato
        mensagens = map mensagemErro (todosOsErros dadosComErros)
    resultadosM3 <- sequence
        [ testar "separar: campos" (separar ';' "a;b;c") ["a", "b", "c"]
        , testar "separar: campos vazios" (separar ';' "a;;b;") ["a", "", "b", ""]
        , testar "separar: texto vazio" (separar ';' "") [""]
        , testar "lerPartida: linha valida" (lerPartida 1 "1;Coritiba;2;1;Athletico") (Right (Partida 1 "Coritiba" 2 1 "Athletico"))
        , testar "lerPartida: ignora espacos e CR" (lerPartida 1 " 1 ; A ; 2 ; 1 ; B \r") (Right (Partida 1 "A" 2 1 "B"))
        , testar "erro CamposInvalidos: poucos campos" (lerPartida 4 "1;A;1;1") (Left (CamposInvalidos 4 "1;A;1;1"))
        , testar "erro CamposInvalidos: campos demais" (lerPartida 2 "1;A;1;1;B;x") (Left (CamposInvalidos 2 "1;A;1;1;B;x"))
        , testar "erro CamposInvalidos: time vazio" (lerPartida 2 "1;;1;1;B") (Left (CamposInvalidos 2 "1;;1;1;B"))
        , testar "erro CamposInvalidos: linha vazia" (lerPartida 9 "") (Left (CamposInvalidos 9 ""))
        , testar "erro NumeroInvalido: placar dois" (lerPartida 3 "1;A;dois;0;B") (Left (NumeroInvalido 3 "dois"))
        , testar "erro NumeroInvalido: placar 2a" (lerPartida 3 "1;A;0;2a;B") (Left (NumeroInvalido 3 "2a"))
        , testar "erro NumeroInvalido: decimal" (lerPartida 3 "1;A;2.5;0;B") (Left (NumeroInvalido 3 "2.5"))
        , testar "erro NumeroInvalido: hexadecimal" (lerPartida 3 "1;A;0x10;0;B") (Left (NumeroInvalido 3 "0x10"))
        , testar "erro NumeroInvalido: placar vazio" (lerPartida 3 "1;A;;0;B") (Left (NumeroInvalido 3 ""))
        , testar "erro NumeroInvalido: rodada texto" (lerPartida 5 "x;A;1;0;B") (Left (NumeroInvalido 5 "x"))
        , testar "erro NumeroInvalido: rodada zero" (lerPartida 5 "0;A;1;0;B") (Left (NumeroInvalido 5 "0"))
        , testar "erro PlacarNegativo: mandante" (lerPartida 6 "1;A;-1;0;B") (Left (PlacarNegativo 6))
        , testar "erro PlacarNegativo: visitante" (lerPartida 6 "1;A;1;-3;B") (Left (PlacarNegativo 6))
        , testar "erro MesmoTime" (lerPartida 7 "1;A;1;1;A") (Left (MesmoTime 7 "A"))
        , testar "precedencia: numero antes de mesmo time" (lerPartida 7 "1;A;x;1;A") (Left (NumeroInvalido 7 "x"))
        , testar "lerCampeonato: entrada valida" (lerCampeonato valida) (Right [Partida 1 "A" 1 0 "B", Partida 1 "C" 2 2 "D", Partida 2 "A" 0 0 "C"])
        , testar "lerCampeonato: campeonato de teste" (lerCampeonato dadosCampeonato) (Right partidasExemplo)
        , testar "lerCampeonato: texto vazio" (lerCampeonato "") (Right [])
        , testar "lerCampeonato: so comentarios e brancos" (lerCampeonato "# a\n\n   \n# b\n") (Right [])
        , testar "lerCampeonato: ignora comentarios e brancos" (lerCampeonato ("# x\n\n" ++ valida)) (lerCampeonato valida)
        , testar "erro TimeRepetidoNaRodada: mandante" (lerCampeonato "1;A;1;0;B\n1;A;2;0;C") (Left (TimeRepetidoNaRodada 1 "A"))
        , testar "erro TimeRepetidoNaRodada: visitante e mandante" (lerCampeonato "2;A;1;0;B\n2;C;2;0;A") (Left (TimeRepetidoNaRodada 2 "A"))
        , testar "mesmo time em rodadas diferentes e valido" (fmap length (lerCampeonato "1;A;1;0;B\n2;A;2;0;B")) (Right 2)
        , testar "numero da linha conta brancos e comentarios" (lerCampeonato "# c\n\n1;A;x;0;B") (Left (NumeroInvalido 3 "x"))
        , testar "lerCampeonato: para no primeiro erro" (primeiroErro "1;A;x;0;B\n1;C;-1;0;D") (Just (NumeroInvalido 1 "x"))
        , testar "todosOsErros: texto com 5 erros" (todosOsErros dadosComErros)
            [ NumeroInvalido 3 "dois", CamposInvalidos 4 "2;Maringa;1;1", PlacarNegativo 6
            , MesmoTime 7 "Coritiba", TimeRepetidoNaRodada 3 "Athletico" ]
        , testar "todosOsErros: entrada valida" (todosOsErros dadosCampeonato) []
        , testar "todosOsErros: texto vazio" (todosOsErros "") []
        , testar "todosOsErros: primeiro coincide com lerCampeonato" (listToMaybeErro (todosOsErros dadosComErros)) (primeiroErro dadosComErros)
        , testar "mensagemErro: indica a linha" (any ("linha 3" `isInfixOf`) (take 1 mensagens)) True
        , testar "mensagemErro: indica a rodada" (any ("rodada 3" `isInfixOf`) (drop 4 mensagens)) True
        , testar "tabelaFormatada: linhas" (lines (tabelaFormatada tabelaMini)) tabelaMiniTexto
        , testar "tabelaFormatada: tabela vazia" (lines (tabelaFormatada [])) tabelaVaziaTexto
        , testar "tabelaFormatada: uma linha por time mais cabecalho" (length (lines (tabelaFormatada (classificacao partidas)))) 7
        , testar "tabelaFormatada: saldo positivo tem sinal" ("+8" `isInfixOf` tabelaFormatada tabelaFinal) True
        , testar "fluxo completo: texto -> tabela final" (fmap classificacao (lerCampeonato dadosCampeonato)) (Right tabelaFinal)
        ]
    let todos = resultados ++ resultadosM2 ++ resultadosM3
        aprovados = length (filter id todos)
    putStrLn ("\nTestes aprovados: " ++ show aprovados ++ "/" ++ show (length todos))
    if and todos
        then pure ()
        else fail "Existem testes com falha."
