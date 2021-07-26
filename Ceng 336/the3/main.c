







#include "pragmas.h"

#include "ADC.h"
#include "LCD.h"
#include <string.h>
#include <stdio.h>

volatile char isRB0Pressed=0;
volatile int adc_val=0;
volatile char adc_interrupted =0;
volatile int disp1= -1;
volatile int disp2= -1;
volatile int disp3= -1;
volatile int password_disp_level = 0;
volatile char isTheNumberSet = 0;
int stateNumber = 0; // 0 for password set state, 1 for password check state, 2 for fail state, 3 for success state.
int password1 = 0;
int password2 = 0;
int password3 = 0;
volatile int tmr1PostScaler = 0;
const unsigned tmr0_initial_val = 0;
const unsigned tmr1_initial_val = 8000;
volatile int count_down = 90;
volatile char isCountDownStarted = 0;
volatile char sevenSegNumber = 2;// 2 is for disp2, 3 is for disp3 4 is for disp4.
int numberOfTries = 3;
volatile int k = 10;
unsigned int tmr0interrupted = 0;
unsigned int tmr1interrupted = 0;
unsigned int adcinterrupted = 0;
int disp7seg_1 = 0;
int disp7seg_2 = 0;
int disp7seg_3 = 9;
int disp7seg_4 = 0;
int isLCDChanged = 1;
int prev_adc_val = 0;
int ms500 = 0 ;
int startToggleRBs = 0;
int samplingSwitch = 0;  // 0 for adc_val, 1 for thermo.
int thermo_adc_val = 0;
int isDialConverting = 0;
int IsSecondSamplerON = 0;
int justFailed = 0;
int justSucceeded = 0;
volatile int isRB4Pressed = 0;


void display7Segments();


void AdcInterrupted(){
    adcinterrupted = 0;
    adc_interrupted = 1;
    adc_val = (ADRESH << 8 | ADRESL);
}

void Tmr1Interrupted(){
    int firstDigit;
    int secondDigit;
    tmr1interrupted = 0;
    tmr1PostScaler++;
    if(tmr1PostScaler == 153){
        tmr1PostScaler = 0;
        TMR1 = tmr1_initial_val;
        if(isCountDownStarted){

            count_down--;
            firstDigit = count_down / 10;
            secondDigit = count_down % 10;
            disp7seg_3 = firstDigit;
            disp7seg_4 = secondDigit;
        }
        
        if(count_down <= 0){
            stateNumber = 2; // go to the fail state.
            justFailed = 1;
        }
    }
}

void toggleRbs(){
    int val =0;
    if(PORTBbits.RB1 == 0){
        val = 1;
    }else{
        val = 0;
    }
    
    LATBbits.LATB1 = val;
    LATBbits.LATB2 = val;
    LATBbits.LATB3 = val;
    LATBbits.LATB4 = val;
    LATBbits.LATB5 = val;
    LATBbits.LATB6 = val;
    LATBbits.LATB7 = val;
}

void Tmr0Interrupted(){
    tmr0interrupted = 0;
    
    if(startToggleRBs){
        ms500++;
        if(ms500 == 9768){
            ms500 = 0;
            toggleRbs();
        }
    }else if(startToggleRBs == 0 && stateNumber == 2){ // if it is in the fail state
        LATBbits.LATB1 = 1;
        LATBbits.LATB2 = 1;
        LATBbits.LATB3 = 1;
        LATBbits.LATB4 = 1;
        LATBbits.LATB5 = 1;
        LATBbits.LATB6 = 1;
        LATBbits.LATB7 = 1;
    }

    
    if(sevenSegNumber == 2){
        sevenSegNumber = 3;
    }else if(sevenSegNumber == 3){
        sevenSegNumber = 4;
    }else if (sevenSegNumber == 4){
        sevenSegNumber = 2;
    }
    
    
    if(stateNumber == 1){ // if the password check state then light the 7 segments up
        display7Segments();
    }
}


