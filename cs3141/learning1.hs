inc :: Int -> Int
inc x = x + 1

square :: Int -> Int
square x = x * x

maximum :: Ord a => a -> a -> a
maximum x y | x >= y = x
            | otherwise = y

type Point = (Int, Int)

origin :: [Point]
origin = [(0, 0), (0,5)]

moveRight :: Point -> Int -> Point
moveRight (x, y) distance = (x + distance, y)

showResult :: Show a => a -> String
showResult x = "The result is " ++ show x
