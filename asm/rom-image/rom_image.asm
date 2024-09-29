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
; RAM Labels ($0000 - $3FFF)
;--------------------------------------------------------------

; Zero page ($0000 - $00FF):
PTR_1 = $00						; Pointer 1 (w, be)
PTR_2 = $02						; Pointer 2 (w, be)

; Stack: $0100 - $03FF

MESSAGE = $0400					; LCD Print Message (str 256 b)

NUMBER = $0500					; Unsigned integer number to be converted to ASCII (w, be)
MOD10 = $0502					; Number mod 10 (w, be)
VALUE = $0504					; Current division value (w, be)
; Empty: $0506 - $050F

TIME_SECONDS = $0510			; System time seconds (b)
TIME_MINUTES = $0511			; System time minutes (b)
TIME_HOURS = $0512				; System time hours (b)
DATE_DAY = $0513				; System date day (b)
DATE_MONTH = $0514				; System date month (b)
DATE_YEAR = $0515				; System date year (w, be)

; Empty: $0700 - $3FFF

;--------------------------------------------------------------
; I/O Labels ($4000 - $7FFF)
;--------------------------------------------------------------

; Not addressable: $4000 - $5FFF

PORTB = $6000			; VIA port B                      LCD Module Data
PORTA = $6001			; VIA port A                      LCD Module Control
DDRB = $6002			; VIA port B direction register   LCD Module Data
DDRA = $6003			; VIA port A direction register   LCD Module Control
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
IER = $600E				; VIA interrupt enable register   
PORTA_NH = $600F		; VIA port A (no handshake)       LCD Module Data

; Not addressable: $6010 - $7FFF

;--------------------------------------------------------------
; Main
;--------------------------------------------------------------
	.org $8000 ; $0000 in ROM
reset:
			; Driver initialization
			sei
			
			jsr via_init
			jsr lcd_init
			
			lda #0					; Second = 0
			sta TIME_SECONDS
			lda #19					; Minute = 19
			sta TIME_MINUTES
			lda #15					; Hour = 15
			sta TIME_HOURS

			lda #29					; Day = 29
			sta DATE_DAY
			lda #9					; Month = 9
			sta DATE_MONTH
			lda #$E8				; Year = 2024
			sta DATE_YEAR
			lda #$07
			sta DATE_YEAR + 1
			
			cli
main:		
			jsr print_time			; Print system time to LCD display
			
			ldx #255				; Load x and y with 255
			ldy #255
delay1:								; Total delay: count from 65536 to 0
			dex
			beq delay2
			jmp delay1
delay2:
			dey
			beq end_delay
			jmp delay1
end_delay:
			
			jsr add_second			; Add 1 second to system time
			
			jmp main

;--------------------------------------------------------------
; Subroutine: Print current system time on LCD
;--------------------------------------------------------------
print_time:
			pha
			
			lda #%00000001 			; Clear display
			jsr lcd_instruction
			
			lda TIME_HOURS
			sta NUMBER
			lda #0
			sta NUMBER + 1
			jsr print_int
			
			lda #':'
			jsr print_char
			
			lda TIME_MINUTES
			sta NUMBER
			lda #0
			sta NUMBER + 1
			jsr print_int
			
			lda #':'
			jsr print_char
			
			lda TIME_SECONDS
			sta NUMBER
			lda #0
			sta NUMBER + 1
			jsr print_int
			
			pla
			rts
			
;--------------------------------------------------------------
; Subroutine: Add 1 second to time
;--------------------------------------------------------------
add_second:
			pha
			
			inc TIME_SECONDS
			lda TIME_SECONDS
			cmp #60
			bpl end_add_second
			
			lda #0
			sta TIME_SECONDS
			inc TIME_MINUTES
			lda TIME_MINUTES
			cmp #60
			bpl end_add_second
			
			lda #0
			sta TIME_MINUTES
			inc TIME_HOURS
			lda TIME_HOURS
			cmp #24
			bpl end_add_second
			
			lda #0
			sta TIME_HOURS

end_add_second:
			
			pla
			rts

;--------------------------------------------------------------
; Includes
;--------------------------------------------------------------
	.include via.asm
	.include lcd.asm

;--------------------------------------------------------------
; Non-maskable Interrupt Service Routine
;--------------------------------------------------------------
nmi:
			rti

;--------------------------------------------------------------
; Read-Only Data
;--------------------------------------------------------------
	.org 	$C000 ; $4000 in ROM
data:
	.string "Hello, world!"
	.byte 	$00

;--------------------------------------------------------------
	.org 	$FD00 ; $7D00 in ROM
keymap:
	.byte	"?????????????? `" ; 00-0F
	.byte	"?????ql???zsaw2?" ; 10-1F
	.byte	"?cxde43?? vftr5?" ; 20-2F
	.byte	"?nbhgy6???mju78?" ; 30-3F
	.byte	"?,kio09??./l;p-?" ; 40-4F
	.byte	"??'?[=?????]?\??" ; 50-5F
	.byte	"?????????1?47???" ; 60-6F
	.byte	"0.2568???+3-*9??" ; 70-7F
	.byte	"????????????????" ; 80-8F
	.byte	"????????????????" ; 90-9F
	.byte	"????????????????" ; A0-AF
	.byte	"????????????????" ; B0-BF
	.byte	"????????????????" ; C0-CF
	.byte	"????????????????" ; D0-DF
	.byte	"????????????????" ; E0-EF
	.byte	"????????????????" ; F0-FF
keymap_shifted:
	.byte	"?????????????? ~" ; 00-0F
	.byte	"?????QL???ZSAW@?" ; 10-1F
	.byte	"?CXDE$#?? VFTR%?" ; 20-2F
	.byte	"?NBHGY^???MJU&*?" ; 30-3F
	.byte	"?<KIO)(??>?L:P_?" ; 40-4F
	.byte	'??"?{+?????}?|??' ; 50-5F
	.byte	"????????????????" ; 60-6F
	.byte	"?.???????+?-*???" ; 70-7F
	.byte	"????????????????" ; 80-8F
	.byte	"????????????????" ; 90-9F
	.byte	"????????????????" ; A0-AF
	.byte	"????????????????" ; B0-BF
	.byte	"????????????????" ; C0-CF
	.byte	"????????????????" ; D0-DF
	.byte	"????????????????" ; E0-EF
	.byte	"????????????????" ; F0-FF
 
;--------------------------------------------------------------
; Vectors
;--------------------------------------------------------------
	.org	$FFFA ; $7FFA in ROM
	.word	nmi
	.word	reset
	.word	irq