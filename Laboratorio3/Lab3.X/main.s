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

    
; Archivo:	LAB4.S
; Dispositivo:	PIC16F887
; Autor:	Jorge Lanza
; Compilador:	pic-as (v2.31), MPLABX V5.40
;
; Programa:	7 segmentos y contador con pushbuttons
; Hardware:	Pushbottons en PORTB, 4 LEDs PORTA, 7 segmentos en PORTC y PORTD
; 
; Creado:	23 feb, 2021
; úlitma modificación: 23 feb, 2021

 PROCESSOR 16F887
 #include <xc.inc>
 
;***************************
;				CONFIGURACIÓN DE BITS
;***************************
 
;configuration word 1
 CONFIG FOSC=INTRC_NOCLKOUT ; Oscilador externo de cristal a 1MHz
 CONFIG WDTE=OFF    ; wdt disables (reinicio repetitivo del pic)
 CONFIG PWRTE=ON    ; PWRT enabled (espera de 72ms al iniciar)
 CONFIG MCLRE=OFF   ; El pin de MCLR se utiliza como I/O
 CONFIG CP=OFF	    ; Sin protección de código
 CONFIG CPD=OFF	    ; Sin protección de datos
 
 CONFIG BOREN=OFF   ; Sin reinicio cuándo el voltaje de alimentación baja de 4V
 CONFIG IESO=OFF    ; Reinicio sin cambio de reloj de interno a externo
 CONFIG FCMEN=OFF   ; Cambio de reloj externo a interno en caso de fallo
 CONFIG LVP=ON	    ; programación en bajo voltaje permitida
 
 ;configuration word 2
 CONFIG WRT=OFF	    ; Protección de autoescritura por el programa desactivada
 CONFIG BOR4V=BOR40V ; Reinicio abajo de 4v, (BOR21V=2.1V)
 
 
;***************************
;				    VARIABLES
;***************************
 
PSECT udata_bank0 
    cont_auto:		DS 1
    cont_timer0:	DS 1 ; 1 byte
    
PSECT udata_shr ;memoria compartida
    w_temp:	 DS 1
    status_temp: DS 1
    
;***************************
;			   INSTRUCCIONES VECTOR DE RESET
;***************************

 PSECT resVector, class=CODE, abs, delta=2
 ORG 00h	    ; posición 0000h para el reset
 resetVector:
    PAGESEL main
    goto main
 
;***************************
;			CONFIGURACIÓN DEL MICROCONTROLADOR
;***************************

PSECT intVect, class=CODE,abs, delta=2
ORG 04h
push:
    movwf w_temp
    swapf STATUS, w
    movwf status_temp

isr:
    btfsc RBIF
    call  int_OCB
    btfsc T0IF
    call  int_tm0

pop:
    swapf status_temp, w
    movwf STATUS
    swapf w_temp, f
    swapf w_temp, w
    retfie
 


PSECT code, delta=2, abs
ORG 100h
siete_seg:
    clrf    PCLATH
    bsf	    PCLATH, 0
    andlw   0Fh
    addwf   PCL, F
    retlw   3Fh	    ; 0
    retlw   06h	    ; 1
    retlw   5Bh	    ; 2
    retlw   4Fh	    ; 3
    retlw   66h	    ; 4
    retlw   6Dh	    ; 5
    retlw   7Dh	    ; 6
    retlw   07h	    ; 7
    retlw   7Fh	    ; 8
    retlw   6Fh	    ; 9
    retlw   77h	    ; A
    retlw   7Ch	    ; B
    retlw   39h	    ; C
    retlw   5Eh	    ; D
    retlw   79h	    ; E
    retlw   71h	    ; F
    
main:
    call    config_IO
    call    Tm0_config
    call    reloj_config
    call    config_iocb
    call    config_interrup
    banksel PORTA
    clrf    PORTA
    movlw   3Fh
    movwf   PORTC
    movwf   PORTD
    clrf    cont_auto
    clrf    cont_timer0
    
    
    
;***************************
;				    LOOP PRINCIPAL
;***************************
loop:
    call siete_seg_manual
    call siete_seg_auto
    goto loop
;***************************
;				    SUBRUTINAS
;***************************

;**********CONFIGURACIONES************

config_IO: 
    banksel ANSEL
    clrf    ANSEL	    ; pines digitales
    clrf    ANSELH
    
    banksel TRISA
    bsf	    TRISB, 0	    ;PORTB, 0 y 1 como entreada
    bsf	    TRISB, 1
    clrf    TRISA	    ;PORT A, C y D como salidas
    clrf    TRISC   
    clrf    TRISD
    bcf	    OPTION_REG, 7   ;habilita pull-ups
    bsf	    WPUB, 0	    ;incrementar
    bsf	    WPUB, 1	    ;decrementar
    return

Tm0_config:
    banksel TRISA
    bcf	    T0CS    ; selección del reloj interno
    bcf	    PSA	    ; asignamos prescaler al Timer0
    bsf	    PS2
    bsf	    PS1
    bcf	    PS0	    ; prescaler a 128
    banksel PORTA
    movlw   217
    movwf   TMR0
    bcf	    T0IF
    return

reloj_config:
    banksel TRISA
    bsf	    IRCF2
    bcf	    IRCF1
    bcf	    IRCF0	    ; reloj a 1MHz 
    return

config_interrup:
    banksel TRISA
    bsf	    GIE
    
    bsf	    RBIE	    ;interrupción del puerto B
    bcf	    RBIF
    
    bsf	    T0IE	    ;interrupción del Timer0
    bcf	    T0IF   
    return

config_iocb:
    banksel TRISA
    bsf	    IOCB, 0
    bsf	    IOCB, 1
    
    banksel PORTA
    movf    PORTB, W
    bcf	    RBIF    
    return

    

int_OCB:
    btfss   PORTB, 0
    incf    PORTA
    btfss   PORTB, 1
    decf    PORTA
    bcf	    RBIF
    return

int_tm0:
    banksel PORTA
    movlw   217
    movwf   TMR0
    bcf	    T0IF
    incf    cont_timer0
    return
    
siete_seg_manual:
    movf    PORTA, W
    call    siete_seg
    movwf   PORTC
    return
 
siete_seg_auto:
    movlw   50
    subwf   cont_timer0, w	
    btfsc   ZERO
    call    aumento_contador_siete_seg
    return
    
aumento_contador_siete_seg:
    clrf    cont_timer0
    incf    cont_auto
    movf    cont_auto, W
    call    siete_seg
    movwf   PORTD
    return
END