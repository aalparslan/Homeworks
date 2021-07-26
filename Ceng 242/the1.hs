import Text.Printf

convertTL :: Double -> String -> Double
countOnWatch :: [ String ] -> String -> Int -> Int
encrypt :: Int -> Int
compoundInterests :: [( Double , Int ) ] -> [ Double ]

getRounded :: Double -> Double
getRounded x = read s :: Double
               where s = printf "%.2f" x

convertTL numInTL "USD" = getRounded (numInTL / 8.18)
convertTL numInTL "EUR" = getRounded (numInTL / 9.62)
convertTL numInTL "BTC" = getRounded( numInTL / 473497.31)


sonsuzyap liste = liste ++ sonsuzyap liste
count x = length . filter (x==)
countOnWatch liste isim sayi = count isim (take sayi (sonsuzyap liste))



processDigit x =
    if (x `mod` 3 == 0) then x-1
    else if (x `mod` 4 == 0) then ( (x*2) `mod` 10)
    else if (x `mod` 5 == 0) then ( (x+3) `mod` 10)
    else (x+4) `mod` 10

encrypt digits =  (processDigit( (fromIntegral ((digits `mod` 10000) - (digits `mod` 1000))) `div` 1000))*1000 + (processDigit( (fromIntegral ((digits `mod` 1000) - (digits `mod` 100))) `div` 100))*100 + (processDigit( (fromIntegral ((digits `mod` 100) - (digits `mod` 10))) `div` 10))*10 + (processDigit( (fromIntegral ((digits `mod` 10) - (digits `mod` 1))) `div` 1))*1


calculateInterest (para, yil) =  if para >= 10000 && yil >= 2 then 0.115
                                else if para < 10000 && yil >= 2 then 0.095
                                else if para > 10000 && yil < 2 then 0.105
                                else if para < 10000 && yil < 2 then 0.090
                                else 0

findTotalAmount (para,yil) = getRounded ( para * (1 + (calculateInterest (para,yil)) / 12 ) ^ (12 * yil) )

compoundInterests [] = []
compoundInterests ((x,y):xs) = (findTotalAmount (x,y)) : compoundInterests xs
