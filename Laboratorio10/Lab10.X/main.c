// Dispositivo:		PIC16F887
// Autor;			Luis Pedro Molina Velásquez 
// Carné;			18822
// Compilador:		pic-as (v2.31) MPLABX V5.40
// ----------------------------------------------------------------------------     
// ----------------------- Laboratorio No. 10 ---------------------------------      
// -------------------------- Módulo UART -------------------------------------

// Creado:                  04 mayo, 2021
// Ultima modificación:     09 mayo , 2021

//  Bits de configuracion   

// CONFIG1
#pragma config FOSC = INTRC_NOCLKOUT// Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
#pragma config PWRTE = OFF      // Power-up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = OFF      // RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
#pragma config BOREN = OFF      // Brown Out Reset Selection bits (BOR disabled)
#pragma config IESO = OFF       // Internal External Switchover bit (Internal/External Switchover mode is disabled)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
#pragma config LVP = OFF        // Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

// CONFIG2
#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits (Write protection off)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

#define _XTAL_FREQ 8000000
#include <xc.h>
#include <stdint.h>
#include <stdio.h>

// ------- Código de la primera parte - Entregable en el laboratorio ---------- 
/*
// ----------------------------- Variables ------------------------------------

const char var = 70;

// ------------------- Configuración de interrupciones ------------------------

void setup(void);

void __interrupt() isr(void) {
    
    if (PIR1bits.RCIF == 1) {
        PORTB = RCREG;                  // Trasladando valores a PORTB
    }
    if (PIR1bits.TXIF == 1) {
        TXREG = var;                    //
    }
    __delay_us(100);                    //
}

// ------------------------------ Main ----------------------------------------

void main(void) {
    
    setup();                            //


//------------------------------- Loop ----------------------------------------

while (1) {
}    
}    

// ----------------------- Configuración de I/O -------------------------------

void setup(void) {
    
    ANSEL  = 0x00;
    ANSELH = 0x00;

    TRISA = 0x00;                       // PORTA outputs
    TRISB = 0x00;                       // PORTB outputs
    
// ------------------------- Limpieza de puertos ------------------------------

    PORTA = 0x00;
    PORTB = 0x00;
    
// ------------------ Configuración de oscillador interno --------------------- 
    
    OSCCONbits.IRCF2 = 1;               // 1
    OSCCONbits.IRCF1 = 1;               // 1
    OSCCONbits.IRCF0 = 1;               // 1 --> 8MHz
    OSCCONbits.SCS   = 1;               // Oscillador interno == 1

// ----------------- Configuración de comunicación serial ---------------------
    
    TXSTAbits.SYNC    = 0;
    TXSTAbits.BRGH    = 1;
    BAUDCTLbits.BRG16 = 1;
    
    SPBRG = 207;
    SPBRGH = 0;
    
    RCSTAbits.SPEN = 1;
    RCSTAbits.RX9  = 0;
    RCSTAbits.CREN = 1;
    
    TXSTAbits.TXEN = 1;
    
    PIR1bits.RCIF = 0;                  // Bandera rx
    PIR1bits.TXIF = 0;                  // bandera tx    

    
// -------------------- Configuración de interrupciones -----------------------

    INTCONbits.GIE  = 1;
    INTCONbits.PEIE = 1;                // Periferical interrupt
    PIE1bits.RCIE   = 1;                // Interrupcion rx
    PIE1bits.TXIE   = 1;                // Interrupcion TX

}
*/

// ------- Código de la segunda parte - Entregable en el laboratorio ---------- 

// ------------------- Configuración de interrupciones ------------------------

void setup(void);                       //
void putch(char data);                  // Función para recibir dato a trasmitir
void text(void);                        // Introducción de cadenas de texto

// ------------------------------ Main ----------------------------------------

void main(void) {
    
    setup();                            //
    
//------------------------------- Loop ----------------------------------------

    while(1) {                          //
        text();                         // Función para cadenas de caracteres
    }
}
    
// ------------------------------ Putch --------------------------------------- 

void putch(char data) {                 // Función de libreria stdio.h
    
    while (TXIF == 0);                  // 
    TXREG = data;                       //
    return;
}

// ------------------------------- Text ---------------------------------------

void text(void) {                   
    
    __delay_ms(250);                    // Delay 250 ms para despliegue de carac
    printf(" ¿Qué acción desea ejecutar? \r ");
            
    __delay_ms(250);                    //
    printf(" 1- Desplegar cadena de caracteres \r ");
    
    __delay_ms(250);                    //
    printf(" 2- Trasladar a PORTA \r ");
    
    __delay_ms(250);                    //
    printf(" 3- Trasladar a PORTB \r ");
    
    while (RCIF == 0);                  // Si flag RCIF == 0 
    
    if (RCREG == '1') {                 // Si se presiono '1'
        __delay_ms(500);                
        printf(" Desplegando cadena de caracteres... \r ");
    }
    
    if (RCREG == '2') {                 // Si se presiono '2'
        __delay_ms(500);    
        printf(" Inserte el caracter que desea trasladar a PORTA \r ");
        while (RCIF == 0);              // Mientras la flag RCIF == 0
        PORTA = RCREG;                  // El valor del registro RCREG == PORTA        
    }
    
    if (RCREG == '3') {                 // Si se presiono '3'
        __delay_ms(500);            
        printf(" Inserte el caracter que desea trasladar a PORTB \r ");
        while (RCIF == 0);              // Mientras la flag RCIF == 0
        PORTB = RCREG;                  // El valor del registro RCREG == PORTB
    }
    
    else {                              // Si se ingresa un valor fuera de rango
        NULL;                           // No se ejecuta nada
    }
            
    return;
}

// ----------------------- Configuración de I/O -------------------------------

void setup(void) {
    
    ANSEL  = 0x00;                      //
    ANSELH = 0x00;                      //
    
    TRISA = 0x00;                       // PORTA como outputs
    TRISB = 0x00;                       // PORTB como outputs

// ------------------------- Limpieza de puertos ------------------------------

    PORTA = 0x00;                       //
    PORTB = 0x00;                       //
// ------------------ Configuración de oscillador interno --------------------- 

    OSCCONbits.IRCF2 = 1;               // 1
    OSCCONbits.IRCF1 = 1;               // 1
    OSCCONbits.IRCF0 = 1;               // 1 --> 8 MHz
    OSCCONbits.SCS   = 1;               // Activando oscillador
    
// -------------------- Configuración de interrupciones -----------------------
    
    INTCONbits.GIE  = 1;                 //
    INTCONbits.PEIE = 1;                 //
    PIE1bits.RCIE   = 1;                 // RX
    PIE1bits.TXIE   = 1;                 // TX
    
// ------------------------ Interrupciones RX y TX ----------------------------
    
    TXSTAbits.SYNC    = 0;               //
    TXSTAbits.BRGH    = 1;               //
    BAUDCTLbits.BRG16 = 1;               //
    SPBRG             = 208;             //
    SPBRGH            = 0;               //
    RCSTAbits.SPEN    = 1;               //
    RCSTAbits.RX9     = 0;               //
    RCSTAbits.CREN    = 1;               //
    TXSTAbits.TXEN    = 1;               //
    PIR1bits.RCIF     = 0;               //
    PIR1bits.TXIF     = 0;               //
}    