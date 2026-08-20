import Test.QuickCheck
import Data.List
import Data.Maybe
import Data.Char

-- 1 ---------------------------------------------
data WebColour = RGB Int Int Int | HSL Int Int Int
-- 1p. Must be correct Haskell but OK to use a triple RGB(Int,Int,Int) or split over two types


isValidWebColour (RGB r g b) = all byte [r,g,b]
isValidWebColour (HSL h s l) = angle h && percent s && percent l

byte    = upto 255
percent = upto 100
angle   = upto 359

upto limit m = m >= 0 && m <= limit
-- 3p but -1 if very ugly (excessive cut and paste)


instance Show WebColour where
  show (RGB r g b) = "rgb" ++ show (r,g,b)
  show (HSL h s l) = "hsl(" ++ show h ++ ","
                            ++ show s ++ "%,"
                            ++ show l ++ "%)"

-- -1 if no instance dec  -1 for small errors (no % sign)




-- 2 -------------------------------------------------

allProps :: [a -> Bool] -> a -> Bool

allProps []     _ = True
allProps (p:ps) a = p a && allProps ps a










-- 3 -----------------------------------------------------------
allProps' ps a = and [ p a | p <- ps]

-- OK if there is an unnecessary base case










-- 4 -----------------------------------------------------------
dimension :: [[a]] -> Maybe Int
-- base case is dimension [] = 0 (easily missed with recursive defs)

dimension rows
  | and [length r == len | r <- rows] = Just len
  | otherwise                         = Nothing
     where len = length rows


-- OK if length rows is recomputed several times

-- 5 -----------------------------------------------------------
-- 3 points

data IntSquare = Square [[Int]]
  deriving (Eq,Show)

prop_Square (Square s) = isJust (dimension s)

instance Arbitrary IntSquare where
  arbitrary = do dim <- abs <$> arbitrary
                 sq  <- vectorOf dim (vectorOf dim arbitrary)
                 return $ Square sq 

-- -1 for missing constructor
-- -1 for missing <$> or equivalent
-- OK to forget abs (still works) - OK to use a fixed range or even sized

-- 6 -----------------------------------------------------------
-- 2 points

diag :: [[a]] -> [a]

diag xss = diagHelper (length xss) 
  where diagHelper 0 = []
        diagHelper m = let  n = m - 1 in xss!!n!!n : diagHelper n

-- generous with off-by-one errors. Good but not recursive (e.g. list comprehension) max 1p.
-- should work with xss as [] (so base case needs to be 0) -1p

-- 7 -----------------------------------------------------------
type CardSquare = [[Card]]

data Rank = Numeric Integer | Jack | Queen | King | Ace
  deriving (Eq, Ord, Show)

data Suit = Hearts | Spades | Diamonds | Clubs
        deriving (Eq, Enum, Bounded, Show)
        -- permits [Hearts..Clubs] etc

data Card = Card Rank Suit
  deriving (Eq,Show)


-- 5 points
-- Note they are not required to check that all cards are unique (but OK if you do)

isRoyal :: CardSquare -> Bool
isRoyal css = dimension css == Just 4 && all good4 all4s
   where all4s = [diag css, diag (map reverse css)] ++ css ++ transpose css                 
         good4 cs =  suits `containsAll` allSuits  &&  ranks `containsAll` royals                 
                       where (ranks,suits)       = unzip [(r,s) | Card r s <- cs]
                             as `containsAll` bs = null (bs \\ as)                
                             royals    = [Jack,Queen,King,Ace]
                             allSuits  = [Hearts .. Clubs]

-- common error: all (`elem` royals) ranks -- does not check for duplicates -1p
-- common error: missing diagonal (-1p?) OK if transpose is used insead of reverse

-- most solutions will need to check the dimension is good


------------------------------------------------------------------
-- PART 2 --------------------------------------------------------

-- 2.1 -------------------------------------------------------------
-- 2p
allProps2 ps v = foldr (\p b -> p v && b) True ps 

-- 2.2 ---------
-- 8 points.  Max 6 if they don't use monad or applicative in the add case.
-- -1 not using safe sqrt -1   if there is still an error possibility from e.g. fromJust


type VarName = String
data Exp = Var VarName | Add Exp Exp | SquareRoot Exp | Num Float
  deriving Show

eval :: [(VarName,Float)] -> Exp -> Maybe Float

eval env = ev where 
  ev (Num n) = Just n
  ev (Add e1 e2) = do                   -- (+) <$> ev e1 <*> ev e2
                 v1 <- ev e1
                 v2 <- ev e2
                 return (v1 + v2)       
  ev (SquareRoot e) = ev e >>= safeSqrt -- do {v <- ev e; safeSqrt v}
                 
  ev (Var x) = lookup x env

  safeSqrt v  = if v < 0 then Nothing else Just (sqrt v)



-- 2.3 -----------------------------------------------------------------



-- SOLUTION -----------------------------------------------------------
-- 8 points
-- show not needed. -1 for extra base case in type
-- 3p data type def
-- 5p code -- should it handle the extra case? Assumption stated? Othewise Node q [] locks you in. 

data DTree q a = Q q [(a,DTree q a)] 
   deriving Show 


runDTree :: DTree String String -> IO()

runDTree (Q s [])     = putStrLn s
runDTree t@(Q s alts) = do
  putStrLn $ s ++ " " ++ show (map fst alts) 
  a <- getLine
  case lookup a alts of
       Nothing -> putStrLn "Answer not recognised" >> runDTree t
       Just t' -> runDTree t'

---- For testing only
transportDT :: DTree String String
transportDT = Q "How is the weather?"
                   [("sunny",busOrWalk 3),
                    ("cloudy",busOrWalk 2),
                    ("rainy",busOrWalk 1)]
   where 
         busOrWalk n =  Q "How many km is it?"
                             [("<"++ show n ,decision "Walk")
                             ,(show n ++ "+",decision "Take the bus")]
         decision d = Q d []
         
--2.4 -----------------------------------------------------------------
-- 6 points

-- -1 point if there is no module definition
-- "In this question you are to define an abstract data type for bags,
--  in the form of a module..."


-- module Bag (Bag 
--            , countBag, unionBag, makeBag)
-- where

data Bag a = Bag (a -> Integer)

countBag :: Bag a -> a -> Integer
unionBag :: Bag a -> Bag a -> Bag a
makeBag  :: (a -> Bool) -> Bag a

countBag (Bag f)         = f   -- 1 point (ok to eta expand)

unionBag (Bag f) (Bag g) = Bag (\a -> f a + g a) -- 2 points

makeBag p                = Bag (\a -> if p a then 1 else 0) -- 2 points
