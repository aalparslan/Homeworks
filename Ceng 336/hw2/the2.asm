;   Alparslan Yesilkaya. ID: 2237923
    
;   In this project, THE2 is implemented.
;   It is TESTED ON PicSimLab WITH 10 MHz CLOCK FREQUENCY due to the computer that is built the project on allowed the accurate and highest frequency at this level.
;   Accuracy  and the compliance of the project specs are verified for PicSimLab environmet with 10MHz clock frequency. 
;   I would like this project to be graded on PicSimLab WITH 10 MHz CLOCK FREQUENCY, even though it satisfies the constraints for 40 MHZ clock freq.
;   The reason for that is due to the limitation of the hardware that I posses, I have not have the  chance to test the project on 
;   PicSimLab with 40 MHz clock.However, I was able to test the time constraints on the MPLAB simulator with 40 MHz and satisfactory results are obtained.
;   However; according to THE2 specifications, the project built on to run with 40MHz clock frequency. 
;   As a result, the project complies with all the  time requirements that are stated in the pdf file (such as 20 seconds count down,
;   1 second wait time between presses and 0.5 second display time at the last state) only for 40MHz clock frequency.

;   -In order to prevent code repeatation, project is built as much modular as possible.
;   -Timer0 and  Timer1 interruts are used. RB button interrupts are used for state changes.
;   -Timer0 is used for the count down mechanism. Timer1 is used for saving current letter after 1 second of inactivitiy.
;   -Project contains three states. These states are message_write_state, message_review_state and message_read_state. At any time, the execution
;    is in either of these states or in an interrupt routine.
;   -Most of the functions (key_detect, show displays, state_updater)  are used in all the states (message_write_state, message_review_state, message_review_state).
;   -Table is used for holding possible 7-segment display shapes.
;   -key_detect detects the keypad press and update global pressed_key variable making availible the pressed key to the rest of the program
;   -show_display whenever called displays what is inside of the disp0, disp1, disp2, and disp3. By just setting disp varibles using the Table and
;    calling show_display will easily display the shape on the 7-segment display.
;   -state_updater checks state_flag and goes to a new state if necesssary. In order to change the state in any state, just updating state_flag is enough.
;   - PORTD is used both for input and output alternatingly. 
    
    
LIST P=18F4620
    
#include <P18F4620.INC>

config OSC = HSPLL      ; Oscillator Selection bits (HS oscillator, PLL enabled (Clock Frequency = 4 x FOSC1))
config FCMEN = OFF      ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
config IESO = OFF       ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
config PWRT = ON        ; Power-up Timer Enable bit (PWRT enabled)
config BOREN = OFF      ; Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software)
config BORV = 3         ; Brown Out Reset Voltage bits (Minimum setting)

; CONFIG2H
config WDT = OFF        ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
config WDTPS = 32768    ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
config CCP2MX = PORTC   ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
config PBADEN = OFF     ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset)
config LPT1OSC = OFF    ; Low-Power Timer1 Oscillator Enable bit (Timer1 configured for higher power operation)
config MCLRE = ON       ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

; CONFIG4L
config STVREN = OFF     ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will not cause Reset)
config LVP = OFF        ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
config XINST = OFF      ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
config CP0 = OFF        ; Code Protection bit (Block 0 (000800-003FFFh) not code-protected)
config CP1 = OFF        ; Code Protection bit (Block 1 (004000-007FFFh) not code-protected)
config CP2 = OFF        ; Code Protection bit (Block 2 (008000-00BFFFh) not code-protected)
config CP3 = OFF        ; Code Protection bit (Block 3 (00C000-00FFFFh) not code-protected)

; CONFIG5H
config CPB = OFF        ; Boot Block Code Protection bit (Boot block (000000-0007FFh) not code-protected)
config CPD = OFF        ; Data EEPROM Code Protection bit (Data EEPROM not code-protected)

; CONFIG6L
config WRT0 = OFF       ; Write Protection bit (Block 0 (000800-003FFFh) not write-protected)
config WRT1 = OFF       ; Write Protection bit (Block 1 (004000-007FFFh) not write-protected)
config WRT2 = OFF       ; Write Protection bit (Block 2 (008000-00BFFFh) not write-protected)
config WRT3 = OFF       ; Write Protection bit (Block 3 (00C000-00FFFFh) not write-protected)

; CONFIG6H
config WRTC = OFF       ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) not write-protected)
config WRTB = OFF       ; Boot Block Write Protection bit (Boot Block (000000-0007FFh) not write-protected)
config WRTD = OFF       ; Data EEPROM Write Protection bit (Data EEPROM not write-protected)

; CONFIG7L
config EBTR0 = OFF      ; Table Read Protection bit (Block 0 (000800-003FFFh) not protected from table reads executed in other blocks)
config EBTR1 = OFF      ; Table Read Protection bit (Block 1 (004000-007FFFh) not protected from table reads executed in other blocks)
config EBTR2 = OFF      ; Table Read Protection bit (Block 2 (008000-00BFFFh) not protected from table reads executed in other blocks)
config EBTR3 = OFF      ; Table Read Protection bit (Block 3 (00C000-00FFFFh) not protected from table reads executed in other blocks)

; CONFIG7H
config EBTRB = OFF      ; Boot Block Table Read Protection bit (Boot Block (000000-0007FFh) not protected from table reads executed in other blocks)


state   udata 0x21
state

counter   udata 0x22
counter

w_temp  udata 0x23
w_temp

status_temp udata 0x24
status_temp

pclath_temp udata 0x25
pclath_temp

portb_var   udata 0x26
portb_var
   
disp0	udata 0x28
disp0
	
disp1	udata 0x29
disp1	
	
disp2	udata 0x2a
disp2
	
disp3	udata 0x2b
disp3	
	
light_up    udata 0x2c
light_up
	
	
L1 udata 0x2d
L1
 
L2 udata 0x2e
L2
 
is_rb4_pressed_then_released udata 0x2f
is_rb4_pressed_then_released
 
temp_PORTD udata 0x30
temp_PORTD
 
