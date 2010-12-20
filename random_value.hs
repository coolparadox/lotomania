module Main where

import System
import Numeric
import Random

main :: IO (Int)
main = do
	min_str:max_str:[] <- getArgs
	answer <- getStdRandom $ randomR (parse_inputs min_str max_str)
	putStrLn (show answer)
	return 0

parse_inputs :: String -> String -> (Integer, Integer)
parse_inputs min_str max_str = (min, max) where
	(min, ""):[] = readDec min_str
	(max, ""):[] = readDec max_str

