import Test.QuickCheck
import Data.List
import Data.Maybe

-- Given the following types

type VarName = String

data Exp = Add Exp Exp | Negate Exp | Var VarName | Num Int
  deriving (Eq, Show)

data EvalData = EvalData Exp [(VarName,Int)]
  deriving (Eq, Show)

data Simplified = Partial Exp | Full Int
    deriving (Eq,Show)

-- data type invariant

prop_simplified :: Simplified -> Bool
prop_simplified (Partial (Num n)) = False
       -- should be represented as Full n
prop_simplified _                 = True

prop_eval :: EvalData -> Bool
prop_eval evdata = case eval evdata of
                      Partial _ -> False
                      _         -> True

-- Q 2.1 -----------------------
eval ::  EvalData -> Simplified

eval (EvalData e t) = case simplify e of
           Num n -> Full n
           exp   -> Partial exp
   where simplify :: Exp -> Exp
         simplify (Add e1 e2) = add (simplify e1) (simplify e2)
         simplify (Negate e1) = negate $ simplify e1
         simplify (Num n)     = Num n
         simplify (Var x)     = case lookup x t of
                                   Just n -> Num n
                                   Nothing -> Var x

         negate (Num n) = Num (-n)
         negate exp     = Negate exp

         add (Num n1) (Num n2) = Num (n1 + n2)
         add e1       e2       = if e1 == Negate e2 || e2 == Negate e1
                                 then Num 0
                                 else Add e1 e1


-- Q 2.2 -------------------------
{-
For any expression exp, if the table t contains enough variables, then eval t exp will give a fully evaluated term.  
Make an Arbitrary instance definition for EvalData that generates expressions with any number of variables, 
and makes sure that the table contains values for all of the variables.
 -}

instance Arbitrary EvalData where
  arbitrary =
   do
    n <- arbitrary 
    let varNames = map show [1..n]
    values <- vectorOf n arbitrary
    let table = zip varNames values
    exp <- sized (genExp varNames)
    return (EvalData exp table)



genExp :: [VarName] -> Int -> Gen Exp
genExp vs n = frequency [(min 1 (length vs),genVar),
                         (1,                genNum),
                         (n,                genNeg),
                         (n,                genAdd)]
          where genVar = Var <$> elements vs -- vs must be non empty
                genNum = Num <$> arbitrary
                genNeg = Negate <$> genExp vs (n-1)
                genAdd = do let gen = genExp vs (n `div` 2)
                            e1 <- gen
                            e2 <- gen
                            return $ Add e1 e2

-- Q 2.3 --------------------------
----------

trim :: [[a]] -> [[a]]
prop_trim :: Bool
prop_trim = trim [[1,2,3],[10,20,30],[100,200]] == [[1,2],[10,20],[100,200]]

trim1,trim2 :: [[a]] -> [[a]]

trim1 xss = map (take (minLength1 xss)) xss
     where minLength1 = minimum . map length

trim2 xss = map (take (minLength2 xss)) xss
     where minLength2 = length . minimum . map (map $ const ()) 

trim = trim1

ex1 = [[1,2,3],[1..]]
ex2 = [[1..]]
ex3 = [[1..n] | n <- [1..]]

{- 
* trim1 ex1 produces no output, because it has to compute 
the length of each of the lists in order to find the shortest, 
and this does not terminate for [1..].

* trim2 ex1 produces [[1,2,3],[1,2,3]]. 

* It terminates because the shortest list is found by 
converting them to unit lists and comparing them with (<). 
Because of lazy evaluation, the comparison (<) of ():():():[] 
and the infinite list ():():... terminates as soon as the 
fourth element of the second has been evaluated. 

* trim2 ex2 does not produce any output because the only list is infinite, 
and so it tries to calculate its length. 

* No trim function can produce output for such an infinite input because
it needs to inspect every element of the outer list to find the shortest, 
and this cannot be computed in finite time. 
 -}


-- Q 2.4 --------------------------
-- module DiffList (DiffList,nil,toList,cons,append) where
newtype DiffList a = DL ([a] -> [a])

nil :: DiffList a
nil = DL id

toList :: DiffList a -> [a]
toList (DL d) = d []

append :: DiffList a -> DiffList a -> DiffList a
cons :: a -> DiffList a -> DiffList a
----
append (DL a) (DL b) = DL (a . b)
cons a (DL b) = DL (\ys -> a : b ys)