temp_LATD udata 0x31
temp_LATD

timer1_counter udata 0x32
timer1_counter
 
pressed_key	udata 0x33 ; 0 : not pressed, 1: 1 pressed, 2: 2 pressed, 3: 3 pressed, 4: 4 pressed, 5: 5 pressed, 6: 6 pressed,
pressed_key		   ; 7: 7 pressed, 8: 8 pressed, 9: 9 pressed, 10: star pressed, 11: kare pressed
	
current_key_name    udata 0x34
current_key_name
    
current_key_press_count	    udata 0x35
current_key_press_count	   
	    
character_storage_1	udata	0x36
character_storage_1	
	
character_storage_2	udata	0x37
character_storage_2	
	
character_storage_3	udata	0x38
character_storage_3
	
character_storage_4	udata	0x39
character_storage_4	
	
character_storage_5	udata	0x3A
character_storage_5	
	
character_storage_6	udata	0x3B
character_storage_6
	
storage_pointer		udata	0x3C
storage_pointer	
		
found_key_number	udata	0x3D
found_key_number	
	
last_character_number	udata	0x3E
last_character_number
	
message_review_pointer	udata	0x3F			    ; it can take values of either 0 or 1 or 2.
message_review_pointer
	
key_released	udata 0x40
key_released	
	
   
deneme	    udata   0x41
deneme	    
	    
state_flag	udata 0x42
state_flag						    ; 0 if message_write_state, 1 if message_review,    2 if message_read
	
isback_or_forth	    udata 0x43
isback_or_forth						    ; 0 means forth 1 means back
	    
timer1_timed_out    udata 0x44
timer1_timed_out    
    
is_first_time_in_m_read	udata 0x45  
is_first_time_in_m_read	
	
L11	udata 0x46
L11
	
L21	udata 0x47	    
L21
	
org     0x00
goto    init

org     0x08
goto    isr             ;go to interrupt service routine

init:

    
    
    ;Disable interrupts
    clrf    INTCON
    clrf    INTCON2

    ;Configure Output Ports
    
    clrf    LATA
    movlw   b'11000011' ; RA<5,2> OUTPUT
    movwf   TRISA
    
    clrf    LATD
    movlw   b'00000000' ; RD<7,0> OUTPUT
    movwf   TRISD

   

    ;Configure Input/Interrupt Ports
    clrf    LATB
    movlw   b'00011000' ;RB<4,0> INPUT
    movwf   TRISB 
    bcf     INTCON2, 7  ; Pull-ups are enabled - clear INTCON2<7>
    clrf    PORTB
    
    ; waiting for the first button press
    wait_for_rb3:
    btfsc   PORTB,3
    goto    wait_for_rb3

    ;Initialize Timer0
    movlw   b'00000111'	    ; timer0 will be 16 bit ; timer0on is set
    movwf   T0CON   ; 
    movlw   0x67        ;   FFFF-BDB=62500; 62500*8*5 = 2500000 instruction cycle;
    movwf   TMR0H
    movlw   0x66
    movwf   TMR0L
    ;initialize Timer1
     movlw   b'11111000'    ;read/write in two 16-bit operations
			    ;Timer1 increment from internal clock with a prescaler of 1:8.
			    ;Disable Timer1 by setting TMR1ON to 0 (for now)
    movwf   T1CON	    ;T1CON = b'01111000'
    
    movlw   0x0B        
    movwf   TMR1H
    movlw   0xB0
    movwf   TMR1L

    ;Enable interrupts
    bsf     PIE1, 0	    ;Enable Timer1 interrupt
    movlw   b'11101000'	    ;Enable Global, peripheral, TMR0IE and RB interrupts by setting GIE, PEIE and RBIE bits to 1
    movwf   INTCON
   
    bsf     T1CON, 0	    ;Enable Timer1 by setting TMR1ON to 1
    bsf     T0CON, 7	    ;Enable Timer0 by setting TMR0ON to 1
    
    clrf    light_up
    clrf    is_rb4_pressed_then_released
    clrf    timer1_counter
    clrf    pressed_key		
    clrf    current_key_name    
    clrf    current_key_press_count
    movlw   d'34'		    ; put _ to all the empty storages
    movwf   character_storage_1
    movwf   character_storage_2
    movwf   character_storage_3
    movwf   character_storage_4
    movwf   character_storage_5
    movwf   character_storage_6
    
    clrf    storage_pointer
    clrf    found_key_number
    clrf    last_character_number
    clrf    message_review_pointer
    clrf    deneme
    clrf    state_flag
    clrf    isback_or_forth
    clrf    timer1_timed_out
    setf    key_released
    setf    is_first_time_in_m_read
    
    movlw   d'20'
    movwf   counter ; put 20 to the counter
    call    DELAY1

    goto    main
    
    
    
    
    
   
    
    
table:
    rlncf   WREG, W   
    addwf   PCL, f	    ; modify program counter
    retlw   B'00111111'  ; 7-Segment = 0
    retlw   B'00000110'  ; 7-Segment = 1
    retlw   B'01011011'  ; 7-Segment = 2
    retlw   B'01001111'  ; 7-Segment = 3
    retlw   B'01100110'  ; 7-Segment = 4
    retlw   B'01101101'  ; 7-Segment = 5
    retlw   B'01111101'  ; 7-Segment = 6
    retlw   B'00000111'  ; 7-Segment = 7
    retlw   B'01111111'  ; 7-Segment = 8
    retlw   B'01101111'  ; 7-Segment = 9
    retlw   B'01011111'  ; 7-Segment = a -> 10
    retlw   B'01111100'  ; 7-Segment = b -> 11
    retlw   B'01011000'  ; 7-Segment = c -> 12
    retlw   B'01011110'  ; 7-Segment = d -> 13
    retlw   B'01111011'  ; 7-Segment = e -> 14
    retlw   B'01110001'  ; 7-Segment = f -> 15
    retlw   B'01101111'  ; 7-Segment = g -> 16
    retlw   B'01110100'  ; 7-Segment = h -> 17
    retlw   B'00000100'  ; 7-Segment = i -> 18
    retlw   B'00001110'  ; 7-Segment = j -> 19
    retlw   B'01110101'  ; 7-Segment = k -> 20
    retlw   B'00111000'  ; 7-Segment = l -> 21
    retlw   B'01010101'  ; 7-Segment = m -> 22
    retlw   B'01010100'  ; 7-Segment = n -> 23
    retlw   B'01011100'  ; 7-Segment = o -> 24
    retlw   B'01110011'  ; 7-Segment = p -> 25
    retlw   B'01010000'  ; 7-Segment = r -> 26
    retlw   B'01100100'  ; 7-Segment = s -> 27
    retlw   B'01111000'  ; 7-Segment = t -> 28   
    retlw   B'00011100'  ; 7-Segment = u -> 29
    retlw   B'00101010'  ; 7-Segment = v -> 30
    retlw   B'01101110'  ; 7-Segment = y -> 31
    retlw   B'01011011'  ; 7-Segment = z -> 32
    retlw   B'00000000'  ; 7-Segment = z -> 33
    retlw   B'00001000'  ; 7-Segment = _ -> 34
    
    
    
