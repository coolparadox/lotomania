module Main where

import System
import Numeric

import CombAnal

main :: IO (Int)
main = do
	sample_size:values <- getArgs
	putStr (process sample_size values)
	return 0

process :: String -> [String] -> String
process sample_size_str values = answer where
	answer = print_combinations set
	set = combine sample_size values
	(sample_size, ""):[] = readDec sample_size_str

print_combinations :: [[String]] -> String
print_combinations combs = concat (map print_combination combs)

print_combination :: [String] -> String
print_combination (x:others) = x ++ " " ++ (print_combination others)
print_combination [] = "\n"

