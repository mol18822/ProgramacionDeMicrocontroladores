;Dispositivo:		PIC16F887
;Autor;			Luis Pedro Molina Velásquez 
;Carné;			18822
;Compilador:		pic-as (v2.31) MPLABX V5.40
; ---------------------------------------------------------------------------- ;    
; ------------------------- Laboratorio No. 4 -------------------------------- ;     
; ------------------ Interrupt-on-change del PORTB --------------------------- ;

;Creado:		22 febrero, 2021
;Ultima modificación:	27 febrero, 2021

; ---------------------------------------------------------------------------- ;
    
PROCESSOR 16F887
#include <xc.inc>

; ---------------------------- Configuraciones ------------------------------ ; 
    
; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT enabled)
  CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = ON            ; Brown Out Reset Selection bits (BOR enabled)
  CONFIG  IESO = ON             ; Internal External Switchover bit (Internal/External Switchover mode is enabled)
  CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is enabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)
  
; ------------------------------ Macros -------------------------------------- ;

; ---------------- Macro para incrementar y decrementar ---------------------- ;
Inc_Dec macro			

    btfss   PORTB,  0
    incf    PORTA
    btfss   PORTB,  1
    decf    PORTA
    endm
    
; --------------------- Macro para reset del Timer0 -------------------------- ;
    
RT0 macro   

    btfss   T0IF
    movlw   134
    movwf   TMR0
    bcf	    T0IF
    endm

; ---------------------------- Variables ------------------------------------- ;

PSECT udata_shr			; Common memory
 
    wtempo:			; Variable 1
    DS  1
    
    stattempo:			; Variable 2
    DS  1
    
    SevenD:			; Variable 3
    DS  2			    

    Contador_auto:		; Variable 4
    DS  1
    
    Contador_Timer0:		; Variable 5
    DS  1
; --------------------------- Vector Reset ----------------------------------- ;
    
PSECT resVect, class=code, abs, delta=2

ORG 00h				; Posicion 0000h para el vector reset
    
resetVec:
    
    PAGESEL main
    goto main
 
PSECT code, delta=2, abs
 
ORG 04h				; 
 
; --------------------------- Interrupciones --------------------------------- ;
 
Push:
    
    movwf   wtempo		;
    swapf   STATUS, W		;
    movwf   stattempo		;
    
Isr:
    
    btfsc   RBIF		;
    call    Int_IOCB		;
    btfsc   T0IF		;
    call    Int_Timer0	    	;
    
Pop:
    
    swapf   stattempo, W	;
    movwf   STATUS		;
    swapf   wtempo, F		;
    swapf   wtempo, W		;
    retfie
    
PSECT code, delta=2, abs
ORG 100h			; Posición para el código
    
; ------------------------- Configuración de tabla --------------------------- ;

 Table:
    
    clrf  PCLATH
    bsf   PCLATH,0
    andlw 0x0F
    addwf PCL			; PC = PCLATH + PCL + W
    retlw 00111111B		; Cero	    --> 0
    retlw 00000110B		; Uno	    --> 1
    retlw 01011011B		; Dos	    --> 2
    retlw 01001111B		; Tres	    --> 3
    retlw 01100110B		; Cuatro    --> 4
    retlw 01101101B		; Cinco	    --> 5
    retlw 01111101B		; Seis	    --> 6
    retlw 00000111B		; Siete	    --> 7
    retlw 01111111B		; Ocho	    --> 8
    retlw 01100111B		; Nueve	    --> 9
    retlw 01110111B		; A	    -->	10
    retlw 01111100B		; B	    --> 11
    retlw 00111001B		; C	    -->	12  
    retlw 01011110B		; D	    --> 13
    retlw 01111001B		; E	    --> 14
    retlw 01110001B		; F	    --> 15
    
; --------------------------- Configuración ---------------------------------- ; 

main:
   
    call    Config_Input_Output
    call    Config_Timer0
    call    Oscillator
    call    Config_IOCB
    call    Config_Int
    BANKSEL PORTA
    clrf    PORTA
    movlw   3Fh
    movwf   PORTC
    movwf   PORTD
    clrf    Contador_auto
    clrf    Contador_Timer0
    
; --------------------------- Loop Principal --------------------------------- ;
 
loop:
    
    call sevenD_1
    call sevenD_2
    
    goto loop
    
; -------------------- Configurando puertos digitales ------------------------ ;
    
Config_Input_Output:
    
    BANKSEL ANSEL		; Se selecciona bank 3
    clrf    ANSEL		; Definir puertos digitales
    clrf    ANSELH
    
; ------------ Configuración de pines del puerto A --> Outputs --------------- ;
  
    BANKSEL TRISA		; Se selecciona bank 1
    bcf	    TRISA,  0		; R0 --> Output --> Led 1 --> 0001
    bcf	    TRISA,  1		; R1 --> Output --> Led 2 --> 0010
    bcf	    TRISA,  2		; R2 --> Output --> Led 3 --> 0100
    bcf	    TRISA,  3		; R3 --> Output --> Led 4 --> 1000
    
