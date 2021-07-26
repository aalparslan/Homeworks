#include <iostream>
#include<fstream>
#include<vector>
#include <bits/stdc++.h>
#include<cstdlib>
#include<sys/socket.h>
#include<unistd.h>
#include<stdio.h>
#include<sys/wait.h>
#include <algorithm>
#include "logging.h"
#include "logging.c"

#define  PIPE(fd) socketpair(AF_UNIX, SOCK_STREAM, PF_UNIX, fd)
using namespace  std;

class monsterResponseClass{
public:
    int fdIndex;
    monster_response_type mr_type;
    monster_response_content mr_content;
};
class monsterClass {
    coordinate coords;
    int health;
    string monsterSymbol;
    int attackPower;
    int defence;
    int rangeOfAttack;
    int damage;
    int monsterFDIndex;
public:
    void setCoordniate(coordinate coord){
        this->coords.x = coord.x;
        this->coords.y = coord.y;
    }
    void setHealth(int health){
        this->health = health;
    }
    void setMonsterSymbol(string symbol){
        this->monsterSymbol = symbol;
    }
    void setAttackPower(int attackPower){
        this->attackPower = attackPower;
    }
    void setDefence(int def){
        this->defence = def;
    }
    void setRangeOfAttack(int attackRange){
        this->rangeOfAttack = attackRange;
    }
    void setDamage(int dmg){
        this->damage = dmg;
    }
    void setMonsterFDIndex(int index){
        this->monsterFDIndex = index;
    }
    coordinate getCoords(){
        return coords;
    }
    int getHealth(){
        return  health;
    }
    string  getMonsterSymbol(){
        return monsterSymbol;
    }
    int getAttackPower(){
        return  attackPower;
    }
    int getDefence(){
        return defence;
    }
    int getRangeOfAttack(){
        return rangeOfAttack;
    }
    int getDamage(){
        return  damage;
    }
    int getMonsterFDIndex(){
        return monsterFDIndex;
    }
};

void resetPlayerMessage(player_message * pm){
    for(int i = 0; i < MONSTER_LIMIT; i++){
        pm->monster_coordinates[i] = {0,0};
    }
    pm->alive_monster_count = 0;
    pm->new_position = {0,0};
    pm->game_over = false;
    pm->total_damage = 0;
}

void resetPlayerResponse(player_response *pr){
    for(int i = 0; i < MONSTER_LIMIT; i++){
        pr->pr_content.attacked[i] = 0;
    }
    pr->pr_content.move_to = {0,0};
    pr->pr_type = pr_ready;
}



vector<string> tokenize(string line){

    vector<string> tokens;
    stringstream ss(line);
    string inter;
    while(getline(ss, inter, ' ')){
        tokens.push_back(inter);
    }
    return tokens;
}

bool compareCoords( monsterClass monster1, monsterClass monster2){
    bool k = false;
    coordinate monster1Coords = monster1.getCoords();
    coordinate monster2Coords = monster2.getCoords();

    if(monster1Coords.x < monster2Coords.x){
        k = true;
    }

    if(monster1Coords.x == monster2Coords.x){
        if(monster1Coords.y < monster2Coords.y){
            k = true;
        }
    }
    return k;
}

void monsterCoordSort(vector<monsterClass> &monsters){
    sort(monsters.begin(), monsters.end(), compareCoords);
}

bool compareMonsterResponseCoords(monsterResponseClass mRespose1, monsterResponseClass mResponse2){
    bool k = false;
    coordinate mR1Coord = mRespose1.mr_content.move_to;
    coordinate mR2Coord = mResponse2.mr_content.move_to;

    if(mR1Coord.x < mR2Coord.x){
        k = true;
    }
    if(mR1Coord.x == mR2Coord.x){
        if(mR1Coord.y < mR2Coord.y){
            k = true;
        }
    }
    return  k;
}

void monsterResponseCoordSort(vector<monsterResponseClass> &monsterResponse){
    sort(monsterResponse.begin(), monsterResponse.end(), compareMonsterResponseCoords);
}

void monsterRemoveAndSort(vector<monsterClass> &monsters, coordinate CoordToRemove){

    monsters.erase(remove_if(monsters.begin(), monsters.end(), [&] (monsterClass  monster){
        return (monster.getCoords().x == CoordToRemove.x && monster.getCoords().y == CoordToRemove.y);
    }),
                   monsters.end());

    // after removal sort the vector...
    monsterCoordSort(monsters);
}

