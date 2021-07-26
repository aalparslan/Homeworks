//Alparslan Yesilkaya - 2237923
#include"common.h"


/**********************************************************************
 *------------------------ GAME TASK  --------------------------------
 * Sends commands by the hemp of transmitBuffer_push
 * Calculates the next move of the robot.
 * Determines robot state and system state based on current state.
 **********************************************************************/

/**********************************************************************
 *------------------------ GAME TASK FUNTIONAILTY ---------------------
 * moveForward()       ===>  Sends move forward command
 * turnRight()         ===>  Sends turn right command
 * turnLeft()          ===>  Sends turn left command
 * gotoMetalinThisHalf ===>  Robot goes towards the metal at the left side or right of the obstacle in the middle depending on where the robot is
 * determineHalves     ===>  Determines if the robot is on the left or on the right of the middle obstacle
 * markVisited         ===>  Marks the metals for the removal that will be performed later.
 * deneme              ===>  Main logic of the game task. Determines which function to execute, which commands to send and end the program.
 **********************************************************************/


/**********************************************************************
 * ----------------------- GLOBAL VARIABLES ---------------------------
 **********************************************************************/


char transmission_buffer[TRANSMISSION_BUF_SIZE];            // all the data to be trasmitted is hold here. Used as ring buffer by the help of pop and push pointers
extern char robotState;                                     // robot state during the execution
extern char systemState;                                    // system state during the execution
extern int x;
extern int y; 
extern int robotDegree;                                     // robot angle by the positive x axis.  changes by multiple of 90 degrees.
extern int metal_x, metal_y, metal_type;                    // for holding metal coords and type
extern unsigned char pop_send;                              // transmissionBuffer pointer for implementing ring buffer logic
extern unsigned char push_send;                             // transmissionBuffer pointer for implementing ring buffer logic
int quadrant = 0;                                           // 1 for first, 2 for second, 3 for third, 4 for fouth quadrants. 0 is unset
char same_xs = 0;                                           // x values of the robot and the metal is the same
char same_ys = 0;                                           // y values of the robot and the metal is the same
int k = 0;
extern int is_transmitting;                                 // 0 for no 1 for yes. If yes then execution must wait
extern int total_metal_appeared;                            // info appearance of total metal number in a particular moment
extern int remove_x;                                        // for values of -1 do not perform any removal
extern int remove_y;                                        // if they are changed then do the removal... after removal set it back to -1
extern int game_time;                                       // holds total commands number executed so far. used for  removal of metals from the LCD screen
extern int is_array_all_visited;                            // 0 if there are metals to be received 1 otherwise
extern char string_pool[4][16];                             // any change to this array will be reflected to the LCD
char var1 = 0;                                              // 0 unset,
                                                            // 1 robot is on the left half metal is on the right half,
                                                            // 2 is robot is on the right half, metal is on the left half,
                                                            // 3 is they are in the same half




/**********************************************************************
 * -----------------------  FUNCTIONS ---------------------------------
 **********************************************************************/


void moveForward(){ // robot moves 1 cell
    k = 0;
    while (k < 10){
        if( is_transmitting == 0){ // if there is data to sent wait it ti be sent.
            transmission_buffer[0] = '$';
            transmission_buffer[1] = 'F';
            transmission_buffer[2] = ':';   
            transmitBuffer_push(transmission_buffer,3);  
            k++;
            game_time = game_time + 1;
            
        }        
    }
    k = 0;
}
void turnRight(){ // robot turns 90 degrees to right
    k = 0;
    while (k < 10){
        if(is_transmitting == 0){ // if there is data to sent wait it ti be sent.
            transmission_buffer[0] = '$';
            transmission_buffer[1] = 'R';
            transmission_buffer[2] = ':';   
            transmitBuffer_push(transmission_buffer,3);
            k++;
            game_time = game_time + 1;
                     
        }        
    }
    k = 0;
    if(robotDegree == 0){ // update the robot degree
        robotDegree = 270;
    }else{
        robotDegree = robotDegree - 90;
    }
}

void turnLeft(){// robot turns 90 degrees to left
    k = 0;
    while (k < 10){
        if(is_transmitting == 0){ // if there is data to sent wait it ti be sent.
            transmission_buffer[0] = '$';
            transmission_buffer[1] = 'L';
            transmission_buffer[2] = ':';   
            transmitBuffer_push(transmission_buffer,3);  
            k++;
            game_time = game_time + 1;    
                      
        }        
    }
    k = 0;    
    if(robotDegree == 270){ // update the robot degree
        robotDegree = 0;
    }else{
        robotDegree = robotDegree + 90;
    }    
}

