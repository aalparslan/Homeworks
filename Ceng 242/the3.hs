data Cell = SpaceCraft Int | Sand | Rock Int | Pit deriving (Eq , Read , Show )

type Grid = [[ Cell ]]

type Coordinate = (Int , Int )

data Move = North | East | South | West | PickUp | PutDown deriving (Eq , Read , Show )

data Robot = Robot { name :: String ,
                     location :: Coordinate ,
                     capacity :: Int ,
                     energy :: Int ,
                     storage :: Int } deriving (Read , Show )



isInGrid :: Grid -> Coordinate -> Bool

isInGrid grid (x,y) = if ( y >= 0 && y <= ((length grid) -1)) && (x >= 0 && x <= ( ( length (head grid)  ) -1) ) then True
                      else False


totalCount :: Grid -> Int


rParser (Rock p ) = p
rParser (x) = 0


findSubListTotalCount [] = 0
findSubListTotalCount (x:y) = (rParser x) + (findSubListTotalCount y)


totalCount [] = 0
totalCount (x:y) = (findSubListTotalCount x) + (totalCount y)



coordinatesOfPits :: Grid -> [ Coordinate ]

coordinatesOfPitsHelperSub [] _ _ = []
coordinatesOfPitsHelperSub (x:y) k l = if(x == Pit) then [(k,l)] ++ (coordinatesOfPitsHelperSub y (k+1) l)
                                       else coordinatesOfPitsHelperSub y (k+1) l


coordinatesOfPitsHelper [] _ _ = []
coordinatesOfPitsHelper (x:y) k l =  (coordinatesOfPitsHelperSub x k l) ++ (coordinatesOfPitsHelper y k (l+1) )


filter'' pred [] = []
filter'' pred ((k,l):xs) = if(pred l) then [(k,l)] ++ (filter'' pred xs)
                           else filter'' pred xs

filter' pred [] = []
filter' pred  ((k,l):xs) = if(pred k) then [(k,l)] ++ (filter' pred  xs)
                                else filter' pred  xs

