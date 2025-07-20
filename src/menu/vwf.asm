INCLUDE "macros.h"
INCLUDE "common/gfx.h"
INCLUDE "common/actor.h"

NEWCHARMAP vwf
createCharmap 1, "ABCDEFGHIJKLMNOPQRSTUVWXYZ.,'!?abcdefghijklmnopqrstuvwxyz-\"(): "
CHARMAP "$", 0xFFFF
PUSHC vwf

SECTION "VWF VARS", WRAMX, ALIGN[8]
print_buf:
	ds 16*13
	.end
x_position:
	ds 1

SECTION "VWF", ROMX, ALIGN[8]
font_data:
	INCBIN "menu/font.bin"

letter_sizes:
	INCBIN "menu/widths.bin"

gfx_task:
	GFXTASK print_buf, $9001

vwf_strings:
	.s00:
		db "test string wahoo!", 0
	.s01:
		db "Addy reference?", 0
	.s02:
		db ".,'\"!?-():", 0

vwfSpawner::
	push bc
	ld a, HIGH(vwf_strings.s01)
	ldh [scratch], a
	ld a, LOW(vwf_strings.s01)
	ld de, .actor
	call spawnActorVariable
	pop de
	jp removeActor
	
	.actor:
		NEWACTOR vwfInit, vwfTick, $00

vwfTick::
	ld a, [bc]
	ld e, a
	add $01
	ld [bc], a
	
	inc c
	ld a, [bc]
	ld d, a
	adc $00
	ld [bc], a
	
	ld a, [de]
	and a
	jr z, .dead
	
	call vwfPrintChar
	ld hl, gfx_task
	jp loadTiles
	
	.dead:
	ld e, c
	ld d, b
	jp removeActor

;bc = ptr to actor
vwfInit::
	;transfer scratch+variable to actor to form ptr to string
	;simultaneously put it in hl
	ld hl, VARIABLE
	add hl, bc
	ld a, [hl]
	ld [bc], a
	inc c
	ld l, a
	ldh a, [scratch]
	ld [bc], a
	ld h, a
	
	call strwid
	
	swapInRam print_buf
	ld hl, print_buf
	ldsz c, print_buf
	xor a
	.erase:
		ldi [hl], a
		dec c
	jr nz, .erase		
	
	ld a, 12*8
	sub b
	rra
	ld [x_position], a
	
	restoreBankRam
	ret
	
	
	ret

;hl = ptr to string
strwid:
	ld b, $00
	ld d, HIGH(letter_sizes)
	
	ldi a, [hl]
	.loop:
		ld e, a
		ld a, [de]
		add b
		ld b, a
		ldi a, [hl]
		and a
	jr nz, .loop
	ret	

;de = ptr to string
vwfPrintString::
	ld a, [de]
	
	.loop:
		inc de
		push de
		call vwfPrintChar
		pop de
		ld a, [de]
		and a
	jr nz, .loop
	ret

;a = letterID
vwfPrintChar:
	ld d, a
	
	add a
	add a
	add a
	ld c, a
	sbc a
	cpl
	inc a
	add HIGH(font_data)
	ld b, a
	
	swapInRam print_buf
	push de
	
	ld hl, x_position
	ld a, [hl]
	and $F8
	add a
	ld e, a
	ld d, HIGH(print_buf)
	
	ld a, [hl]
	and $07
	cpl
	add $09
	ldh [scratch], a
	
	.loop:
		ld a, [bc]
		inc c
		ld l, a
		ld h, $00
		ldh a, [scratch]
		.shift:
			add hl, hl
			dec a
		jr nz, .shift
		
		ld a, [de]
		or h
		ld [de], a
		inc e
		ld [de], a
		ld a, e
		add $10
		ld e, a
		
		ld a, l
		ld [de], a
		dec e
		ld [de], a
		ld a, e
		sub $0E
		ld e, a
		
		ld a, c
		and $07
	jr nz, .loop
	
	pop af
	add LOW(letter_sizes)
	ld e, a
	ld d, HIGH(letter_sizes)
	
	ld hl, x_position
	ld a, [de]
	add [hl]
	ld [hl], a
	
	restoreBankRam
	ret

POPC
