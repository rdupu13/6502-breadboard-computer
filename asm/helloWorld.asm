; 6502 Computer Program ROM (32KB)
; Ryan Dupuis

; Empty: $0000 - $00FF

; Stack: $0100 - $01FF

VALUE = $0200 ; 2 bytes
MOD10 = $0202 ; 2 bytes
COUNTER = $020A ; 2 bytes
NUMBER = $020C ; 2 bytes

BLOCK_LENGTH = $020E
BLOCK_LOCATION = $0210 ; 2 bytes

KB_BUFFER = $0300 ; 256 bytes

KB_CLK_COUNTER = $0400 ; 1 byte
KB_SCANCODE = $0401 ; 1 byte
KB_WR_PTR = $0402 ; 1 byte
KB_RD_PTR = $0403 ; 1 byte

MESSAGE = $0500 ; 256 bytes

RETURN_VALUE = $0600 ; 2 bytes
ARG1 = $0602 ; 2 bytes
ARG2 = $0604 ; 2 bytes

; Empty: $0700 - $3FFF

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

reset:
 ; Interrupt initialization
 ldx #$FF
 txs ; <- CANNOT BE IN A SUBROUTINE
 cli
 lda #$82
 sta IER
 lda #$00
 sta PCR
 
 jsr lcd_init
 jsr kb_init
 
 
 
main_loop:
 jmp main_loop
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

kb_init:
 lda #$00
 sta KB_WR_PTR
 sta KB_RD_PTR
 rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lcd_init: ; Initializes LCD
 lda #%11111111 ; Set PORTB to output
 sta DDRB
 lda #%11100000 ; Set PORTA to output on bits 7-5 and input on others
 sta DDRA
 lda #%00111000 ; Set 8-bit mode ; 2-line display ; 5x8 font
 jsr lcd_instruction
 lda #%00001110 ; Display on ; Cursor on ; Blink off
 jsr lcd_instruction
 lda #%00000110 ; Increment and shift cursor ; Don't shift entire display
 jsr lcd_instruction
 lda #%00000001 ; Clear display
 jsr lcd_instruction
 rts
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lcd_wait: ; Waits until LCD is not busy
 pha
 lda #%00000000 ; Set PORTB to input
 sta DDRB

lcd_busy:
 ; Read busy flag and address from LCD
 lda #%01000000 ; Set RW ; Clear RS and E bits
 sta PORTA
 lda #%11000000 ; Enable
 sta PORTA
 lda PORTB
 and #%10000000 ; If busy flag of LCD set, continue in a loop
 bne lcd_busy
 
 lda #%01000000 ; Set RW ; Clear RS and E bits
 sta PORTA
 lda #%11111111 ; Set PORTB to output
 sta DDRB
 pla
 rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lcd_instruction: ; Sends instruction in accumulator to LCD
 sta PORTB
 jsr lcd_wait
 lda #%00000000 ; Clear RS, RW, and E bits
 sta PORTA
 lda #%10000000 ; Enable
 sta PORTA
 lda #%00000000 ; Clear RS, RW, and E bits
 sta PORTA
 rts
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_char: ; Displays char in accumulator on LCD, moving cursor as necessary
 jsr lcd_wait
 sta PORTB
 lda #%00100000 ; Set RS ; Clear RW and E bits
 sta PORTA
 lda #%10100000 ; Enable
 sta PORTA
 lda #%00100000 ; Set RS ; Clear RW and E bits
 sta PORTA
 rts
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_str: ; Displays MESSAGE on LCD
 ldx #$00
print_str_loop:
 lda data,x
 beq exit_print_str
 jsr print_char
 inx
 jmp print_str_loop
exit_print_str:
 rts
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_int: ; Converts integer in NUMBER to decimal and stores it to MESSAGE
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
 tay ; Save low byte in Y
 lda MOD10 + 1
 sbc #$00
 bcc ignore_result ; Ignore result if remainder < 10
 sty MOD10
 sta MOD10 + 1
 
ignore_result:
 dex
 bne divide_loop
 rol VALUE ; Shift in the last bit of the quotient
 
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
 pha ; Push new first char onto stack
 ldy #$00

push_char_loop:
 lda MESSAGE,y ; Get char on string and put into X
 tax
 pla
 sta MESSAGE,y ; Pull char off stack and add it to the string
 iny
 txa
 pha           ; Push char from string onto stack
 bne push_char_loop
 
 pla
 sta MESSAGE,y ; Pull the null of the stack and add it to the end of the string
 
 rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load_block: ; Loads a block of length BLOCK_LENGTH from ROM at BLOCK_LOCATION to MESSAGE in RAM
 pha
 
 ldx BLOCK_LENGTH
load_block_loop:
 lda BLOCK_LOCATION,x
 sta MESSAGE,x
 dex
 bne load_block_loop
 
 pla
 rts
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

read_kb_buffer:
 pha
 lda KB_WR_PTR
 cmp KB_RD_PTR
 beq exit_read_kb_buffer
 
 ldx KB_RD_PTR
 lda KB_BUFFER,x
 jsr print_char
 
 inc KB_RD_PTR
 
 jmp read_kb_buffer
 
exit_read_kb_buffer:
 pla
 rts
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

nmi:
 rti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

irq:
 ; SHORT keyboard reader (must be less than 35 clock cycles!!)
 ror PORTA             ; 6
 ror KB_SCANCODE       ; 6
 dec KB_CLK_COUNTER    ; 6
 bne load_scancode     ; 4 at worst
 rti                   ; 6
 ;               Total: 28 at worst
 
load_scancode:
 pha
 ldx KB_WR_PTR
 lda KB_SCANCODE
 sta KB_BUFFER,x
 inc KB_WR_PTR
 lda #$09
 sta KB_CLK_COUNTER
 pla
 rti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 .org $C000

data:
 .string "Hello, world!"
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 .org $fffa
 .word nmi
 .word reset
 .word irq