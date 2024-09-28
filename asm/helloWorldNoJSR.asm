PORTB = $6000
PORTA = $6001
DDRB  = $6002
DDRA  = $6003

 .org $8000

reset:
  
 ldx #$ff
 txs
 
 lda #%11111111 ; Set all pins on port B to output
 sta DDRB
 lda #%11111111 ; Set all pins on port A to output
 sta DDRA
 
 lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
 sta PORTB
 lda #%00000000 ; Clear RS/RW/E bits
 sta PORTA
 lda #%10000000 ; Set E bit to send instruction
 sta PORTA
 lda #%00000000 ; Clear RS/RW/E bits
 sta PORTA
 
 lda #%00001111 ; Display on; cursor on; blink on
 sta PORTB
 lda #%00000000 ; Clear RS/RW/E bits
 sta PORTA
 lda #%10000000 ; Set E bit to send instruction
 sta PORTA
 lda #%00000000 ; Clear RS/RW/E bits
 sta PORTA
 
 lda #%00000110 ; Increment and shift cursor; don't shift entire display
 sta PORTB
 lda #%00000000 ; Clear RS/RW/E bits
 sta PORTA
 lda #%10000000 ; Set E bit to send instruction
 sta PORTA
 lda #%00000000 ; Clear RS/RW/E bits
 sta PORTA
 
 lda #%00000001 ; Clear display
 sta PORTB
 lda #%00000000 ; Clear RS/RW/E bits
 sta PORTA
 lda #%10000000 ; Set E bit to send instruction
 sta PORTA
 lda #%00000000 ; Clear RS/RW/E bits
 sta PORTA
 
 
 
 lda #"H"
 sta PORTB
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 lda #%10100000 ; Set E bit to send instruction
 sta PORTA
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 
 lda #"e"
 sta PORTB
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 lda #%10100000 ; Set E bit to send instruction
 sta PORTA
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 
 lda #"l"
 sta PORTB
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 lda #%10100000 ; Set E bit to send instruction
 sta PORTA
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 
 lda #"l"
 sta PORTB
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 lda #%10100000 ; Set E bit to send instruction
 sta PORTA
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 
 lda #"o"
 sta PORTB
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 lda #%10100000 ; Set E bit to send instruction
 sta PORTA
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 
 lda #","
 sta PORTB
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 lda #%10100000 ; Set E bit to send instruction
 sta PORTA
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 
 lda #" "
 sta PORTB
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 lda #%10100000 ; Set E bit to send instruction
 sta PORTA
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 
 lda #"w"
 sta PORTB
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 lda #%10100000 ; Set E bit to send instruction
 sta PORTA
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 
 lda #"o"
 sta PORTB
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 lda #%10100000 ; Set E bit to send instruction
 sta PORTA
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 
 lda #"r"
 sta PORTB
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 lda #%10100000 ; Set E bit to send instruction
 sta PORTA
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 
 lda #"l"
 sta PORTB
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 lda #%10100000 ; Set E bit to send instruction
 sta PORTA
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 
 lda #"d"
 sta PORTB
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 lda #%10100000 ; Set E bit to send instruction
 sta PORTA
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 
 lda #"!"
 sta PORTB
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA
 lda #%10100000 ; Set E bit to send instruction
 sta PORTA
 lda #%00100000 ; Set RS; Clear RW/E bits
 sta PORTA

loop:
 jmp loop
 
 .org $fffc
 .word reset
 .word $0000