void __interrupt(high_priority) FNC()
{
    if(INTCONbits.INT0IF)
    {
        isRB0Pressed = 1;
        INTCONbits.INT0IF = 0;
    }
    
    if(PIR1bits.ADIF) // ADC interrupt
    {
        PIR1bits.ADIF = 0;
        adcinterrupted = 1;
    adc_interrupted = 1;
    adc_val = (ADRESH << 8 | ADRESL);
    }
    
    if(PIR1bits.TMR1IF){ // tmr1 interrupt
        PIR1bits.TMR1IF = 0;
        tmr1interrupted = 1;
    }
    
    if(INTCONbits.TMR0IF){ // tmr0 interrupt
        INTCONbits.TMR0IF = 0;
        tmr0interrupted = 1;
    }
    
    if(INTCONbits.RBIF){ // rb interrupt is checked
        if(PORTBbits.RB4){
            isRB4Pressed = 1;
        }
        INTCONbits.RBIF = 0;
    }
    

}


    
void startADCChannel(unsigned char channel)
    {
        // 0b 0101 -> 5th chanel
        ADCON0bits.CHS0 =  channel & 0x1; // Select channel..
        ADCON0bits.CHS1 = (channel >> 1) & 0x1;
        ADCON0bits.CHS2 = (channel >> 2) & 0x1;
        ADCON0bits.CHS3 = (channel >> 3) & 0x1;
        
        ADCON0bits.GODONE = 1; //Start conversion
    }
    

void startUpState(){
    LCDStr("SuperSecureSafe!");
    __delay_ms(3000);
    LCDGoto(1,1);
    LCDStr("                                ");
}

void displayPassword(){
    char values[10] = {0};
    LCDGoto(1,2);
    if(disp1 == -1){
        LCDStr("__");
    }else if(disp1 < 1000){
       
        sprintf(values, "%d", disp1/10);
        LCDStr(values);
        isTheNumberSet = 1;
    }else{
        LCDStr("XX");
        isTheNumberSet = 0;
    }
    LCDStr("-");
    if(disp2 == -1){
        LCDStr("__");
    }else if(disp2 < 1000){
        
        sprintf(values, "%d", disp2/10);
        LCDStr(values);
        isTheNumberSet = 1;
    }else{
         LCDStr("XX");
         isTheNumberSet = 0;
    }
    LCDStr("-");
    if(disp3 == -1){
        LCDStr("__");
    }else if(disp3 < 1000){
        
        sprintf(values, "%d", disp3/10);
        LCDStr(values);
        isTheNumberSet = 1;
    }else{
         LCDStr("XX");
         isTheNumberSet = 0;
    }
}




void passwordSetState(){
    
    if(isLCDChanged){
        LCDGoto(1,1); // ~ 6ms with
        LCDStr("Set Password:");
        displayPassword(); // ~ 4 ms
        LATD = 0x0;
        isLCDChanged = 0;
    }

    
    if(isRB0Pressed){
        if (isTheNumberSet){
            password_disp_level++;
        }
        
        isRB0Pressed = 0;
    }
    

   
    startADCChannel(0); // channel zero pot. meter0
    if(adc_interrupted == 1){ // adc value is ready to be read
        adc_interrupted = 0;
        
        if(password_disp_level == 0){ // this means disp1 has not been set before
            if(disp1 != adc_val){
                // display is changed
                isLCDChanged = 1;
            }else{
                isLCDChanged = 0;
            }
            disp1 = adc_val;
        }else if(password_disp_level == 1){ // this means disp2 has not been set before
            if(disp2 != (1024-adc_val)){
                // display is changed
                isLCDChanged = 1;
            }else{
                isLCDChanged = 0;
            }
            disp2 = 1024-adc_val;
        }else if(password_disp_level == 2){ //this means disp3 has not been set before
            if(disp3 != adc_val){
                // display is changed
                isLCDChanged = 1;
            }else{
                isLCDChanged = 0;
            }
            disp3 = adc_val;
        }else if(password_disp_level == 3){
            // all the displays are set move to the password check state
            password1 = disp1/10; // store the final password combination.
            password2 = disp2/10;
            password3 = disp3/10;
            LCDGoto(1,1);   // clear the display
            LCDStr("                                ");
            disp1 = -1; // reset displays
            disp2 = -1;
            disp3 = -1;
            isTheNumberSet = 0;
            password_disp_level = 0;
            stateNumber = 1; // goto password check state.
            isLCDChanged = 1;
            prev_adc_val = adc_val;
            LCDGoto(1,1); // ~ 6ms with
            LCDStr("Input Password:");
        }
    
    }else{ // adc value is not ready to be read yet!
        
    }
}


