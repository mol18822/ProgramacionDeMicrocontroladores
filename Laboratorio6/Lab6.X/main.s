;Dispositivo:		PIC16F887
;Autor;			Luis Pedro Molina Velásquez 
;Carné;			18822
;Compilador:		pic-as (v2.31) MPLABX V5.40
; ---------------------------------------------------------------------------- ;    
; ------------------------- Laboratorio No. 6 -------------------------------- ;     
; -------------------------- Temporizadores ---------------------------------- ;

;Creado:		02 marzo, 2021
;Ultima modificación:	06 marzo, 2021

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
  
; ------------------------------- Macros ------------------------------------- ;

TMR2_reset  macro
    BANKSEL PR2
    movlw   100
    movwf   PR2
endm
    
; ---------------------------- Variables ------------------------------------- ;
  
PSECT udata_shr			; Memoria compartida

    W_temp:			; Variable 1
	DS  1			; 1 byte
    Status_temp:		; Variable 2
	DS  1			; 1 byte
    nibble:			; Variable 3	--> Contador hexadecimal
	DS  2			; 2 bytes	
    var4Displays:		; Variable 4	--> Variable para displays
	DS  2			; 2 bytes
    flags:			; Variable 5
	DS  1			; 1 byte
	
PSECT udata_bank0		; Memoria banco 0

    counter:			; Variable 6
	DS  1			; 1 byte
    blink_flag:			; Variable 7
	DS  1			; 1 byte
	
; --------------------------- Vector Reset ----------------------------------- ;
	
PSECT resVect, class=code, abs, delta=2
ORG 00h				; Posición 0000h para el vector reset

resetVec:
    PAGESEL	main
    goto	main

; ----------------- Configuración de interrupciones -------------------------- ;

PSECT intVect, class=code, abs, delta=2 
ORG 04h				; Posición para las interrupciones
    
Push:
    movwf   W_temp		;
    swapf   STATUS, W		;
    movwf   Status_temp		;
    
Isr:    
    BANKSEL PORTB		;
    btfsc   TMR1IF		; Chequeando overflow en Timer1
    call    int_Timer1		; Llamando subrutina de interrupción de Timer1
    btfsc   T0IF		; Chequeando overflow en Timer0
    call    int_Timer0		; Llamando subrutina de interrupción de Timer0
    BANKSEL PIR1		;
    btfsc   TMR2IF		; Chequeando overflow en Timer2
    call    int_Timer2		; Llamando subrutina de interrupción de Timer2
    BANKSEL TMR2		; 
    bcf	    TMR2IF		; Bandera TMR2IF == 0 
    
Pop:
    swapf   Status_temp, W	;
    movwf   STATUS		;
    swapf   W_temp, F		;
    swapf   W_temp, W		;
    retfie  
    
; ---------------------- Subrutinas de interrupción -------------------------- ;    
; ------------------------- Interrupción de Timer0 --------------------------- ;
    
int_Timer0:    
    call    reset_Timer0	; Limpieza de Timer0
    bcf	    PORTD, 1		; 
    bcf	    PORTD, 2		;
    btfsc   flags, 0		;
    goto    Display2		;

reset_Timer0:
    movlw   255			;
    movwf   TMR0		;
    bcf	    T0IF		;
    return    
        
; ------------------------- Interrupción de Timer1 --------------------------- ;
    
int_Timer1:
    BANKSEL TMR1H		; 
    movlw   225			;
    movwf   TMR1H		;
    BANKSEL TMR1L		;
    movlw   124			; 
    movwf   TMR1L		;   
    incf    counter		;
    bcf	    TMR1IF		;
    return

; ----------------------- Interrupción de Timer2 ----------------------------- ;
    
int_Timer2:
    btfsc   blink_flag, 0	; Chequeando la bandera 
    goto    flag_off		; 
    
flag_on: 
    bsf	    blink_flag, 0	; Flag == 1
    return
    
flag_off:    
    bcf	    blink_flag, 0	; Flag == 0 
    return

; ---------------------- Interrupción para Displays -------------------------- ;
    
Display1:    
    movf    var4Displays, W	;
    movwf   PORTC		;
    bsf	    PORTD, 2		;
    goto    Next_D		;
    
Display2:
    movf    var4Displays+1 , W	;
    movwf   PORTC		;
    bsf	    PORTD, 1		;
    
Next_D:
    movlw   1			;
    xorwf   flags, F		;
    return    
    
; ---------------------------------------------------------------------------- ;
    