state_updater:
    movlw   h'00'
    cpfseq  state_flag
    goto    not_message_write
    goto    yes_message_write
    
    not_message_write:
    movlw   h'01'
    cpfseq  state_flag	
    goto    not_message_review
    goto    yes_message_review
    
    not_message_review:
    movlw   h'02'
    cpfseq  state_flag
    goto    not_message_read
    goto    yes_message_read
    
    not_message_read:
    nop					    ; mistake
    yes_message_read:
    goto    message_read_state
    yes_message_review:
    goto    message_review_state
    yes_message_write:
    goto    message_write_state
    
  
;----------------------------------------------------------------------------------------------------------------------------    
			 
    
    
show_displays:			; show what is specified in the disp0, disp1, disp2, disp3 before calling this function disp0, disp1, disp2, disp3 must be set
	
    movlw   h'00'	        ; to a number that corresponds to a number in the table
    cpfseq  light_up
    goto    light_up_not_zero 
    bcf	    LATA,3
    bcf	    LATA,4		; First Digit 0 - Disp0
    bcf	    LATA,5
    bsf	    LATA,2
    movf    disp0,0		; value obtained from disp0 and placed in Wreg
    call    table		; Assuming appropriate number put in the Wreg before show_displays
    movwf   LATD
    call    DELAY
    return
    
    light_up_not_zero:
    movlw   h'01'
    cpfseq  light_up
    goto light_up_not_one
    bcf	    LATA,2
    bcf	    LATA,4
    bcf	    LATA,5		; Second Digit	- Disp1
    bsf	    LATA,3
    movf    disp1,0		; value obtained from disp1 and placed in Wreg
    call    table		; Assuming appropriate number put in the Wreg before show_displays
    movwf   LATD
    call    DELAY
    return
    
    light_up_not_one:
    movlw   h'02'
    cpfseq  light_up
    goto light_up_not_two
    bcf	    LATA,2
    bcf	    LATA,3
    bcf	    LATA,5		; Second Digit	- Disp2
    bsf	    LATA,4
    movf    disp2,0		; value obtained from disp2 and placed in Wreg
    call    table		; Assuming appropriate number put in the Wreg before show_displays
    movwf   LATD
    call    DELAY
    return
    
    light_up_not_two:
    bcf	    LATA,2
    bcf	    LATA,3
    bcf	    LATA,4		; Second Digit	- Disp3
    bsf	    LATA,5
    movf    disp3,0		; value obtained from disp3 and placed in Wreg
    call    table		; Assuming appropriate number put in the Wreg before show_displays
    movwf   LATD
    call    DELAY
    return
    

    
update_count_down:
    movlw   d'20'
    cpfseq  counter
    goto    counter_is_not_20
    goto    counter_is_20
    
    counter_is_not_20:
    movlw   d'9'
    cpfsgt  counter
    goto    counter_is_one_digit
    goto    counter_is_in_between_9_20 ; [10,...,19]
    
    
    counter_is_one_digit:
    movlw   h'00'
    movwf   disp0		; disp0 is set accordingly
    movff   counter, disp1
    return

    
    counter_is_in_between_9_20: 
    movlw   d'1'
    movwf   disp0		; disp0 is set to 1
    movlw   h'0A'		; counter - 10 will give the x of the 1x number
    subwf   counter,0		;w <- counter-10
    movwf   disp1		; result is put into disp1
    return
    
    
    counter_is_20:
    movlw   d'2'		; disp0 is set to 2
    movwf   disp0
    movlw   d'0'
    movwf   disp1		; disp1 is set to 0    
    return
    


key_detect:
        ;-------------------------------- FOR KEYPAD DETECTION-----------------------------------
    movff   PORTD, temp_PORTD
    ;movff   LATD, temp_LATD
    
    movlw   b'11100000' ;only disable RB interrupts by clearing RBIE bit to 0
    movwf   INTCON
    
;    bcf	    LATA,2
;    bcf	    LATA,3
;    bcf	    LATA,4		
;    bcf	    LATA,5
  
    movlw   h'0F'
    movwf   TRISD

    movlw   h'00'
    movwf   LATB
    movlw   h'0F'
    movwf   LATD
    
    
    
    btfss   PORTD,0
    goto    ROW4
    btfss   PORTD,1
    goto    ROW3
    btfss   PORTD,2
    goto    ROW2
    btfss   PORTD,3
    goto    ROW1
    goto    non_of_the_keys_pressed
    
    ROW4:
    movlw   h'01'
    movwf   LATB
    call    DELAY
    btfsc   PORTD,0
    goto    yildiz
    movlw   h'02'
    movwf   LATB
    call    DELAY
    btfsc   PORTD,0
    goto    sifir
    movlw   h'04'
    movwf   LATB
    call    DELAY
    btfsc   PORTD,0
    goto    kare
    goto    no_press
    

