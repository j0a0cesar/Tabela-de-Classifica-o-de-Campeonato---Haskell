module Leitura
    ( Erro(..)
    , separar
    , lerPartida
    , lerCampeonato
    , todosOsErros
    , tabelaFormatada
    , mensagemErro
    ) where

import Data.Char (isDigit, isSpace)
import Data.Either (lefts, rights)
import Data.List (dropWhileEnd, isPrefixOf, nub)
import Text.Read (readMaybe)
import Classificacao (pontosLinha, saldo)
import Tipos

-- Erros
-- Cada construtor tem a posicao do problema: o numero da linha no texto, contando linhas em branco e comentarios, ou a rodada
data Erro
    = CamposInvalidos Int String        -- linha, texto da linha
    | NumeroInvalido Int String         -- linha, campo que nao e numero valido
    | PlacarNegativo Int                -- linha
    | MesmoTime Int Time                -- linha, time que joga contra si mesmo
    | TimeRepetidoNaRodada Int Time     -- rodada, time escalado duas vezes
    deriving (Show, Eq)

mensagemErro :: Erro -> String
mensagemErro (CamposInvalidos n linha) =
    "linha " ++ show n ++ ": esperados 5 campos separados por ';' e nomes de time nao vazios, mas veio \""
        ++ linha ++ "\""
mensagemErro (NumeroInvalido n campo) =
    "linha " ++ show n ++ ": \"" ++ campo ++ "\" nao e um numero inteiro valido (a rodada deve ser >= 1)"
mensagemErro (PlacarNegativo n) =
    "linha " ++ show n ++ ": o placar nao pode ter gols negativos"
mensagemErro (MesmoTime n time) =
    "linha " ++ show n ++ ": " ++ time ++ " nao pode jogar contra si mesmo"
mensagemErro (TimeRepetidoNaRodada r time) =
    "rodada " ++ show r ++ ": " ++ time ++ " joga mais de uma vez"

-- Leitura de uma linha
aparar :: String -> String
aparar = dropWhileEnd isSpace . dropWhile isSpace

-- Quebra o texto em cada ocorrencia do separador e mantem campos vazios
separar :: Char -> String -> [String]
separar sep texto = case break (== sep) texto of
    (campo, [])        -> [campo]
    (campo, _ : resto) -> campo : separar sep resto

-- readMaybe aceita formas como "0x10" por isso o campo e checado antes
inteiro :: String -> Maybe Int
inteiro campo
    | ehInteiro campo = readMaybe campo
    | otherwise       = Nothing
  where
    ehInteiro ('-' : ds) = digitos ds
    ehInteiro ds         = digitos ds
    digitos ds           = not (null ds) && all isDigit ds

lerNumero :: Int -> String -> Either Erro Int
lerNumero n campo = maybe (Left (NumeroInvalido n campo)) Right (inteiro campo)

exigir :: Bool -> Erro -> Either Erro ()
exigir True  _    = Right ()
exigir False erro = Left erro

camposDaLinha :: Int -> String -> Either Erro (String, String, String, String, String)
camposDaLinha n linha = case map aparar (separar ';' linha) of
    [r, m, gm, gv, v] | not (null m) && not (null v) -> Right (r, m, gm, gv, v)
    _                                                -> Left (CamposInvalidos n linha)

-- Ordem das verificacoes e precedencia dos erros: campos, numeros, placar negativo, mesmo time
lerPartida :: Int -> String -> Either Erro Partida
lerPartida n linha = do
    (r, m, gm, gv, v) <- camposDaLinha n linha
    rod   <- lerNumero n r
    golsM <- lerNumero n gm
    golsV <- lerNumero n gv
    exigir (rod >= 1) (NumeroInvalido n r)
    exigir (golsM >= 0 && golsV >= 0) (PlacarNegativo n)
    exigir (m /= v) (MesmoTime n m)
    pure (Partida rod m golsM golsV v)

-- Leitura do campeonato

-- Pares (numero da linha, texto)
linhasUteis :: String -> [(Int, String)]
linhasUteis = filter (util . snd) . zip [1 ..] . lines
  where
    util l = let t = aparar l in not (null t) && not ("#" `isPrefixOf` t)

-- Times escalados mais de uma vez na mesma rodada (um erro por par, sem repetir)
repeticoes :: [Partida] -> [Erro]
repeticoes partidas = map (uncurry TimeRepetidoNaRodada) (nub repetidos)
  where
    escalacoes = concatMap (\p -> [(rodada p, mandante p), (rodada p, visitante p)]) partidas
    repetidos  = [ e | (i, e) <- zip [0 :: Int ..] escalacoes, e `elem` take i escalacoes ]

verificarRodadas :: [Partida] -> Either Erro ()
verificarRodadas partidas = case repeticoes partidas of
    []       -> Right ()
    erro : _ -> Left erro

-- Para no primeiro erro. Texto sem partidas devolve Right []
lerCampeonato :: String -> Either Erro [Partida]
lerCampeonato texto = do
    partidas <- traverse (uncurry lerPartida) (linhasUteis texto)
    verificarRodadas partidas
    pure partidas

-- Todos os erros: primeiro os de cada linha depois os de rodada
-- O primeiro elemento coincide com o Left de lerCampeonato
todosOsErros :: String -> [Erro]
todosOsErros texto = lefts resultados ++ repeticoes (rights resultados)
  where
    resultados = map (uncurry lerPartida) (linhasUteis texto)

-- Saída
alinharDireita :: Int -> String -> String
alinharDireita w s = replicate (w - length s) ' ' ++ s

alinharEsquerda :: Int -> String -> String
alinharEsquerda w s = s ++ replicate (w - length s) ' '

sinal :: Int -> String
sinal n
    | n > 0     = '+' : show n
    | otherwise = show n

-- Uma linha por time, mais o cabecalho
tabelaFormatada :: [Linha] -> String
tabelaFormatada linhas = unlines (formatar cabecalho : map (formatar . colunas) (zip [1 :: Int ..] linhas))
  where
    largura   = foldr (max . length . timeLinha) 4 linhas
    cabecalho = ["Pos", "Time", "Pts", "J", "V", "E", "D", "SG"]
    colunas (pos, l) =
        [ show pos, timeLinha l, show (pontosLinha l), show (jogos l)
        , show (vitorias l), show (empates l), show (derrotas l), sinal (saldo l) ]
    formatar [pos, nome, pts, j, v, e, d, sg] = unwords
        [ alinharDireita 3 pos, alinharEsquerda largura nome, alinharDireita 3 pts
        , alinharDireita 2 j, alinharDireita 2 v, alinharDireita 2 e
        , alinharDireita 2 d, alinharDireita 3 sg ]
    formatar outras = unwords outras
