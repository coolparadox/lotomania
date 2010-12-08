module Main where

import LotoMania

main :: IO (Int)
main = do
	bets_str <- getContents
	putStr (process_ranks bets_str)
	return 0

