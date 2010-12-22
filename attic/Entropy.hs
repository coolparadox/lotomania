module Entropy where

entropy_rank :: (Integer, Integer) -> [Integer] -> Integer
entropy_rank _ [] = 0
entropy_rank range sequence = rank_zero where
	ranged_sequence = range_sequence range sequence
	rank_zero = zero_count_rank ranged_sequence

range_sequence :: (Integer, Integer) -> [Integer] -> [Integer]
range_sequence (min, max) seq = [min] ++ seq ++ [max]

diff :: [Integer] -> [Integer]
diff [] = []
diff sequence = zipWith (-) (tail sequence) (sequence)

test :: String
test = concat (map test_entropy_rank test_data)

test_entropy_rank :: [Integer] -> String
test_entropy_rank seq = (show seq) ++ " = " ++ (show (entropy_rank (1,60) seq)) ++ "\n"

test_data :: [[Integer]]
test_data = [
	[1,2,3,4,5,6],
	[55,56,57,58,59,60],
	[1,2,3,58,59,60],
	[10,20,30,40,50,60],
	[1,56,57,58,59,60],
	[1,2,3,4,5,60],
	[1,2,4,5,7,8],
	[1,2,4,5,7,60],
	[1,2,5,7,9,10],
	[1,2,5,7,9,60],
	[22,23,24,25,26,27],
	[9,12,19,22,35,37],
	[4,28,30,31,35,54]
	]

unsign :: [Integer] -> [Integer]
unsign = map abs

count_zeros :: [Integer] -> Integer
count_zeros seq = toInteger (length (filter (==0) seq))

zero_count_deep :: [Integer] -> Integer
zero_count_deep [] = 0
zero_count_deep x = (count_zeros x) + (zero_count_deep (unsign (diff x)))

zero_count_rank :: [Integer] -> Integer
zero_count_rank x = (addorial (toInteger (length x) - 2)) - (zero_count_deep x)

addorial :: Integer -> Integer
addorial 0 = 0
addorial n 
	| n > 0 = n + (addorial (n-1))
	| otherwise = error "negative addorial."

