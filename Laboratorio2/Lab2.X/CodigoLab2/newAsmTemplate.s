;Dispositivo:		PIC16F887
;Autor;			Luis Pedro Molina Velásquez 
;Carné;			18822
;Compilador:		pic-as (v2.31) MPLABX V5.40
; ---------------------------------------------------------------------------- ;    
; ------------------------- Laboratorio No. 2 -------------------------------- ;     
; ------------------------- Sumador de 4 bits -------------------------------- ;

;Creado:		09 febrero, 2021
;Ultima modificación:	13 febrero, 2021
    
PROCESSOR 16F887
#include <xc.inc>

; CONFIGURACIÓN 1
  CONFIG  FOSC = XT ; 
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIGURACIÓN 2 
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)
  
;--------------------------- CONFIGURATION ----------------------------------- ;
  
PSECT code, delta=2, abs
ORG 100h
main:
     
    banksel ANSEL         
    clrf    ANSEL          ; Colocamos en cero los pines con ANSEL y ANSELH, 
    clrf    ANSELH	   ; para que puedan ser I/O digitales
    
    banksel  TRISA
    
; ------------------------ PORT A CONFIGURATION ------------------------------ ;
    
    bcf TRISA, 0           ; Output
    bcf TRISA, 1	   ; Output
    bcf TRISA, 2	   ; Output
    bcf TRISA, 3	   ; Output
    bsf TRISA, 4           ; Input
    bsf TRISA, 5	   ; Input
    
; ------------------------ PORT B CONFIGURATION ------------------------------ ;
    
    bcf TRISB, 0           ; Output
    bcf TRISB, 1	   ; Output
    bcf TRISB, 2	   ; Output
    bcf TRISB, 3	   ; Output
    bsf TRISB, 4           ; Input
    bsf TRISB, 5	   ; Input
    
; ------------------------ PORT C CONFIGURATION ------------------------------ ;
    
    bcf TRISC, 0           ; Output
    bcf TRISC, 1	   ; Output
    bcf TRISC, 2	   ; Output
    bcf TRISC, 3	   ; Output
    bcf TRISC, 4	   ; Output
    
; ------------------------ PORT D CONFIGURATION ------------------------------ ;
    
    bsf TRISD, 1           ; Input 
    
; ---------------------------------------------------------------------------- ;

; -------------------------- Limpiando pines --------------------------------- ;
    
    banksel PORTA
    clrf    PORTA
    clrf    PORTB
    clrf    PORTC
    clrf    PORTD
    
; ---------------------------------------------------------------------------- ;

; -------------------------- Bucle Principal --------------------------------- ;
    
    
; -------------------------- Botones en Pull-Up ------------------------------ ;
    
loop: 
    
    clrw                   ; Limpiando último valor de w
    btfss   PORTA, 4       ; Testeo PB pin 4 en PORTA --> Para ver si está en 0
    call    Increase_1     ; Si pin 4 PORTA == 0 ; --> Ir a Increase_1
    btfss   PORTA, 5       ; Testeo PB pin 5 en PORTA --> Para ver si está en 0 
    call    Decrease_1     ; Si pin 5 PORTA == 0 ; --> Ir a Decrease_1
    btfss   PORTB, 4       ; Testeo PB pin 4 en PORTB --> Para ver si está en 0
    call    Increase_2     ; Si pin 4 PORTB == 0 ; --> Ir a Increase_2
    btfss   PORTB, 5       ; Testeo PB pin 5 en PORTB --> Para ver si está en 0
    call    Decrease_2     ; Si pin 5 PORTB == 0 ; --Z Ir a Decrease_2
    btfss   PORTD, 1       ; Testeo PB pin 1 en PORTD --> Para ver si está en 0
    call    Suma	   ; Si pin 1 PIND == 0 ; --> Ir a Suma
    goto    loop           ; Mantenerse en el ciclo actual, denominado "loop"

; ------------------------- Counter 1 - PORTA --------------------------------- ;
    
; ----------------------------- Increase ------------------------------------- ;

Increase_1:
    
    btfss   PORTA, 4       ; Antirebote 
    goto    $-1            ; Si pin 4 de PORTA == 0 ; --> Regresar una línea
    incf    PORTA, 1       ; Al soltar el PB se envía la señal --> Incrementar 
    return                 ; Regresa a la interrupción en el loop

; ----------------------------- Decrease ------------------------------------- ;

Decrease_1:
    
    btfss   PORTA, 5       ; Antirebote 
    goto    $-1            ; Si pin 4 de PORTA == 0 ; --> Regresar una línea
    decf    PORTA, 1       ; Al soltar el PB se envía la señal --> Decrecer
    return                 ; Regresa a la interrupción en el loop
    
; -------------------------- Counter 2 - PORTB ------------------------------- ;
    
; ----------------------------- Increase ------------------------------------- ;
    
Increase_2:
    
    btfss   PORTB, 4       ; Antirebote
    goto    $-1            ; Si pin 4 de PORTB == 0 ; --> Regresar una línea 
    incf    PORTB, 1       ; Al soltar el PB se envía la señal --> Incrementar
    return                 ; Regresa a la interrupción en el loop
    
; ----------------------------- Decrease ------------------------------------- ;
    
Decrease_2:
    
    btfss   PORTB, 5       ; Antirebote
    goto    $-1            ; Si el pin 5 de PORTB esta en cero regresa una linea
    decf    PORTB, 1       ; Cuando se haya soltado el boton se decrementa PORTB
    return                 ; Regresa a la interrupción en el loop
    
; ----------------------------- Sumador -------------------------------------- ;
    
Suma:    
    
    btfsc   STATUS, 0      ; Testea si la flag de carry == 1
    bsf     PORTC,  4      ; Si flag de carry == 1 ; --> pin 4 de PORTC == 1
    btfss   STATUS, 0      ; Testea si la flag de carry  == 0
    bcf     PORTC,  4      ; Si flag de carry == 0 ; --> pin 4 de PORTC == 0
    btfss   PORTD,  1      ; Antirebote --> Testea si pin 1 de PORTD == 0 
    goto    $-1            ; Si pin 1 de PORTD == 0 ; --> Regresa una línea
    movf    PORTA,  0      ; Asignando valor de PORTA a w
    addwf   PORTB,  0      ; El valor de w se suma a PORTB. El resultado  a W
    movwf   PORTC          ; Asignando valor de w a PORTC   
    return                 ; Regresa a la interrupción en el loop
end

; ---------------------------------------------------------------------------- ;