//Alparslan Yesilkaya - 2237923
#include"common.h"

/**********************************************************************
 *------------------------ RECEIVE TASK  --------------------------------------
 * Processes the received data continuously
 * Parses the data
 * Changes the robot and system state for later processing of game task
 * Determines closest target
 **********************************************************************/

/**********************************************************************
 *------------------------ RECEIVE TASK -------------------------------
 * clear_string_pool()     ===>  Clears the string pool array
 * checkIfarrayAllVisited  ===>  Continuously checks if all the metals are visited or removed from the map
 * arrayNotVisited         ===>  Checks if still metals that are not visited
 * performRemoval          ===>  Continuously traces the array for removal of metals.
 * getClosest              ===>  By tracing the array of metals finds the closest one by Manhattan distance.
 * parseResponse           ===>  Parses the received data and determines execution of the data by its content. Sets the state informtion
 **********************************************************************/





/**********************************************************************
 * ----------------------- GLOBAL VARIABLES ---------------------------
 **********************************************************************/
char data_size;                         // data is stored temporarily by this var in the parse funtions
char rcvBuffer[RECEIVING_BUF_SIZE];     // all the received data is hold here. Used as ring buffer by the help of pop and push pointers
extern char systemState;                // system state during the execution
extern int metal_x, metal_y;            // for holding metal coords and type
extern char robotState;                 // robot state during the execution
int new_metal_x, new_metal_y;           // for holding newly received metal data
extern int x, y;
extern int total_metal_appeared;        // info appearance of total metal number in a particular moment
int tt =0;
extern char string_pool[4][16];         // any change to this array will be reflected to the LCD
extern int is_lcd_changed;              // 0 for no, 1 for yes      if 1 task0 updates the LCD screen

#pragma        udata      xdata            // for inreasing data stack
typedef struct{                         // represents a metal
    int point_x;
    int point_y;
    int inital_time;
    int is_visited;                     // 7 for yes otherwise no
}point;

point array[25];                        // holds all the 25 expected metal information
extern int remove_x;                    // for values of -1 do not perform any removal
extern int remove_y;                    // if they are changed then do the removal... after removal set it back to -1
extern int game_time;                   // holds total commands number executed so far. used for  removal of metals from the LCD screen
extern int is_array_all_visited;        // 0 if there are metals to be received 1 otherwise
int notvisited ;



/**********************************************************************
 * ----------------------- FUNCTIONS -----------------------------------
 **********************************************************************/
void clear_string_pool(){
    tt = 0;
    for(tt = 0; tt < 16; tt++){
        string_pool[0][tt] = ' ';
    }
    tt = 0;
    for(tt = 0; tt < 16; tt++){
        string_pool[1][tt] = ' ';
    }
    tt = 0;
    for(tt = 0; tt < 16; tt++){
        string_pool[2][tt] = ' ';
    }
    tt = 0;
    for(tt = 0; tt < 16; tt++){
        string_pool[3][tt] = ' ';
    }
    tt = 0;
    
    string_pool[0][7] = 0xFF;
    string_pool[2][7] = 0xFF;
    string_pool[3][7] = 0xFF;
}

void checkIfarrayAllVisited(){
    tt = 0;
    for(tt = 0; tt < total_metal_appeared; tt++){
        if(array[tt].is_visited != 7){ // even if one of the metals is still in the list then not all is visited.
            is_array_all_visited = 0;
            return;
        }
    }
    is_array_all_visited = 1;
}

void arrayNotVisited(){
    tt = 0;
    notvisited =0;
    for(tt = 0; tt < total_metal_appeared; tt++){
        if(array[tt].is_visited != 7){ // even if one of the metals is still in the list then not all is visited.
            
            notvisited =notvisited + 1;
        }
    }
    if(notvisited == 0){
        is_array_all_visited = 1;
    }else{
        is_array_all_visited = 0;
    }
    
}

