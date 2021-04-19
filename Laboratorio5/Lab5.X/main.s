
;Dispositivo:		PIC16F887
;Autor;			Luis Pedro Molina Velásquez 
;Carné;			18822
;Compilador:		pic-as (v2.31) MPLABX V5.40
; ---------------------------------------------------------------------------- ;    
; ------------------------- Laboratorio No. 5 -------------------------------- ;     
; ----------------------- Displays simultáneos ------------------------------- ;

;Creado:		02 marzo, 2021
;Ultima modificación:	06 marzo, 2021

; ---------------------------------------------------------------------------- ;
    
PROCESSOR 16F887
#include <xc.inc>

; -------------------------- Configuraciones --------------------------------- ; 
    
; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillador interno
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
  
PSECT udata_shr			; Memoria compartida

    W_temp:			; Variable 1
	DS  1			; 1 byte
    Status_temp:		; Variable 2
	DS  1			; 1 byte
	
PSECT udata_bank0		; Memoria banco 0
	
    Contador_Centenas:		; Variable 3
	DS  1			; 1 byte
    Contador_Decenas:		; Variable 4
	DS  1			; 1 byte
    nibble:			; Variable 5	--> Contador hexadecimal
	DS  2			; 2 bytes
    storage:			; Variable 6	--> Almacena valor de cont hexa
	DS  1			; 1 byte
    var4Displays:		; Variable 7	--> Variable para displays
	DS  5			; 5 bytes
    PORTD_storage:		; Variable 8	--> Elíge cual disp encender
	DS  1			; 1 byte
	
; --------------------------- Vector Reset ----------------------------------- ;
	
PSECT resVector, class=code, abs, delta=2
ORG 00h				; Posición 0000h para el vector reset

resetVec:
    PAGESEL	main
    goto	main

; ----------------- Configuración de interrupciones -------------------------- ;

PSECT intVect, class=code, abs, delta=2 
ORG 04h				; 

Push:
    movwf   W_temp		;
    swapf   STATUS, W		;
    movwf   Status_temp		;
    
Isr:
    btfsc   RBIF		;
    call    int_OCB		;
    btfsc   T0IF		;
    call    int_Timer0	    	;
    
Pop:
    swapf   Status_temp, W	;
    movwf   STATUS		;
    swapf   W_temp, F		;
    swapf   W_temp, W		;
    retfie

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
    
main:
    call    configuration_IO	; Configuración de I/O en los diferentes puertos
    call    configuration_Tm0	; Configuración de Timer0
    call    oscillator		; Clock
    call    configuration_IOCB	; Configuración de interrupt on change en PORTB
    call    configuration_int	; Configuración de interrupciones
    banksel PORTA		; 
    clrf    PORTA		;
    clrf    PORTD		;
    movlw   00111111		; Se almcacena valor "0" en W
    movwf   PORTC		; Valor de W a PORTC, 5 displays en "0"
    
    bsf	    PORTD, 0		; Primer display  == 1
    bcf	    PORTD, 0		; Primer display  == 0
    bsf	    PORTD, 1		; Segundo display == 1
    bcf	    PORTD, 1		; Segundo display == 0
    bsf	    PORTD, 2		; Tercer dispaly  == 1
    bcf	    PORTD, 2		; Tercer display  == 0
    bsf	    PORTD, 3		; Cuarto display  == 1
    bcf	    PORTD, 3		; Cuarto display  == 0
    bsf	    PORTD, 4		; Quinto display  == 1 
    bcf	    PORTD, 4		; Quinto display  == 0
    movlw   00000001		; Valor almacenado a W --> Solo 1 bit encendido
    movwf   PORTD_storage	; W a la variable de almacenamiento de displays
    clrf    Contador_Centenas	;
    clrf    Contador_Decenas	;
    
; ------------------------- Loop principal ----------------------------------- ;
    
loop:
    call nibbles_separation	;
    call display_conthexa	;
    call Cont_Centenas		;
    goto loop			;
    
; --------------------------- Subrutinas ------------------------------------- ;
 
; ----------------- Configuración de puertos digitales ----------------------- ;
    
configuration_IO:
   
    BANKSEL ANSEL		; Se selecciona bank 3
    clrf    ANSEL		; Definir puertos digitales
    clrf    ANSELH
    
