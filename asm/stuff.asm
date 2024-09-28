RET0 = $3000
RET1 = $3001
ARG1 = $3002
ARG2 = $3003

PORTB = $6000
PORTA = $6001
DDRB  = $6002
DDRA  = $6003

 .org $8000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

reset:
 
 jsr lcd_init
 
 
 
 lda #$05
 sta ARG1
 lda #$07
 sta ARG2
 jsr multiply
 
loop:
 jmp loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

multiply: ; RET0 RET1 = ARG1 * ARG2
 pha
 
 lda #$00
 ldx #$08
 lsr ARG1
multiply_loop:
 bcc no_add
 clc
 adc ARG2
no_add:
 ror
 ror ARG1
 dex
 bne multiply_loop 
 
 sta RET0
 lda ARG1
 sta RET1
 
 pla
 rsr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lcd_init:
 pha
 
 lda #%11111111 ; Set all pins on port A to output
 sta DDRA
 lda #%11111111 ; Set all pins on port B to output
 sta DDRB
 
 lda #%00111000 ; Set 8-bit mode ; 2-line display ; 5x8 font
 jsr lcd_instruction
 lda #%00001111 ; Display on ; Cursor on ; Blink on
 jsr lcd_instruction
 lda #%00000110 ; Increment and shift cursor ; Don't shift entire display
 jsr lcd_instruction
 lda #%00000001 ; Clear display
 jsr lcd_instruction
 lda #%00000010 ; Return home
 jsr lcd_instruction
 
 pla
 rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lcd_instruction:
 sta PORTB
 lda #%00000000
 sta PORTA
 lda #%10000000
 sta PORTA
 lda #%00000000
 sta PORTA
 rsr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_char:
 sta PORTB
 lda #%00100000
 sta PORTA
 lda #%10100000
 sta PORTA
 lda #%00100000
 sta PORTA
 rsr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 .org $fffa
 .word $0000
 .word reset
 .word $0000




