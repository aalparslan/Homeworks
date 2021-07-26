


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


variables udata_acs
counter_1 res 1
counter_2 res 1
counter_3 res 1
waitCoef res 1
rowA res 1
rowC res 1
rowD res 1
on_off res 1 ;off is 0, on is 1
isrb0pressed res 1
isrb1pressed res 1
isrb2pressed res 1
isrb3pressed res 1
isleftedge res 1
leftedgeindex res 1
rightedgeindex res 1
portnumber res 1 ; 0 = portA, 1 = portC, 2 = portD
genericrow res 1
msecnumber res 1 ; 0 for came from loop A, 1 for came from loop C, 2 for came from loop D
rb0number res 1
rb1number res 1
rb2number res 1
rb3number res 1
delaycounter1 res 1
delaycounter2 res 1
delaycounter3 res 1
delaycounter4 res 1
initialrowA res 1
initialrowC res 1
initialrowD res 1
goout res 1
ischanged res 1
isrb0released res 1
isrb1released res 1
isrb2released res 1
isrb3released res 1
delaycounter5 res 1
delaycounter6 res 1
delaycounter7 res 1
delaycounter8 res 1
counterdraw1 res 1
counterdraw2 res 1
counterdraw3 res 1
counterdraw4 res 1







org 0x0000
    goto init

org 0x0008
    goto $


;this is bad, button is unresponsive during this procedure, it blocks the program
;make timing fit round robin approach by converting whiles to ifs yourself!
waste_time100:

    movlw h'0b'
    movwf counter_3
    loop3:
    movlw h'c1'
    movwf counter_2
    loop2:
    movlw h'9c'
    movwf counter_1
    loop1:
    decfsz counter_1,f
    goto loop1
    decfsz counter_2,f
    goto loop2
    decfsz counter_3,f
    goto loop3
    return




init:
    clrf TRISA
    clrf TRISC
    clrf TRISD ; All ports of the A,C,D is set to output
    clrf LATA
    clrf LATC
    clrf LATD
    clrf isrb0pressed
    clrf isrb1pressed
    clrf isrb2pressed
    clrf isrb3pressed
    clrf isleftedge
    clrf leftedgeindex
    clrf rightedgeindex
    clrf portnumber
    clrf genericrow
    clrf delaycounter1
    clrf delaycounter2
    clrf delaycounter3
    clrf delaycounter4
    clrf isrb0released
    clrf isrb1released
    clrf isrb2released
    clrf isrb3released
    clrf delaycounter5
    clrf delaycounter6
    clrf delaycounter7
    clrf delaycounter8
    setf counterdraw1
    setf counterdraw2
    setf counterdraw3
    clrf counterdraw4


    movlw h'FF'
    movwf ADCON1 ; set port A as Digital
    movlw b'00001111'
    movwf TRISB ; Set RB0, RB1, RB2, RB3 as input

    clrf on_off
    init_complete: ; debugger label@@@@
    goto run


startup
    movlw b'11111111'
    movwf LATA
    movwf LATC
    movwf LATD

    movlw h'0A' ; 10 defa run etmek icin. Toplamada 1000ms harcayacak.
    movwf waitCoef
    loopx:
    call waste_time100 ; wait 100ms
    decfsz waitCoef
    goto loopx



    movlw b'00000000'
    movwf LATA
    movwf LATC
    movwf LATD
    return



msec200_passed:

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    main:

    movlw h'00'
    cpfseq msecnumber
    goto itisnotA
    goto itisA

    itisnotA:
    movlw h'01'
    cpfseq msecnumber
    goto itisnotC
    goto itisC

    itisnotC:
    movlw h'02'
    cpfseq msecnumber
    goto itisnotD
    goto itisD

    itisnotD:
    nop ;  it should not have come here @ mistake!
    movlw h'03'
    cpfseq msecnumber
    goto itisnot_draw
    goto itis_draw

    itisnot_draw:
    nop; it should not have come here

    itis_draw:
    goto return_from_msec200_draw


    itisD:
    goto return_from_msec200_d

    itisC:
    goto return_from_msec200_c

    itisA:
    goto return_from_msec200_a




    rb0_released:
    movlw h'00'
    cpfseq rb0number
    goto itisnotzero_rb0
    goto itiszero_rb0

    itisnotzero_rb0:
    movlw h'01'
    cpfseq rb0number
    goto itisnotone_rb0
    goto itisone_rb0

    itisnotone_rb0:
    movlw h'02'
    cpfseq rb0number
    goto itisnottwo_rb0
    goto itistwo_rb0

    itisnottwo_rb0:
    movlw h'03'
    cpfseq rb0number
    goto itisnotthree_rb0
    goto itsithree_rb0

    itisnotthree_rb0:
    movlw h'04'
    cpfseq rb0number
    nop ; mistake !!! it should not have come here!
    goto itisfour_rb0

    itisfour_rb0:
    goto rb0_released4

    itsithree_rb0:
    goto rb0_released3

    itistwo_rb0:
    goto rb0_released2

    itisone_rb0:
    goto rb0_released1

    itiszero_rb0:
    nop ; it shoul not have come here mistake!!!





    rb1_released:

    movlw h'00'
    cpfseq rb1number
    goto itisnotzero_rb1
    goto itiszero_rb1

    itisnotzero_rb1:
    movlw h'01'
    cpfseq rb1number
    goto itisnotone_rb1
    goto itisone_rb1

    itisnotone_rb1:
    movlw h'02'
    cpfseq rb1number
    goto itisnottwo_rb1
    goto itistwo_rb1

    itisnottwo_rb1:
    movlw h'03'
    cpfseq rb1number
    goto itisnotthree_rb1
    goto itsithree_rb1

    itisnotthree_rb1:
    movlw h'04'
    cpfseq rb1number
    nop ; mistake !!! it should not have come here!
    goto itisfour_rb1

    itisfour_rb1:
    goto rb1_released4

    itsithree_rb1:
    goto rb1_released3

    itistwo_rb1:
    goto rb1_released2

    itisone_rb1:
    goto rb1_released1

    itiszero_rb1:
    nop ; it shoul not have come here mistake!!!





    rb2_released:

    movlw h'00'
    cpfseq rb2number
    goto itisnotzero_rb2
    goto itiszero_rb2

    itisnotzero_rb2:
    movlw h'01'
    cpfseq rb2number
    goto itisnotone_rb2
    goto itisone_rb2

    itisnotone_rb2:
    movlw h'02'
    cpfseq rb2number
    goto itisnottwo_rb2
    goto itistwo_rb2

    itisnottwo_rb2:
    movlw h'03'
    cpfseq rb2number
    goto itisnotthree_rb2
    goto itsithree_rb2

    itisnotthree_rb2:
    movlw h'04'
    cpfseq rb2number
    nop ; mistake !!! it should not have come here!
    goto itisfour_rb2

    itisfour_rb2:
    goto rb2_released4

    itsithree_rb2:
    goto rb2_released3

    itistwo_rb2:
    goto rb2_released2

    itisone_rb2:
    goto rb2_released1

    itiszero_rb2:
    nop ; it shoul not have come here mistake!!!





    rb3_released:

    movlw h'00'
    cpfseq rb3number
    goto itisnotzero_rb3
    goto itiszero_rb3

    itisnotzero_rb3:
    movlw h'01'
    cpfseq rb3number
    goto itisnotone_rb3
    goto itisone_rb3

    itisnotone_rb3:
    movlw h'02'
    cpfseq rb3number
    goto itisnottwo_rb3
    goto itistwo_rb3

    itisnottwo_rb3:
    movlw h'03'
    cpfseq rb3number
    goto itisnotthree_rb3
    goto itsithree_rb3

    itisnotthree_rb3:
    movlw h'04'
    cpfseq rb3number
    nop ; mistake !!! it should not have come here!
    goto itisfour_rb3

    itisfour_rb3:
    goto rb3_released4

    itsithree_rb3:
    goto rb3_released3

    itistwo_rb3:
    goto rb3_released2

    itisone_rb3:
    goto rb3_released1

    itiszero_rb3:
    nop ; it shoul not have come here mistake!!!


    ;;;;;;


