// Dispositivo:		PIC16F887
// Autor;			Luis Pedro Molina Velásquez 
// Carné;			18822
// Compilador:		pic-as (v2.31) MPLABX V5.40
// ----------------------------------------------------------------------------     
// ----------------------- Laboratorio No. 8 ----------------------------------      
// -------------------------- Módulo ADC --------------------------------------

// Creado:                  20 abril, 2021
// Ultima modificación:     25 abril, 2021

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

#define _XTAL_FREQ 4000000
#include <xc.h>
#include <stdint.h>

// ----------------------------- Variables ------------------------------------

char Centenas;                      // Variable para centenas en Displays
char Decenas;                       // Variable para decenas en Displays
char Unidades;                      // Variable para unidades en Displays
char Storage;                       // Variable que almacena residuo de divisiones
char Counter;                       // Variable que almacena valor en PORTx
int  var4Displays;                  // Variable para multiplexeo de Displays

char Table[10] = {
    0b00111111,                     // 0
    0b00000110,                     // 1
    0b01011011,                     // 2
    0b01001111,                     // 3
    0b01100110,                     // 4
    0b01101101,                     // 5
    0b01111101,                     // 6
    0b00000111,                     // 7
    0b01111111,                     // 8 
    0b01101111};                    // 9
 
// ------------------- Configuración de interrupciones ------------------------

void setup(void);   
char nibbles_separation(void);

void __interrupt() isr(void) {
    
    if (T0IF == 1) {   
        PORTBbits.RB2 = 0;          // Transistor de Display 3 == 0 --> Unidades 
        PORTBbits.RB0 = 1;          // Transistor de Display 1 == 1 --> Centenas
        PORTD = (Table[Centenas]);  // Trasladando valor
        var4Displays = 0b00000001;  // 
        
    if (var4Displays == 0b00000001) {
        PORTBbits.RB0 = 0;          // Transistor de Display 1 == 0 --> Centenas
        PORTBbits.RB1 = 1;          // Transistor de Display 2 == 1 --> Decenas
        PORTD = (Table[Decenas]);   // Trasladando valor
        var4Displays = 0b00000010;  // 
        }
        
    if (var4Displays == 0b00000010) {
        PORTBbits.RB1 = 0;          // Transistor de Display 2 == 0 --> Decenas
        PORTBbits.RB2 = 1;          // Transistor de Display 3 == 1 --> Unidades
        PORTD = (Table[Unidades]);  // Muevo unidades a un dispay
        var4Displays = 0b00000000;  // 
        }
        
    INTCONbits.T0IF = 0;            // Interrupción de Timer0 == 0 
    TMR0 = 255;                     // Valor de reset de Timer0
    }
    
    if (PIR1bits.ADIF == 1) {
        if (ADCON0bits.CHS == 0)    //
            PORTC = ADRESH;         //
        else        
            Counter = ADRESH;       //
        PIR1bits.ADIF = 0;          //
    }
}

// ------------------------------ Main ----------------------------------------

void main(void) {
    setup();    
    ADCON0bits.GO = 1;              // 
    
//------------------------------- Loop ----------------------------------------
    
while(1) {
        
    if (ADCON0bits.GO == 0) {
        if (ADCON0bits.CHS == 1)
            ADCON0bits.CHS = 0;
        else
            ADCON0bits.CHS = 1;
        
        __delay_us(100);
        ADCON0bits.GO = 1;
    }
        nibbles_separation();    
    }
}

// ----------------------- Configuración de I/O -------------------------------

void setup(void){
    
    ANSEL  = 0b00000011;
    ANSELH = 0b11111111;
    
    TRISAbits.TRISA0 = 1;           // AN0 --> Input    --> Potenciometro 1
    TRISAbits.TRISA1 = 1;           // AN1 --> Input    --> Potenciometro 2
    TRISBbits.TRISB0 = 0;           // Transistor 1     --> Display de centenas
    TRISBbits.TRISB1 = 0;           // Transistor 2     --> Display de decenas
    TRISBbits.TRISB2 = 0;           // Transistor 3     --> Display de unidades
    TRISC = 0x00;                   // Leds en PORTC    --> Para potenciometro 1
    TRISD = 0x00;                   // Display en PORTD --> Para potenciometro 2

// ------------------------- Limpieza de puertos ------------------------------
    
    PORTA = 0x00;
    PORTB = 0x00;
    PORTC = 0x00;
    PORTD = 0x00;

// ------------------ Configuración de oscillador interno --------------------- 
    
    OSCCONbits.IRCF2 = 0;           // 0
    OSCCONbits.IRCF1 = 1;           // 1
    OSCCONbits.IRCF0 = 0;           // 0 
    OSCCONbits.SCS   = 1;           //

// ------------------------ Configuración de Timer0 ---------------------------
    
    OPTION_REGbits.T0CS = 0;        //
    OPTION_REGbits.PSA  = 0;        //
    OPTION_REGbits.PS2  = 1;        //
    OPTION_REGbits.PS1  = 1;        //
    OPTION_REGbits.PS0  = 1;        //

// -------------------- Configuración de interrupciones -----------------------
    
    INTCONbits.GIE  = 1;            //
    INTCONbits.T0IF = 0;            //   
    INTCONbits.T0IE = 1;            //
    INTCONbits.PEIE = 1;            // 
    PIR1bits.ADIF   = 0;            // Flag de ADC == 0
    PIE1bits.ADIE   = 1;            // Interrupción de ADC == 1

// ----------------------- Configuración de módulo ADC ------------------------
    
    ADCON0bits.ADON  = 1;           // ADC == 1
    ADCON0bits.ADCS1 = 1;           // Configuración de oscillador interno
    ADCON0bits.ADCS0 = 1;           //
    ADCON0bits.CHS   = 0;           //
    ADCON1bits.ADFM  = 0;           // Bits significativos a la izquierda
    ADCON1bits.VCFG0 = 0;           //
    ADCON1bits.VCFG1 = 0;           //    
}    

// ------------------------- Separación de nibbles ----------------------------

char nibbles_separation(void) {
    //Counter = PORTC;              // 
    Centenas = Counter/100;         // 
    Storage = Counter%100;          // 
    Decenas = Storage/10;           // 
    Unidades = Storage%10;          // 
}
