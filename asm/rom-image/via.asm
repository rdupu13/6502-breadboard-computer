;--------------------------------------------------------------
; 6522 Versatile Interface Adapter Driver
; 
; Author: Ryan Dupuis
;
; Includes: (none)
;
; Memory labels:
;		PORTB, PORTA, DDRB,     DDRA,
;        T1CL,  T1CH, T1LL,     T1LH,
;        T2CL,  T2CH,   SR,      ACR,
; 		  PCR,   IFR,  IER, PORTA_NH
; Files:     (none)
; Blocks:    MESSAGE
;--------------------------------------------------------------

;--------------------------------------------------------------
; Subroutine: Chip initialization
;--------------------------------------------------------------
via_init:
			cli
			
			lda #%00000000 			; T1 disabled, T2 interrupt, SR in ext clk, PB latch disable, PA latch disable
			sta ACR
			lda #%01000001 			; CB2 in (rising), CB1 (falling), CA2 in (falling) ; CA1 (rising)
			sta PCR
			lda #%10000000 			; Enable no interrupts
			sta IER
			lda #%11111111 			; Set PORTB to output (expects LCD module)
			sta DDRB
			lda #%11111111 			; Set PORTA to output (expects bits 7,6,5 to be LCD control)
			sta DDRA
			
			rts

;--------------------------------------------------------------
; Interrupt Service Routine
;--------------------------------------------------------------
irq:
			
			jsr keyboard_interrupt
 
;--------------------------------------------------------------