;    
    ROW3:
    movlw   h'01'
    movwf   LATB
    call    DELAY
    btfsc   PORTD,1
    goto    yedi
    movlw   h'02'
    movwf   LATB
    call    DELAY
    btfsc   PORTD,1
    goto    sekiz
    movlw   h'04'
    movwf   LATB
    call    DELAY
    btfsc   PORTD,1
    goto    dokuz
    goto    no_press
;    
    ROW2:
    movlw   h'01'
    movwf   LATB
    call    DELAY
    btfsc   PORTD,2
    goto    dort
    movlw   h'02'
    movwf   LATB
    call    DELAY
    btfsc   PORTD,2
    goto    bes
    movlw   h'04'
    movwf   LATB
    call    DELAY
    btfsc   PORTD,2
    goto    alti
    goto    no_press
    
;    
    ROW1:
    movlw   h'01'
    movwf   LATB
    call    DELAY
    btfsc   PORTD,3
    goto    bir
    movlw   h'02'
    movwf   LATB
    call    DELAY
    btfsc   PORTD,3
    goto    iki
    movlw   h'04'
    movwf   LATB
    call    DELAY
    btfsc   PORTD,3
    goto    uc
    goto    no_press
    
    bir:
    movlw   h'00'	    ; this is for multiple press of the same key
    movwf   LATB	    ; clears LATB for new inputs..
    call    DELAY1		    ; Delay is needed to action to take place... and these 3 lines must be executed after every keypress
    movlw   h'01'
    movwf   pressed_key
    clrf    key_released
    goto    no_press
    
    iki:
    movlw   h'00'	    ; this is for multiple press of the same key
    movwf   LATB	    ; clears LATB for new inputs..
    call    DELAY1		    ; Delay is needed to action to take place... and these 3 lines must be executed after every keypresss!
    movlw   h'02'
    movwf   pressed_key
    clrf    key_released
    goto    no_press
    uc:
    movlw   h'00'	    ; this is for multiple press of the same key
    movwf   LATB	    ; clears LATB for new inputs..
    call    DELAY1		    ; Delay is needed to action to take place... and these 3 lines must be executed after every keypresss!
    movlw   h'03'
    movwf   pressed_key
    clrf    key_released
    goto    no_press
    dort:
    movlw   h'00'	    ; this is for multiple press of the same key
    movwf   LATB	    ; clears LATB for new inputs..
    call    DELAY1	    ; Delay is needed to action to take place... and these 3 lines must be executed after every keypresss!
    movlw   h'04'
    movwf   pressed_key
    clrf    key_released
    goto    no_press
    bes:
    movlw   h'00'	    ; this is for multiple press of the same key
    movwf   LATB	    ; clears LATB for new inputs..
    call    DELAY1		    ; Delay is needed to action to take place... and these 3 lines must be executed after every keypresss!
    movlw   h'05'
    movwf   pressed_key
    clrf    key_released
    goto    no_press
    alti:
    movlw   h'00'	    ; this is for multiple press of the same key
    movwf   LATB	    ; clears LATB for new inputs..
    call    DELAY1		    ; Delay is needed to action to take place... and these 3 lines must be executed after every keypresss!
    movlw   h'06'
    movwf   pressed_key
    clrf    key_released
    goto    no_press
    yedi:
    movlw   h'00'	    ; this is for multiple press of the same key
    movwf   LATB	    ; clears LATB for new inputs..
    call    DELAY1		    ; Delay is needed to action to take place... and these 3 lines must be executed after every keypresss!
    movlw   h'07'
    movwf   pressed_key
    clrf    key_released
    goto    no_press
    sekiz:
    movlw   h'00'	    ; this is for multiple press of the same key
    movwf   LATB	    ; clears LATB for new inputs..
    call    DELAY1		    ; Delay is needed to action to take place... and these 3 lines must be executed after every keypresss!
    movlw   h'08'
    movwf   pressed_key
    clrf    key_released
    goto    no_press
    dokuz:
    movlw   h'00'	    ; this is for multiple press of the same key
    movwf   LATB	    ; clears LATB for new inputs..
    call    DELAY1		    ; Delay is needed to action to take place... and these 3 lines must be executed after every keypresss!
    movlw   h'09'
    movwf   pressed_key
    clrf    key_released
    goto    no_press
    yildiz:
    movlw   h'00'	    ; this is for multiple press of the same key
    movwf   LATB	    ; clears LATB for new inputs..
    call    DELAY1		    ; Delay is needed to action to take place... and these 3 lines must be executed after every keypresss!
    movlw   h'0A'
    movwf   pressed_key
    clrf    key_released
    goto    no_press
    sifir:
    movlw   h'00'	    ; this is for multiple press of the same key
    movwf   LATB	    ; clears LATB for new inputs..
    call    DELAY1		    ; Delay is needed to action to take place... and these 3 lines must be executed after every keypresss!
    movlw   h'0B'
    movwf   pressed_key
    clrf    key_released
    goto    no_press
    kare:
    movlw   h'00'	    ; this is for multiple press of the same key
    movwf   LATB	    ; clears LATB for new inputs..
    call    DELAY1		    ; Delay is needed to action to take place... and these 3 lines must be executed after every keypresss!
    movlw   h'0C'
    movwf   pressed_key
    clrf    key_released
    goto    no_press
    
    
    non_of_the_keys_pressed:
    btfsc   key_released,0
    goto    no_press
    setf    key_released		; since non of the keys are pressed we can say key_released
    call    DELAY1
    
    no_press:

    
    movlw   b'00000000' 
    movwf   TRISD
    
    movlw   b'11101000' ;Enable Global, peripheral, TMR0IE and RB interrupts by setting GIE, PEIE and RBIE bits to 1
    movwf   INTCON
    
    movff   temp_PORTD, PORTD
    return
    ;movff   temp_LATD, LATD

    
;-------------------------------------------------- KEYPAD DETECTION ENDS----------------------------------------------------------
;----------------------------------------------------------------------------------------------------------------------------------    
;----------------------------------------------------------------------------------------------------------------------------------    
;----------------------------------------------------------------------------------------------------------------------------------        
    
