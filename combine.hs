module Main where

import System
import Numeric

import CombAnal

main :: IO (Int)
main = do
	set_size:sample_size:other_args <- getArgs
	putStr (process_combinations set_size sample_size)
	return 0

process_combinations :: String -> String -> String
process_combinations set_size_str sample_size_str = answer where
	answer = print_combinations set
	set = combine [1..set_size] sample_size
	(set_size, ""):[] = readDec set_size_str
	(sample_size, ""):[] = readDec sample_size_str

print_combinations :: (Show a) => [[a]] -> String
print_combinations combs = concat (map print_combination combs)

print_combination :: (Show a) => [a] -> String
print_combination (x:(others@(_:_))) = (show x) ++ "," ++ (print_combination others)
print_combination (x:others) = (show x) ++ (print_combination others)
print_combination [] = "\n"

