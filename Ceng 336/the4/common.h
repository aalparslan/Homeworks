#ifndef COMMON_H
#define COMMON_H

#include "device.h"

#define _XTAL_FREQ   10000000
/***********************************************************************
 * ------------------------ Timer settings -----------------------------
 **********************************************************************/


#define _10MHZ	63320
#define _16MHZ	61768
#define _20MHZ	60768
#define _32MHZ	57768
#define _40MHZ 	55768


/***********************************************************************
 * ----------------------------- Events --------------------------------
 **********************************************************************/
#define ALARM_EVENT       0x80
#define LCD_EVENT         0x01


/***********************************************************************
 * ----------------------------- Alarms --------------------------------
 **********************************************************************/
#define ALARM_GAME_TASK          0       
#define ALARM_RCV_TASK           1      
#define LCD_ALARM_ID             2     
#define ALARM_TSK0               3     





/***********************************************************************
 * ----------------------------- Task ID -------------------------------
 **********************************************************************/

#define GAME_TASK_ID            1 
#define RCV_TASK_ID             2
#define LCD_ID                  5
#define TASK0_ID                6





// Priorities 
/* Lcd task and task0 are preempted by  receive task and game task */
#define RCV_TASK_PRIO   8
#define GAME_TASK_PRIO  8
#define LCD_PRIO        10
#define TASK0_PRIO      10




/***************************************************************************
 *                           GLOBALS                                       *
 ***************************************************************************/
// System state definitions
#define SIM_IDLE      0		// Simulator idle state
#define SIM_ACTIVE    1		// Simulator active state

#define WAITING_ 0
#define RUNNING_ 1

// receiving or sendign buffer sizes
#define TRANSMISSION_BUF_SIZE 100
#define RECEIVING_BUF_SIZE 100

/* Robot states */
#define MOVING  0          
#define TURNING_RIGHT 1
#define TURNING_LEFT 2
#define MAYSTOP 3
#define STOPPED 4



/***************************************************************************
 *                           FUNCTIONS                                       *
 ***************************************************************************/


void dataReceived(); // data will be received using serial communication this function is invoked when a receiving interrupt occurs.
void transmitBuffer_push(char *str,unsigned char size); // str is transmitted when this function is called.
unsigned char receiveBuffer_pop(char *str); // str is loaded with the command that is received and the command popped from receiving buffer


#endif

/* End of File : common.h */
