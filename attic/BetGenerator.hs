module BetGenerator where

import Natural

value_filter :: Natural -> Natural -> Bool
value_filter max value = (value /= 0) && (value <= max)

undiff_filter :: Natural -> (Natural, Natural) -> Bool
undiff_filter max (x, y) = answer_x && answer_y where
	answer_x = value_filter max x
	answer_y = value_filter max y

undiff_value :: Natural -> Natural -> Natural -> [(Natural, Natural)]
undiff_value max init x = filter (undiff_filter max) (answer_plus ++ answer_minus) where
	answer_plus = [(init, init + x)]
	answer_minus = if ((init >= x) && (x > 0)) then [(init, init - x)] else []

undiff_list :: Natural -> Natural -> [Natural] -> [[Natural]]
undiff_list _ init [] = [[init]]
undiff_list max init (x:others) = concat seqs where
	seqs = [map (y1:) (undiff_list max y2 others) | (y1, y2) <- undiff_value max init x]

undiff_list_range :: (Natural, Natural) -> [Natural] -> [[Natural]]
undiff_list_range (init_min, init_max) seq = concat answer where
	answer = [undiff_list init_max init seq | init <- [init_min..init_max]]

undiff_lists_deep :: (Natural, Natural) -> Natural -> [[Natural]] -> [[Natural]]
undiff_lists_deep _ 0 seqs = seqs
undiff_lists_deep range depth seqs = undiff_lists_deep range new_depth new_seqs where
	new_depth = depth - 1
	new_seqs = concat (map (undiff_list_range range) seqs)

bet_is_sorted :: [Natural] -> Bool
bet_is_sorted (x:y:others) = (x <= y) && (bet_is_sorted (y:others))
bet_is_sorted _ = True

sort_bet :: [Natural] -> [Natural]
sort_bet [] = []
sort_bet (x:xs) = sorted_le ++ [x] ++ sorted_gt where
	sorted_le = sort_bet [y | y <- xs, y <= x]
	sorted_gt = sort_bet [y | y <- xs, y > x]

