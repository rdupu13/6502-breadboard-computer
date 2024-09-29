;--------------------------------------------------------------
; 6502 Computer Program ROM (32KB)
; 
; Author: Ryan Dupuis
;
; Includes:
;		via.asm
;		lcd_print.asm
;--------------------------------------------------------------

;--------------------------------------------------------------
; RAM Labels ($0000 - $7FFF)
;--------------------------------------------------------------

; Empty : $0000 - $00FF

; Stack: $0100 - $03FF

MESSAGE = $0400			; LCD Print Message (256 b)

BLOCK_LENGTH = $0500            ; Block Length (b)
BLOCK_LOCATION = $0501	        ; Block Location (w)

; Empty: $0700 - $3FFF

; Not addressable: $4000 - $5FFF

PORTB = $6000			; VIA port B                      LCD Module Data
PORTA = $6001			; VIA port A                      LCD Module Control
DDRB = $6002			; VIA port B direction register   
DDRA = $6003			; VIA port A direction register   
T1CL = $6004			; VIA timer 1 count low byte      
T1CH = $6005			; VIA timer 1 count high byte     
T1LL = $6006			; VIA timer 1 latches low byte    
T1LH = $6007			; VIA timer 1 latches high byte   
T2CL = $6008			; VIA timer 2 count low byte      
T2CH = $6009			; VIA timer 2 count high byte     
SR = $600A				; VIA shift register              
ACR = $600B				; VIA auxillary control register  
PCR = $600C				; VIA peripheral control register 
IFR = $600D				; VIA interrupt flag register     
IER = $600				; VIA interrupt enable register   
PORTA_NH = $600F		; VIA port A (no handshake)       LCD Module Data

; Not addressable: $6010 - $7FFF

	.org $8000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

reset: 
			jsr via_init
			jsr lcd_init
 
			ldx #$00
load:
			lda data,x
			beq main
			inx
			jmp load
 
main:
			jmp main
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.include via.asm
	.include lcd_print.asm

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

nmi:
			ldx #$00
nmi_loop:
			lda nmi_data,x
			jsr print_char
			inx
			cmp #$07
			bne nmi_loop
			
			rti

nmi_data:
	.string "ERROR"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.org $C000

data:
	.string "hellaur! :D"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.org $FD00
 
keymap:
	.byte "?????????????? `" ; 00-0F
	.byte "?????ql???zsaw2?" ; 10-1F
	.byte "?cxde43?? vftr5?" ; 20-2F
	.byte "?nbhgy6???mju78?" ; 30-3F
	.byte "?,kio09??./l;p-?" ; 40-4F
	.byte "??'?[=?????]?\??" ; 50-5F
	.byte "?????????1?47???" ; 60-6F
	.byte "0.2568???+3-*9??" ; 70-7F
	.byte "????????????????" ; 80-8F
	.byte "????????????????" ; 90-9F
	.byte "????????????????" ; A0-AF
	.byte "????????????????" ; B0-BF
	.byte "????????????????" ; C0-CF
	.byte "????????????????" ; D0-DF
	.byte "????????????????" ; E0-EF
	.byte "????????????????" ; F0-FF
keymap_shifted:
	.byte "?????????????? ~" ; 00-0F
	.byte "?????QL???ZSAW@?" ; 10-1F
	.byte "?CXDE$#?? VFTR%?" ; 20-2F
	.byte "?NBHGY^???MJU&*?" ; 30-3F
	.byte "?<KIO)(??>?L:P_?" ; 40-4F
	.byte '??"?{+?????}?|??' ; 50-5F
	.byte "????????????????" ; 60-6F
	.byte "?.???????+?-*???" ; 70-7F
	.byte "????????????????" ; 80-8F
	.byte "????????????????" ; 90-9F
	.byte "????????????????" ; A0-AF
	.byte "????????????????" ; B0-BF
	.byte "????????????????" ; C0-CF
	.byte "????????????????" ; D0-DF
	.byte "????????????????" ; E0-EF
	.byte "????????????????" ; F0-FF
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.org $FFFA
	.word nmi
	.word reset
	.word irq
