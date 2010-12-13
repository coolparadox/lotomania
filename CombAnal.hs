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

combine :: [a] -> Natural -> [[a]]
combine [] _ = []
combine _ 0 = [[]]
combine [x] 1 = [[x]]
combine (x:xs) n = comb_x ++ comb_xs where
	comb_x = map (x:) (combine xs (n-1))
	comb_xs = combine xs n

