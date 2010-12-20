-- Combinatorial Analysis

module CombAnal where

import Natural

fatorial :: Natural -> Natural
fatorial 0 = 1
fatorial n = n * (fatorial (n-1))

combination :: Natural -> Natural -> Natural
combination n k 
	| n >= k = (fatorial n) `quot` ((fatorial k) * (fatorial (n-k)))
	| otherwise = 0

-- Pascal's Triangle approach. Elegant, but not efficient.
-- combination :: Natural -> Natural -> Natural
-- combination _ 0 = 1
-- combination n k 
-- 	| n >= k = (combination (n-1) (k-1)) + (combination (n-1) k)
-- 	| otherwise = 0

combine :: Natural -> [a] -> [[a]]
combine 0 _ = [[]]
combine _ [] = []
combine n (x:xs) = comb_x ++ comb_xs where
	comb_x = map (x:) (combine (n-1) xs)
	comb_xs = combine n xs

