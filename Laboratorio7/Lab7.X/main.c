// Dispositivo:		PIC16F887
// Autor;			Luis Pedro Molina Velásquez 
// Carné;			18822
// Compilador:		pic-as (v2.31) MPLABX V5.40
// ----------------------------------------------------------------------------     
// ----------------------- Laboratorio No. 7 ----------------------------------      
// ----------------------- Programación en C ----------------------------------

// Creado:                  13 abril, 2021
// Ultima modificación:     18 abril, 2021

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


#include <xc.h>
#include <stdint.h>

// ----------------------------- Variables ------------------------------------
 
char Centenas;  
char Decenas;
char Unidades;
char Storage;
char Counter;  
int  var4Displays; 

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


void __interrupt() isr(void)
{
    if(T0IF == 1) {   
        PORTBbits.RB4 = 0;          // Transistor de Display 3 == 0 --> Unidades 
        PORTBbits.RB2 = 1;          // Transistor de Display 1 == 1 --> Centenas
        PORTD = (Table[Centenas]);  // Trasladando valor
        var4Displays = 0b00000001;  // 
        
    if (var4Displays == 0b00000001) {
        PORTBbits.RB2 = 0;          // Transistor de Display 1 == 0 --> Centenas
        PORTBbits.RB3 = 1;          // Transistor de Display 2 == 1 --> Decenas
        PORTD = (Table[Decenas]);   // Trasladando valor
        var4Displays = 0b00000010;  // 
        }
        
    if (var4Displays == 0b00000010) {
        PORTBbits.RB3 = 0;          // Transistor de Display 2 == 0 --> Decenas
        PORTBbits.RB4 = 1;          // Transistor de Display 3 == 1 --> Unidades
        PORTD = (Table[Unidades]);  // Muevo unidades a un dispay
        var4Displays = 0b00000000;  // 
        }
        
    INTCONbits.T0IF = 0;            // Interrupción de Timer0 == 0 
    TMR0 = 255;                     // Valor de reset de Timer0
        
    }
    
    if (RBIF == 1) {
        if (PORTBbits.RB0 == 0)     {
            PORTC = PORTC + 1;      // PORTC incrementa 1
        }
        if  (PORTBbits.RB1 == 0)   {
            PORTC = PORTC - 1;      // PORTC decrementa 1
        }
        INTCONbits.RBIF = 0;        
    }
}

// ------------------------------ Main ----------------------------------------

void main(void) {
    setup();    

    while(1) {
        nibbles_separation();    
    }
}

// ----------------------- Configuración de I/O -------------------------------

void setup(void){
    
    ANSEL = 0x00;
    ANSELH = 0x00;
    
    TRISBbits.TRISB0 = 1;
    TRISBbits.TRISB1 = 1;
    TRISBbits.TRISB2 = 0;
    TRISBbits.TRISB3 = 0;
    TRISBbits.TRISB4 = 0;
    TRISC = 0x00;
    TRISD = 0x00;
    
// ------------------------- Limpieza de puertos ------------------------------
    
    PORTA = 0x00;
    PORTB = 0x00;
    PORTC = 0x00;
    PORTD = 0x00;
    
// ------------------------ Configuración de Pull-up -------------------------- 
    
    OPTION_REGbits.nRBPU = 0;
    WPUB = 0b00000011;
    IOCBbits.IOCB0 = 1;
    IOCBbits.IOCB1 = 1;
    
// ------------------ Configuración de oscillador interno --------------------- 
    
    OSCCONbits.IRCF2 = 0;
    OSCCONbits.IRCF1 = 1;
    OSCCONbits.IRCF0 = 0;   
    OSCCONbits.SCS   = 1;
    
// ------------------------ Configuración de Timer0 ---------------------------
    
    OPTION_REGbits.T0CS = 0;
    OPTION_REGbits.PSA = 0;
    OPTION_REGbits.PS2 = 1;
    OPTION_REGbits.PS1 = 1;
    OPTION_REGbits.PS0 = 1;
    
// -------------------- Configuración de interrupciones -----------------------
    
    INTCONbits.GIE = 1;
    INTCONbits.RBIF = 1;
    INTCONbits.RBIE = 1;
    INTCONbits.T0IE = 1;
    INTCONbits.T0IF = 0;   
}

// ------------------------- Separación de nibbles ----------------------------

char nibbles_separation(void) {
    Counter = PORTC;                // 
    Centenas = Counter/100;         // 
    Storage = Counter%100;          // 
    Decenas = Storage/10;           // 
    Unidades = Storage%10;          // 
}