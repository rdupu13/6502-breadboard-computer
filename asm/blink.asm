PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

 .org $8000

reset:
 
 lda #$FF
 sta DDRB
 sta DDRA
 
 lda #$00
 sta PORTB
 sta PORTA
 ldx #$FF
 
loop:
 dex
 bne loop

 inc PORTA
 lda PORTA
 cmp #$55
 bne loop

 inc PORTB
 jmp loop



 .org $fffa
 .word $0000
 .word reset
 .word $0000