find_last_key_number:
    movlw   h'00'
    cpfseq  storage_pointer
    goto    not_storage_0_f
    goto    storage_0_f
    
    not_storage_0_f:
    movlw   h'01'
    cpfseq  storage_pointer
    goto    not_storage_1_f
    goto    storage_1_f
    
    not_storage_1_f:
    movlw   h'02'
    cpfseq  storage_pointer
    goto    not_storage_2_f
    goto    storage_2_f
    
    not_storage_2_f:
    movlw   h'03'
    cpfseq  storage_pointer
    goto    not_storage_3_f
    goto    storage_3_f
    
    not_storage_3_f:
    movlw   h'04'
    cpfseq  storage_pointer
    goto    not_storage_4_f
    goto    storage_4_f
    
    not_storage_4_f:
    movlw   h'05'
    cpfseq  storage_pointer
    goto    not_storage_5_f
    goto    storage_5_f
    
    not_storage_5_f:
    nop						    ; if it comes here there is a mistake @@
    
    storage_0_f:
    movlw   d'34'
    movwf   last_character_number       
    storage_1_f:
    movff   character_storage_1, last_character_number
    return
    storage_2_f:
    movff   character_storage_2, last_character_number
    return
    storage_3_f:
    movff   character_storage_3, last_character_number
    return
    storage_4_f:
    movff   character_storage_4, last_character_number
    return
    storage_5_f:
    movff   character_storage_5, last_character_number
    return
    
 ;----------------------------------------------------------------------------------------------------------------------------------    
 ;----------------------------------------------------------------------------------------------------------------------------------    
 ;----------------------------------------------------------------------------------------------------------------------------------          
    
find_key_from_input:
    ; 6 + (current_key_name -1)*3 + current_key_press_count will give character number.    
    decf    current_key_name		;(current_key_name -1)    
    movlw   h'03'
    mulwf   current_key_name		; (current_key_name -1)*3  result will be stored in the PRODH:PRODL
    movf    PRODL,0			; put the result back in to Wreg
    addlw   h'06'			; 6 + (current_key_name -1)*3 
    addwf   current_key_press_count,0	; 6 + (current_key_name -1)*3 + current_key_press_count
    movwf   found_key_number
    incf    current_key_name		; restore current_key_name
    return

;----------------------------------------------------------------------------------------------------------------------------------    
;----------------------------------------------------------------------------------------------------------------------------------    
;----------------------------------------------------------------------------------------------------------------------------------        
    
save_key:	; if storage_pointer:0 then storage1, 1 then storage2, 2 then storage 3, 3 then storage4, 4 then storage 5, 5 then storage 6. (mapping structure)
            
    movlw   h'00'
    cpfseq  storage_pointer
    goto    not_storage_1
    goto    storage_1
    
    not_storage_1:
    movlw   h'01'
    cpfseq  storage_pointer
    goto    not_storage_2
    goto    storage_2
    
    not_storage_2:
    movlw   h'02'
    cpfseq  storage_pointer
    goto    not_storage_3
    goto    storage_3
    
    not_storage_3:
    movlw   h'03'
    cpfseq  storage_pointer
    goto    not_storage_4
    goto    storage_4
    
    not_storage_4:
    movlw   h'04'
    cpfseq  storage_pointer
    goto    not_storage_5
    goto    storage_5
    
    not_storage_5:
    movlw   h'05'
    cpfseq  storage_pointer
    goto    not_storage_6
    goto    storage_6
    
    not_storage_6:
    nop							; if it comes here there is a mistake @@
  
							; 0 : not pressed, 1: 1 pressed, 2: 2 pressed, 3: 3 pressed, 4: 4 pressed, 5: 5 pressed, 6: 6 pressed,
							; 7 : 7 pressed,   8: 8 pressed, 9: 9 pressed, 10: star pressed, 11: kare pressed
    storage_6:
    call    find_key_from_input
    movff   found_key_number, character_storage_6
    movlw   h'02'					; will go to the message_read_state
    movwf   state_flag
    clrf    message_review_pointer
    goto    finish_save_key
    storage_5:
    call    find_key_from_input
    movff   found_key_number, character_storage_5
    incf    storage_pointer
    goto    finish_save_key
    storage_4:
    call    find_key_from_input
    movff   found_key_number, character_storage_4
    incf    storage_pointer
    goto    finish_save_key    
    storage_3:
    call    find_key_from_input
    movff   found_key_number, character_storage_3
    incf    storage_pointer
    goto    finish_save_key    
    storage_2:
    call    find_key_from_input
    movff   found_key_number, character_storage_2
    incf    storage_pointer
    goto    finish_save_key    
    storage_1:
    call    find_key_from_input
    movff   found_key_number, character_storage_1
    incf    storage_pointer
    goto    finish_save_key    
    
    finish_save_key:    
    return
    
;----------------------------------------------------------------------------------------------------------------------------------    
;----------------------------------------------------------------------------------------------------------------------------------    
;----------------------------------------------------------------------------------------------------------------------------------        
    
