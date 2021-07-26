
//Alparslan Yesilkaya - 2237923
#include "common.h"
#include "LCD.h"

/**********************************************************************
 *------------------------ TASK0  --------------------------------------
 * if is_lcd_changes is 1 updates the LCD by the content of string_pool
 **********************************************************************/


/**********************************************************************
 * -----------------------  Variables ----------------------------
 **********************************************************************/

extern char string_pool[4][16];
extern int is_lcd_changed;


/**********************************************************************
 * ------------------------------ TASK0 -------------------------------
 * 
 * Writes various strings to LCD 
 * 
 **********************************************************************/
TASK(TASK0)
{
    SetRelAlarm(ALARM_TSK0, 100, 350);
    while(1){
        WaitEvent(ALARM_EVENT);
        ClearEvent(ALARM_EVENT);
        if(is_lcd_changed == 1){
            ClearLCDScreen();
            LcdPrintString(string_pool[0], 0, 0);
            LcdPrintString(string_pool[1], 0, 1);
            LcdPrintString(string_pool[2], 0, 2);
            LcdPrintString(string_pool[3], 0, 3);            
            is_lcd_changed = 0;            
        }
       
    }

    TerminateTask();
}

/* End of File : tsk_task0.c */