drawingPhase
    ; baslangicta solbastan basla yani ra0 to -> ra7
    clrf isleftedge
    clrf delaycounter1
    clrf delaycounter2
    clrf delaycounter3
    clrf delaycounter4

    clrf goout
    movff rowA, initialrowA
    movff rowC, initialrowC
    movff rowD, initialrowD
    movlw h'00'
    cpfseq portnumber
    goto notportA
    goto yesportA


    notportA:
    movlw h'01'
    cpfseq portnumber
    goto notportC
    goto yesportC

    notportC:
    movlw h'02'
    cpfseq portnumber
    nop ; it should not have come here there is a problem..
    goto yesportD

    yesportD:
    btfss rowD,0 ; eger set edilmemisse 0. bit toggle it
    bsf	rowD,0
    ;btg rowD,0
    movff rowD, LATD
    movff rowD, genericrow
    movlw h'00'
    movwf rightedgeindex
    movwf leftedgeindex
    goto loop_drawing_a


    yesportC:
    btfss rowC,0
    bsf	rowC,0
    ;btg rowC,0
    movff rowC,LATC
    movff rowC, genericrow ; generic rowa kopyala islemler onun uzerinden yapilacak
    movlw h'00'
    movwf rightedgeindex
    movwf leftedgeindex
    goto loop_drawing_a

    yesportA:
    btfss rowA,0
    bsf	rowA,0
    ;btg rowA, 0
    movff rowA,LATA ; put it to LATA.
    movff rowA,genericrow
    movlw h'00'
    movwf rightedgeindex
    movwf leftedgeindex
    goto loop_drawing_a

    loop_drawing_a:


    
     movlw h'00'
     cpfseq counterdraw1
     goto decrease_cd1
     goto check_cd2
     
     check_cd2:
     movlw h'00'
     cpfseq counterdraw2
     goto decrease_cd2 
     goto check_cd3
     
     check_cd3:
     movlw h'00'
     cpfseq counterdraw3
     goto	decrease_cd3
     goto timers_zero
      
      
     decrease_cd1:
     decfsz counterdraw1
     goto jumpy
     
     
     decrease_cd2:
     decfsz counterdraw2
     goto jumpy
      
     decrease_cd3:
     decfsz counterdraw3
     goto jumpy
      
      
     timers_zero:
      ;;;;; Burade m200 2e git geri gel

      
      incf counterdraw4
      movlw h'16'
      cpfseq counterdraw4
      goto notequalto14
      goto equalto14
      
      
      
      notequalto14:
      setf counterdraw1
      setf counterdraw2
      setf counterdraw3
      goto jumpy
      
      equalto14:
      clrf counterdraw4
      
      
     
      
      
      ;------------------------------------------------------------- TO HIT THE MSEC200 LABEL START
      movlw h'03'
      movwf msecnumber
      goto msec200_passed
      return_from_msec200_draw:

      ;------------------------------------------------------------ TO HIT THE MSEC200 LABEL END
      
      setf counterdraw1
      setf counterdraw2
      setf counterdraw3
      goto jumpy
      
     jumpy:
      
      








    ;------------------------ FOR REPLACING GENERIC ROW VALUE ONE OF THE A,C,D ROWS START         -------------------

    movlw h'00'
    cpfseq portnumber
    goto notportA_replace
    goto yesportA_replace


    notportA_replace:
    movlw h'01'
    cpfseq portnumber
    goto notportC_replace
    goto yesportC_replace

    notportC_replace:
    movlw h'02'
    cpfseq portnumber
    nop ; it should not have come here there is a problem..
    goto yesportD_replace

    yesportD_replace:
    btfsc goout,0
    goto goout_d
    movf genericrow,0
    cpfseq rowD
    goto replace_d
    goto afterreplacement

    replace_d:
    movff genericrow, rowD
    movf rowD,0
    iorwf initialrowD,0
    movwf LATD
    ;movff rowD, LATD
    goto afterreplacement



    yesportC_replace:
    btfsc goout,0
    goto goout_c
    movf genericrow,0
    cpfseq rowC
    goto replace_c
    goto afterreplacement

    replace_c:
    movff genericrow, rowC
    movf rowC,0
    iorwf initialrowC,0
    movwf LATC
    ;movff rowC, LATC
    goto afterreplacement



    yesportA_replace:
    btfsc goout,0
    goto goout_a
    movf genericrow,0
    cpfseq rowA
    goto replace_a
    goto afterreplacement

    replace_a:
    movff genericrow, rowA
    movf rowA,0
    iorwf initialrowA,0 ;;; to keep initial line not affected
    movwf LATA
    goto afterreplacement




    goout_d:
    movff genericrow, rowD
    movf rowD,0
    iorwf initialrowD,0
    movwf LATD
    movwf rowD
    return

    goout_c:
    movff genericrow, rowC
    movf rowC,0
    iorwf initialrowC,0
    movwf LATC
    movwf rowC
    return

    goout_a:
    movff genericrow, rowA
    movf rowA,0
    iorwf initialrowA,0
    movwf LATA
    movwf rowA
    return


    ;--------------------------  FOR REPLACING GENERIC ROW VALUE ONE OF THE A,C,D ROWS FINISH     -------------

    afterreplacement:


    ;;;;---------------------------------------------------------------- for delaycounters decrement - o dan buyukse azaltma yapar
    movlw h'00' ; once delaycounter1 bitirilir sonra delaycounter2
    cpfseq delaycounter1
    goto decrement_counter1_draw
    goto decrement_counter2_draw



    decrement_counter1_draw:
    decfsz delaycounter1 ;decrement
    goto  counter_continue_draw

    decrement_counter2_draw:
    movlw h'00'
    cpfseq delaycounter2
    goto dec_counter2
    goto  decrement_counter3_draw

    dec_counter2:
    decfsz delaycounter2
    goto counter_continue_draw


    decrement_counter3_draw:
    movlw h'00'
    cpfseq delaycounter3
    goto dec_counter3
    goto decrement_counter4_draw



    dec_counter3:
    decfsz delaycounter3
    goto counter_continue_draw


    decrement_counter4_draw:
    movlw h'00'
    cpfseq delaycounter4
    decfsz delaycounter4
    goto counter_continue_draw

    counter_continue_draw:

    ;-------------------------------------------------------------------









    ;;;;---------------------------------------------------------------- for delaycounters decrement - o dan buyukse azaltma yapar
    movlw h'00' ; once delaycounter1 bitirilir sonra delaycounter2
    cpfseq delaycounter5
    goto decrement_counter5_draw
    goto decrement_counter6_draw



    decrement_counter5_draw:
    decfsz delaycounter5 ;decrement
    goto  counter_continue_draw_r

    decrement_counter6_draw:
    movlw h'00'
    cpfseq delaycounter6
    goto dec_counter6
    goto  decrement_counter7_draw

    dec_counter6:
    decfsz delaycounter6
    goto counter_continue_draw_r


    decrement_counter7_draw:
    movlw h'00'
    cpfseq delaycounter7
    goto dec_counter7
    goto decrement_counter8_draw



    dec_counter7:
    decfsz delaycounter7
    goto counter_continue_draw_r


    decrement_counter8_draw:
    movlw h'00'
    cpfseq delaycounter8
    decfsz delaycounter8
    goto counter_continue_draw_r

    counter_continue_draw_r:

    ;-------------------------------------------------------------------





    btfss PORTB,1 ;if RB1 botton is pressed it will be high in simulator @ if testing in picsimlab change this to btfsc@@@@@@@
    goto rb1ispressed_drawing_a
    goto rb1isnotpressed_drawing_a

    rb1ispressed_drawing_a:
    btfsc isrb1pressed,0
    goto rb1isnotpressed_drawing_a
    setf isrb1pressed

    movlw h'FF'
    movwf delaycounter1
    movwf delaycounter2
    movwf delaycounter3
    movwf delaycounter4


    rb1isnotpressed_drawing_a:


    btfss PORTB,2 ;if RB2 botton us pressed it will be hight in simulator @ if testing in picsimlab change this to btfsc@@@@@@@
    goto rb2ispressed_drawing_a
    goto rb2isnotpressed_drawing_a

    rb2ispressed_drawing_a:
    btfsc isrb2pressed,0
    goto rb2isnotpressed_drawing_a
    setf isrb2pressed

    movlw h'FF'
    movwf delaycounter1
    movwf delaycounter2
    movwf delaycounter3
    movwf delaycounter4

    rb2isnotpressed_drawing_a:
    ; devam et..


    btfss PORTB,0 ;if RB0 button is pressed it will be hight in simulator @ if testing in picsimlab change this to btfsc@@@@@@@
    goto rb0ispressed_drawing_a
    goto rb0isnotpressed_drawing_a

    rb0ispressed_drawing_a:
    btfsc isrb0pressed,0
    goto rb0isnotpressed_drawing_a
    setf isrb0pressed

    movlw h'FF'
    movwf delaycounter1
    movwf delaycounter2
    movwf delaycounter3
    movwf delaycounter4
    rb0isnotpressed_drawing_a:
    ;devam et...



    btfss PORTB,3 ;if RB3 button is pressed it will be hight in simulator @ if testing in picsimlab change this to btfsc@@@@@@@
    goto rb3ispressed_drawing_a
    goto rb3isnotpressed_drawing_a

    rb3ispressed_drawing_a:
    btfsc isrb3pressed,0
    goto rb3isnotpressed_drawing_a
    setf isrb3pressed

    movlw h'FF'
    movwf delaycounter1
    movwf delaycounter2
    movwf delaycounter3
    movwf delaycounter4
    rb3isnotpressed_drawing_a:
    ; devam et..



    rb1_pressed_drawing_a:

    btfsc isrb1pressed,0 ; eger 0 ise gec bir sonrakini
    goto rb1_isdelay_finished_drawing
    goto rb1_pressed_drawing_ay

    rb1_isdelay_finished_drawing:
    movlw h'00'
    cpfseq delaycounter1
    goto rb1_pressed_drawing_ay
    cpfseq delaycounter2
    goto rb1_pressed_drawing_ay
    cpfseq delaycounter3
    goto rb1_pressed_drawing_ay
    cpfseq delaycounter4
    goto rb1_pressed_drawing_ay
    goto rb1_pressed_drawing_ax


    rb1_pressed_drawing_ax: ;basilmis

    btfsc PORTB,1
    bra rb1_released_drawing_a; ve realease edilmisse gerekli isleme git
    rb1_pressed_drawing_ay: ; basilmamis
    ;devam et

    rb2_pressed_drawing_a:

    btfsc isrb2pressed,0
    goto rb2_isdelay_finished_drawing
    goto rb2_pressed_drawing_ay


    rb2_isdelay_finished_drawing:
    movlw h'00'
    cpfseq delaycounter1
    goto rb2_pressed_drawing_ay
    cpfseq delaycounter2
    goto rb2_pressed_drawing_ay
    cpfseq delaycounter3
    goto rb2_pressed_drawing_ay
    cpfseq delaycounter4
    goto rb2_pressed_drawing_ay
    goto rb2_pressed_drawing_ax

    rb2_pressed_drawing_ax: ;basilmis

    btfsc PORTB,2
    bra rb2_released_drawing_a
    rb2_pressed_drawing_ay: ; basilmamis
    ;devam et

    rb0_pressed_drawing_a:

    btfsc isrb0pressed,0
    goto rb0_isdelay_finished_drawing
    goto rb0_pressed_drawing_ay


    rb0_isdelay_finished_drawing:
    movlw h'00'
    cpfseq delaycounter1
    goto rb0_pressed_drawing_ay
    cpfseq delaycounter2
    goto rb0_pressed_drawing_ay
    cpfseq  delaycounter3
    goto rb0_pressed_drawing_ay
    cpfseq delaycounter4
    goto rb0_pressed_drawing_ay
    goto rb0_pressed_drawing_ax


    rb0_pressed_drawing_ax: ;basilmis

    btfsc PORTB,0
    bra rb0_released_drawing_a
    rb0_pressed_drawing_ay: ; basilmamis
    ;devam et...


    rb3_pressed_drawing_a:

    btfsc isrb3pressed,0
    goto rb3_isdelay_finished_drawing
    goto rb3_pressed_drawing_ay


    rb3_isdelay_finished_drawing:
    movlw h'00'
    cpfseq delaycounter1
    goto rb3_pressed_drawing_ay
    cpfseq delaycounter2
    goto rb3_pressed_drawing_ay
    cpfseq delaycounter3
    goto rb3_pressed_drawing_ay
    cpfseq delaycounter4
    goto rb3_pressed_drawing_ay
    goto rb3_pressed_drawing_ax


    rb3_pressed_drawing_ax: ;basilmis

    btfsc PORTB,3
    bra rb3_released_drawing_a
    rb3_pressed_drawing_ay: ;basilmamis
    ;devam et






    goto loop_drawing_a

    rb1_released_drawing_a:





    btfsc isrb1released,0
    goto rb1_isrelease_delay_finished_draw
    ; eger ilk defa release edilmis ise.
    setf isrb1released
    movlw h'4C'
    movwf  delaycounter5
    movwf  delaycounter6
    movwf  delaycounter7
    movwf  delaycounter8
    goto   loop_drawing_a


    rb1_isrelease_delay_finished_draw:
    movlw h'00'
    cpfseq delaycounter5
    goto loop_drawing_a
    cpfseq delaycounter6
    goto loop_drawing_a
    cpfseq delaycounter7
    goto loop_drawing_a
    cpfseq delaycounter8
    goto loop_drawing_a



    ;-------------------------------------- FOR rbx_released Tag START
    movlw h'01'
    movwf rb1number
    goto rb1_released
    rb1_released1:
    ;--------------------------------------  FOR rbx_released Tag END

    clrf isrb1released
    clrf isrb1pressed


    btfss isleftedge,0
    goto rb1_released_drawing_rightegde_a
    goto rb1_released_drawing_leftegde_a


    rb1_released_drawing_rightegde_a: ;                                   --- RIGHT EDGE RB1
    movf leftedgeindex,0
    subwf rightedgeindex,0
    cpfseq h'00' ; eger indexleri cikardiktan sonra sonuc 0 ise kucuklte yapma!
    goto notequal0_rb1_right_a
    goto loop_drawing_a ; 0 dan kucuk olamaz.

    notequal0_rb1_right_a:
    movlw b'00000001'
    cpfseq rightedgeindex
    goto  notequal1_rb1_right_a
    bcf	genericrow,1
    ;btg genericrow,1;esit o zaman toggle
    ;movff rowA,LATA ; put it to LATA.
    decf rightedgeindex
    goto loop_drawing_a

    notequal1_rb1_right_a:
    movlw b'00000010'
    cpfseq rightedgeindex
    goto notequal2_rb1_right_a
    bcf	genericrow,2
    ;btg genericrow,2 ;esit o zaman toggle
    ;movff rowA,LATA ; put it to LATA.
    decf rightedgeindex
    goto loop_drawing_a

    notequal2_rb1_right_a:
    movlw b'00000011'
    cpfseq rightedgeindex
    goto notequal3_rb1_right_a
    bcf genericrow,3
    ;btg genericrow,3 ;esit o zaman toggle
    ;movff rowA,LATA ; put it to LATA.
    decf rightedgeindex
    goto loop_drawing_a

    notequal3_rb1_right_a:
    movlw b'00000100'
    cpfseq rightedgeindex
    goto notequal4_rb1_right_a
    bcf	genericrow,4
    ;btg genericrow,4 ;esit o zaman toggle
    ;movff rowA,LATA ; put it to LATA.
    decf rightedgeindex
    goto loop_drawing_a

    notequal4_rb1_right_a:
    movlw b'00000101'
    cpfseq rightedgeindex
    goto notequal5_rb1_right_a
    bcf genericrow,5
    ;btg genericrow,5 ;esit o zaman toggle
    ;movff rowA,LATA ; put it to LATA.
    decf rightedgeindex
    goto loop_drawing_a

    notequal5_rb1_right_a:
    movlw b'00000110'
    cpfseq rightedgeindex
    goto notequal6_rb1_right_a
    bcf genericrow,6
    ;btg genericrow,6 ;esit o zaman toggle
    ;movff rowA,LATA ; put it to LATA.
    decf rightedgeindex
    goto loop_drawing_a

    notequal6_rb1_right_a:
    movlw b'00000111'
    cpfseq rightedgeindex
    nop ;no where to go! check it later@@@
    bcf genericrow,7
    ;btg genericrow,7 ;esit o zaman toggle
    ;movff rowA,LATA ; put it to LATA.
    decf rightedgeindex
    goto loop_drawing_a



    rb1_released_drawing_leftegde_a: ;                                     ---LEFT EDGE RB1
    movlw h'00'
    cpfseq leftedgeindex ; eger left edge 0 ise bisey yapma
    goto notequal0_rb1_left_a
    goto loop_drawing_a



    notequal0_rb1_left_a:
    movlw b'00000001'
    cpfseq leftedgeindex
    goto notequal1_rb1_left_a
    bsf	genericrow,0
    ;btg genericrow,0 ; esit o zaman toggle et.
    ;movff rowA,LATA ; put it to LATA.
    decf leftedgeindex
    goto loop_drawing_a

    notequal1_rb1_left_a:
    movlw b'00000010'
    cpfseq leftedgeindex
    goto notequal2_rb1_left_a
    bsf	genericrow,1
    ;btg genericrow,1 ; esit o zaman toggle et.
    ;movff rowA,LATA ; put it to LATA.
    decf leftedgeindex
    goto loop_drawing_a

    notequal2_rb1_left_a:
    movlw b'00000011'
    cpfseq leftedgeindex
    goto notequal3_rb1_left_a
    bsf	genericrow,2
    ;btg genericrow,2 ; esit o zaman toggle et.
    ;movff rowA,LATA ; put it to LATA.
    decf leftedgeindex
    goto loop_drawing_a

    notequal3_rb1_left_a:
    movlw b'00000100'
    cpfseq leftedgeindex
    goto notequal4_rb1_left_a
    bsf	genericrow,3
    ;btg genericrow,3 ; esit o zaman toggle et.
    ;movff rowA,LATA ; put it to LATA.
    decf leftedgeindex
    goto loop_drawing_a

    notequal4_rb1_left_a:
    movlw b'00000101'
    cpfseq leftedgeindex
    goto notequal5_rb1_left_a
    bsf	genericrow,4
    ;btg genericrow,4 ; esit o zaman toggle et.
    ;movff rowA,LATA ; put it to LATA.
    decf leftedgeindex
    goto loop_drawing_a

    notequal5_rb1_left_a:
    movlw b'00000110'
    cpfseq leftedgeindex
    goto notequal6_rb1_left_a
    bsf	genericrow,5
    ;btg genericrow,5 ; esit o zaman toggle et.
    ;movff rowA,LATA ; put it to LATA.
    decf leftedgeindex
    goto loop_drawing_a

    notequal6_rb1_left_a:
    movlw b'00000111'
    cpfseq leftedgeindex
    nop // check this later this case is not possible it should not come here
    bsf	genericrow,6
    ;btg genericrow,6 ; esit o zaman toggle et.
    ;movff rowA,LATA ; put it to LATA.
    decf leftedgeindex
    goto loop_drawing_a


    rb2_released_drawing_a:



    btfsc isrb2released,0
    goto rb2_isrelease_delay_finished_draw
    ; eger ilk defa release edilmis ise.
    setf isrb2released
    movlw h'4C'
    movwf  delaycounter5
    movwf  delaycounter6
    movwf  delaycounter7
    movwf  delaycounter8
    goto   loop_drawing_a


    rb2_isrelease_delay_finished_draw:
    movlw h'00'
    cpfseq delaycounter5
    goto loop_drawing_a
    cpfseq delaycounter6
    goto loop_drawing_a
    cpfseq delaycounter7
    goto loop_drawing_a
    cpfseq delaycounter8
    goto loop_drawing_a


    ;-------------------------------------- FOR rbx_released Tag START
    movlw h'01'
    movwf rb2number
    goto rb2_released
    rb2_released1:
    ;--------------------------------------  FOR rbx_released Tag END
    clrf isrb2released
    clrf isrb2pressed

    btfss isleftedge,0
    goto rb2_released_drawing_rightegde_a
    goto rb2_released_drawing_leftegde_a

    rb2_released_drawing_rightegde_a: ; ----                               RIGHT EDGE RB2
    movlw b'00000111'
    cpfseq rightedgeindex ; eger left edge 0 ise bisey yapma
    goto notequal7_rb2_right_a
    goto loop_drawing_a ; no where to go the just loop around

    notequal7_rb2_right_a:
    movlw b'00000110'
    cpfseq rightedgeindex
    goto notequal6_rb2_right_a
    bsf	genericrow,7
    ;btg genericrow,7 ; 8. ledi yak.
    ;movff rowA,LATA ; put it to LATA.
    incf rightedgeindex
    goto loop_drawing_a

    notequal6_rb2_right_a:
    movlw b'00000101'
    cpfseq rightedgeindex
    goto notequal5_rb2_right_a
    bsf	genericrow,6
    ;btg genericrow,6 ; 7. ledi yak
    ;movff rowA,LATA ; put it to LATA.
    incf rightedgeindex
    goto loop_drawing_a

    notequal5_rb2_right_a:
    movlw b'00000100'
    cpfseq rightedgeindex
    goto notequal4_rb2_right_a
    bsf	genericrow,5
    ;btg genericrow,5 ; 6. ledi yak
    ;movff rowA,LATA ; put it to LATA.
    incf rightedgeindex
    goto loop_drawing_a

    notequal4_rb2_right_a:
    movlw b'00000011'
    cpfseq rightedgeindex
    goto notequal3_rb2_right_a
    bsf	genericrow,4
    ;btg genericrow,4 ; 5. ledi yak
    ;movff rowA,LATA ; put it to LATA.
    incf rightedgeindex
    goto loop_drawing_a


    notequal3_rb2_right_a:
    movlw b'00000010'
    cpfseq rightedgeindex
    goto notequal2_rb2_right_a
    bsf	genericrow,3
    ;btg genericrow,3 ; 4. ledi yak
    ;movff rowA,LATA ; put it to LATA.
    incf rightedgeindex
    goto loop_drawing_a


    notequal2_rb2_right_a:
    movlw b'00000001'
    cpfseq rightedgeindex
    goto notequal1_rb2_right_a
    bsf	genericrow,2
    ;btg genericrow,2 ; 3. ledi yak
    ;movff rowA,LATA ; put it to LATA.
    incf rightedgeindex
    goto loop_drawing_a

    notequal1_rb2_right_a:
    movlw b'00000000'
    cpfseq rightedgeindex
    goto loop_drawing_a
    bsf	genericrow,1
    ;btg genericrow,1 ; 2.ledi yak
    ;movff rowA,LATA ; put it to LATA.
    incf rightedgeindex
    goto loop_drawing_a

    rb2_released_drawing_leftegde_a: ; -                                -- LEFT EDGE RB2
    movf leftedgeindex,0
    subwf rightedgeindex,0
    cpfseq h'00' ;eger sonuc 0 ise daha azatma yapma!
    goto checkzeroth_rb2
    goto loop_drawing_a

    checkzeroth_rb2:
    movlw b'00000000'
    cpfseq leftedgeindex
    goto notequal0_rb2_left_a
    bcf	genericrow,0
    ;btg genericrow,0 ; 0.ledi sondur
    ;movff rowA,LATA ; put it to LATA.
    incf leftedgeindex
    goto loop_drawing_a


    notequal0_rb2_left_a:
    movlw b'00000001'
    cpfseq leftedgeindex
    goto notequal1_rb2_left_a
    bcf	genericrow,1
    ;btg genericrow,1 ; 1.ledi sondur
    ;movff rowA,LATA ; put it to LATA.
    incf leftedgeindex
    goto loop_drawing_a


    notequal1_rb2_left_a:
    movlw b'00000010'
    cpfseq leftedgeindex
    goto notequal2_rb2_left_a
    bcf	genericrow,2
    ;btg genericrow,2 ; 2.ledi sondur
    ;movff rowA,LATA ; put it to LATA.
    incf leftedgeindex
    goto loop_drawing_a

    notequal2_rb2_left_a:
    movlw b'00000011'
    cpfseq leftedgeindex
    goto notequal3_rb2_left_a
    bcf	genericrow,3
    ;btg genericrow,3 ; 4.ledi sondur
    ;movff rowA,LATA ; put it to LATA.
    incf leftedgeindex
    goto loop_drawing_a


    notequal3_rb2_left_a:
    movlw b'00000100'
    cpfseq leftedgeindex
    goto notequal4_rb2_left_a
    bcf	genericrow,4
    ;btg genericrow,4 ; 5.ledi sondur
    ;movff rowA,LATA ; put it to LATA.
    incf leftedgeindex
    goto loop_drawing_a


    notequal4_rb2_left_a:
    movlw b'00000101'
    cpfseq leftedgeindex
    goto notequal5_rb2_left_a
    bcf	genericrow,5
    ;btg genericrow,5 ; 6.ledi sondur
    ;movff rowA,LATA ; put it to LATA.
    incf leftedgeindex
    goto loop_drawing_a


    notequal5_rb2_left_a:
    movlw b'00000110'
    cpfseq leftedgeindex
    goto notequal6_rb2_left_a
    bcf	genericrow,6
    ;btg genericrow,6 ; 7.ledi sondur
    ;movff rowA,LATA ; put it to LATA.
    incf leftedgeindex
    goto loop_drawing_a

    notequal6_rb2_left_a:
    movlw b'00000111'
    cpfseq leftedgeindex ; aslinda burayada gelememeli
    nop ; it should not have come here problem @@@@
    goto loop_drawing_a

    rb0_released_drawing_a:


    btfsc isrb0released,0
    goto rb0_isrelease_delay_finished_draw
    ; eger ilk defa release edilmis ise.
    setf isrb0released
    movlw h'4C'
    movwf  delaycounter5
    movwf  delaycounter6
    movwf  delaycounter7
    movwf  delaycounter8
    goto   loop_drawing_a


    rb0_isrelease_delay_finished_draw:
    movlw h'00'
    cpfseq delaycounter5
    goto loop_drawing_a
    cpfseq delaycounter6
    goto loop_drawing_a
    cpfseq delaycounter7
    goto loop_drawing_a
    cpfseq delaycounter8
    goto loop_drawing_a


    ;-------------------------------------- FOR rbx_released Tag START
    movlw h'01'
    movwf rb0number
    goto rb0_released
    rb0_released1:
    ;--------------------------------------  FOR rbx_released Tag END
    clrf isrb0released
    clrf isrb0pressed

    movf isleftedge,0 ; put the result in working reg
    xorlw h'ff' ;to toggle bits
    movwf isleftedge
    goto loop_drawing_a
    ;movf rowA,0 ; put the result in working reg
    ;xorlw h'ff'; to toggle the leds xor them.
    ;movwf rowA; store the result in the memory for row A.
    ;goto devam_a

    rb3_released_drawing_a:



    btfsc isrb3released,0
    goto rb3_isrelease_delay_finished_draw
    ; eger ilk defa release edilmis ise.
    setf isrb3released
    movlw h'4C'
    movwf  delaycounter5
    movwf  delaycounter6
    movwf  delaycounter7
    movwf  delaycounter8
    goto   loop_drawing_a


    rb3_isrelease_delay_finished_draw:
    movlw h'00'
    cpfseq delaycounter5
    goto loop_drawing_a
    cpfseq delaycounter6
    goto loop_drawing_a
    cpfseq delaycounter7
    goto loop_drawing_a
    cpfseq delaycounter8
    goto loop_drawing_a

    clrf isrb3pressed
    clrf isrb3released

    ;-------------------------------------- FOR rbx_released Tag START
    movlw h'01'
    movwf rb3number
    goto rb3_released
    rb3_released1:
    ;--------------------------------------  FOR rbx_released Tag END
    
    setf goout; to go out of drawing phase
    goto loop_drawing_a


    ;@@@@






