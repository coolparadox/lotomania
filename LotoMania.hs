module LotoMania where

import AnComb
import Entropy

all_bets :: [[Integer]]
all_bets = combination 50 [1..100]

rank_a_bet :: [Integer] -> (Integer, [Integer])
rank_a_bet bet = (rank_value, bet) where
	rank_value = entropy_rank (1, 100) bet

all_bets_ranked :: [(Integer, [Integer])]
all_bets_ranked = map rank_a_bet all_bets

print_ranked_bet :: (Integer, [Integer]) -> String
print_ranked_bet (rank_value, bet) = (show rank_value) ++ ":" ++ (show bet) ++ "\n"

print_all_bets :: String
print_all_bets = concat (map print_ranked_bet all_bets_ranked)