void gotoMetalinThisHalf(){
    
    if(robotDegree == 0){
        if(same_xs){
            if(quadrant == 1){
                turnLeft();
            }else if(quadrant == 4){
                turnRight();
            }else{
                quadrant = quadrant; // mistake@@@
            }
            same_xs = 0;
        }else if(same_ys){
            if(quadrant == 3){
                turnLeft();
                turnLeft();
            }else if(quadrant == 4){
                moveForward();
                x = x+1;
            }else{
                quadrant = quadrant; // mistake@@@
            }                    
            same_ys = 0;
        }else{
            if(quadrant == 1){
                moveForward();
                x = x +1;
            }
            else if (quadrant == 2){
                turnLeft();
            }
            else if(quadrant == 3){
                turnRight();
            }
            else if(quadrant == 4){
                moveForward();
                x = x+1;
            }else{
                quadrant = quadrant; // mistake@@@ 
            }
        }

    }
    else if(robotDegree == 90){
        if(same_xs){
            if(quadrant == 1){
                moveForward();
                y = y - 1;
            }else if(quadrant == 4){
                turnRight();
                turnRight();
            }else{
                quadrant = quadrant; // mistake@@@
            }
            same_xs = 0;
        }else if(same_ys){
            if(quadrant == 3){
                turnLeft();
            }else if(quadrant == 4){
                turnRight();
            }else{
                quadrant = quadrant; // mistake@@@
            }                    
            same_ys = 0;
        }else{
            if(quadrant == 1){
                moveForward();
                y = y - 1;
            }
            else if (quadrant == 2){
                moveForward();
                y = y - 1;
            }
            else if(quadrant == 3){
                turnLeft();
            }
            else if(quadrant == 4){
                turnRight();
            }else{
                quadrant = quadrant; // mistake@@@ 
            }
        }                 
    }
    else if(robotDegree == 180){
        if(same_xs){
            if(quadrant == 1){
                turnRight();
            }else if(quadrant == 4){
                turnLeft();
            }else{
                quadrant = quadrant; // mistake@@@
            }
            same_xs = 0;
        }else if(same_ys){
            if(quadrant == 3){
                moveForward();
                x = x-1;
            }else if(quadrant == 4){
                turnRight();
                turnRight();
            }else{
                quadrant = quadrant; // mistake@@@
            }                    
            same_ys = 0;
        }else{
            if(quadrant == 1){
                turnRight();
            }
            else if (quadrant == 2){
                moveForward();
                x = x - 1;
            }
            else if(quadrant == 3){
                moveForward();
                x = x-1;
            }
            else if(quadrant == 4){
                turnLeft();
            }else{
                quadrant = quadrant; // mistake@@@ 
            }
        }                    
    }
    else if(robotDegree == 270){
        if(same_xs){
            if(quadrant == 1){
                turnLeft();

            }else if(quadrant == 4){
                moveForward();
                y = y + 1;
            }else{
                quadrant = quadrant; // mistake@@@
            }
            same_xs = 0;
        }else if(same_ys){
            if(quadrant == 3){
                turnRight();
            }else if(quadrant == 4){
                turnLeft();
            }else{
                quadrant = quadrant; // mistake@@@
            }                    
            same_ys = 0;
        }else{
            if(quadrant == 1){
                turnLeft();
            }
            else if (quadrant == 2){
                turnRight();
            }
            else if(quadrant == 3){
                moveForward();
                y = y + 1;
            }
            else if(quadrant == 4){
                moveForward();
                y = y + 1;
            }else{
                quadrant = quadrant; // mistake@@@ 
            }
        }                 
    }
    else{
        robotDegree = robotDegree; // error check the algorithm
    }    
}

char determineHalves(){
    if( x <= 6 && metal_x >= 7){
        var1 = 1;
    }else if( x >= 7 && metal_x <= 6){
        var1 = 2;
    }else{
        var1 = 3;
    }
}

void markVisited(int coord1, int coord2){
    remove_x = coord1;
    remove_y = coord2;
}


