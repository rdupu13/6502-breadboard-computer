;--------------------------------------------------------------
; LCD Driver
; 
; Author: Ryan Dupuis
;
; Includes: (none)
;
; Memory labels:
;		VALUE (w)
;		NUMBER (w)
;		MOD10 (w)
; 		MESSAGE ()
;--------------------------------------------------------------

;--------------------------------------------------------------
; Subroutine: Initialize LCD
;--------------------------------------------------------------
lcd_init:
			lda	#%00111000 			; Set 8-bit mode, 2-line display, 5x8 font
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
			lda #%11111111			; Set PORTB to output
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
			lda #%00000000			; Clear RS, RW, and E bits
			sta PORTA
			
			rts
 
;--------------------------------------------------------------
; Subroutine: Print character in accumulator to LCD
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
; Subroutine: Display MESSAGE on LCD
;--------------------------------------------------------------
print_str:
			ldx #$00

print_str_loop:
			lda MESSAGE,x
			beq exit_print_str
			jsr print_char
			inx
			jmp print_str_loop
exit_print_str:
			
			rts
 
;--------------------------------------------------------------
; Subroutine: Convert integer in NUMBER to decimal and store it to MESSAGE
;--------------------------------------------------------------
print_int:
			pha
			
			lda #$00
			sta MESSAGE
			
			; Load number to convert
			lda NUMBER
			sta VALUE
			lda NUMBER + 1
			sta VALUE + 1
			
divide:
			; Initialize remainder to zero
			lda #$00
			sta MOD10
			sta MOD10 + 1
			clc
			
			ldx #$10
divide_loop:
			; Rotate all
			rol VALUE
			rol VALUE + 1
			rol MOD10
			rol MOD10 + 1
			
			; Subtract ten from remainder
			sec
			lda MOD10
			sbc #$0A
			tay 					; Save low byte in Y
			lda MOD10 + 1
			sbc #$00
			bcc ignore_result		; Ignore result if remainder < 10
			sty MOD10
			sta MOD10 + 1
			
ignore_result:
			dex
			bne divide_loop
			rol VALUE 				; Shift in the last bit of the quotient
			
			lda MOD10
			clc
			adc #"0"
			jsr push_char
			
			; If VALUE > 0, continue dividing
			lda VALUE
			ora VALUE + 1
			bne divide
			
			jsr print_str
			
			pla
			rts
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

push_char:
			pha						; Push new first char onto stack
			ldy #$00

push_char_loop:
			lda MESSAGE,y			; Get char on string and put into X
			tax
			pla
			sta MESSAGE,y			; Pull char off stack and add it to the string
			iny
			txa
			pha 					; Push char from string onto stack
			bne push_char_loop
			
			pla
			sta MESSAGE,y			; Pull the null of the stack and add it to the end of the string
			
			rts
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;