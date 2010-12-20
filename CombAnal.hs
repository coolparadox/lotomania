-- Combinatorial Analysis

module CombAnal where

import Natural

fatorial :: Natural -> Natural
fatorial 0 = 1
fatorial n = n * (fatorial (n-1))

combination :: Natural -> Natural -> Natural
combination k n
	| n >= k = (fatorial n) `quot` ((fatorial k) * (fatorial (n-k)))
	| otherwise = 0

-- Pascal's Triangle approach. Elegant, but not efficient.
-- combination :: Natural -> Natural -> Natural
-- combination 0 _ = 1
-- combination k n
-- 	| n >= k = (combination (n-1) (k-1)) + (combination (n-1) k)
-- 	| otherwise = 0

combine :: Natural -> [a] -> [[a]]
combine 0 _ = [[]]
combine _ [] = []
combine k (x:xs) = comb_x ++ comb_xs where
	comb_x = map (x:) (combine (k-1) xs)
	comb_xs = combine k xs

