module Ex01 where

  -- needed to display the picture in the playground
import Codec.Picture

  -- our line graphics programming interface
import ShapeGraphics






-- Part 1
-- picture of a house

housePic :: Picture
housePic = [door, house]
  where
    house :: PictureObject
    house = undefined 
    door :: PictureObject
    door  = undefined

-- these are the coordinates - convert them to a list of Point - DONE
type Point = (Int, Int)

houseCOs :: [Point]
houseCOs = [(300, 750), (300, 450), (270, 450), (500, 200),
         (730, 450), (700, 450), (700, 750)]

doorCOs :: [(Float, Float)]
doorCOs = [(420, 750), (420, 550), (580, 550), (580, 750)]

smoke :: PictureObject 
smoke = undefined

grey :: Colour
grey = Colour 255 255 255 128

chimneyHouse :: Picture
chimneyHouse = undefined



-- Part 2
movePoint :: Point -> Vector -> Point
movePoint (Point x y) (Vector xv yv)
  = Point (x + xv) (y + yv)


movePictureObject :: Vector -> PictureObject ->PictureObject
movePictureObject vec (Path points colour lineStyle) 
  = undefined
movePictureObject vec (Circle center radius colour lineStyle fillStyle) 
  = undefined
-- add other cases  



-- Part 3


-- generate the picture consisting of circles:
-- [Circle (Point 400 400) (400/n) col Solid SolidFill,
--  Circle (Point 400 400) 2 * (400/n) col Solid SolidFill,
--  ....
--  Circle (Point 400 400) 400 col Solid SolidFill]
simpleCirclePic :: Colour -> Float -> Picture
simpleCirclePic col n = undefined



-- use 'writeToFile' to write a picture to file "ex01.png" to test your 
-- program if you are not using Haskell for Mac 
-- e.g., call 
-- writeToFile [house, door]

writeToFile pic 
  = writePng "ex01.png" (drawPicture 3 pic)






