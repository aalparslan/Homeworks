// Alparslan Yesilkaya  - 2237923
#include"common.h"

/**********************************************************************
 *------------------------ COMMON  --------------------------------------
 * Contains functions and variables that are used globally
 **********************************************************************/

/**********************************************************************
 *------------------------ COMMON FUNTIONAILTY --------------------------------------
 * dataReceived()      ===>  Triggered by interrupt routine when any data is received by  serial communication. Data is parsed and pointers are moved accordingly.
 * transmitBuffer_push ===>  Send its argument str via serial communication. Pointers are moved accordingly. Causes a send interrupt.
 * receiveBuffer_pop   ===>  Its argument str is loaded with the current data and data is removed from original buffer. Pointers are moved accordingly.
 **********************************************************************/


/**********************************************************************
 * ----------------------- GLOBAL VARIABLES ---------------------------
 **********************************************************************/

char transmissionBuffer[TRANSMISSION_BUF_SIZE];     // buffer for transmitting data by pop_send and push_send pointers
char receivingBuffer[RECEIVING_BUF_SIZE];           // buffer for receiving data by pop_receive and push_receive pointers
unsigned char push_receive = 0 ;                    // receivingBuffer pointer for implementing ring buffer logic
unsigned char pop_receive = 0;                      // receivingBuffer pointer for implementing ring buffer logic
unsigned char push_send = 0;                        // transmissionBuffer pointer for implementing ring buffer logic
unsigned char pop_send = 0;                         // transmissionBuffer pointer for implementing ring buffer logic
unsigned char locky = 0;                            // for locking critical sections in the program
char state_of_receiving = WAITING_;                 // receiving buffer state
int i =0;                                           // regular vars for looping
int j =0;
char systemState = SIM_IDLE;                        // system state during the execution
int x = 0, y = 0;
int metal_x, metal_y, metal_type;                   // for holding metal coords and type
char robotState = MAYSTOP;                          // robot state during the execution
int robotDegree = 270;                              // robot angle by the positive x axis.  changes by multiple of 90 degrees.
int total_metal_appeared = 0;                       // info appearance of total metal number in a particular moment
int remove_x = -1;                                  // for values of -1 do not perform any removal
int remove_y = -1;                                  // if they are changed then do the removal... after removal set it back to -1
int game_time = 0;                                  // holds total commands number executed so far. used for  removal of metals from the LCD screen
int is_array_all_visited = 0;                       // 0 if there are metals to be received 1 otherwise
#pragma        udata      ydata                        // for inreasing data stack
char string_pool[4][16] = {"      GOLD      ", "      RUSH      ", "                ", "                "}; // any change to this array will be reflected to the LCD
int is_lcd_changed = 1;                             // 0 for no, 1 for yes      if 1 task0 updates the LCD screen
short int lcdFlip = 0;                              // 0 for no, 1 for yes
short int RB4ispressed = 0;                         // 0 if not pressed currently, 1 if pressed currently

int is_transmitting = 0;                            // 0 for no 1 for yes
int interrupt_var =  0;                             // for regulating data transmission
int delay_var = 0;                                  // for satisfying the 50ms - 150ms time condition between commands


/**********************************************************************
 * ----------------------- FUNCTIONS THAT ARE USED GLOBALLY  ----------
 **********************************************************************/

// for satisfying the 50ms - 150ms time condition between commands
void at_least_50ms_delay_between_commands(){
    delay_var = 0;
    for(delay_var = 0; delay_var < 10000; delay_var++){
    }
    delay_var = 0;
}


// Triggered by the interrupt routine when data is received
void dataReceived(){
       
    unsigned char received_byte = RCREG;

    if((state_of_receiving == WAITING_) && (received_byte == '$')){
        receivingBuffer[push_receive] = received_byte;
        push_receive = (push_receive+1)%RECEIVING_BUF_SIZE;
        state_of_receiving = RUNNING_;
    }else if((state_of_receiving == RUNNING_) && received_byte != ':'){
        receivingBuffer[push_receive] = received_byte;
        push_receive = (push_receive+1)%RECEIVING_BUF_SIZE;
    }else if((state_of_receiving == RUNNING_) && (received_byte == ':')){
         receivingBuffer[push_receive] = received_byte;
         push_receive = (push_receive+1)%RECEIVING_BUF_SIZE;
         state_of_receiving = WAITING_;
    }
    
}



void transmitBuffer_push(char *str,unsigned char size){
    locky = 1; // lock the section
    i = 0;

    while(i < size){
        transmissionBuffer[push_send] = str[i];

        push_send = (push_send+1)%TRANSMISSION_BUF_SIZE;
        i++;

    }
    locky = 0; // release the lock

    //transmitData();
    is_transmitting = 1;
    i = 0;
    
    while(i <= size  ){ //loop as much as the size and wait for last interrupt to arrive.
        if(interrupt_var == 0){
            if(size == i){
                break;
            }
            if(pop_send != push_send && !locky){ // if there is data
                interrupt_var = 1;
                TXREG = transmissionBuffer[pop_send];
                pop_send = (pop_send+1)%TRANSMISSION_BUF_SIZE;
                TXSTAbits.TXEN = 1;
                
                i++;
            }
        }
    }
    //at_least_50ms_delay_between_commands();
    i = 0;
    is_transmitting = 0;
}

unsigned char receiveBuffer_pop(char *str){ // returns the length of the string
    j =0;
    while(receivingBuffer[pop_receive] != '$' && pop_receive != push_receive ){// if r buffer is not empty and not $
        pop_receive = (pop_receive+1)%RECEIVING_BUF_SIZE; // move the pointer
    }
    if(pop_receive == push_receive){
        return 0; // nothing to receive
    }
    pop_receive = (pop_receive+1)%RECEIVING_BUF_SIZE; // move the pointer to pass $
   
    while(receivingBuffer[pop_receive] != ':' && pop_receive != push_receive ){
        str[j] = receivingBuffer[pop_receive];
        j++;
        pop_receive = (pop_receive+1)%RECEIVING_BUF_SIZE;
    }
    if(pop_receive == push_receive ){return 0;} // if this happens string did not end with :
    
     pop_receive = (pop_receive+1)%RECEIVING_BUF_SIZE; // skip :
     return j;
}