void passwordCheckState(){
    
    if(isLCDChanged){

        displayPassword(); // ~ 4 ms
        
        isLCDChanged = 0;
    }
    
    if(prev_adc_val != adc_val && samplingSwitch == 1){ // potantiometer is moved then cd started.
        isCountDownStarted = 1;
    }
    
    display7Segments();
   
    

    
    if(isRB0Pressed){
        if (isTheNumberSet){
            if(password_disp_level == 0){ // if the current lcd number level is 1
                if((disp1/10) == password1){
                    password_disp_level++;
                }else{
                    numberOfTries--; // take necessary precautions
                }
                             
            }else if(password_disp_level == 1){
                if((disp2/10) == password2){
                    password_disp_level++;
                }else{
                    numberOfTries--; // take necessary precautions
                }
            }else if(password_disp_level == 2){
                if((disp3/10) == password3){
                    password_disp_level++;
                }else{
                    numberOfTries--; // take necessary precautions
                }
            }
            
        }
        isCountDownStarted = 1;
        isRB0Pressed = 0;
    }
    
    
    if(numberOfTries == 2){
        startToggleRBs = 1;
    }else if(numberOfTries == 1){
        LATCbits.LATC5 = 1; // turn the heater on
        IsSecondSamplerON = 1; // turn the thermo sampler on
    }else if (numberOfTries == 0){ // run out of attempts go to fail state
        stateNumber = 2;
        justFailed = 1;
    }
    
    
    
    
    
    

    if(samplingSwitch == 0 && isDialConverting == 0){
        samplingSwitch = 1;
        isDialConverting = 1;
        startADCChannel(0); // channel 0 is pmeter
    }else if (samplingSwitch == 1 && isDialConverting == 0){
        samplingSwitch = 0;
        isDialConverting = 1;
        startADCChannel(2); // channel 0 is thermo
    }



    if(adc_interrupted && isDialConverting == 1){
        isDialConverting = 0;
        adc_interrupted = 0;

        if(samplingSwitch == 1){ // siradaki 1 anlaminda ama mevcut olan 0
            if(password_disp_level == 0){ // this means disp1 has not been set before
                if(disp1 != adc_val){
                    // display is changed
                    isLCDChanged = 1;
                }else{
                    isLCDChanged = 0;
                }
                disp1 = adc_val;
            }else if(password_disp_level == 1){ // this means disp2 has not been set before
                if(disp2 != (1024-adc_val)){
                    // display is changed
                    isLCDChanged = 1;
                }else{
                    isLCDChanged = 0;
                }
                disp2 = 1024-adc_val;
            }else if(password_disp_level == 2){ //this means disp3 has not been set before
                if(disp3 != adc_val){
                    // display is changed
                    isLCDChanged = 1;
                }else{
                    isLCDChanged = 0;
                }
                disp3 = adc_val;
            }else if(password_disp_level == 3){
                // Success!!!
                password1 = disp1/10; // store the final password combination.
                password2 = disp2/10;
                password3 = disp3/10;
                LCDGoto(1,1);   // clear the display
                LCDStr("                                ");
                disp1 = -1; // reset displays
                disp2 = -1;
                disp3 = -1;
                isTheNumberSet = 0;
                password_disp_level = 0;
                stateNumber = 3; // goto password successState
                justSucceeded = 1;
            }
        }

        if(samplingSwitch == 0){ // siradaki 0 anlaminda ama mevcut olan 1
            
           
            if((adc_val * 5.0f / 1023.0f * 100.0f) > 40 && IsSecondSamplerON ){
                stateNumber = 2;// fail state
                justFailed = 1;
            }
        }
    }
}


void write7segment(unsigned char k) {
    switch (k) {
        case 0:
            LATD = 0x3F;
            break;
        case 1:
            LATD = 0x06;
            break;
        case 2:
            LATD = 0x5B;
            break;
        case 3:
            LATD = 0x4F;
            break;
        case 4:
            LATD = 0x66;
            break;
        case 5:
            LATD = 0x6D;
            break;
        case 6:
            LATD = 0x7D;
            break;
        case 7:
            LATD = 0x07;
            break;
        case 8:
            LATD = 0x7F;
            break;
        case 9:
            LATD = 0x6F;
            break;
        case 10:    // this is for 3 tries
            LATD = 0x49;
            break;
        case 11:        // this is for 2 tries
            LATD = 0x48;
            break;
        case 12:        // this is for 1 try
            LATD = 0x08;
            break;
        default:
             // if execution comes here there is a mistake.
            LATD = 0x79;
            break;
    }
    return;
}

void displayTries(){
    if(numberOfTries == 3){
        LATA = 8; // select display 2
         write7segment((unsigned char) 10);
    }else if(numberOfTries == 2){
        LATA = 8; // select display 2
         write7segment((unsigned char) 11);
        
    }else if(numberOfTries == 1){
         LATA = 8; // select display 2
         write7segment((unsigned char) 12);
    }
}


