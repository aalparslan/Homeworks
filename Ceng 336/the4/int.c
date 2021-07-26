//Alparslan Yesilkaya - 2237923
#include "common.h"

extern short int lcdFlip;
extern short int RB4ispressed;
extern int is_lcd_changed;
extern int interrupt_var;
/**********************************************************************
 * Function you want to call when an IT occurs.
 **********************************************************************/
  extern void AddOneTick(void);
/*extern void MyOwnISR(void); */
  void InterruptVectorL(void);
  void InterruptVectorH(void);

/**********************************************************************
 * General interrupt vector. Do not modify.
 **********************************************************************/
#pragma code IT_vector_low=0x18
void Interrupt_low_vec(void)
{
   _asm goto InterruptVectorL  _endasm
}
#pragma code

#pragma code IT_vector_high=0x08
void Interrupt_high_vec(void)
{
   _asm goto InterruptVectorH  _endasm
}
#pragma code

/**********************************************************************
 * General ISR router. Complete the function core with the if or switch
 * case you need to jump to the function dedicated to the occuring IT.
 * .tmpdata and MATH_DATA are saved automaticaly with C18 v3.
 **********************************************************************/
#pragma	code _INTERRUPT_VECTORL = 0x003000
#pragma interruptlow InterruptVectorL 
void InterruptVectorL(void)
{
	EnterISR();
	
	if (INTCONbits.TMR0IF == 1)
		AddOneTick();
	/* Here are the other interrupts you would desire to manage */
	if (PIR1bits.TXIF == 1) {
//        transmitData();
        //if(still have chars to send)
        //{
            //TXREG = blahblah; // do another load normally this would clear the interrupt in hardware in real life. picsim doesnt do this for some reason.
        //PIR1bits.TXIF = 0;
        //}
        //else
        //{
        //PIR1bits.TXIF = 0; // You only need to do this on picsim. normally this would have no effect in PIC, this flag cannot be cleared by software. only way to clear the interrupt is load another char on TXREG or unset TXSTAbits.TXEN. this feature is probably not correctly implemented in picsim
        //???TXSTAbits.TXEN = 0; // you do this both for picsim and real life to terminate the transmission. 
        //}
        PIR1bits.TXIF = 0;
        TXSTAbits.TXEN = 0;
        interrupt_var = 0; // intrrupt is handled.
	}
	if (PIR1bits.RCIF) {
        // receiving is the same for both picsim and real life.
        dataReceived();
		PIR1bits.RCIF = 0;	// clear RC1IF flag
	}
    

    
    
    if (RCSTAbits.OERR)
    {
        RCSTAbits.CREN = 0;
        RCSTAbits.CREN = 1;
    }
    
    if(INTCONbits.RBIF == 1){
        if(PORTBbits.RB4){
            RB4ispressed = 1;            
        }else if(!PORTBbits.RB4 && RB4ispressed){ // if rb4 is released
            RB4ispressed = 0;
            if(lcdFlip == 0){
                lcdFlip = 1;
            }else{
                lcdFlip = 0; 
            }
            is_lcd_changed = 1;
        }
        INTCONbits.RBIF = 0; // silent the interrupt
    }
	LeaveISR();
}
#pragma	code

/* BE CARREFULL : ONLY BSR, WREG AND STATUS REGISTERS ARE SAVED  */
/* DO NOT CALL ANY FUNCTION AND USE PLEASE VERY SIMPLE CODE LIKE */
/* VARIABLE OR FLAG SETTINGS. CHECK THE ASM CODE PRODUCED BY C18 */
/* IN THE LST FILE.                                              */
#pragma	code _INTERRUPT_VECTORH = 0x003300
#pragma interrupt InterruptVectorH nosave=FSR0, TBLPTRL, TBLPTRH, TBLPTRU, TABLAT, PCLATH, PCLATU, PROD, section(".tmpdata"), section("MATH_DATA")
void InterruptVectorH(void)
{
  if (INTCONbits.INT0IF == 1)
    INTCONbits.INT0IF = 0;
}
#pragma	code



extern void _startup (void);
#pragma code _RESET_INTERRUPT_VECTOR = 0x003400
void _reset (void)
{
    _asm goto _startup _endasm
}
#pragma code


/* End of file : int.c */
