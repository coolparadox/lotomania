module Main where

import System
import Numeric

import CombAnal

main :: IO (Int)
main = do
	sample_size:set_size:[] <- getArgs
	putStrLn (process sample_size set_size)
	return 0

process :: String -> String -> String
process sample_size_str set_size_str = answer where
	answer = show (combination sample_size set_size)
	(sample_size, ""):[] = readDec sample_size_str
	(set_size, ""):[] = readDec set_size_str

