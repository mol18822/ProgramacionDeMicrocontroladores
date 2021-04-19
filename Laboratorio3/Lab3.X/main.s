;Dispositivo:		PIC16F887
;Autor;			Luis Pedro Molina Velásquez 
;Carné;			18822
;Compilador:		pic-as (v2.31) MPLABX V5.40
; ---------------------------------------------------------------------------- ;    
; ------------------------- Laboratorio No. 3 -------------------------------- ;     
; ------------------------- Botones y Timer 0 -------------------------------- ;

;Creado:		16 febrero, 2021
;Ultima modificación:	20 febrero, 2021

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
    
; ---------------------------- Variables ------------------------------------- ;
  
PSECT udata_bank0		 

counter:	DS 1

; --------------------------- Vector Reset ----------------------------------- ;
    
PSECT resVect, class=code, abs, delta=2

ORG 00h				; Posicion 0000h para el vector reset
    
resetVec:
    
    PAGESEL main
    goto main

PSECT code, delta=2, abs
 
ORG 100h			; Posicion para el código
 
; ------------------------- Configuración de tabla ---------------------------- ;
 
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
    
    call Oscillator
    
; -------------------- Configurando puertos digitales ------------------------ ;
    
    BANKSEL ANSEL		; Se selecciona bank 3
    clrf    ANSEL		; Definir puertos digitales
    clrf    ANSELH
    
; ------------ Configuración de pines del puerto A --> Inputs ---------------- ;
    
    BANKSEL TRISA		; Se selecciona bank 1
    bsf	    TRISA,  0		; R0 --> Input  --> PB1  --> Increase	    
    bsf	    TRISA,  1		; R1 --> Input	--> PB2	 --> Decrease

; ----------- Configuración de pines del puerto B -- > Outputs --------------- ;
    
    BANKSEL TRISB		; Se selecciona bank 1
    bcf	    TRISB,  0		; R0 --> Output  --> Led 1  --> 0001
    bcf	    TRISB,  1		; R1 --> Output  --> Led 2  --> 0010
    bcf	    TRISB,  2		; R2 --> Output  --> Led 3  --> 0100
    bcf	    TRISB,  3		; R3 --> Output  --> Led 4  --> 1000
    
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
    
    BANKSEL TRISD		; Se selecciona el bank 1
    bcf	    TRISD,  0		; R0 --> Output  --> Led 5 - Alarma
    
; ---------------------------------------------------------------------------- ;
    
    BANKSEL OPTION_REG
    movlw   11000111B	
    movwf   OPTION_REG		; Prescaler de 256
    
; -------------------------- Limpieza de puertos ----------------------------- ; 
    
    BANKSEL PORTA
    
    clrf    PORTA
    clrf    PORTB
    clrf    PORTC
    clrf    PORTD
   
; --------------------------- Loop Principal --------------------------------- ;
 
loop:

    btfss   PORTA, 0		; RA0 --> PB1
    call    Increase_1		; Llamando al aumentador
    
    btfss   PORTA, 1		; RA1 --> PB2
    call    Decrease_1		; LLamando al decresor
    
    btfss   T0IF		; Suma cuando llegue al overflow el timer0
    goto    $-1
    call    Resett		; Regresa el overflow a 0
    incf    PORTB
    
    bcf	    PORTD, 0
    call    overf 
   
    goto loop			; Regresa al inicio del loop 

; ---------------------------- Sub-Rutinas ----------------------------------- ;

; -------------------------- Oscilador interno ------------------------------- ;
    
Oscillator:		    
    
    BANKSEL OSCCON
    bcf	    IRCF2		; 0
    bsf	    IRCF1		; 1
    bcf	    IRCF0		; 0
    bsf	    SCS			; Activar oscilador interno
    return  


; ------------------------------- Increase ----------------------------------- ;
    
Increase_1: 
    
    btfss   PORTA, 0		; Antirebote
    goto    $-1			; Si pin 0 de PORTA == 0 ; --> Regresar una linea
    incf    counter		; Incrementando valor y almacenandolo en "counter"
    movf    counter, W		; Trasladando valor a W
    call    Table		; Llamando Table --> 7D
    movwf   PORTC, 1		; Trasladando output a PORTC 
    return			; Regresa al inicio del loop
    
; ------------------------------- Decrease ----------------------------------- ; 
    
Decrease_1: 
    
    btfss   PORTA, 1		; Antirebote
    goto    $-1			; Si pin 1 de PORTA == 1 ; --> Regresar una línea
    decfsz  counter		; Decrementando valor y almacenandolo en "counter"
    movwf   counter, W		; Trasladando valor a W
    call    Table		; LLamando Table --> 7D
    movwf   PORTC, 1		; Trasladando output a PORTC
    return			; Regresa al inicio del loop

; ------------------------- Reinicio de conteo ------------------------------- ;
 
Resett:
    
    movlw   1			; Tiempo de intruccion
    movwf   TMR0
    bcf	    T0IF		; Bit de overflow == 0
    return			; Regresa al loop principal

; ---------------------------- Overfl0w -------------------------------------- ;

overf:
    
    movf    PORTB, W		; Valor de contador de 4 bits a W
    subwf   counter, W		; Resta de W a counter
    btfsc   STATUS, 2		; Si los valores son iguales --> z flag == 1
    call    Signal		; Si z flag == 1 ; --> Led == 1
    return
    
    
; ----------------------------- Señal ---------------------------------------- ;    

Signal:
    
    bsf	    PORTD, 0		; Led == 1
    clrf    PORTB		; Reinicio de contador binario
    return
     
; ---------------------------------------------------------------------------- ; 
END