; ------------ Configuración de pines del puerto A --> Outputs --------------- ;
  
    BANKSEL TRISA		; Se selecciona banco 1
    bcf	    TRISA,  0		; R0 --> Output 
    bcf	    TRISA,  1		; R1 --> Output 
    bcf	    TRISA,  2		; R2 --> Output 
    bcf	    TRISA,  3		; R3 --> Output 
    bcf	    TRISA,  4		; R4 --> Output 
    bcf	    TRISA,  5		; R5 --> Output 
    bcf	    TRISA,  6		; R6 --> Output 
    bcf	    TRISA,  7		; R7 --> Output 
 
; ----------- Configuración de pines del puerto B -- > Outputs --------------- ;
    
    BANKSEL TRISB		; Se selecciona banco 1
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
    bcf	    TRISD,  0		; R0 --> Output  
    bcf	    TRISD,  1		; R1 --> Output  
    bcf	    TRISD,  2		; R3 --> Output  
    bcf	    TRISD,  3		; R4 --> Output  
    bcf	    TRISD,  4		; R5 --> Output  

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

; ----------------------- Configuración de Timer0 ---------------------------- ;
    
configuration_Tm0:
    
    banksel TRISA		; Selección de banco 1
    bcf	    T0CS		; Selección de clock interno
    bcf	    PSA			; Preescaler a Tm0
    bcf	    PS2			;
    bsf	    PS1			;
    bcf	    PS0			; Preescaler 1/8
    banksel PORTA		; Selección de banco 0
    movlw   125			; Valor hallado con la fórmula --> Cuenta hasta 255
    movwf   TMR0		; Traslado de valor a Tm0
    bcf	    T0IF		; Flag de interrupción == 0
    return

; ---------------- Configuración del oscillador interno ---------------------- ;

oscillator:
    
    BANKSEL TRISA		;
    bcf	    IRCF2		; 0
    bsf	    IRCF1		; 1
    bsf	    IRCF0		; 1
    return  

; ----------------------- Configuración de iocb ------------------------------ ;
    
configuration_IOCB:
    
    BANKSEL TRISA		; Selección de banco 1
    bsf	    IOCB, 0		; Interrupción en PORTB --> RB0
    bsf	    IOCB, 1		; Interrupción en PORTB --> RB1
    BANKSEL PORTA		; Selección de banco 0
    movf    PORTB, W		; Traslado de valor de PORTB a W
    bcf	    RBIF		; Flag de interrupción de PORTB == 0
    return
    
; ------------------- Configuración de interrupciones ------------------------ ;

configuration_int:
    
    banksel TRISA		; Sellección de banco 1
    bsf	    GIE			; Interrupciones == 1
    bsf	    RBIE		; Interrupciones en PORTB == 1
    bcf	    RBIF		; Flag de interrupciones en PORTB == 0
    bsf	    T0IE		; Interrupción de Timer0 == 1
    bcf	    T0IF		; Flag de interrupciones de Timer0 == 0
    return
    
; ---------------------- Rutina de interrupciones ---------------------------- ;
    
int_OCB:
    
    btfss   PORTB, 0		; Chequeo de valor de RB0, PORTB --> PB1
    incf    PORTA		; Incremento de valor en PORTA --> Cont Hexa
    btfss   PORTB, 1		; Chequeo de valor de RB1, PORTB --> PB2
    decf    PORTA		; Decremento de valor en PORTA --> Cont Hexa
    bcf	    RBIF		; Flag de interrupción de PORTB == 0
    return
    
int_Timer0:	    
    
    BANKSEL PORTA		; Selección de banco 0
    movlw   125			; Valor a cargarse --> W
    movwf   TMR0		; Valor de W a Timer0
    bcf	    T0IF		; Flag de interrupción de Timer0 == 0
    btfsc   PORTD_storage, 0	; Se revisa si RD0 == 1
    goto    Display1		; Si RD0 == 1 --> Se va a Display1
    btfsc   PORTD_storage, 1	; Se revisa si RD1 == 1
    goto    Display2		; Si RD1 == 1 --> Se va a Display2
    btfsc   PORTD_storage, 2	; Se revisa si RD2 == 1
    goto    Display3		; Si RD2 == 1 --> Se va a Display3
    btfsc   PORTD_storage, 3	; Se revisa si RD3 == 1
    goto    Display4		; Si RD3 == 1 --> Se va a Display4
    btfsc   PORTD_storage, 4	; Se revisa si RD4 == 1
    goto    Display5		; Si RD4 == 1 --> Se va a Display5
    
