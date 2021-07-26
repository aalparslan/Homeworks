import Data.List
naturals :: [Integer]
interleave :: [a] -> [a] -> [a]
integers :: [Integer]

splitOn :: Char                      -- character to split the string on
        -> String                    -- string to split
        -> (String, String) -- left and right pieces of the split string

tokenizeS :: String -- valid SJSON string to tokenize
        -> [String] -- list of tokens resulting from the tokenization

prettifyS :: String -> String

naturals = [0,1 ..]

interleave [] _ = []
interleave _ [] = []
interleave (x:xs) (y:ys) = x:[y] ++ interleave xs ys

integers = [0] ++ interleave [-1,-2 ..] [1,2 ..]



mysplit' p [] = []
mysplit' p k = x : mysplit' p (drop 1 y) where (x,y) = span (/= p) k


splitOn x ("") = ("", "")
splitOn x y =    ((head (mysplit' x y))  , drop ( 1 + (length (head (mysplit' x y)))) y)

intToString [] = ""
intToString (x:xs) = (show x) ++ (intToString xs)


stringtemizleyici [] sonuc = sonuc
stringtemizleyici (x:xs) sonuc = if (x `elem` ['a' .. 'z']) || ( x `elem` ['A' .. 'Z']) || (x `elem` ( intToString (take 10000 integers)) || (x `elem` ['{', '}', ' ', ':', ',']))
                                then sonuc ++ [x] ++ stringtemizleyici xs sonuc
                                else stringtemizleyici xs sonuc


stringlistesitemizleyici [] = []
stringlistesitemizleyici (x:xs) = [stringtemizleyici x ""] ++ stringlistesitemizleyici xs


tokenize''''  []  = []
tokenize'''' (x:xs) = if (x == '{')  then  ["{"] ++ (tokenize'''' xs)
                     else if (x == '}' )  then   ["}"]  ++ (tokenize'''' xs)
                     else if ( x == ':')  then  [":"] ++ (tokenize'''' xs)
                     else if (x == ',')  then [","]  ++ (tokenize'''' xs)
                     else  (tokenize''''  xs)


tokenize''' [] = []
tokenize''' (x:xs) = if (length x) > 1  && ((head x) `elem` ['{','}',':',','] ) then (tokenize'''' x ) ++ (tokenize''' xs)
                   else [x]  ++ (tokenize''' xs)

tokenizeS'' [] = []
tokenizeS'' str =  [fst (splitOn '\'' ( str))] ++  tokenizeS'' (snd (splitOn '\'' ( str)))

tokenizeS' [] = []
tokenizeS' (x:xs)  =  if (x /= '\'') && (x == ' ')  then [] ++ (tokenizeS' xs)
                            else if (x /= '\'' && (x /= ' ')) then [x] ++ (tokenizeS' xs)
                            else "\'" ++ fst (splitOn '\'' ( xs))  ++ "\'" ++ (tokenizeS' (snd (splitOn '\'' ( xs))) )




tokenizeS str = tokenize''' (stringlistesitemizleyici (tokenizeS'' (tokenizeS' str)))



spacegenerator derinlik = if (derinlik == 0 ) then ""
                          else "    " ++ spacegenerator (derinlik-1)

prettify' [] _ = []
prettify' (x:xs) derinlik  =  if (x == "{") then  "{\n" ++ (spacegenerator (derinlik+1)) ++ (prettify' xs (derinlik+1))
                              else if (x == "}") then "\n"++ (spacegenerator (derinlik-1)) ++ "}"  ++ (prettify' xs (derinlik-1))
                              else if (x == ",") then ",\n" ++ (spacegenerator derinlik) ++ (prettify' xs (derinlik))
                              else if (x /= ":") then "\'" ++ x ++ "\'" ++ (prettify' xs (derinlik))
                              else  x ++ " " ++ (prettify' xs (derinlik))


prettifyS str = prettify' (tokenizeS str) 0











-----
