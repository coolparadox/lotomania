module Entropy where

entropy_rank :: (Integer, Integer) -> [Integer] -> Integer
entropy_rank _ [] = 0
entropy_rank (min, max) sequence = abs (entropy ([min] ++ sequence ++ [max]))

entropy :: [Integer] -> Integer
entropy [] = 0
entropy [x] = x
entropy sequence = entropy (diffs sequence)

diffs :: [Integer] -> [Integer]
diffs [] = []
diffs sequence = zipWith (-) (tail sequence) (sequence)

