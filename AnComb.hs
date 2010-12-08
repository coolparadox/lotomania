module AnComb where

import Natural

combination :: Natural -> [a] -> [[a]]
combination _ [] = []
combination 0 _ = [[]]
combination 1 [x] = [[x]]
combination n (x:xs) = comb_x ++ comb_xs where
	comb_x = map (x:) (combination (n-1) xs)
	comb_xs = combination n xs

