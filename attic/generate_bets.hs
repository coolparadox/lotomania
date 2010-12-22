module Main where

import System
import Numeric

import Natural
import BetGenerator

main :: IO (Int)
main = do
	set_size:bet_size:seed_min:seed_max:[] <- getArgs
	putStr (process_work set_size bet_size seed_min seed_max)
	return 0

process_work :: String -> String -> String -> String -> String
process_work set_size_str bet_size_str seed_min_str seed_max_str = answer where
	answer = print_combinations bets
	bets = generate_bets set_size bet_size seed_min seed_max
	(set_size, ""):[] = readDec set_size_str
	(bet_size, ""):[] = readDec bet_size_str
	(seed_min, ""):[] = readDec seed_min_str
	(seed_max, ""):[] = readDec seed_max_str

generate_bets :: Natural -> Natural -> Natural -> Natural -> [[Natural]]
generate_bets set_size bet_size seed_min seed_max = filter bet_is_sorted bets where
	bets = undiff_lists_deep (1, set_size) (bet_size - 1) seeds
	seeds = map (:[]) [seed_min..seed_max]

print_combinations :: (Show a) => [[a]] -> String
print_combinations combs = concat (map print_combination combs)

print_combination :: (Show a) => [a] -> String
print_combination (x:(others@(_:_))) = (show x) ++ "," ++ (print_combination others)
print_combination (x:others) = (show x) ++ (print_combination others)
print_combination [] = "\n"