process_input:
    ; ---------------------------------- by this piece of code '1', '0', '*', '#' will be unresponsive.
    movlw   h'01'
    cpfseq  pressed_key
    goto    process_input_keep_going_1
    goto    invalid_key
    
    process_input_keep_going_1:
    movlw   h'0A'
    cpfseq  pressed_key
    goto    process_input_keep_going_2
    goto    invalid_key
    
    process_input_keep_going_2:
    movlw   h'0B'
    cpfseq  pressed_key
    goto    process_input_keep_going_3
    goto    invalid_key
    
    process_input_keep_going_3:
    movlw   h'0C'
    cpfseq  pressed_key
    goto    process_input_keep_going_x
    goto    invalid_key    
    
    invalid_key:
    clrf    pressed_key
    return;#
    ;-------------------
    process_input_keep_going_x:
    
    movlw   h'00'
    cpfseq  pressed_key
    goto    a_key_pressed
    return;#
    a_key_pressed:
    movlw   h'00'
    cpfseq  current_key_name
    goto    not_first_hit
    goto    first_hit
    
    first_hit:
    movff   pressed_key, current_key_name	
    movlw   h'01'
    movwf   current_key_press_count			;since first hit, put 1 as count
    goto    finish_procesess_input;#
    
    not_first_hit:
    movf    pressed_key,0			        ; put pressed key to the Wreg
    cpfseq  current_key_name
    goto    a_different_key_is_pressed
    goto    same_key_is_pressed
    
    a_different_key_is_pressed:
    ;----save the current character to storage------------------------
    ; prevent 1 coming 1, 0, yildiz and kare
    call    save_key					; updates pointer and saves current_key_name and current_key_press_count
    movff   pressed_key, current_key_name
    movlw   h'01'
    movwf   current_key_press_count			; current_key_press_count = 1 first press
    goto    finish_procesess_input;#
    ;----save the current character to storage end..------------------
    same_key_is_pressed:				; current_key_press_count can be 1 or 2 or 3
    call    DELAY
    movlw   h'01'
    cpfseq  current_key_press_count
    goto    current_key_press_count_is_not_one
    goto    current_key_press_count_is_one
    
    
    current_key_press_count_is_not_one:
    movlw   h'02'
    cpfseq  current_key_press_count
    goto    current_key_press_count_is_not_two
    goto    current_key_press_count_is_two

    
    current_key_press_count_is_not_two:
    movlw   h'03'
    cpfseq  current_key_press_count
    goto    count_is_not_three
    goto    current_key_press_count_is_three

    
    count_is_not_three:
    nop							;if execution reaches here mistake@
    
    current_key_press_count_is_three:
    movlw   h'01'
    movwf   current_key_press_count			; This will provide loop back...
    goto    finish_procesess_input
    
    current_key_press_count_is_two:
    incf    current_key_press_count
    goto    finish_procesess_input
    
    current_key_press_count_is_one:
    incf    current_key_press_count
    goto    finish_procesess_input
    
    finish_procesess_input:
    clrf    pressed_key					 ; clear so that it will not enter process_input until a key is pressed
    clrf    timer1_counter
    return

;----------------------------------------------------------------------------------------------------------------------------------    
;----------------------------------------------------------------------------------------------------------------------------------    
;----------------------------------------------------------------------------------------------------------------------------------        
    
update_disp2_disp3:
    movlw   h'00'
    cpfseq  current_key_name
    goto    put_characters				; input is present
    goto    put_under_score				; no press
    
    put_characters:   
    call    find_key_from_input
    movff   found_key_number, disp3  
    call    find_last_key_number			 ; it will find last key number from storages.
    movff   last_character_number, disp2
    return
    
    
    put_under_score:
    btfss   timer1_timed_out,0
    goto    put_under_score_cont
    movlw   d'34'
    movwf   disp3
    call    find_last_key_number			 ; it will find last key number from storages.
    movff   last_character_number, disp2
    return
    
    put_under_score_cont:
    
    movlw   d'34'
    cpfseq  disp2
    goto    initialize_disp2_3
    return
    initialize_disp2_3:
    movlw   d'34'
    movwf   disp2
    movwf   disp3
    return

    
;----------------------------------------------------------------------------------------------------------------------------------    
;----------------------------------------------------------------------------------------------------------------------------------    
;----------------------------------------------------------------------------------------------------------------------------------        
    
message_write_state:
    call    update_count_down			        ; this will update disp0, disp1, disp2, disp3 accordingly forcount_down
    call    show_displays			    	; this will show that is inside disp0, disp1, disp2, disp3
    call    key_detect
    
    btfss   key_released,0				; being key_released clean means not released yet
    goto    jump1
    call    process_input
    call    update_disp2_disp3
    
    
    btfss   is_rb4_pressed_then_released,0
    goto    jump1
    movlw   h'01'
    movwf   state_flag				        ; if pressed and released then set  flag to 1 to go to message_review state			
    clrf    is_rb4_pressed_then_released
    jump1:
   
    goto    state_updater
    
    
;----------------------------------------------------------------------------------------------------------------------------------    
;----------------------------------------------------------------------------------------------------------------------------------    
;----------------------------------------------------------------------------------------------------------------------------------    
    
process_input_message_review:				; updates the message_review_pointer according to the keypress.
    movlw   h'0A'
    cpfseq  pressed_key
    goto    yildiz_is_not_pressed
    goto    yildiz_is_pressed
    
    yildiz_is_not_pressed:
    movlw   h'0C'
    cpfseq  pressed_key
    return			    			; do nothing since other buttons must be unresponsive in message review state
    goto    kare_is_pressed
    
   
    kare_is_pressed:

    clrf    pressed_key
    movlw   h'00'
    cpfseq  message_review_pointer
    goto    message_review_pointer_not_0_k
    goto    message_review_pointer_is_0_k
    
    message_review_pointer_not_0_k:
    movlw   h'01'
    cpfseq  message_review_pointer
    goto    message_review_pointer_not_1_k
    goto    message_review_pointer_is_1_k
    
    message_review_pointer_not_1_k:
    movlw   h'02'
    cpfseq  message_review_pointer
    goto    message_review_pointer_not_2_k
    goto    message_review_pointer_is_2_k
    
    message_review_pointer_not_2_k:
    nop							; not possible, if it reaches here error.
    return
    
    message_review_pointer_is_2_k:
    return						; do not update message_review_pointer since it reached to the boundary    
    
    message_review_pointer_is_1_k:
    movlw   h'02'
    movwf   message_review_pointer
    return
    
    message_review_pointer_is_0_k:
    movlw   h'01'
    movwf   message_review_pointer  
    return						

    
    yildiz_is_pressed:
    incf    deneme
    clrf    pressed_key
    movlw   h'00'
    cpfseq  message_review_pointer
    goto    message_review_pointer_not_0_y
    goto    message_review_pointer_is_0_y
    
    message_review_pointer_not_0_y:
    movlw   h'01'
    cpfseq  message_review_pointer
    goto    message_review_pointer_not_1_y
    goto    message_review_pointer_is_1_y
    
    message_review_pointer_not_1_y:
    movlw   h'02'
    cpfseq  message_review_pointer
    goto    message_review_pointer_not_2_y
    goto    message_review_pointer_is_2_y
    
    message_review_pointer_not_2_y:
    nop							; not possible, if it reaches here error.
    
    message_review_pointer_is_2_y:    
    movlw   h'01'
    movwf   message_review_pointer 
    return
    
    message_review_pointer_is_1_y:   
    movlw   h'00'
    movwf   message_review_pointer
    return
    
    message_review_pointer_is_0_y:        
    return						; do not update message_review_pointer since it reached to the boundary
    
 ;----------------------------------------------------------------------------------------------------------   
 ;------------------------------------------------------------------------------------------------------------------------------------------
 ;------------------------------------------------------------------------------------------------------------------------------------------ 
    
