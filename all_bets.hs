module Main where

import LotoMania

main :: IO (Int)
main = do
	putStr (print_bets all_bets)
	return 0