; ----------- Configuración de pines del puerto B -- > Outputs --------------- ;
    
    BANKSEL TRISB		; Se selecciona bank 1
    bsf	    TRISB,  0		; R0 --> Input --> PB1 --> Increase
    bsf	    TRISB,  1		; R1 --> Input --> PB2 --> Decrease

; ------------ Configuración de pines del puerto C --> Outputs --------------- ;
    
    BANKSEL TRISC		; Se selecciona bank 1
    bcf	    TRISC,  0		; R0 --> Output  --> 7D - A 
    bcf	    TRISC,  1		; R1 --> Output  --> 7D - B
    bcf	    TRISC,  2		; R2 --> Output  --> 7D - C
    bcf	    TRISC,  3		; R3 --> Output  --> 7D - D
    bcf	    TRISC,  4		; R4 --> Output  --> 7D - E
    bcf	    TRISC,  5		; R5 --> Output  --> 7D - F
    bcf	    TRISC,  6		; R6 --> Output  --> 7D - G
  
; ----------- Configuración de pines del puerto D --> Outputs ---------------- ;
    
    BANKSEL TRISD		; Se selecciona bank 1
    bcf	    TRISD,  0		; R0 --> Output  --> 7D - A
    bcf	    TRISD,  1		; R1 --> Output  --> 7D - B
    bcf	    TRISD,  2		; R2 --> Output  --> 7D - C
    bcf	    TRISD,  3		; R3 --> Output  --> 7D - D
    bcf	    TRISD,  4		; R4 --> Output  --> 7D - E
    bcf	    TRISD,  5		; R5 --> Output  --> 7D - F
    bcf	    TRISD,  6		; R6 --> Output  --> 7D - G
    
; ------------------------- PORTB en pull-up --------------------------------- ;    

    BANKSEL	OPTION_REG
    bcf		OPTION_REG,  7
    
    BANKSEL	WPUB
    bsf		WPUB,  0	; Increase
    bsf		WPUB,  1	; Decrease
    

; -------------------------- Limpieza de puertos ----------------------------- ; 
    
    BANKSEL PORTA
    
    clrf    PORTA
    clrf    PORTB
    clrf    PORTC
    clrf    PORTD
    return
; ---------------------------- Sub-Rutinas ----------------------------------- ;
    
; ----------------------- Configuración del Timer0 --------------------------- ;

Config_Timer0:
    
    BANKSEL TRISA
    bcf	    T0CS		;
    bcf	    PSA			;
    bsf	    PS2			;
    bsf	    PS1			;
    bcf	    PS0			;
    
    BANKSEL PORTA		;
    movlw   217			;
    movwf   TMR0		;
    bcf	    T0IF		;
    return

; -------------------------- Oscilador interno ------------------------------- ;

Oscillator:		    
    
    BANKSEL TRISA
    bsf	    IRCF2		; 
    bcf	    IRCF1		; 
    bcf	    IRCF0		; 
    return  

; -------------------- Configuración de Interrupciones------------------------ ;

Config_Int:
    
    BANKSEL TRISA
    bsf	    GIE
    
    bsf	    RBIE
    bcf	    RBIF    
    
    bsf	    T0IE
    bcf	    T0IF
    return
    
; ----------------------- Configuración de IOCB ------------------------------ ;
    
Config_IOCB:
    
    BANKSEL TRISA
    bsf	    IOCB,  0
    bsf	    IOCB,  1
    
    BANKSEL PORTA
    movf    PORTB, W
    bcf	    RBIF
    return
    
; ------------------------ Interrupción de IOCB ------------------------------ ;
    
Int_IOCB:
    
    btfss   PORTB,  0
    incf    PORTA
    btfss   PORTB,  1
    decf    PORTA
    bcf	    RBIF
    return

; ----------------------- Interrupción de Timer0 ----------------------------- ;
    
Int_Timer0:
    
    BANKSEL PORTA
    movlw   217
    movwf   TMR0
    bcf	    T0IF
    incf    Contador_Timer0
    return
    
; -------------------- Display 7 segmentos en PORTC -------------------------- ;
    
sevenD_1:
    
    movf    PORTA, W
    call    Table
    movwf   PORTC
    return
    
; -------------------- Display 7 segmentos en PORTD -------------------------- ;
    
sevenD_2:
    
    movlw   50
    subwf   Contador_Timer0, W
    btfsc   ZERO
    call    Increase_Cont7D
    return
    
;------------- Increase para contador de 7 segmentos en PORTD ---------------- ;
    
Increase_Cont7D:
    
    clrf    Contador_Timer0
    incf    Contador_auto
    movf    Contador_auto, W
    call    Table
    movwf   PORTD
    return
        
END