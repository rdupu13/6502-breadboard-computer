;--------------------------------------------------------------
; helloWorld.asm
; 
; 6502 Computer Program ROM Image 
; 32KB
; 
; Author: Ryan Dupuis
; 
; Includes: (none)
;--------------------------------------------------------------

; Empty: $0000 - $00FF

; Stack: $0100 - $01FF

; Empty: $0200 - $3FFF

; Not addressable: $4000 - $5FFF

PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
T1CL = $6004
T1CH = $6005
T1LL = $6006
T1LH = $6007
T2CL = $6008
T2CH = $6009
SR = $600A
ACR = $600B
PCR = $600C
IFR = $600D
IER = $600E
PORTA_NH = $600F

; Not addressable: $6010 - $7FFF

			.org $8000

;--------------------------------------------------------------
; Subroutine: Initializes LCD
;--------------------------------------------------------------
reset:
			lda #$82
			sta IER
			lda #$00
			sta PCR
			
			jsr lcd_init
 
main:
			jmp main

;--------------------------------------------------------------
; Subroutine: Initializes LCD
;--------------------------------------------------------------
lcd_init:
			lda #%11111111 			; Set PORTB to output
			sta DDRB
			lda #%11100000 			; Set PORTA to output on bits 7-5 and input on others
			sta DDRA
			lda #%00111000 			; Set 8-bit mode, 2-line display, 5x8 font
			jsr lcd_instruction
			lda #%00001110 			; Display on, cursor on, blink off
			jsr lcd_instruction
			lda #%00000110 			; Increment and shift cursor, don't shift entire display
			jsr lcd_instruction
			lda #%00000001 			; Clear display
			jsr lcd_instruction
			
			rts
 
;--------------------------------------------------------------
; Subroutine: Wait until LCD is not busy
;--------------------------------------------------------------
lcd_wait:
			pha
			
			lda #%00000000 			; Set PORTB to input
			sta DDRB
			
lcd_busy:
			; Read busy flag and address from LCD
			lda #%01000000 			; Set RW, clear RS and E bits
			sta PORTA
			lda #%11000000 			; Enable
			sta PORTA
			lda PORTB
			and #%10000000 			; If busy flag of LCD set, continue in a loop
			bne lcd_busy
 
			lda #%01000000 			; Set RW, clear RS and E bits
			sta PORTA
			lda #%11111111 			; Set PORTB to output
			sta DDRB
			
			pla
			rts

;--------------------------------------------------------------
; Subroutine: Send instruction in accumulator to LCD
;--------------------------------------------------------------
lcd_instruction:
			sta PORTB
			jsr lcd_wait
			lda #%00000000 			; Clear RS, RW, and E bits
			sta PORTA
			lda #%10000000 			; Enable
			sta PORTA
			lda #%00000000 			; Clear RS, RW, and E bits
			sta PORTA
			
			rts
 
;--------------------------------------------------------------
; Subroutine: Display char in accumulator on LCD, move cursor as necessary
;--------------------------------------------------------------
print_char:
			jsr lcd_wait
			sta PORTB
			lda #%00100000 			; Set RS, clear RW and E bits
			sta PORTA
			lda #%10100000 			; Enable
			sta PORTA
			lda #%00100000 			; Set RS, clear RW and E bits
			sta PORTA
			
			rts

;--------------------------------------------------------------
; Subroutine: Display message in data on LCD
;--------------------------------------------------------------
print_str:
			ldx #$00
			
print_str_loop:
			lda data,x
			beq exit_print_str
			jsr print_char
			inx
			jmp print_str_loop
exit_print_str:
			
			rts
 

;--------------------------------------------------------------
; Memory Allocation
;--------------------------------------------------------------

	.org $C000

data:
	.string "Hello, world!"
 
;--------------------------------------------------------------
; Vectors
;--------------------------------------------------------------

	.org $fffa
	.word $0000
	.word reset
	.word $0000