void performRemoval(){
    if(remove_x != -1 && remove_y != -1){ // removal if it is picked up
        tt = 0;
        for(tt = 0; tt < total_metal_appeared; tt++){
            if(array[tt].is_visited != 7 && array[tt].point_x == remove_x && array[tt].point_y == remove_y ){
                array[tt].is_visited = 7; // mark as visited.
                string_pool[remove_y][remove_x] = ' ';
                is_lcd_changed = 1;
                remove_x = -1;
                remove_y = -1;
                break;
            }
        }
    }
    tt = 0;
    for(tt =0; tt < total_metal_appeared; tt++){ // removal if the metal is already disappeared!
        if(array[tt].is_visited != 7 && ( game_time - array[tt].inital_time) > 100){
           array[tt].is_visited = 7;
           string_pool[array[tt].point_y][array[tt].point_x] = ' ';
           is_lcd_changed = 1;
        }
    }
    
}

int abs_distance(int k1, int k2, int l1, int l2){

    if(k1 >= l1){
        if(k2 >= l2){
            return (k1 - l1) + (k2 - l2);
        }else{
            return (k1 - l1) + (l2 - k2);
        }
    }else{
        if(k2 >= l2){
            return (l1 - k1) + (k2 - l2);
        }else{
            return (l1 - k1) + (l2 - k2);
        }
    }
}

void getClosest(){  // only fills up the new_metal_xy with the closest point coords if there is such point
    int dist = 100;
    point closest;
    tt =0;
    for(tt = 0; tt  < total_metal_appeared; tt++){
        if(array[tt].is_visited != 7 && abs_distance(x,y, array[tt].point_x, array[tt].point_y) < dist){
            dist = abs_distance(x,y, array[tt].point_x, array[tt].point_y);
            closest.point_x = array[tt].point_x;
            closest.point_y = array[tt].point_y;
        }
    }
    if(dist != 100){
        new_metal_x = closest.point_x;
        new_metal_y = closest.point_y;
    }else{
        new_metal_x = metal_x;
        new_metal_y = metal_y;
    }

}

void parseResponse(){
    data_size = receiveBuffer_pop(rcvBuffer); // this fills up the rcvBuffer
    if(!data_size){
        return; // no data then just return
    }
    
    
    
    if(rcvBuffer[0] == 'A' ){ // put all the 25 metals to the array. Later process them.
        array[total_metal_appeared].point_x = ( rcvBuffer[1]);
        array[total_metal_appeared].point_y = (rcvBuffer[2]);
        array[total_metal_appeared].is_visited = 0;
        array[total_metal_appeared].inital_time = game_time;
        total_metal_appeared = total_metal_appeared +1;
        
        if(rcvBuffer[3] == 1){ // gold
            string_pool[rcvBuffer[2]][rcvBuffer[1]] = 'G';
            is_lcd_changed = 1;
        }else{ // silver
            string_pool[rcvBuffer[2]][rcvBuffer[1]] = 'S';
            is_lcd_changed = 1;
        }
        
    }

    
    if(rcvBuffer[0] == 'G' && rcvBuffer[1] == 'O'){
        systemState = SIM_ACTIVE;
        robotState = MAYSTOP;
        clear_string_pool();
        is_lcd_changed = 1;
    }
    else if(rcvBuffer[0] == 'A' && robotState == MAYSTOP){
        // sensor response...
        //AXYT:
        getClosest();
        metal_x = new_metal_x;
        metal_y = new_metal_y;
        robotState = MOVING;
    }else if(rcvBuffer[0] == 'A' && robotState == MOVING){
        getClosest();
        if(abs_distance(x,y,new_metal_x,new_metal_y) < abs_distance(x,y,metal_x,metal_y) && new_metal_x){ // there is a metal which is closer
            robotState = MAYSTOP;
        }
    }
}
TASK(RCV_TASK)
{
    //PIE1bits.TX1IE = 1;    // enable USART transmit interrupt
    PIE1bits.RCIE = 1;    // enable USART receive interrupt
    
    SetRelAlarm(ALARM_RCV_TASK, 10, 70); // this is the alarm that triggers receive task
    while(1) {
        WaitEvent(ALARM_EVENT);
        ClearEvent(ALARM_EVENT);
        parseResponse();
        performRemoval();
        checkIfarrayAllVisited();
        arrayNotVisited();
       
        
    }
    TerminateTask();
}