rowSelection:

    reserve_for_a:
    ;---------
    movf rowA,0 ; change LATs according to their saved values. Instruction takes rowA stores it in W
    movwf LATA
    movf rowC,0
    movwf LATC
    movf rowD,0
    movwf LATD

    clrf delaycounter1
    clrf delaycounter2
    setf on_off

    ;----------

    selecta:

    clrf isrb1pressed
    clrf isrb0pressed
    clrf isrb2pressed
    clrf isrb3pressed



    btfss on_off,0 ; eger 1 e set edilmise siradaki line i gec
    goto turn_a_off

    turn_a_on:
    movlw b'11111111'; turn on all the leds of A.
    goto blinkRowA

    turn_a_off:
    movlw b'00000000'
    goto blinkRowA

    blinkRowA:

    movwf LATA



    loopA200:


    movlw h'10';---------------- 100 ms bekleme baslangic
    movwf counter_3
    loopA3:
    movlw h'90'
    movwf counter_2
    loopA2:

    ;;---- loopun 2. zarfi baslangic---------------------------------------



    ;;;;---------------------------------------------------------------- for delaycounters decrement - o dan buyukse azaltma yapar
    movlw h'00' ; once delaycounter1 bitirilir sonra delaycounter2
    cpfseq delaycounter1
    goto decrement_counter1_a
    goto decrement_counter2_a

    decrement_counter1_a:
    decfsz delaycounter1 ;decrement
    goto  counter_continue_a

    decrement_counter2_a:
    movlw h'00'
    cpfseq delaycounter2
    decfsz delaycounter2
    goto  counter_continue_a


    counter_continue_a:

    ;-------------------------------------------------------------------



    ;;;;---------------------------------------------------------------- for delaycounters decrement - o dan buyukse azaltma yapar
    movlw h'00' ; o
    cpfseq delaycounter5
    goto decrement_counter5_a
    goto decrement_counter6_a

    decrement_counter5_a:
    decfsz delaycounter5 ;decrement
    goto  counter_continue_a_r

    decrement_counter6_a:
    movlw h'00'
    cpfseq delaycounter6
    decfsz delaycounter6
    goto  counter_continue_a_r


    counter_continue_a_r:

    ;-------------------------------------------------------------------


    btfsc PORTB,1 ;
    goto rb1isnotpressed_a
    goto rb1ispressed_a

    rb1ispressed_a:
    btfsc isrb1pressed,0
    goto rb1isnotpressed_a
    setf isrb1pressed

    movlw h'5C'
    movwf delaycounter1
    movwf delaycounter2

    rb1isnotpressed_a:


    btfsc PORTB,2 ;if RB2 botton is pressed it will be high in simulator @ if testing in picsimlab change this to btfsc@@@@@@@
    goto rb2isnotpressed_a
    goto rb2ispressed_a


    rb2ispressed_a:
    btfsc isrb2pressed,0
    goto rb2isnotpressed_a
    setf isrb2pressed

    movlw h'5C'
    movwf delaycounter1
    movwf delaycounter2

    rb2isnotpressed_a:
    ; devam et..






    btfsc PORTB,0 ;if RB0 button is pressed it will be hight in simulator @ if testing in picsimlab change this to btfsc@@@@@@@
    goto rb0isnotpressed_a
    goto rb0ispressed_a

    rb0ispressed_a:

    btfsc isrb0pressed,0
    goto rb0isnotpressed_a
    setf isrb0pressed

    movlw h'5C'
    movwf delaycounter1
    movwf delaycounter2

    rb0isnotpressed_a:
    ;devam et...



    btfsc PORTB,3 ;if RB3 button is pressed it will be hight in simulator @ if testing in picsimlab change this to btfsc@@@@@@@
    goto rb3isnotpressed_a
    goto rb3ispressed_a

    rb3ispressed_a:
    btfsc isrb3pressed,0
    goto rb3isnotpressed_a

    setf isrb3pressed
    movlw h'5C'
    movwf delaycounter1
    movwf delaycounter2

    rb3isnotpressed_a:
    ; devam et..



    rb1_pressed_a:

    btfsc isrb1pressed,0 ; eger 0 ise gec bir sonrakini
    goto rb1_isdelay_finished_a
    goto rb1_pressed_ay

    rb1_isdelay_finished_a:
    movlw h'00'
    cpfseq delaycounter1
    goto rb1_pressed_ay
    cpfseq delaycounter2
    goto rb1_pressed_ay
    goto rb1_pressed_ax; if counters are both zero then accept releases

    rb1_pressed_ax: ;basilmis

    btfsc PORTB,1
    bra rb1_released_a; ve realease edilmisse gerekli isleme git
    rb1_pressed_ay: ; basilmamis
    ;devam et

    rb2_pressed_a:

    btfsc isrb2pressed,0
    goto rb2_isdelay_finished_a
    goto rb2_pressed_ay

    rb2_isdelay_finished_a:
    movlw h'00'
    cpfseq delaycounter1
    goto rb2_pressed_ay
    cpfseq delaycounter2
    goto rb2_pressed_ay
    goto rb2_pressed_ax

    rb2_pressed_ax: ;basilmis

    btfsc PORTB,2
    bra rb2_released_a
    rb2_pressed_ay: ; basilmamis
    ;devam et

    rb0_pressed_a:

    btfsc isrb0pressed,0
    goto rb0_isdelay_finished_a
    goto rb0_pressed_ay

    rb0_isdelay_finished_a:
    movlw h'00'
    cpfseq delaycounter1
    goto rb0_pressed_ay
    cpfseq delaycounter2
    goto rb0_pressed_ay
    goto rb0_pressed_ax

    rb0_pressed_ax: ;basilmis


    btfsc PORTB,0
    bra rb0_released_a
    rb0_pressed_ay: ; basilmamis
    ;devam et...


    rb3_pressed_a:

    btfsc isrb3pressed,0
    goto rb3_isdelay_finished_a
    goto rb3_pressed_ay

    rb3_isdelay_finished_a:
    movlw h'00'
    cpfseq delaycounter1
    goto rb3_pressed_ay
    cpfseq delaycounter2
    goto rb3_pressed_ay
    goto rb3_pressed_ax

    rb3_pressed_ax: ;basilmis

    btfsc PORTB,3
    bra rb3_released_a
    rb3_pressed_ay: ;basilmamis
    ;devam et


    goto devam_a



    rb1_released_a:



    btfsc isrb1released,0
    goto rb1_isrelease_delay_finished_a
    ; eger ilk defa release edilmis ise.
    setf isrb1released
    movlw h'4C'
    movwf  delaycounter5
    movwf  delaycounter6
    goto devam_a


    rb1_isrelease_delay_finished_a:
    movlw h'00'
    cpfseq delaycounter5
    goto devam_a
    cpfseq delaycounter6
    goto devam_a



    ;-------------------------------------- FOR rbx_released Tag START
    movlw h'02'
    movwf rb1number
    goto rb1_released
    rb1_released2:
    ;--------------------------------------  FOR rbx_released Tag END
    clrf isrb1released
    clrf isrb1pressed
    goto reserve_for_c


    rb2_released_a:


    btfsc isrb2released,0
    goto rb2_isrelease_delay_finished_a
    ; eger ilk defa release edilmis ise.
    setf isrb2released
    movlw h'4C'
    movwf  delaycounter5
    movwf  delaycounter6
    goto devam_a


    rb2_isrelease_delay_finished_a:
    movlw h'00'
    cpfseq delaycounter5
    goto devam_a
    cpfseq delaycounter6
    goto devam_a


    ;-------------------------------------- FOR rbx_released Tag START
    movlw h'02'
    movwf rb2number
    goto rb2_released
    rb2_released2:
    ;--------------------------------------  FOR rbx_released Tag END
    clrf isrb2released
    clrf isrb2pressed

    movlw h'FF'
    movwf on_off
    movwf LATA

    goto devam_a ; nothing will happen at the top now.


    rb0_released_a:





    btfsc isrb0released,0
    goto rb0_isrelease_delay_finished_a
    ; eger ilk defa release edilmis ise.
    setf isrb0released
    movlw h'4C'
    movwf  delaycounter5
    movwf  delaycounter6
    goto devam_a


    rb0_isrelease_delay_finished_a:
    movlw h'00'
    cpfseq delaycounter5
    goto devam_a
    cpfseq delaycounter6
    goto devam_a






    ;-------------------------------------- FOR rbx_released Tag START
    movlw h'02'
    movwf rb0number
    goto rb0_released
    rb0_released2:
    ;--------------------------------------  FOR rbx_released Tag END
    clrf isrb0released
    clrf isrb0pressed
    movf rowA,0 ; put the result in working reg
    xorlw h'ff'; to toggle the leds xor them.
    movwf rowA; store the result in the memory for row A.
    goto devam_a

    rb3_released_a:





    btfsc isrb3released,0
    goto rb3_isrelease_delay_finished_a
    ; eger ilk defa release edilmis ise.
    setf isrb3released
    movlw h'4C'
    movwf  delaycounter5
    movwf  delaycounter6
    goto devam_a


    rb3_isrelease_delay_finished_a:
    movlw h'00'
    cpfseq delaycounter5
    goto devam_a
    cpfseq delaycounter6
    goto devam_a



    clrf isrb3pressed
    clrf isrb3released

    ;-------------------------------------- FOR rbx_released Tag START
    movlw h'02'
    movwf rb3number
    goto rb3_released
    rb3_released2:
    ;--------------------------------------  FOR rbx_released Tag END

    ; do the drawing below for the rowA

    ;----------------------------------------- DRAWING PHASE START---------------------------------------------------
    movlw h'00'
    movwf portnumber ; to indicate port0 is calling drawing phase

    call drawingPhase ;rowA updated bir sekilde cikilacak diger seyler degismeyecek
    nop
    ;----------------------------------------- DRAWING PHASE END-----------------------------------------------------
    movlw h'00'
    movwf on_off
    movwf LATA
    



    devam_a:

    ;;----- loopun 2. zarfi bitis son zarfinin baslangici asagida. ----------
    movlw h'FF'
    movwf counter_1
    loopA1:



    decfsz counter_1,f
    goto loopA1
    decfsz counter_2,f
    goto loopA2
    decfsz counter_3,f
    goto loopA3    ;---------------------- 200ms bekleme bitis


    ;------------------------------------------------------------- TO HIT THE MSEC200 LABEL START
    movlw h'00'
    movwf msecnumber
    goto msec200_passed
    return_from_msec200_a:

    ;------------------------------------------------------------ TO HIT THE MSEC200 LABEL END

    movf on_off,0 ; put the result in working reg
    xorlw h'ff' ; toggle the bits
    movwf on_off
    goto selecta


    reserve_for_c:
    ;---------
    movf rowA,0 ; change LATs according to theri saved values. Instruction takes rowA stores it in W
    movwf LATA
    movf rowC,0
    movwf LATC
    movf rowD,0
    movwf LATD
    clrf delaycounter1
    clrf delaycounter2

    setf on_off
    ;----------

    selectc:
    clrf isrb1pressed
    clrf isrb0pressed
    clrf isrb2pressed
    clrf isrb3pressed



    btfss on_off,0; eger 1 e set edilimse 0.bit siradaki line i atla
    goto turn_c_off

    turn_c_on:
    movlw b'11111111'
    goto blinkRowC

    turn_c_off:
    movlw h'00'
    goto blinkRowC

    blinkRowC:

    movwf LATC

    loopC200:




    movlw h'10' ;--- 100 ms bekleme baslangic
    movwf counter_3
    loopC3:
    movlw h'90'
    movwf counter_2
    loopC2:
    ;;;; ----------------- loopun 2. zarfi baslangic


    ;----------- for delaycounters decrement - 0 dan buyukse azatma yapar
    movlw h'00' ; once delaycounter1 bitirilir sonra delaycounter2
    cpfseq delaycounter1
    goto decrement_counter1_c
    goto decrement_counter2_c

    decrement_counter1_c:
    decfsz delaycounter1 ;decrement
    goto  counter_continue_c

    decrement_counter2_c:
    movlw h'00'
    cpfseq delaycounter2
    decfsz delaycounter2
    goto  counter_continue_c


    counter_continue_c:

    ;-------------------------------------------------------------------





    ;;;;---------------------------------------------------------------- for delaycounters decrement - o dan buyukse azaltma yapar
    movlw h'00' ; o
    cpfseq delaycounter5
    goto decrement_counter5_c
    goto decrement_counter6_c

    decrement_counter5_c:
    decfsz delaycounter5 ;decrement
    goto  counter_continue_c_r

    decrement_counter6_c:
    movlw h'00'
    cpfseq delaycounter6
    decfsz delaycounter6
    goto  counter_continue_c_r


    counter_continue_c_r:

    ;-------------------------------------------------------------------







    btfss PORTB,1 ;if RB1 botton is pressed it will be high in simulator @ if testing in picsimlab change this to btfsc@@@@@@@
    goto rb1ispressed_c
    goto rb1isnotpressed_c

    rb1ispressed_c:
    btfsc isrb1pressed,0
    goto rb1isnotpressed_c
    setf isrb1pressed

    movlw h'4C'
    movwf delaycounter1
    movwf delaycounter2
    rb1isnotpressed_c:

    btfss PORTB,2 ;if RB2 botton us pressed it will be hight in simulator @ if testing in picsimlab change this to btfsc@@@@@@@
    goto rb2ispressed_c
    goto rb2isnotpressed_c

    rb2ispressed_c:
    btfsc isrb2pressed,0
    goto rb2isnotpressed_c
    setf isrb2pressed

    movlw h'4C'
    movwf delaycounter1
    movwf delaycounter2
    rb2isnotpressed_c:
    ; devam et..



    btfss PORTB,0 ;if RB0 button is pressed it will be hight in simulator @ if testing in picsimlab change this to btfsc@@@@@@@
    goto rb0ispressed_c
    goto rb0isnotpressed_c

    rb0ispressed_c:
    btfsc isrb0pressed,0
    goto rb0isnotpressed_c
    setf isrb0pressed

    movlw h'4C'
    movwf delaycounter1
    movwf delaycounter2
    rb0isnotpressed_c:
    ;devam et...


    btfss PORTB,3 ;if RB3 button is pressed it will be hight in simulator @ if testing in picsimlab change this to btfsc@@@@@@@
    goto rb3ispressed_c
    goto rb3isnotpressed_c

    rb3ispressed_c:
    btfsc isrb3pressed,0
    goto rb3isnotpressed_c
    setf isrb3pressed

    movlw h'4C'
    movwf delaycounter1
    movwf delaycounter2
    rb3isnotpressed_c:
    ; devam et..



    rb1_pressed_c:

    btfsc isrb1pressed,0 ; eger 0 ise gec bir sonrakini
    goto rb1_isdelay_finished_c
    goto rb1_pressed_cy

    rb1_isdelay_finished_c:
    movlw h'00'
    cpfseq delaycounter1
    goto rb1_pressed_cy
    cpfseq delaycounter2
    goto rb1_pressed_cy
    goto rb1_pressed_cx

    rb1_pressed_cx: ;basilmis

    btfsc PORTB,1
    bra rb1_released_c; ve realease edilmisse gerekli isleme git
    rb1_pressed_cy: ; basilmamis
    ;devam et

    rb2_pressed_c:

    btfsc isrb2pressed,0
    goto rb2_isdelay_finished_c
    goto rb2_pressed_cy

    rb2_isdelay_finished_c:
    movlw h'00'
    cpfseq delaycounter1
    goto rb2_pressed_cy
    cpfseq delaycounter2
    goto rb2_pressed_cy
    goto rb2_pressed_cx

    rb2_pressed_cx: ;basilmis

    btfsc PORTB,2
    bra rb2_released_c
    rb2_pressed_cy: ; basilmamis
    ;devam et

    rb0_pressed_c:

    btfsc isrb0pressed,0
    goto rb0_isdelay_finished_c
    goto rb0_pressed_cy

    rb0_isdelay_finished_c:
    movlw h'00'
    cpfseq delaycounter1
    goto rb0_pressed_cy
    cpfseq delaycounter2
    goto rb0_pressed_cy
    goto rb0_pressed_cx

    rb0_pressed_cx: ;basilmis

    btfsc PORTB,0
    bra rb0_released_c
    rb0_pressed_cy: ; basilmamis
    ;devam et...


    rb3_pressed_c:

    btfsc isrb3pressed,0
    goto rb3_isdelay_finished_c
    goto rb3_pressed_cy

    rb3_isdelay_finished_c:
    movlw h'00'
    cpfseq delaycounter1
    goto rb3_pressed_cy
    cpfseq delaycounter2
    goto rb3_pressed_cy
    goto rb3_pressed_cx

    rb3_pressed_cx: ;basilmis

    btfsc PORTB,3
    bra rb3_released_c
    rb3_pressed_cy: ;basilmamis
    ;devam et




    goto devam_c






    rb1_released_c:



    btfsc isrb1released,0
    goto rb1_isrelease_delay_finished_c
    ; eger ilk defa release edilmis ise.
    setf isrb1released
    movlw h'4C'
    movwf  delaycounter5
    movwf  delaycounter6
    goto devam_c


    rb1_isrelease_delay_finished_c:
    movlw h'00'
    cpfseq delaycounter5
    goto devam_c
    cpfseq delaycounter6
    goto devam_c


    ;-------------------------------------- FOR rbx_released Tag START
    movlw h'03'
    movwf rb1number
    goto rb1_released
    rb1_released3:
    ;--------------------------------------  FOR rbx_released Tag END

    clrf isrb1released
    clrf isrb1pressed
    goto reserve_for_d


    rb2_released_c:


    btfsc isrb2released,0
    goto rb2_isrelease_delay_finished_c
    ; eger ilk defa release edilmis ise.
    setf isrb2released
    movlw h'4C'
    movwf  delaycounter5
    movwf  delaycounter6
    goto devam_c


    rb2_isrelease_delay_finished_c:
    movlw h'00'
    cpfseq delaycounter5
    goto devam_c
    cpfseq delaycounter6
    goto devam_c



    ;-------------------------------------- FOR rbx_released Tag START
    movlw h'03'
    movwf rb2number
    goto rb2_released
    rb2_released3:
    ;--------------------------------------  FOR rbx_released Tag END
    clrf isrb2released
    clrf isrb2pressed
    goto reserve_for_a


    rb0_released_c:



    btfsc isrb0released,0
    goto rb0_isrelease_delay_finished_c
    ; eger ilk defa release edilmis ise.
    setf isrb0released
    movlw h'4C'
    movwf  delaycounter5
    movwf  delaycounter6
    goto devam_c


    rb0_isrelease_delay_finished_c:
    movlw h'00'
    cpfseq delaycounter5
    goto devam_c
    cpfseq delaycounter6
    goto devam_c






    ;-------------------------------------- FOR rbx_released Tag START
    movlw h'03'
    movwf rb0number
    goto rb0_released
    rb0_released3:
    ;--------------------------------------  FOR rbx_released Tag END
    clrf isrb0released
    clrf isrb0pressed
    movf rowC,0 ;put the result in working reg
    xorlw h'ff' ; to toggle the lets xor them
    movwf rowC ; store the result in the memory for row C
    goto devam_c

    rb3_released_c:




    btfsc isrb3released,0
    goto rb3_isrelease_delay_finished_c
    ; eger ilk defa release edilmis ise.
    setf isrb3released
    movlw h'4C'
    movwf  delaycounter5
    movwf  delaycounter6
    goto devam_c


    rb3_isrelease_delay_finished_c:
    movlw h'00'
    cpfseq delaycounter5
    goto devam_c
    cpfseq delaycounter6
    goto devam_c



    clrf isrb3pressed
    clrf isrb3released



    ;-------------------------------------- FOR rbx_released Tag START
    movlw h'03'
    movwf rb3number
    goto rb3_released
    rb3_released3:
    ;--------------------------------------  FOR rbx_released Tag END

    ; do the drawing below for the rowC

    ;----------------------------------------- DRAWING PHASE START---------------------------------------------------
    movlw h'01'
    movwf portnumber ; to indicate portC is calling drawing phase

    call drawingPhase ;rowC updated bir sekilde cikilacak diger seyler degismeyecek
    nop
    ;----------------------------------------- DRAWING PHASE END-----------------------------------------------------

    movlw h'FF'
    movwf on_off
    movwf LATC


    devam_c:

    ;;;;; -------------------------- loopun 2. zarfi bitis
    movlw h'FF'
    movwf counter_1
    loopC1:

    ;
    decfsz counter_1,f
    goto loopC1
    decfsz counter_2,f
    goto loopC2
    decfsz counter_3,f
    goto loopC3	    ; ----- 200ms bekleme bitis


    ;------------------------------------------------------------- TO HIT THE MSEC200 LABEL START
    movlw h'01'
    movwf msecnumber
    goto msec200_passed
    return_from_msec200_c:

    ;------------------------------------------------------------ TO HIT THE MSEC200 LABEL END

    movf on_off,0 ; put the result back in working reg
    xorlw h'ff'; toggle the bits
    movwf on_off
    goto selectc


    reserve_for_d:
    ;---------
    movf rowA,0 ; change LATs according to theri saved values. Instruction takes rowA stores it in W
    movwf LATA
    movf rowC,0
    movwf LATC
    movf rowD,0
    movwf LATD
    clrf delaycounter1
    clrf delaycounter2

    setf on_off
    ;----------

    selectd:

    clrf isrb1pressed
    clrf isrb0pressed
    clrf isrb2pressed
    clrf isrb3pressed


    btfss on_off,0
    goto turn_d_off

    turn_d_on:
    movlw b'11111111'
    goto blinkRowD
    turn_d_off:
    movlw b'00000000'
    goto blinkRowD

    blinkRowD:

    movwf LATD


    loopD200:

    movlw h'10' ; ---- 100ms bekleme baslangic
    movwf counter_3
    loopD3:
    movlw h'90'
    movwf counter_2
    loopD2:
    ;-------- loop 2. zarf baslangic -----------------------------


    ;;;;---------------------------------------------------------------- for delaycounters decrement - o dan buyukse azaltma yapar
    movlw h'00' ; once delaycounter1 bitirilir sonra delaycounter2
    cpfseq delaycounter1
    goto decrement_counter1_d
    goto decrement_counter2_d

    decrement_counter1_d:
    decfsz delaycounter1 ;decrement
    goto  counter_continue_d

    decrement_counter2_d:
    movlw h'00'
    cpfseq delaycounter2
    decfsz delaycounter2
    goto  counter_continue_d


    counter_continue_d:

    ;-------------------------------------------------------------------




    ;;;;---------------------------------------------------------------- for delaycounters decrement - o dan buyukse azaltma yapar
    movlw h'00' ; o
    cpfseq delaycounter5
    goto decrement_counter5_d
    goto decrement_counter6_d

    decrement_counter5_d:
    decfsz delaycounter5 ;decrement
    goto  counter_continue_d_r

    decrement_counter6_d:
    movlw h'00'
    cpfseq delaycounter6
    decfsz delaycounter6
    goto  counter_continue_d_r


    counter_continue_d_r:

    ;-------------------------------------------------------------------






    btfss PORTB,1 ;if RB1 botton is pressed it will be high in simulator @ if testing in picsimlab change this to btfsc@@@@@@@
    goto rb1ispressed_d
    goto rb1isnotpressed_d

    rb1ispressed_d:
    btfsc isrb1pressed,0
    goto rb1isnotpressed_d
    setf isrb1pressed

    movlw h'4C'
    movwf delaycounter1
    movwf delaycounter2
    rb1isnotpressed_d:


    btfss PORTB,2 ;if RB2 botton us pressed it will be hight in simulator @ if testing in picsimlab change this to btfsc@@@@@@@
    goto rb2ispressed_d
    goto rb2isnotpressed_d

    rb2ispressed_d:
    btfsc isrb2pressed,0
    goto rb2isnotpressed_d
    setf isrb2pressed

    movlw h'4C'
    movwf delaycounter1
    movwf delaycounter2
    rb2isnotpressed_d:
    ; devam et..


    btfss PORTB,0 ;if RB0 button is pressed it will be hight in simulator @ if testing in picsimlab change this to btfsc@@@@@@@
    goto rb0ispressed_d
    goto rboisnotpressed_d

    rb0ispressed_d:
    btfsc isrb0pressed,0
    goto rboisnotpressed_d
    setf isrb0pressed

    movlw h'4C'
    movwf delaycounter1
    movwf delaycounter2
    rboisnotpressed_d:
    ;devam et...



    btfss PORTB,3 ;if RB3 button is pressed it will be hight in simulator @ if testing in picsimlab change this to btfsc@@@@@@@
    goto rb3ispressed_d
    goto rv3isnotpressed_d

    rb3ispressed_d:
    btfsc isrb3pressed,0
    goto rv3isnotpressed_d
    setf isrb3pressed

    movlw h'4C'
    movwf delaycounter1
    movwf delaycounter2
    rv3isnotpressed_d:
    ; devam et..



    rb1_pressed_d:

    btfsc isrb1pressed,0 ; eger 0 ise gec bir sonrakini
    goto rb1_isdelay_finished_d
    goto rb1_pressed_dy

    rb1_isdelay_finished_d:
    movlw h'00'
    cpfseq delaycounter1
    goto rb1_pressed_dy
    cpfseq delaycounter2
    goto rb1_pressed_dy
    goto rb1_pressed_dx

    rb1_pressed_dx: ;basilmis

    btfsc PORTB,1
    bra rb1_released_d; ve realease edilmisse gerekli isleme git
    rb1_pressed_dy: ; basilmamis
    ;devam et

    rb2_pressed_d:

    btfsc isrb2pressed,0
    goto rb2_isdelay_finished_d
    goto rb2_pressed_dy

    rb2_isdelay_finished_d:
    movlw h'00'
    cpfseq delaycounter1
    goto rb2_pressed_dy
    cpfseq delaycounter2
    goto rb2_pressed_dy
    goto rb2_pressed_dx


    rb2_pressed_dx: ;basilmis

    btfsc PORTB,2
    bra rb2_released_d
    rb2_pressed_dy: ; basilmamis
    ;devam et

    rb0_pressed_d:

    btfsc isrb0pressed,0
    goto rb0_isdelay_finished_d
    goto rb0_pressed_dy

    rb0_isdelay_finished_d:
    movlw h'00'
    cpfseq delaycounter1
    goto rb0_pressed_dy
    cpfseq delaycounter2
    goto rb0_pressed_dy
    goto rb0_pressed_dx

    rb0_pressed_dx: ;basilmis

    btfsc PORTB,0
    bra rb0_released_d
    rb0_pressed_dy: ; basilmamis
    ;devam et...


    rb3_pressed_d:

    btfsc isrb3pressed,0
    goto rb3_isdelay_finished_d
    goto rb3_pressed_dy


    rb3_isdelay_finished_d:
    movlw h'00'
    cpfseq delaycounter1
    goto rb3_pressed_dy
    cpfseq delaycounter2
    goto rb3_pressed_dy
    goto rb3_pressed_dx

    rb3_pressed_dx: ;basilmis

    btfsc PORTB,3
    bra rb3_released_d
    rb3_pressed_dy: ;basilmamis
    ;devam et





    goto devam_d


    rb1_released_d:



    btfsc isrb1released,0
    goto rb1_isrelease_delay_finished_d
    ; eger ilk defa release edilmis ise.
    setf isrb1released
    movlw h'4C'
    movwf  delaycounter5
    movwf  delaycounter6
    goto devam_d


    rb1_isrelease_delay_finished_d:
    movlw h'00'
    cpfseq delaycounter5
    goto devam_d
    cpfseq delaycounter6
    goto devam_d



    ;-------------------------------------- FOR rbx_released Tag START
    movlw h'04'
    movwf rb1number
    goto rb1_released
    rb1_released4:
    ;--------------------------------------  FOR rbx_released Tag END
    clrf isrb1released
    clrf isrb1pressed

    movlw h'FF'
    movwf on_off
    movwf LATD


    goto devam_d ;nothing will happen at the bottom now.


    rb2_released_d:


    btfsc isrb2released,0
    goto rb2_isrelease_delay_finished_d
    ; eger ilk defa release edilmis ise.
    setf isrb2released
    movlw h'4C'
    movwf  delaycounter5
    movwf  delaycounter6
    goto devam_d


    rb2_isrelease_delay_finished_d:
    movlw h'00'
    cpfseq delaycounter5
    goto devam_d
    cpfseq delaycounter6
    goto devam_d



    ;-------------------------------------- FOR rbx_released Tag START
    movlw h'04'
    movwf rb2number
    goto rb2_released
    rb2_released4:
    ;--------------------------------------  FOR rbx_released Tag END
    clrf isrb2released
    clrf isrb2pressed


    goto reserve_for_c


    rb0_released_d:



    btfsc isrb0released,0
    goto rb0_isrelease_delay_finished_d
    ; eger ilk defa release edilmis ise.
    setf isrb0released
    movlw h'4C'
    movwf  delaycounter5
    movwf  delaycounter6
    goto devam_d


    rb0_isrelease_delay_finished_d:
    movlw h'00'
    cpfseq delaycounter5
    goto devam_d
    cpfseq delaycounter6
    goto devam_d




    ;-------------------------------------- FOR rbx_released Tag START
    movlw h'04'
    movwf rb0number
    goto rb0_released
    rb0_released4:

    ;--------------------------------------  FOR rbx_released Tag END
    clrf isrb0released
    clrf isrb0pressed
    movf rowD,0 ; put the result in working reg
    xorlw h'ff'; to toggle the leds xor them.
    movwf rowD; store the result in the memory for row A.
    goto devam_d


    rb3_released_d:




    btfsc isrb3released,0
    goto rb3_isrelease_delay_finished_d
    ; eger ilk defa release edilmis ise.
    setf isrb3released
    movlw h'4C'
    movwf  delaycounter5
    movwf  delaycounter6
    goto devam_d


    rb3_isrelease_delay_finished_d:
    movlw h'00'
    cpfseq delaycounter5
    goto devam_d
    cpfseq delaycounter6
    goto devam_d



    clrf isrb3pressed
    clrf isrb3released

    ;-------------------------------------- FOR rbx_released Tag START
    movlw h'04'
    movwf rb3number
    goto rb3_released
    rb3_released4:
    ;--------------------------------------  FOR rbx_released Tag END
    ; do the drawing below for the rowD

    ;----------------------------------------- DRAWING PHASE START---------------------------------------------------
    movlw h'02'
    movwf portnumber ; to indicate portC is calling drawing phase

    call drawingPhase ;rowD updated bir sekilde cikilacak diger seyler degismeyecek
    nop
    ;----------------------------------------- DRAWING PHASE END-----------------------------------------------------
    movlw h'FF'
    movwf on_off
    movwf LATD
    

    devam_d:
    ;-------- loop 2. zarf bitis ---------------------------------------


    movlw h'FF'
    movwf counter_1
    loopD1:


    decfsz counter_1,f
    goto loopD1
    decfsz counter_2,f
    goto loopD2
    decfsz counter_3,f
    goto loopD3  ; --------------------- 200 ms bitis



    ;------------------------------------------------------------- TO HIT THE MSEC200 LABEL START
    movlw h'02'
    movwf msecnumber
    goto msec200_passed
    return_from_msec200_d:

    ;------------------------------------------------------------ TO HIT THE MSEC200 LABEL END



    movf on_off,0 ; put the result in working reg.
    xorlw h'ff'; toggle the bits
    movwf on_off
    goto selectd







run:

    call startup
    sec_passed:
    goto rowSelection
end


;;;