update_displays_message_review:				; disp0, disp1, disp2, disp3 update according to message_review_pointer only depends on message_review_pointer

    movlw   h'00'
    cpfseq  message_review_pointer
    goto    message_review_pointer_not_0
    goto    message_review_pointer_is_0
    
    message_review_pointer_not_0:
    movlw   h'01'
    cpfseq  message_review_pointer
    goto    message_review_pointer_not_1
    goto    message_review_pointer_is_1
    
    message_review_pointer_not_1:
    movlw   h'02'
    cpfseq  message_review_pointer
    goto    message_review_pointer_not_2
    goto    message_review_pointer_is_2
    
    message_review_pointer_not_2:
    nop							; not possible, if it reaches here error.
    
    message_review_pointer_is_2:
    movff   character_storage_3, disp0
    movff   character_storage_4, disp1
    movff   character_storage_5, disp2
    movff   character_storage_6, disp3
    return
    
    message_review_pointer_is_1:
    movff   character_storage_2, disp0
    movff   character_storage_3, disp1
    movff   character_storage_4, disp2
    movff   character_storage_5, disp3
    return
    
    message_review_pointer_is_0:
    movff   character_storage_1, disp0
    movff   character_storage_2, disp1
    movff   character_storage_3, disp2
    movff   character_storage_4, disp3      
    return						
    
;------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------    
    
message_review_state:
    call    key_detect
    btfss   key_released,0				; being key_released clean means not released yet
    goto    jump2
    call    process_input_message_review
    jump2:
    call    update_displays_message_review
    call    show_displays
    
    btfss   is_rb4_pressed_then_released,0
    goto    jumpx
    clrf    state_flag					; if pressed and released then clear flag to go to message_write state
    clrf    is_rb4_pressed_then_released
    jumpx:
    goto    state_updater
   
;------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------  
message_read_state: 
    call    show_displays
    call    update_displays_message_review
    goto    state_updater
    
    
;------------------------------------------------------------------------------------------------------------------------------------------  
;------------------------------------------------------------------------------------------------------------------------------------------  
;------------------------------------------------------------------------------------------------------------------------------------------      
      
main:

    goto message_write_state
    goto    main
;------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------    

    
DELAY:                          ; Time Delay Routines
    movlw   d'3'
    cpfseq  light_up		; Test if light_up is 3 if 3 then set it to 0 
    goto inc_light_up		; light_up controls which display to light up in the current round
    goto set_light_up_to_zero
    
    inc_light_up:
    incf    light_up
    goto delay_continue
    
    set_light_up_to_zero:	
    movlw   d'0'
    movwf   light_up
    goto delay_continue
    
    delay_continue:
    
    movlw h'01'			    ; put 1 to W
    movwf L2			    ; put w into L2

LOOP2:
    movlw 30			    ; put 30 into W
    movwf L1			    ; put  w into L1

LOOP1:
    decfsz L1,F			    ; Decrement L1. If 0 Skip next instruction
        goto LOOP1		    ; ELSE Keep counting down
    decfsz L2,F			    ; Decrement L2. If 0 Skip next instruction
        goto LOOP2		    ; ELSE Keep counting down
    return
;------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------  
    
DELAY1:				    ; Time Delay Routines
    
    movlw   b'00000000' 
    movwf   TRISD
    
    movlw   b'11101000'		    ;Enable Global, peripheral, TMR0IE and RB interrupts by setting GIE, PEIE and RBIE bits to 1
    movwf   INTCON
    
    movff   temp_PORTD, PORTD    
    
    movlw h'B0'			    ; put 1 to W    ; 70
    movwf L21			    ; put w into L2

LOOP21:
    call show_displays
    movlw h'FF'			    ; put 30 into W
    movwf L11			    ; put  w into L1

LOOP11:
    decfsz L11,F		    ; Decrement L1. If 0 Skip next instruction
        goto LOOP11		    ; ELSE Keep counting down
    decfsz L21,F		    ; Decrement L2. If 0 Skip next instruction
        goto LOOP21		    ; ELSE Keep counting down
    return    
    
  
    
;------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------  
        
    

isr:
    call    save_registers		;Save current content of STATUS and PCLATH registers to be able to restore them later
    btfsc   PIR1, 0			; is this a timer1 interrupt"\?
    goto    timer1_interrupt
    btfss   INTCON, 2			;Is this a timer0 interrupt?   
    goto    rb_interrupt		;No. Goto PORTB on change interrupt handler part
    goto    timer0_interrupt		;Yes. Goto timer interrupt handler part

;;;;;;;;;;;;;;;;;;;;;;;; Timer interrupt handler part ;;;;;;;;;;;;;;;;;;;;;;;;;;
timer0_interrupt:
    bcf         INTCON, 2		;Clear TMR0IF
    movlw	h'00'
    cpfseq	counter
    goto	jumpj
    goto	tmr0_int_read_s_flow	; then go to the message_read_state
    
    jumpj:
    decf	counter
    
    movlw	h'02'
    cpfseq	state_flag		 ; if somehow in state 2 then continue with tmr0_int_read_s_flow
    goto	jumpa
    goto	tmr0_int_read_s_flow
    
    jumpa:	
   
    

    goto timer0_interrupt_exit

