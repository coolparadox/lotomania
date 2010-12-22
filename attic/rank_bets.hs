module Main where

import System
import Numeric

import Entropy

main :: IO (Int)
main = do
	set_size:other_args <- getArgs
	bets <- getContents
	putStr (process_ranks set_size bets)
	return 0

process_ranks :: String -> String -> String
process_ranks set_size_str bets_str = answer where
	answer = concat (map print_ranked_bet ranked_bets)
	ranked_bets = map (rank_bet set_size) bets
	bets = map read_bet (lines bets_str)
	(set_size, ""):[] = readDec set_size_str

read_bet :: String -> [Integer]
read_bet bet_str = bet where
	(bet, ""):[] = readList bet_str_list
	bet_str_list = "[" ++ bet_str ++ "]"

rank_bet :: Integer -> [Integer] -> (Integer, [Integer])
rank_bet set_size bet = (rank_value, bet) where
	rank_value = entropy_rank (1, set_size) bet

print_ranked_bet :: (Integer, [Integer]) -> String
print_ranked_bet (rank_value, bet) = (show rank_value) ++ ":" ++ (print_combination bet)

print_combination :: (Show a) => [a] -> String
print_combination (x:(others@(_:_))) = (show x) ++ "," ++ (print_combination others)
print_combination (x:others) = (show x) ++ (print_combination others)
print_combination [] = "\n"