quickSort [] = []
quickSort ((k,l):xs) =
          let smallerSorted = quickSort (filter' (<k) xs)
              mediumSortedSmaller = quickSort (filter'' (l >=) (filter' (==k) xs)  )
              mediumSortedBigger = quickSort( filter'' (l < ) (filter' (==k)  xs)  )
              biggerSorted = quickSort (filter' (k<) xs)
          in smallerSorted ++ mediumSortedSmaller ++ [(k,l)] ++ mediumSortedBigger ++ biggerSorted


coordinatesOfPits grid = quickSort (coordinatesOfPitsHelper grid 0 0)



tracePath :: Grid -> Robot -> [ Move ] -> [ Coordinate ]


getRobotCoord (Robot _ k _ _ _) = k
getRobotEnergy (Robot _ _ _ e _) = e
getRobotName (Robot a _ _ _ _) = a
getRobotCapacity (Robot _ _ c _ _) = c
getRobotStorage (Robot _ _ _ _ s) = s




tracePath _ _ [] = []
tracePath grid robot (x:xs) =  if ((getRobotCoord robot) `elem` (coordinatesOfPits grid) ) then [getRobotCoord robot] ++ (tracePath grid (Robot  (getRobotName robot) ( (fst (getRobotCoord robot)) , (snd (getRobotCoord robot)) ) (getRobotCapacity robot)   ((getRobotEnergy robot)-1)  (getRobotStorage robot)  ) xs)
                               else  if(x == North) then if((isInGrid grid  ( fst (getRobotCoord robot), (snd (getRobotCoord robot)) -1 ))  && (getRobotEnergy robot) > 0) then [( fst (getRobotCoord robot), (snd (getRobotCoord robot)) -1 )] ++ (tracePath grid (Robot  (getRobotName robot) ( fst (getRobotCoord robot), (snd (getRobotCoord robot)) -1 ) (getRobotCapacity robot)   ((getRobotEnergy robot)-1)  (getRobotStorage robot)  ) xs)
                                                    else [(getRobotCoord robot)] ++ (tracePath grid robot xs)
                                     else if (x == East) then if((isInGrid grid ( (fst (getRobotCoord robot)) +1, (snd (getRobotCoord robot)) )) && (getRobotEnergy robot) > 0) then [( (fst (getRobotCoord robot)) +1, (snd (getRobotCoord robot)) )] ++ (tracePath grid (Robot  (getRobotName robot) ( (fst (getRobotCoord robot)) +1, (snd (getRobotCoord robot)) ) (getRobotCapacity robot)   ((getRobotEnergy robot)-1)  (getRobotStorage robot)  ) xs)
                                                    else [(getRobotCoord robot)] ++ (tracePath grid robot xs)
                                     else if (x == South) then if( (isInGrid grid ( (fst (getRobotCoord robot)), (snd (getRobotCoord robot)) +1)) && (getRobotEnergy robot) > 0  ) then [( (fst (getRobotCoord robot)), (snd (getRobotCoord robot)) +1)] ++ (tracePath grid (Robot  (getRobotName robot) ( fst (getRobotCoord robot), (snd (getRobotCoord robot)) +1 ) (getRobotCapacity robot)   ((getRobotEnergy robot)-1)  (getRobotStorage robot)  ) xs)
                                                    else  [(getRobotCoord robot)] ++ (tracePath grid robot xs)
                                     else if (x == West) then if(isInGrid grid ( (fst (getRobotCoord robot)) -1, (snd (getRobotCoord robot)) ) && (getRobotEnergy robot) > 0) then [( (fst (getRobotCoord robot)) -1, (snd (getRobotCoord robot)) )] ++ (tracePath grid (Robot  (getRobotName robot) ( (fst (getRobotCoord robot)) -1, (snd (getRobotCoord robot)) ) (getRobotCapacity robot)   ((getRobotEnergy robot)-1)  (getRobotStorage robot)  ) xs)
                                                    else  [(getRobotCoord robot)] ++ (tracePath grid robot xs)
                                     else if (x == PickUp) then if((getRobotEnergy robot) > 5) then [getRobotCoord robot] ++ (tracePath grid (Robot  (getRobotName robot) ( (fst (getRobotCoord robot)) , (snd (getRobotCoord robot)) ) (getRobotCapacity robot)   ((getRobotEnergy robot)-5)  (getRobotStorage robot)  ) xs)
                                                    else [(getRobotCoord robot)] ++ (tracePath grid robot xs)
                                     else if (x == PutDown) then if((getRobotEnergy robot) > 3) then [getRobotCoord robot] ++ (tracePath grid (Robot  (getRobotName robot) ( (fst (getRobotCoord robot)) , (snd (getRobotCoord robot)) ) (getRobotCapacity robot)   ((getRobotEnergy robot)-3)  (getRobotStorage robot)  ) xs)
                                                    else [(getRobotCoord robot)] ++ (tracePath grid robot xs)
                                     else [(99,99)] ++ (tracePath grid robot xs)



--energiseRobots :: Grid -> [ Robot ] -> [ Robot ]


scParser (SpaceCraft p)  = True
scParser _  = False



coordinatesOfSpaceCraftHelperSub [] _ _ = []
coordinatesOfSpaceCraftHelperSub (x:y) k l = if(scParser x) then [(k,l)] ++ (coordinatesOfSpaceCraftHelperSub y (k+1) l)
                                       else coordinatesOfSpaceCraftHelperSub y (k+1) l


coordinatesOfSpaceCraftHelper [] _ _ = []
coordinatesOfSpaceCraftHelper (x:y) k l =  (coordinatesOfSpaceCraftHelperSub x k l) ++ (coordinatesOfSpaceCraftHelper y k (l+1) )


calculateDistance grid (Robot _ (x,y) _ _ _) =  if ( (fst ( head (coordinatesOfSpaceCraftHelper grid 0 0)) ) > x ) then if ( (snd ( head (coordinatesOfSpaceCraftHelper grid 0 0)) ) > y ) then ((fst ( head (coordinatesOfSpaceCraftHelper grid 0 0)) ) - x ) + ((snd ( head (coordinatesOfSpaceCraftHelper grid 0 0)) ) - y) else ((fst ( head (coordinatesOfSpaceCraftHelper grid 0 0)) ) - x ) + (y - (snd ( head (coordinatesOfSpaceCraftHelper grid 0 0)) ) )
                                                else if ( (snd ( head (coordinatesOfSpaceCraftHelper grid 0 0)) ) > y ) then (x - (fst ( head (coordinatesOfSpaceCraftHelper grid 0 0)) )  ) + ((snd ( head (coordinatesOfSpaceCraftHelper grid 0 0)) ) - y) else (x - (fst ( head (coordinatesOfSpaceCraftHelper grid 0 0)) ) ) + (y - (snd ( head (coordinatesOfSpaceCraftHelper grid 0 0)) ) )

calculateEnergy2 grid x  = if (100 - (calculateDistance grid x) * 20  ) > 0 then (100 - (calculateDistance grid x) * 20  )
                         else 0

calculateEnergy1 grid x mevcutEnerji = if ((calculateEnergy2 grid x ) + mevcutEnerji) > 100 then 100
                                       else ((calculateEnergy2 grid x ) + mevcutEnerji)

energiseRobots _ [] = []
energiseRobots grid (x:y) = [(Robot  (getRobotName x) (getRobotCoord x) (getRobotCapacity x)      (calculateEnergy1 grid x (getRobotEnergy x))   (getRobotStorage x)  )] ++ (energiseRobots grid y)


applyMoves :: Grid -> Robot -> [ Move ] -> ( Grid , Robot )



rockDecrease (Rock p) = (Rock (p-1))
spaceCraftIncrease (SpaceCraft p) = (SpaceCraft (p+1))



updateGridForRockPickUp2 _ [] = []
updateGridForRockPickUp2 p (x:xs) = if (p /= 0) then [x] ++ (updateGridForRockPickUp2 (p-1) xs)
                                    else if ((rParser x) == 0 ) then [x] ++ (updateGridForRockPickUp2 (p-1) xs)
                                    else [rockDecrease x] ++ (updateGridForRockPickUp2 (p-1) xs)


 --x,y koordinate and k:l grid
updateGridForRockPickUp1 (_,_) [] =   []
updateGridForRockPickUp1 (x,y) (k:l)  =    if( y /= 0) then [k] ++ updateGridForRockPickUp1 (x,y-1) l
                                           else [(updateGridForRockPickUp2 x k)] ++ updateGridForRockPickUp1 (x,y-1) l








updateGridForRockPutDown2 _ [] = []
updateGridForRockPutDown2 p (x:xs) = if (p /= 0) then [x] ++ (updateGridForRockPutDown2 (p-1) xs)
                                     else [spaceCraftIncrease x] ++ (updateGridForRockPutDown2 (p-1) xs)



updateGridForRockPutDown1 (_,_) [] = []
updateGridForRockPutDown1 (x,y) (k:l) =  if (y/= 0) then [k] ++ updateGridForRockPutDown1 (x, y-1) l
                                         else [updateGridForRockPutDown2 x k ]  ++ updateGridForRockPutDown1 (x,y-1) l


findSpaceShipCoords grid = (head (coordinatesOfSpaceCraftHelper grid 0 0))


updateGridForRockPutDown (k:l) = updateGridForRockPutDown1 (findSpaceShipCoords (k:l)) (k:l)


-- y:ys trajectory.. x:xs moves..
applyMoves' grid robot [] _  = (grid, robot)
applyMoves' grid robot _ []  = (grid, robot)
applyMoves' grid robot (x:xs) (y:ys) = if (x == North || x == East || x == South || x == West) then applyMoves' grid (Robot (getRobotName robot) y (getRobotCapacity robot) ((getRobotEnergy robot)-1) (getRobotStorage robot) )  xs ys
                                       else if (x == PickUp ) then if ( (getRobotStorage robot)  < (getRobotCapacity robot)) then if ((getRobotEnergy robot) >= 5) then  applyMoves' (updateGridForRockPickUp1 (getRobotCoord robot) grid ) (Robot (getRobotName robot) (getRobotCoord robot) (getRobotCapacity robot) ((getRobotEnergy robot) -5) ((getRobotStorage robot)+1) ) xs ys -- if energy is  enough
                                                                                                                              else applyMoves' grid (Robot (getRobotName robot) (getRobotCoord robot) (getRobotCapacity robot) 0 (getRobotStorage robot)) xs ys -- if energy is not enough
                                                                else applyMoves' grid (Robot (getRobotName robot) (getRobotCoord robot) (getRobotCapacity robot) ((getRobotEnergy robot )-5) (getRobotStorage robot)) xs ys -- if capacity is not enough
                                       else if (x == PutDown) then if ((getRobotEnergy robot) > 3) then applyMoves' (updateGridForRockPutDown grid  ) (Robot (getRobotName robot) (getRobotCoord robot) (getRobotCapacity robot) ((getRobotEnergy robot) -3) ((getRobotStorage robot)-1) ) xs ys -- if energy is  enough
                                                                else applyMoves' grid (Robot (getRobotName robot) (getRobotCoord robot) (getRobotCapacity robot) 0 (getRobotStorage robot)) xs ys -- if energy is not enough
                                       else if ((getRobotCoord robot) `elem` (coordinatesOfPits grid)) then applyMoves' grid (Robot (getRobotName robot) (getRobotCoord robot) (getRobotCapacity robot) ((getRobotEnergy robot)-1) (getRobotStorage robot)) xs ys
                                       else  (grid,robot)



applyMoves grid robot (x:xs) = (applyMoves' grid robot (x:xs) (tracePath grid robot (x:xs) ) )
