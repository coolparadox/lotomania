module Natural where

newtype Natural = Natural Integer deriving (Show, Eq, Ord)

toNatural :: Integer -> Natural
toNatural x
	| x < 0 = error "cannot create negative naturals."
	| otherwise = Natural x

fromNatural :: Natural -> Integer
fromNatural (Natural x) = x

instance Num Natural where
	fromInteger = toNatural
	x + y = toNatural ((fromNatural x) + (fromNatural y))
	x - y = let r = (fromNatural x) - (fromNatural y) in
		if (r < 0) then error "unnatural subtraction." else (toNatural r)
	x * y = toNatural ((fromNatural x) * (fromNatural y))
	abs x = x
	signum x
		| x == (Natural 0) = 0
		| otherwise = 1

instance Integral Natural where
	toInteger = fromNatural
	quotRem x y = (toNatural q, toNatural r) where
		(q, r) = quotRem (fromNatural x) (fromNatural y)

instance Enum Natural where
	toEnum i = toNatural (toInteger i)
	fromEnum n = fromEnum (fromNatural n)
	succ n = toNatural (succ (fromNatural n))
	pred n = toNatural (pred (fromNatural n))

instance Real Natural where
	toRational n = toRational (fromNatural n)


