;Jaqueline Rodrigues 

;O projeto foi idealizado de modo que o pic irá ser conectado no sensor,
;assim ao aproximar um objeto do sensor (nesse caso a mão de uma pessoa por exemplo) será apagado um led
;o led começa aceso para dar a ideia de alarme 'ativo'
;e também enviado um sinal para o bluetooth que ira mandar para o celular.
    
#include "p16f873a.inc"

    
; CONFIG
; __config 0xFF39 
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF


    CBLOCK 0x20
    ENDC


ORG 0x0000
GOTO INICIO
    
INICIO:
    	-
    
    BANKSEL TRISB       		;escolhendo banco de trisb
    MOVLW B'00000000'			;led = RB5 = 0; saida de dados, 0 = output
    MOVWF TRISB
    
    					
    BANKSEL ADCON1 		
    MOVLW B'10000000' 			;move  80hexa (10000000) para W
    					;ADFM=1 ajusta a direita
    					; PCFG3=0,PCFG2=0,PCFG1=0,PCFG0=0 entradas AN0-AN7 analógicos
    MOVWF ADCON1 		
    
    BANKSEL ADCON0 			
    MOVLW B'01000001' 			
    MOVWF ADCON0 		
    
    
LOOP:
    CALL LE_ADC 	
    GOTO LOOP				


					; --- CONVERSAO - ANALOGICO PARA DIGITAL ---
LE_ADC:
    BANKSEL ADCON0 			;seleciona o banco 0 de memória
    BSF ADCON0,2 			;bit set -> GO/DONE=1
ESPERA:
    BTFSC ADCON0,2 			; bit GO/DONE = 0?
    GOTO ESPERA 			; --- Envia para Serial ---    
    MOVF ADRESH,W 			;move conteúdo de ADRESH para Work
    CALL SETA_LED
    RETURN				;Retorna ao CALL do LOOP:
    
    
					;3 - é o resultado da leitura analogico digital do ad
SETA_LED:
    SUBLW D'3' 				;w = 3 - w ; SE RESLTADO FOR ZERO, A FLAG Z = 1
    BTFSC STATUS,Z 			;bit test status -> flag z de satus =0? skip if clear
    CALL LIGA_LED			;z=0 
    CALL DESLIGA_LED 		
    RETURN
    
LIGA_LED: 
    BSF PORTB, RB5			;bit set -> led rb5 pin 26
    RETURN

DESLIGA_LED: 
    BCF PORTB, RB5 			;bit clear 
    BANKSEL TXSTA 			;banco de txta
    MOVLW B'00100110' 			; txen q habilita transmissao 
    MOVWF TXSTA 			;coloquei em W
    BANKSEL RCSTA			; rcsta receive status
    MOVLW B'10010000'			;spen=1 porta serial ativada
					;cren=1 permite recebimento contínuo
    MOVWF RCSTA
    BANKSEL SPBRG 			;usart baud rate gemerator bps 9600
    MOVLW B'00011001'
    MOVWF SPBRG    
    GOTO MANDA
    GOTO SETA_LED   
    
 
MANDA:
    BANKSEL TXSTA 			;seleciona o banco de txsta 
    BTFSS TXSTA,TRMT 			;bit test trmt; 
					;trmt status do registrados de transmissao
					;trmt =1 tsr vazio
    GOTO MANDA 				
    BANKSEL TXREG			
    					;txreg = buffer de transmissao
    MOVLW B'01000001'   		
    MOVWF TXREG        
    RETURN

	
END 					;Final do Programa