Display1:	    
    
    clrf    PORTD		; PORTD == 0
    movf    var4Displays, W	; Valor del primer nibble a W
    movwf   PORTC		; Valor a PORTC
    bsf	    PORTD, 0		; RD0 == 1
    goto    Next_D		; Ir a siguiente display
    
Display2:
    
    clrf    PORTD		;
    movf    var4Displays + 1, W	;
    movwf   PORTC		;
    bsf	    PORTD, 1		;
    goto    Next_D		;
    
Display3:
    
    clrf    PORTD		;
    movf    var4Displays + 2, W	;
    movwf   PORTC		;
    bsf	    PORTD, 2		;
    goto    Next_D		;
    
Display4:
    
    clrf    PORTD		;
    movf    var4Displays + 3, W	;
    movwf   PORTC		;
    bsf	    PORTD, 3		;
    goto    Next_D		;
    
Display5:   
    
    clrf    PORTD		;
    movf    var4Displays + 4 , W;
    movwf   PORTC		;
    bsf	    PORTD, 4		;
    goto    Next_D		;
    
Next_D:
    
    bcf	    CARRY		; Señal del Carry == 0 
    btfss   PORTD_storage, 5	; Chequeo de 5to bit de PORTD_storage == 1
    goto    $+3			; Salta 3 instrucciones
    movlw   00000001		; Se carga ese valor a W
    movwf   PORTD_storage	; W a PORTD_storage
    rlf	    PORTD_storage, F	; Señal del carry a la derecha
    return
    
; --------------------------- Subrutinas ------------------------------------- ;
    
; -------------------- Separación de nibbles --------------------------------- ;
    
nibbles_separation:
    
    movf    PORTA, W		; Valor de contador hexadecimal a W
    andwf   0x0f		; Comparación de valores --> Nibble más significativo 
    movwf   nibble + 1		; Almacenamiento en la segunda posición
    swapf   PORTA, W		; Valor de PORTA a W 
    andwf   0x0f		; Comparación de valores
    movwf   nibble		;
    return
    
; ------------------------ Preparación de display ---------------------------- ;
    
display_conthexa:
    
    movf    nibble, W		; Valor de nibble más significativa a W
    call    table		; Valor de W a la tabla de display
    movwf   var4Displays	; Valor a display más significativo   --> Hexa
    movf    nibble + 1, W	; Valor de nibble menos significativa a W
    call    table		; Valor de W a tabla de display
    movwf   var4Displays + 1	; Valor a display menos significativo --> Hexa
    return
    
; ------------------------ Contador de centenas ------------------------------ ;
    
Cont_Centenas:
    
    clrf    Contador_Centenas	; Contador_Centenas == 0 
    bcf	    CARRY		; Flag carry == 0
    movf    PORTA, W		; Valor de cont hexa a W
    movwf   storage		; W a variable Storage
    movlw   100			; 100 a W 
    subwf   storage, F		; Storage - 100 --> Resultado a F
    incf    Contador_Centenas	; Incrementa el contador de centenas 
    btfsc   CARRY		; Carry == 0 --> Valor negativo
    goto    $-3			; Regresa 3 lineas de código --> Resta otra vez
    decf    Contador_Centenas	; Reduce en 1 las centenas
    addwf   storage		; Storage + 100 
    movf    Contador_Centenas, W; Valor de contador a W
    call    table		; Valor de W a la tabla de display
    movwf   var4Displays + 2	; Traslado de valor a display de centenas
    call    Cont_Decenas	; Llamando a contador de decenas
    return
    
Cont_Decenas:
    
    clrf    Contador_Decenas	;
    bcf	    CARRY		;
    movlw   10			;
    subwf   storage		;
    incf    Contador_Decenas	;
    btfsc   CARRY		;
    goto    $-3			;
    decf    Contador_Decenas	;
    addwf   storage		;
    movf    Contador_Decenas, W	;
    call    table		;
    movwf   var4Displays + 3	;
    movf    storage, W		;
    call    table		;
    movwf   var4Displays + 4	;
    return  
    

END
