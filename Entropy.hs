module Entropy where

entropy_rank :: (Integer, Integer) -> [Integer] -> Integer
entropy_rank _ [] = 0
entropy_rank (min, max) sequence = abs (entropy ([min] ++ sequence ++ [max]))

entropy :: [Integer] -> Integer
entropy [] = 0
entropy [x] = x
entropy sequence = entropy (diff sequence)

diff :: [Integer] -> [Integer]
diff [] = []
diff sequence = zipWith (-) (tail sequence) (sequence)

test :: String
test = concat (map test_entropy_rank entropy_rank_test_data)

test_entropy_rank :: [Integer] -> String
test_entropy_rank seq = (show seq) ++ " = " ++ (show (entropy_rank (1,60) seq)) ++ "\n"

entropy_rank_test_data :: [[Integer]]
entropy_rank_test_data = [
	[1,2,3,4,5,6],
	[55,56,57,58,59,60],
	[1,2,3,58,59,60],
	[10,20,30,40,50,60],
	[9,12,19,22,35,37],
	[4,28,30,31,35,54]
	]
