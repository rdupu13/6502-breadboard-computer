;--------------------------------------------------------------
; LCD Driver
; 
; Author: Ryan Dupuis
;
; Includes: (none)
;
; Memory labels:
;		;VALUE (w)
;		;NUMBER (w)
;		;MOD10 (w)
; 		MESSAGE (str 256 b)
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
			sta PORTB
			jsr lcd_wait
			
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
			pha
			tya
			pha
			
			ldy #0
print_str_loop:
			lda (PTR_1),y
			beq exit_print_str
			jsr print_char
			iny
			jmp print_str_loop
exit_print_str:
			
			pla
			tay
			pla
			rts
 
;--------------------------------------------------------------
; Subroutine: Convert ungigned integer NUMBER to decimal and print it
;--------------------------------------------------------------
print_int:
			pha
			
			; Load number to convert
			lda NUMBER
			sta VALUE
			lda NUMBER + 1
			sta VALUE + 1
			
			lda #$00				; Push null char
			pha
divide:
			; Initialize remainder to zero
			lda #0
			sta MOD10
			sta MOD10 + 1
			clc
			
			ldx #16
divide_loop:
			; Rotate all
			rol VALUE
			rol VALUE + 1
			rol MOD10
			rol MOD10 + 1
			
			; Subtract ten from remainder
			sec
			lda MOD10
			sbc #10
			tay 					; Save low byte in Y
			lda MOD10 + 1
			sbc #0
			bcc ignore_result		; Ignore result if remainder < 10
			sty MOD10
			sta MOD10 + 1
			
ignore_result:
			dex
			bne divide_loop
			rol VALUE 				; Shift in the last bit of the quotient
			
			; Push most recent char onto stack
			lda MOD10
			clc
			adc #'0'
			pha
			
			; If VALUE > 0, continue dividing
			lda VALUE
			ora VALUE + 1
			bne divide
			
pop_chars:
			; Pop chars off stack to reverse order until null char reached
			pla
			beq end_pop_chars
			jsr print_char
			jmp pop_chars
end_pop_chars:
			
			pla
			rts
			
;--------------------------------------------------------------