bool isCoordAvailable(vector<monsterClass> monsters, coordinate playerCoord,
                      coordinate bottomLeftCornerOfWall, coordinate coordToBeMoved, coordinate door){
    // check if the position to be moved inside the room
    if((coordToBeMoved.x > 0 && coordToBeMoved.x < bottomLeftCornerOfWall.x) && (coordToBeMoved.y > 0 && coordToBeMoved.y < bottomLeftCornerOfWall.y)){
        // inside the room.
        // check if there is any entity already in that coord
        if(playerCoord.x == coordToBeMoved.x && playerCoord.y == coordToBeMoved.y){
            // player is there
            return false;
        }
        for(int i = 0; i < monsters.size(); i++){
            if(coordToBeMoved.x == monsters[i].getCoords().x && coordToBeMoved.y == monsters[i].getCoords().y){
                // a monster is there
                return false;
            }
        }
        return true;
    }

    if(coordToBeMoved.x == door.x && coordToBeMoved.y == door.y){
        return true;
    }
    return false;
}
int main(int argc, char* argv[]) {

    string firstLine;
    string secondLine;
    string thirdLine;
    string forthLine;
    string fifthLine;

    getline(cin,firstLine);
    getline(cin,secondLine);
    getline(cin,thirdLine);
    getline(cin,forthLine);
    getline(cin,fifthLine);
    vector<string> vectorFirstLine = tokenize(firstLine);
    vector<string> vectorSecondLine = tokenize(secondLine);
    vector<string> vectorThirdLine = tokenize(thirdLine);
    vector<string> vectorFrothLine = tokenize(forthLine);
    vector<string> vectorFifthLine = tokenize(fifthLine);


    int widthOfTheRoom = stoi(vectorFirstLine[0]);
    int heightOfTheRoom = stoi(vectorFirstLine[1]);
    int doorXPosition = stoi(vectorSecondLine[0]);
    int doorYPosition = stoi(vectorSecondLine[1]);
    int playerXPosition = stoi(vectorThirdLine[0]);
    int playerYPosition = stoi(vectorThirdLine[1]);
    int maximumNumOfMonstersToAttackAtaTime = stoi(vectorFrothLine[1]);
    int playerAttackRange = stoi(vectorFrothLine[2]);
    int playerTurnNumber = stoi(vectorFrothLine[3]);
    int numberOfMonsters = stoi(vectorFifthLine[0]);

    /// initialize monster vector
    vector<monsterClass> monsters;
    for(int i = 0; i < numberOfMonsters; i++){
        monsterClass *m = new monsterClass();
        monsters.push_back(*m);
    }
    // below parses multiple monsters input into vectors defined just above.
    for(int i = 0; i < numberOfMonsters; i++){
        string monsterLine;
        getline(cin,monsterLine);
        vector<string> monsterVec = tokenize(monsterLine);

        monsters[i].setMonsterSymbol(monsterVec[1]);
        monsters[i].setCoordniate({stoi(monsterVec[2]),stoi(monsterVec[3])});
        monsters[i].setHealth(stoi(monsterVec[4]));
        monsters[i].setAttackPower(stoi(monsterVec[5]));
        monsters[i].setDefence(stoi(monsterVec[6]));
        monsters[i].setRangeOfAttack(stoi(monsterVec[7]));
        monsters[i].setDamage(0);
        monsters[i].setMonsterFDIndex(i);
    }

    // first one indicates which monster it is... other argument is that monstersfd...

    vector<pair<int, int[2]>> MonsterFDS;

    //monsterFDs[numberOfMonsters][2];
    int playerFD[2];
    int playerPID;
    int monstersPIDs[numberOfMonsters];

    player_message* playerMessage = new player_message;
    player_response* playerResponse = new player_response;
    monster_message* monsterMessage = new monster_message;
    monster_response* monsterResponse = new monster_response;
    game_over_status gameOverStatus;
    map_info* mapInfo = new map_info;

    vector<monsterResponseClass> responsesOfMonsters;

    /// first push data structure into the vector then update it.
    for(int i = 0; i < numberOfMonsters; i++){
        pair<int, int[2]> xxx;
        MonsterFDS.push_back(xxx);
    }

    //// create pipes for monsters and the player
    for(int i = 0; i < numberOfMonsters; i++){
        // her monster icin bir fd[2] pairi ac onlari monsterFDs de depola.


        if(PIPE(MonsterFDS[i].second ) < 0){
            // Dont write anything to stderr or stdout @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ DELETE BELOW LATER...
            perror("failed opening stream socket pair");
            exit(1);
        }else{
            // give names to the pipes so that every monster is numbered
            MonsterFDS[i].first = i;
            monsters[i].setMonsterFDIndex(i);
        }
    }
    if(PIPE(playerFD) < 0 ){
        // Dont write anything to stderr or stdout @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ DELETE BELOW LATER...
        perror("failed opening stream socket pair");
        exit(1);
    }
/////////////////////////////////////////////
    if((playerPID = fork()) < 0){
       // cout<<"fork failed!"<<endl;
    }else if(playerPID == 0){
        // child namely player
        close(playerFD[0]); // close one end
        //// close monster fds for player.
        for(int j = 0; j < numberOfMonsters; j++){
            close(MonsterFDS[j].second[0]);
            close(MonsterFDS[j].second[1]);
        }

        if(dup2(playerFD[1],0) != 0){  // redirect stdin to playerFD[0] socketPair
            perror("Cannot dup2 stdin");
            exit(0);
        }

        if(dup2(playerFD[1], 1) != 1 ){ // redirect stdout to playerFD[1] socketPair
            perror("Cannot dup2 stdout");
            exit(0);
        }
        // load player program with arguments
         char *playerArgs[] = {"./player", &to_string(doorXPosition)[0],
                                     &to_string(doorYPosition)[0], &to_string(maximumNumOfMonstersToAttackAtaTime)[0],
                                     &to_string(playerAttackRange)[0], &to_string(playerTurnNumber)[0], NULL };


        string doorX = to_string(doorXPosition);
        string doorY = to_string(doorYPosition);
        string numOfMonstersToAttack = to_string(maximumNumOfMonstersToAttackAtaTime);
        string pattackRange = to_string(playerAttackRange);
        string pturnNumber= to_string(playerTurnNumber);


        char* Pargs[7];
        Pargs[0] = "./player";
        Pargs[1] = &doorX[0];
        Pargs[2] = &doorY[0];
        Pargs[3] = &numOfMonstersToAttack[0];
        Pargs[4] = &pattackRange[0];
        Pargs[5] = &pturnNumber[0];
        Pargs[6] = NULL;

        if(execv(Pargs[0],Pargs)){
            printf("Warning: execv returned with an error.\n");
            exit(-1);
        }
        printf("Child process should never get here\n");

    }else{// parent
        //// below code forks and starts monsters
        for(int i = 0; i < numberOfMonsters; i++){
            if((monstersPIDs[i] = fork()) < 0){
              //  cout<<"fork failed!"<<endl;
            }else if(monstersPIDs[i] == 0){
                /// child namely monster
                close(MonsterFDS[i].second[0]); // close one end of the socket for current monster.
                //// close playerFD for current mosnter
                close(playerFD[0]);
                close(playerFD[1]);
                /// close other sibling monsters FDs. except itself
                for(int j = 0; j < numberOfMonsters; j++){
                    if(i != j){/// except itself's pipe.
                        close(MonsterFDS[j].second[0]);
                        close(MonsterFDS[j].second[1]);
                    }
                }
               if(dup2(MonsterFDS[i].second[1], 0) != 0){ //// redirect stdin to monster[i][1] socketPair
                   perror("Cannot dup2 stdin");
                   exit(0);
               }
               if(dup2(MonsterFDS[i].second[1], 1) != 1){ //// redirect stdout to monster[i][1] socketPair
                   perror("Cannot dup2 stdout");
                   exit(0);
               }
               /// Load monster program with arguments ...


               string Mhealth = to_string(monsters[i].getHealth());
               string MattackPower = to_string(monsters[i].getAttackPower());
               string Mdefence = to_string(monsters[i].getDefence());
               string MrangeOfAttack = to_string(monsters[i].getRangeOfAttack());

               char* Margs[6];
               Margs[0] = "./monster";
               Margs[1] = &Mhealth[0];
               Margs[2] = &MattackPower[0];
               Margs[3] = &Mdefence[0];
               Margs[4] = &MrangeOfAttack[0];
               Margs[5] = NULL;

               if(execv(Margs[0], Margs)){
                   printf("Warning: execv returned with an error.");
                   exit(-1);
               }
               printf("Child process (monster) should never get here.");
            }
        }
        ///////////////////////////////////////////////////////////////

        bool ifAllReady = true;
        bool gameOver = false;
        int aliveMonsterCount = numberOfMonsters; // this is going to change...
        int totalDamagePlayerReceived  = 0;

        /// close unused fds.
        close(playerFD[1]);
        for(int z = 0; z < numberOfMonsters; z++){
            close(MonsterFDS[z].second[1]);
        }


        read(playerFD[0], playerResponse, sizeof(*playerResponse));
        if(playerResponse->pr_type != 0){
            ifAllReady = false;
        }
        for(int i = 0; i < numberOfMonsters; i++){
            read(MonsterFDS[i].second[0], monsterResponse, sizeof(*monsterResponse));
            if(monsterResponse->mr_type != 0){
                ifAllReady = false;
            }

        }


        if(ifAllReady){
           // cout<<"Monsters and Player are ready!"<<endl;

        }else{
           // cout<<"Monsters or-and Player are not ready!"<<endl;
        }

        monsterCoordSort(monsters); // player wants sorted monster coords. also print_map wants sorted monsterCoords

        mapInfo->player = {playerXPosition, playerYPosition};
        mapInfo->map_width = widthOfTheRoom;
        mapInfo->map_height = heightOfTheRoom;
        mapInfo->door = {doorXPosition, doorYPosition};
        mapInfo->alive_monster_count = monsters.size();

        for(int t = 0; t < monsters.size(); t++){
            string monsterSym = monsters[t].getMonsterSymbol();
            int mx = monsters[t].getCoords().x;
            int my = monsters[t].getCoords().y;
            mapInfo->monster_types[t] = monsterSym[0];
            mapInfo->monster_coordinates[t].x = mx;
            mapInfo->monster_coordinates[t].y = my;
        }

        print_map(mapInfo);


        while(!gameOver){


            ///// Send playerMessage
            resetPlayerMessage(playerMessage);
            playerMessage->new_position = {playerXPosition, playerYPosition};
            playerMessage->game_over = gameOver;
            playerMessage->alive_monster_count = aliveMonsterCount;

            for(int i = 0; i < aliveMonsterCount; i++){
                playerMessage->monster_coordinates[i] = {monsters[i].getCoords().x, monsters[i].getCoords().y};
            }
            playerMessage->total_damage = totalDamagePlayerReceived;
            totalDamagePlayerReceived = 0;

            write(playerFD[0], playerMessage, sizeof (*playerMessage));
            //// Sample Player Stats at the beginning : health = 10, defence = 5, attack = 7.
            ///////////////////
            //// read player response////
            resetPlayerResponse(playerResponse);
            if(read(playerFD[0], playerResponse, sizeof (*playerResponse)) <= 0){
                // pipe on the other side is closed..
                gameOverStatus = go_left;
                gameOver = true;
                print_game_over(gameOverStatus);


            }else{

                if(playerResponse->pr_type == pr_move){
                    if(isCoordAvailable(monsters,{playerXPosition, playerYPosition},
                                        {widthOfTheRoom -1, heightOfTheRoom -1},
                                        playerResponse->pr_content.move_to, {doorXPosition, doorYPosition})){
                        // desired coord is available
                        playerXPosition = playerResponse->pr_content.move_to.x;
                        playerYPosition = playerResponse->pr_content.move_to.y;
                    }else{
                        // desired location is not available
                        // Do nothing...
                    }
                }else if(playerResponse->pr_type == pr_attack){
                    for(int i = 0; i < monsters.size(); i++){
                        int playersDamageToMonster = playerResponse->pr_content.attacked[i];
                        if(  playersDamageToMonster != 0){
                            // player attacks then reflect those attacks on monsters
                            monsters[i].setHealth(monsters[i].getHealth() - max(0, playersDamageToMonster - monsters[i].getDefence() ));
                            monsters[i].setDamage(playersDamageToMonster);
                        }
                    }

                }else if(playerResponse->pr_type == pr_dead){
                    gameOver = true;
                    gameOverStatus = go_died;
                }else{
                    cerr<< "It should not print this.."<<endl;
                }
                //////////////////////////
                ////////////////////////// send monsterMessage to every monster
                for(int i = 0; i < monsters.size(); i++){
                    monsterMessage->game_over = gameOver;
                    monsterMessage->new_position = monsters[i].getCoords();
                    monsterMessage->damage = monsters[i].getDamage();
                    monsterMessage->player_coordinate = {playerXPosition, playerYPosition};
                    ///// below finds this monsters pipe...
                    for(int p = 0; p < MonsterFDS.size(); p++){
                        if(monsters[i].getMonsterFDIndex() == MonsterFDS[p].first){
                            write(MonsterFDS[p].second[0], monsterMessage, sizeof(*monsterMessage));
                        }
                    }
                    ////

                }
                ////////////////////////////////////////
                //////////////////////////////////////// read MonsterResponses

                for(int i = 0; i < monsters.size(); i++){

                    // find current monster's socket pair to read from correct pipe
                    for(int al = 0; al < MonsterFDS.size(); al++){
                        if(MonsterFDS[al].first == monsters[i].getMonsterFDIndex()){
                            read(MonsterFDS[al].second[0], monsterResponse, sizeof(*monsterResponse));
                        }
                    }


                    // obtain responses and store them in monsterResponse vector
                    monsterResponseClass *mResponse = new monsterResponseClass();
                    mResponse->fdIndex = monsters[i].getMonsterFDIndex(); // so we will know this mResponses pipe
                    mResponse->mr_content.move_to = monsterResponse->mr_content.move_to;
                    mResponse->mr_content.attack = monsterResponse->mr_content.attack;
                    mResponse->mr_type = monsterResponse->mr_type;
                    responsesOfMonsters.push_back(*mResponse);
                }
                /// sort obtained responses ...
                monsterResponseCoordSort(responsesOfMonsters);
                //// process by sorted order..
                for(int i = 0; i < responsesOfMonsters.size(); i++){

                    // for this response find its monster by its index..


                    if(responsesOfMonsters[i].mr_type == mr_move){
                        // check if monster can move there...
                        if(isCoordAvailable(monsters, {playerXPosition, playerYPosition},
                                            {widthOfTheRoom -1, heightOfTheRoom -1},
                                            responsesOfMonsters[i].mr_content.move_to,
                                            {doorXPosition, doorYPosition})){
                            // desired coord is available...
                            for(int k = 0; k < monsters.size(); k++){
                                if(monsters[k].getMonsterFDIndex() == responsesOfMonsters[i].fdIndex){
                                    monsters[k].setCoordniate({responsesOfMonsters[i].mr_content.move_to});
                                }
                            }
                        }else{
                            // desired coords is not available...
                            /// do nothing it will return the old coordinate to monster since it was not updated...
                        }

                    }else if(responsesOfMonsters[i].mr_type == mr_attack){
                        // process attack to the player..
                        totalDamagePlayerReceived += responsesOfMonsters[i].mr_content.attack; ////@@ check this
                    }else if(responsesOfMonsters[i].mr_type == mr_dead){
                        // monster is dead do process..
                        wait(NULL);// wait for the monster to terminate...
                       // cout << "One of the child is terminated..."<<endl;
                        vector<int>  monstersIndicesToBeRemoved;
                        for(int k = 0; k < monsters.size(); k++){
                            if(monsters[k].getMonsterFDIndex() == responsesOfMonsters[i].fdIndex){
                                monstersIndicesToBeRemoved.push_back(k);

                            }
                        }

                        for(int q = 0; q < monstersIndicesToBeRemoved.size(); q++){
                            monsterRemoveAndSort(monsters, monsters[monstersIndicesToBeRemoved[q]].getCoords()); // remove the monster from the monsters vector.
                            numberOfMonsters -= 1;
                            aliveMonsterCount -= 1;
                        }

                        monstersIndicesToBeRemoved.clear();

                        if(aliveMonsterCount <= 0){
                            gameOver = true;
                            gameOverStatus =go_survived;
                        }

                    }else{
                        perror("it should not print this..");
                    }
                }
                ///////////////////////////////////////////
                // delete monsterResponses entries...
                responsesOfMonsters.clear();

                // print the map
                for(int i = 0; i < monsters.size(); i++){
                    mapInfo->monster_coordinates[i] = monsters[i].getCoords();
                    string monsterTy = monsters[i].getMonsterSymbol();
                    mapInfo->monster_types[i] = monsterTy[0];
                }
                mapInfo->alive_monster_count = monsters.size();
                mapInfo->door = {doorXPosition, doorYPosition};
                mapInfo->map_height = heightOfTheRoom;
                mapInfo->map_width = widthOfTheRoom;
                mapInfo->player = {playerXPosition, playerYPosition};

                print_map(mapInfo);

                if(playerXPosition == doorXPosition && playerYPosition == doorYPosition){
                    // player left game is over..
                    gameOver = true;
                    gameOverStatus = go_reached;
                }
                if(gameOver){
                    print_game_over(gameOverStatus);
                }
            }
        }
        //send game over signal to the monsters
        monsterMessage->game_over = true;
        for(int usf = 0; usf < monsters.size(); usf++){
            for(int j = 0; j < MonsterFDS.size(); j++){
                if(monsters[usf].getMonsterFDIndex() == MonsterFDS[j].first){
                    write(MonsterFDS[monsters[usf].getMonsterFDIndex()].second[0], monsterMessage, sizeof(*monsterMessage));
                    wait(NULL);
                }
            }
        }

        // some cleanup
        delete playerMessage;
        delete playerResponse;
        delete monsterMessage;
        delete monsterResponse;
        monsters.clear();
        delete mapInfo;

    }
    return 0;
}

/// TODO
//// 8. leaving durumu test edilebilirlik
//// 9. Daha fazla input ile test ...


