void display7Segments(){
    
    if (sevenSegNumber == 2){
        
        if(numberOfTries == 3){
            LATA = 8; // select display 2
             write7segment((unsigned char) 10);
        }else if(numberOfTries == 2){
            LATA = 8; // select display 2
             write7segment((unsigned char) 11);

        }else if(numberOfTries == 1){
             LATA = 8; // select display 2
             write7segment((unsigned char) 12);
        }
        
    }else if(sevenSegNumber == 3){
        LATA = 16; //select display 3
        write7segment((unsigned char) disp7seg_3);
        
    }else if(sevenSegNumber == 4){
         LATA = 32; //select display 4
         write7segment((unsigned char) disp7seg_4);
    }
}

void failState(){
    if(justFailed){
        LATCbits.LATC5 = 0; // turn the heater off
        IsSecondSamplerON = 0; // turn the thermo sampler off
        startToggleRBs = 0;
        LATA = 0x00;
        LCDGoto(1,1);
        LCDStr("                                ");
        LCDStr("You Failed!");
        justFailed = 0;
        LATD = 0xFF;
    }

}

void successState(){
    
    if(justSucceeded){
        
        INTCONbits.INT0IE = 0; //Disable INT0 pin interrupt
        TRISB = 0x00;
        TRISBbits.RB4 = 1; // rb4 is input
        PORTBbits.RB4 = 0;
        INTCONbits.RBIE = 1;
        LATCbits.LATC5 = 0; // turn the heater off
        IsSecondSamplerON = 0; // turn the thermo sampler off
        LATA = 0x00;
        LCDGoto(1,1);
        LCDStr("                                ");
        LCDStr("Unlocked; Press");
        LCDGoto(1,2);
        LCDStr("RB4 to lock!");
        justSucceeded = 0;
        LATD = 0xFF;
    }
    
    if(isRB4Pressed == 1){
        isRB4Pressed = 0;
        INTCONbits.RBIE = 0; //disable rb interrupt
        INTCONbits.INT0IE = 1; //Enable INT0 pin interrupt
        TRISB = 0b00000001;
        stateNumber = 1;
        isRB0Pressed = 0;
        LCDGoto(1,1);
        LCDStr("                                ");
        LCDGoto(1,1); // ~ 6ms with
        LCDStr("Input Password:");
        isLCDChanged = 1;
        count_down = 90;
        isCountDownStarted = 0;
        disp7seg_3 = 9;
        disp7seg_4 = 0;
        
    }
}


void main(void) {
    PLLEN = 0;//PLL disabled...
    //8 MHZ Internal Oscillator
    OSCCONbits.IRCF2 = 1;
    OSCCONbits.IRCF1 = 1;
    OSCCONbits.IRCF0 = 1;
    InitLCD();
    //TRISBbits.RB1 = 0;
    TRISB = 0b00000001;
    PORTA = 0;
    PORTD = 0;
    TRISD &= 0b00000000;
    LATD = 0x00;
    TRISA &= 0b11000011;     // rightmost 7segment display
            
    
    initADC();
    
    startUpState();
       
    
    unsigned short convertion = 0;
    float voltage_value = 0;
    

    T0CON = 0b01000000;     /* init timer 0 */
    TMR0 = tmr0_initial_val;
    
    T1CON = 0b10000100;     // init timer1
    T1CONbits.TMR1ON = 1;   // start timer1
    TMR1 = tmr1_initial_val;
    T0CONbits.TMR0ON = 1;   // start counting

    

    TRISBbits.RB0 = 1;
    INTCONbits.INT0IE = 1; // Enable INT0 pin interrupt
    INTCONbits.INT0IF = 0;
    INTCONbits.TMR0IE = 1; // tmr0 interrupt enable
    
    PIE1bits.TMR1IE = 1; // timer1 interrupt enable
    PIE1bits.ADIE = 1;  // ADC interrupt enable
    PIR1 = 0b00000000;
    INTCONbits.GIE = 1;
    INTCONbits.PEIE = 1;
 
    TRISC = 0x00;

    
    
    
    while(1)
    {

        if(stateNumber == 0){
            passwordSetState();
        }
        else if(stateNumber == 1 ){
            passwordCheckState();
        }
        else if (stateNumber == 2){
            failState();
        }
        else if (stateNumber == 3){
            successState();
        }


        
        if(tmr0interrupted){
            Tmr0Interrupted();
        }
        
        if(AdcInterrupted){
            AdcInterrupted();
        }
        
        if(tmr1interrupted){
            Tmr1Interrupted();
        }
    }
    
    return;
}
