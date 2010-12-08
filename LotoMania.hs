module LotoMania where

import AnComb
import Entropy

all_bets :: [[Integer]]
all_bets = combination 50 [1..100]

print_bets :: [[Integer]] -> String
print_bets bets = concat (map print_bet bets)

print_bet :: [Integer] -> String
print_bet bet = (show bet) ++ "\n"

process_ranks :: String -> String
process_ranks bets_str = answer where
	answer = concat (map print_ranked_bet ranked_bets)
	ranked_bets = map rank_a_bet bets
	bets = map read_bet (lines bets_str)

read_bet :: String -> [Integer]
read_bet bet_str = bet where
	(bet, _):_ = readList bet_str

rank_a_bet :: [Integer] -> (Integer, [Integer])
rank_a_bet bet = (rank_value, bet) where
	rank_value = entropy_rank (1, 100) bet

print_ranked_bet :: (Integer, [Integer]) -> String
print_ranked_bet (rank_value, bet) = (show rank_value) ++ ":" ++ (print_elements bet) ++ "\n"

print_elements :: [Integer] -> String
print_elements [] = ""
print_elements [x] = show x
print_elements (x:xs) = (show x) ++ "," ++ (print_elements xs)