void deneme(){
    if(robotState == MAYSTOP && systemState == SIM_ACTIVE && !(total_metal_appeared == 25 && is_array_all_visited == 1)){
        transmission_buffer[0] = '$';
        transmission_buffer[1] = 'S';
        transmission_buffer[2] = ':';   
        transmitBuffer_push(transmission_buffer,3);         
        game_time = game_time + 1;
        
    }else if(total_metal_appeared == 25 && is_array_all_visited == 1 && robotState != STOPPED){
        robotState = STOPPED;
        systemState = SIM_IDLE;
        transmission_buffer[0] = '$';
        transmission_buffer[1] = 'E';
        transmission_buffer[2] = 'N';   
        transmission_buffer[3] = 'D';
        transmission_buffer[4] = ':';
        transmitBuffer_push(transmission_buffer,5);         
    }
    else if(robotState == MOVING && systemState == SIM_ACTIVE){
        if(x == metal_x && y == metal_y){
            // pick the metal.
            k = 0;
            while(k <1){
                if(TXSTAbits.TXEN == 0){
                    transmission_buffer[0] = '$';
                    transmission_buffer[1] = 'P';
                    transmission_buffer[2] = ':';   
                    transmitBuffer_push(transmission_buffer,3); 
                    robotState = MAYSTOP;                    
                    k++;
                    markVisited(metal_x, metal_y);
                    game_time = game_time + 1;
                }                
            }

        }
        else{
            
            
            
            if (x == metal_x){
                same_xs = 1; 
            }else if (y == metal_y){
                same_ys = 1;
            } 
            
            
            if(x - metal_x > 0){
                if(y - metal_y > 0){
                    // metal is in the 2nd quadrant
                    quadrant = 2;
                }else{
                    // metal is in the 3rd quadrant 
                    quadrant = 3;
                }
            }else{
                if(y - metal_y > 0){
                    // metal is in the 1st quadrant
                    quadrant = 1;
                }else{
                    // metal is in the 4th quadrant 
                    quadrant = 4;
                }                    
            }       
            
            determineHalves();

            ////////// Align  the  robot with the middle hole if needed
            if(var1 == 1){
                if(y < 1){
                    if(robotDegree == 0){
                        turnRight();
                    }else if(robotDegree == 90){
                        turnRight();
                    }else if(robotDegree == 180){
                        turnLeft();
                    }else if(robotDegree == 270){
                        moveForward();
                        y = y+1;
                    }
                }
                else if(y == 1){
                    if(robotDegree == 0){
                        moveForward();
                        x = x +1;
                    }else if(robotDegree == 90){
                        turnRight();
                    }else if(robotDegree == 180){
                        turnRight();
                    }else if(robotDegree == 270){
                        turnLeft();
                    }                    
                }else{
                    if(robotDegree == 0){
                        turnLeft();
                    }else if(robotDegree == 90){
                        moveForward();
                        y = y -1;
                    }else if(robotDegree == 180){
                        turnRight();
                    }else if(robotDegree == 270){
                        turnRight();
                    }                    
                }
            }
            else if(var1 == 2){
                if(y < 1){
                    if(robotDegree == 0){
                        turnRight();
                    }else if(robotDegree == 90){
                        turnRight();
                    }else if(robotDegree == 180){
                        turnLeft();
                    }else if(robotDegree == 270){
                        moveForward();
                        y = y + 1;
                    }
                }
                else if(y == 1){
                    if(robotDegree == 0){
                        turnRight();
                    }else if(robotDegree == 90){
                        turnLeft();
                    }else if(robotDegree == 180){
                        moveForward();
                        x = x - 1;
                    }else if(robotDegree == 270){
                        turnRight();
                    }                    
                }else{
                    if(robotDegree == 0){
                        turnLeft();
                    }else if(robotDegree == 90){
                        moveForward();
                        y = y + 1;
                    }else if(robotDegree == 180){
                        turnRight();
                    }else if(robotDegree == 270){
                        turnRight();
                    }                    
                }                 
            }
            else{ 
              /// if metal and the robot are in the same half. 
                 gotoMetalinThisHalf();
            }            
        }
    }
}




TASK(GAME_TASK) 
{ 
	PIE1bits.RCIE = 1;	// enable USART receive interrupt
 


	SetRelAlarm(ALARM_GAME_TASK, 10, 70);
	/* This is the alarm that triggers updateSituation function with average of 70 ms*/
	while(1) {
        WaitEvent(ALARM_EVENT);
        ClearEvent(ALARM_EVENT);
        deneme();
                       
	}
	TerminateTask();
}