PSECT code, delta=2, abs
ORG 100h			; Posición para el código
        
    
; ----------------------- Configuración de tabla ----------------------------- ;

 table:
   
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
    
; ------------------------------- Main --------------------------------------- ;    
;ORG 118h    
main:
    
    call    oscillator
    call    configuration_IO
    call    config_int
    call    config_Timer0
    call    config_Timer1
    call    config_Timer2
    

; --------------------------- Subrutinas ------------------------------------- ;
    
; ------------------- Configuración de reloj interno ------------------------- ;
    
oscillator:
    
    BANKSEL OSCCON
    bcf	    IRCF2		; 0
    bsf	    IRCF1		; 1
    bcf	    IRCF0		; 0
    bsf	    SCS
    return    
    
; ----------------- Configuración de puertos digitales ----------------------- ;
    
configuration_IO:

    BANKSEL ANSEL		; Se selecciona bank 3
    clrf    ANSEL		; I/O análogicos == 0 
    clrf    ANSELH		; I/O analógicos == 0
    
; ------------- Configuración de pines del puerto C --> Outputs -------------- ;    
    
    BANKSEL TRISC		; Se selecciona banco 1
    clrf    TRISC		; PORTC como outputs
    
; ------------- Configuracióin de pines del puerto D --> Outputs ------------- ;
    
    BANKSEL TRISD		; Se selecciona banco 1
    clrf    TRISD		; PORTD como outputs
        
       
; -------------------------- Limpieza de puertos ----------------------------- ;
    
    BANKSEL PORTA
    clrf    PORTC
    clrf    PORTD
    return
        
; --------------------- Configuración de interrupciones------------------------ ;    
    
config_int:
    
    BANKSEL INTCON
    bsf	    GIE			; Interrupción global
    bsf	    T0IE		; Interrupción de Timer0
    bcf	    T0IF		; Interrupción de Timer0
    
    BANKSEL PIE1		
    bsf	    TMR2IE		; Timer2 para PR2 == 1
    bsf	    TMR1IE		; Interrupción por overflow en Timer1 == 1  
    
    BANKSEL PIR1	    
    bcf	    TMR2IF		; Limpieza de banderas de Timer2
    bcf	    TMR1IF		; Limpieza de banderas de interrupciones de Timer1
    return
    
; ----------------------- Configuración de Timer0 ---------------------------- ;
    
config_Timer0:
    
    BANKSEL OPTION_REG
    bcf	    T0CS
    bcf	    PSA			; Preescaler de 1:256
    bsf	    PS2			; 1 
    bsf	    PS1			; 1
    bsf	    PS0			; 1
    
; ----------------------- Configuración de Timer1 ---------------------------- ;
    
config_Timer1:
    
    BANKSEL T1CON
    bsf	    T1CKPS1		; Preescaler de 1:8
    bsf	    T1CKPS0		;
    bcf	    TMR1CS		; Reloj interno ==  1
    bsf	    TMR1ON		; Timer1 == 1
    
; ------------------------ Configuración de Timer2 --------------------------- ;
    
config_Timer2:
    
    BANKSEL T2CON		; 1001 --> Postscaler 
    movlw   1001110B		; 1    --> Timer2 == 1  
    movwf   T2CON		; 10   --> Preescaler a 1:16
    
; ------------------------- Loop principal ----------------------------------- ;
    
loop:
    TMR2_reset
    BANKSEL PORTA
    call    nibbles_separation
    btfss   blink_flag, 0
    call    nibbles_preparation
    btfsc   blink_flag, 0
    call    blinking
    
    goto    loop

; ----------------------------- Subrutinas ----------------------------------- ;
; ------------------------- División de nibbles ------------------------------ ;
    
nibbles_separation:
    movf    counter, W		;
    andlw   00001111B		;
    movwf   nibble		;
    swapf   counter, W		;		
    andlw   00001111B		;
    movwf   nibble+1		;
    return
    
; ------------------------ Preparación de nibbles ---------------------------- ;
    
nibbles_preparation:
    movf    nibble, W		;
    call    table		;
    movwf   var4Displays, F	; Primer display
    movf    nibble+1, W		;		
    call    table		;
    movwf   var4Displays+1, F	; Segundo display
    bsf	    PORTD, 0		;
    return
    
; ---------------------------- Parpadeo -------------------------------------- ;
    
blinking:
    movlw   0			;
    movwf   var4Displays	;
    movwf   var4Displays+1	;
    bcf	    PORTD, 0		;
    return
    

END  