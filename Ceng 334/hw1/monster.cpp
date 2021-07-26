#include <iostream>
#include<fstream>
#include<vector>
#include <bits/stdc++.h>
#include<cstdlib>
#include<sys/socket.h>
#include<unistd.h>
#include<stdio.h>
#include<sys/wait.h>
#include "logging.h"

using namespace  std;
int distanceToPlayer(coordinate monsterCoord, coordinate playerCoord){
    int manhattanDistance = 0;
    if(monsterCoord.x > playerCoord.x){
        manhattanDistance += monsterCoord.x - playerCoord.x;
    }else{
        manhattanDistance += playerCoord.x - monsterCoord.x;
    }

    if(monsterCoord.y > playerCoord.y){
        manhattanDistance += monsterCoord.y - playerCoord.y;
    }else{
        manhattanDistance += playerCoord.y - monsterCoord.y;
    }

    return manhattanDistance;
}

coordinate getCloser(coordinate currentMonsterCoord, coordinate playerCoord){
    coordinate positionToBeMoved;
    coordinate up = {currentMonsterCoord.x, currentMonsterCoord.y -1}; // upper point
    coordinate upper_right = {currentMonsterCoord.x+1, currentMonsterCoord.y -1};
    coordinate right = {currentMonsterCoord.x+1, currentMonsterCoord.y};
    coordinate bottom_right = {currentMonsterCoord.x+1, currentMonsterCoord.y +1};
    coordinate down = {currentMonsterCoord.x, currentMonsterCoord.y +1};
    coordinate bottom_left = {currentMonsterCoord.x-1, currentMonsterCoord.y +1};
    coordinate left = {currentMonsterCoord.x-1, currentMonsterCoord.y};
    coordinate upper_left = {currentMonsterCoord.x-1, currentMonsterCoord.y -1};

    positionToBeMoved = up;
    if(distanceToPlayer(up,playerCoord) > distanceToPlayer(upper_right,playerCoord)){
        positionToBeMoved = upper_right;
    }

    if(distanceToPlayer(positionToBeMoved, playerCoord) > distanceToPlayer(right, playerCoord)){
        positionToBeMoved = right;
    }

    if(distanceToPlayer(positionToBeMoved, playerCoord) > distanceToPlayer(bottom_right, playerCoord)){
        positionToBeMoved = bottom_right;
    }

    if(distanceToPlayer(positionToBeMoved, playerCoord) > distanceToPlayer(down, playerCoord)){
        positionToBeMoved = down;
    }

    if(distanceToPlayer(positionToBeMoved, playerCoord) > distanceToPlayer(bottom_left, playerCoord)){
        positionToBeMoved = bottom_left;
    }

    if(distanceToPlayer(positionToBeMoved, playerCoord) > distanceToPlayer(left, playerCoord)){
        positionToBeMoved = left;
    }

    if(distanceToPlayer(positionToBeMoved, playerCoord) > distanceToPlayer(upper_left, playerCoord)){
        positionToBeMoved = upper_left;
    }

    return positionToBeMoved;

}

int main(int argc, char* argv[]){

    int health = atoi(argv[1]);
    int attackPower = atoi(argv[2]);
    int defence = atoi(argv[3]);
    int rangeOfAttack = atoi(argv[4]);

    ///// initial settings for monster
    int damage = 0;
    bool gameOver = false;
    monster_response* monsterResponse = new monster_response;
    monster_message*  monsterMessage = new monster_message;
    coordinate currentMonsterCoord;
    coordinate playerCoord;
    monsterResponse->mr_content.move_to = {0,0};
    monsterResponse->mr_content.attack = 0;
    monsterResponse->mr_type = mr_ready;



    /// send initial ready response...
    write(1,monsterResponse, sizeof(*monsterResponse) ); /// write to the stdout

	while(1){

    ////// read monsterMessage...
        read(0,monsterMessage, sizeof(*monsterMessage) ); /// read from stdinput
        damage = monsterMessage->damage;
        health = (health - max(0, damage - defence)); // health calculation
        gameOver = monsterMessage->game_over;
        playerCoord = monsterMessage->player_coordinate;
        currentMonsterCoord = monsterMessage->new_position;

    //////////////////////////////////////////////////////////////
    //////////////// send monsterResponse...
        if(gameOver){
            usleep(10000);
            return 0;
        }

        if(health <= 0){
            // monster is dead
            monsterResponse->mr_type = mr_dead;
            write(1,monsterResponse, sizeof(*monsterResponse));
            usleep(10000);
            return 0; // terminate
        }else{
            // monster is still alive!
            if(distanceToPlayer(currentMonsterCoord, playerCoord) <= rangeOfAttack){
                // monster can attack
                monsterResponse->mr_type = mr_attack;
                monsterResponse->mr_content.attack = attackPower;
            }else{
                // monster needs to get closer to the player
                monsterResponse->mr_type = mr_move;
                monsterResponse->mr_content.move_to = getCloser(currentMonsterCoord, playerCoord); // this coordinate just a request game world will take care possibly.
            }
        }

        write(1,monsterResponse, sizeof(*monsterResponse));

	}



	return 0;
}
