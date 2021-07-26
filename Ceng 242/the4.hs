
import Data.Maybe -- up to you if you want to use it or not


data DictTree k v = Node [(k, DictTree k v)] | Leaf v deriving Show


newtype Digit = Digit Char deriving (Show, Eq, Ord) -- derive equality and comparison too!


type DigitTree = DictTree Digit String
type PhoneNumber = [Digit]



isDigit' x = x `elem` ['0' .. '9']

toDigit :: Char -> Maybe Digit
toDigit x = if (isDigit' x) then Just (Digit x)
            else Nothing

toDigits :: String -> Maybe PhoneNumber


process1 [] = []
process1 (x:xs)  = if ((toDigit x) /= Nothing ) then  [(toDigit x)] ++ (process1 xs)
                  else [Nothing] ++ (process1 xs)

process2 [] = []
process2 (Just x: xs) =   (x) : process2 xs
process2 (Nothing:ls) = process2 ls


toDigits [] = Nothing
toDigits (x:xs) =  if( length (process2 (process1 (x:xs))) /= length (x:xs)) then Nothing
                   else Just (process2 (process1 (x:xs)))


numContacts :: DigitTree -> Int

kLeaf (k, Leaf l) = True
kLeaf _ = False

numContacts' (Node []) = 0
numContacts' (Node ((k, Leaf l):xs)) = 1 + (numContacts' (Node xs))
numContacts' (Node ((k, Node l):xs)) = (numContacts' (Node l)) + (numContacts' (Node xs))

numContacts (Node (x:xs))  = numContacts' (Node (x:xs))



--getContacts :: DigitTree -> [(PhoneNumber, String)]
--getContacts' (Node []) = []
--getContacts' (Node ((k, Leaf l):xs)) = ([k],l) : (getContacts' (Node xs))


--getContacts' (Node ((k, Leaf l):xs)) = [k] : (getContacts' (Node xs))
--getContacts' (Node ((k, Node l):xs)) = [k] : (getContacts' (Node l))




getContacts'' (Node []) = []
getContacts'' (Node ((k, Leaf l):xs)) =  l : (getContacts'' (Node xs))
getContacts'' (Node ((k, Node l):xs)) = (getContacts'' (Node l)) ++ (getContacts'' (Node xs))



isNameThere name (Node []) = False
isNameThere name (Node ((k, Leaf l):xs)) = if (name == l) then True
                                           else False || (isNameThere name (Node xs))
isNameThere name (Node ((k, Node l):xs)) = (isNameThere name (Node l)) || (isNameThere name (Node xs))


getContacts''' isim (Node[]) = []
getContacts''' isim (Node ((k, Leaf l):xs)) = if (l == isim) then [k]
                                              else  (getContacts''' isim (Node xs))

getContacts''' isim (Node ((k, Node l):xs)) =  if(isNameThere isim (Node l)) then [k] ++ (getContacts''' isim (Node l))
                                               else (getContacts''' isim (Node xs))


findContactAdrress isim agac = ((getContacts''' isim agac),isim)



worker [] _ = []
worker (x:xs) agac = [(findContactAdrress x agac)] ++ (worker xs agac)

getContacts agac = worker (getContacts'' agac) agac






autocomplete :: String -> DigitTree -> [(PhoneNumber, String)]


--autocomplete (x:xs) agac =


autocomplete'' _ []= True
autocomplete'' ((Digit x):xs) (y:ys) = if (x == y) then autocomplete'' xs ys
                               else False
autocomplete'' [] _ = False


autocomplete' _ [] = []
autocomplete' (x:xs) (y:ys) = if (autocomplete'' (fst y) (x:xs)) then [y] ++ (autocomplete' (x:xs) ys)
                              else (autocomplete' (x:xs) ys)

processor1 x [] = x
processor1 ((Digit x):xs) (y:ys)=  processor1 xs ys
processor1 [] y = []


autocomplete''' str agac = autocomplete' str (getContacts agac)

autocomplete'''' [] str = []
autocomplete'''' (x:xs) str = ((processor1 (fst x) str), snd x) : (autocomplete'''' xs str)

autocomplete [] agac = []
autocomplete str agac = autocomplete'''' (autocomplete''' str agac) str

-----------
-- Example Trees
-- Two example trees to play around with, including THE exampleTree from the text.
-- Feel free to delete these or change their names or whatever!

exampleTree :: DigitTree
exampleTree = Node [
    (Digit '1', Node [
        (Digit '3', Node [
            (Digit '7', Node [
                (Digit '8', Leaf "Jones")])]),
        (Digit '5', Leaf "Steele"),
        (Digit '9', Node [
            (Digit '1', Leaf "Marlow"),
            (Digit '2', Node [
                (Digit '3', Leaf "Stewart")])])]),
    (Digit '3', Leaf "Church"),
    (Digit '7', Node [
        (Digit '2', Leaf "Curry"),
        (Digit '7', Leaf "Hughes")])]

--areaCodes :: DigitTree
--areaCodes = Node [
--    (Digit '3', Node [
--        (Digit '1', Node [
--            (Digit '2', Leaf "Ankara")]),
--        (Digit '2', Node [
--            (Digit '2', Leaf "Adana"),
--            (Digit '6', Leaf "Hatay"),
--            (Digit '8', Leaf "Osmaniye")])]),
--    (Digit '4', Node [
--        (Digit '6', Node [
--            (Digit '6', Leaf "Artvin")])])]