timer0_interrupt_exit:
	movlw	0x67			 ;FFFF-BDB=62500; 62500*8*5 = 2500000 instruction cycle;		
	movwf	TMR0H			    								    
	movlw   0x66											
	movwf   TMR0L
	call	restore_registers	 ;Restore STATUS and PCLATH registers to their state before interrupt occurs
	retfie 

tmr0_int_read_s_flow:
    btfsc   is_first_time_in_m_read,0
    clrf    message_review_pointer
    clrf    is_first_time_in_m_read
    
    
    
    movlw	h'02'
    movwf	state_flag
    
    movlw	h'00'
    cpfseq	message_review_pointer
    goto	m_read_ptr_not_0
    goto	m_read_ptr_is_0
    
    
    m_read_ptr_not_0:
    movlw	h'01'
    cpfseq	message_review_pointer
    goto	m_read_ptr_not_1
    goto	m_read_ptr_is_1
    
    m_read_ptr_not_1:
    movlw	h'02'
    cpfseq	message_review_pointer
    goto	m_read_ptr_not_2
    goto	m_read_ptr_is_2
    
    m_read_ptr_not_2:
    nop							; mistake
    m_read_ptr_is_2:    
    decf	message_review_pointer
    setf	isback_or_forth				;change direction to the back
    goto	myjump
    m_read_ptr_is_1:
    btfss	isback_or_forth,0			; 0 means forth	    1 means back
    goto	it_is_1_forth
    goto	it_is_1_back
    
    it_is_1_back:
    decf	message_review_pointer
    goto	myjump
    it_is_1_forth:
    incf	message_review_pointer
    goto	myjump
    m_read_ptr_is_0:
    clrf	isback_or_forth				; change the direction to the forth
    incf	message_review_pointer
    goto	myjump
    
    myjump:
    
    
    movlw	0xB3					; for delay of 0.5 sec
    movwf	TMR0H
    movlw	0xB4
    movwf	TMR0L
    call	restore_registers			;Restore STATUS and PCLATH registers to their state before interrupt occurs
    retfie 
	
	
	

timer1_interrupt:
    bcf	    PIR1, 0					;Clear TMR1IF
    movlw   d'19'
    cpfseq  timer1_counter
    goto    increment_timer1_counter
    goto    clear_timer1_counter
    clear_timer1_counter:
    clrf    timer1_counter				; must get 1 sec till here
    movlw   h'00'					; if this state is message_write
    cpfseq  state_flag
    goto    timer1_interrupt_back
    cpfseq  current_key_name				; if current_key_name is 0 then dont save the key
    goto    mw_st
    goto    timer1_interrupt_back
    mw_st:
    
    
    
    setf    timer1_timed_out
    call    save_key					; updates pointer and saves current_key_name and current_key_press_count
    clrf    pressed_key					; time out take the input and 
    clrf    current_key_name
    clrf    current_key_press_count    
    
    
    goto    timer1_interrupt_back
    increment_timer1_counter:
    incf    timer1_counter
    goto    timer1_interrupt_back
    timer1_interrupt_back:
    movlw   0x0B					;FFFF-BDB=62500; 62500*8*5 = 2500000 instruction cycle;
    movwf   TMR1H
    movlw   0xB0
    movwf   TMR1L
    call    restore_registers				;Restore STATUS and PCLATH registers to their state before interrupt occurs
    retfie 


;;;;;;;;;;;;;;;;;;; PORTB on change interrupt handler part ;;;;;;;;;;;;;;;;;;;;;
rb_interrupt:

	btfss   INTCON, 0			 ;Is this PORTB on change interrupt
	goto	rb_interrupt_exit0		 ;No, then exit from interrupt service routine
	btfss	PORTB,4
	goto	rb_interrupt_exit0
	
	movf	PORTB, w			;Read PORTB to working register
	movwf	portb_var			;Save it to shadow register
	btfsc	portb_var, 4			;Test its 4th bit whether it is cleared
	goto	rb_interrupt_exit2		; RB4 is 1
	

rb_interrupt_exit1:
	movf	portb_var, w			;Put shadow register to W
	movwf	LATB				;Write content of W to actual PORTB, so that we will be able to clear RBIF
	bcf     INTCON, 0			;Clear PORTB on change FLAG
	call	restore_registers		;Restore STATUS and PCLATH registers to their state before interrupt occurs
	retfie

rb_interrupt_exit2:
	incf	is_rb4_pressed_then_released	; indicates that rb4 is pressed and released by incrementing it 0 to 1
	movf	portb_var, w			;Put shadow register to W
	movwf	LATB				;Write content of W to actual PORTB, so that we will be able to clear RBIF
	bcf     INTCON, 0			;Clear PORTB on change FLAG
	call	restore_registers		;Restore STATUS and PCLATH registers to their state before interrupt occurs
	retfie 

rb_interrupt_exit0:
    call    restore_registers			;Restore STATUS and PCLATH registers to their state before interrupt occurs
    retfie
    
    

;;;;;;;;;;;; Register handling for proper operation of main program ;;;;;;;;;;;;
save_registers:
    movwf 	w_temp				;Copy W to TEMP register
    swapf 	STATUS, w			;Swap status to be saved into W
    clrf 	STATUS				;bank 0, regardless of current bank, Clears IRP,RP1,RP0
    movwf 	status_temp			;Save status to bank zero STATUS_TEMP register
    movf 	PCLATH, w			;Only required if using pages 1, 2 and/or 3
    movwf 	pclath_temp			;Save PCLATH into W
    clrf 	PCLATH				;Page zero, regardless of current page
    return

restore_registers:
    movf 	pclath_temp, w			;Restore PCLATH
    movwf 	PCLATH				;Move W into PCLATH
    swapf 	status_temp, w			;Swap STATUS_TEMP register into W
    movwf 	STATUS				;Move W into STATUS register
    swapf 	w_temp, f			;Swap W_TEMP
    swapf 	w_temp, w			;Swap W_TEMP into W
    return

end
    
    

