INCLUDE "macros.h"

NEWCHARMAP vwf
createCharmap 0, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ,.-!?$&()~@"

SECTION "VWF VARS", RAMX
next_open_px:
	ds 1
current_tile:
	ds 1
print_buf:
	ds 16*12

SECTION "VWF", ROMX
align 5
font_data:
	db $200

letter_sizes:
	db $20

vwfInit::
	ld hl, VARIABLE
	add hl, bc
	ld a, [hl]
	add a
	add LOW(string_table)
	ld l, a
	adc HIGH(string_table)
	sub l
	ld h, a
	
	ldi a, [hl]
	ld d, [hl]
	ld e, a
	call strwid
	
	ld a, $60
	sub l
	rra
	ld e, a
	
	ld hl, next_open_px
	and $07
	ldi [hl], a
	ld a, e
	and $F8
	rrca
	rrca
	rrca
	add LOW(print_buf)
	ld [hl], a
	ret

;de = ptr to string
strwid:
	ld b, HIGH(letter_sizes)
	ld l, $00
	ld a, [de]
	inc de
	and a
	ret z
	
	.loop:
		add LOW(letter_sizes)
		ld c, a
		ld a, [bc]
		add l
		ld l, a
		ld a, [de]
		inc de
		and a
	jr nz, .loop
	ret	

;a = tileID
;bc = ptr to gfx task
;de = ptr to string
vwfPrintString::
	push bc
	inc c
	inc c
	inc c
	
	ld h, a
	swap a
	ld l, a
	and $F0
	ld [bc], a
	inc c
	
	ld a, h
	add a
	sbc a
	and $F8
	ld h, a
	ld a, l
	and $0F
	add $90
	add h
	ld [bc], a
	
	ld a, [de]
	inc de
	.loop:
		push de
		call vwfPrintChar
		pop de
		ld a, [de]
		inc de
		and a
	jr nz, .loop
	
	pop de
	call removeActor
	ld l, e
	ld h, d
	jp loadTiles

vwfPrintLetter:
	ld e, a
	swap a
	ld d, a
	and $0F
	ld b, a
	ld a, d
	and $F0
	add LOW(font_data)
	ld c, a
	adc HIGH(font_data)
	sub c
	add b
	ld b, a
	
	ld hl, next_open_px
	ldi a, [hl]
	ld l, [hl]
	ld h, HIGH(print_buf)
	ld d, a
	push de
	cpl
	inc a
	and $07
	
	sub $04
	jr c, .daaBig
	add $02
	adc $03
	jr .daaDone
	.daaBig:
	add $FE
	adc $03
	swap a
	.daaDone:
	add a
	daa
	rra
	dec a
	ld e, a
	
	.loop:
		ld a, [bc]
		inc c
		ld d, a
		ld a, [bc]
		inc c
		push bc
		
		push hl
		ld l, d
		ld h, a
		xor a
		bit 0, e
		jr z, .skipShift
		ld d, e
		.doShift:
			add hl, hl
			rla
			rr d
			jr nc, .doShift
		.skipShift:
		ld c, l
		ld b, h
		pop hl
		
		or [hl]
		ldi [hl], a
		ld a, b
		and e
		or [hl]
		ldd [hl], a
		ld a, l
		add $10
		ld l, a
		
		ld a, e
		cpl
		and b
		ldi [hl], a
		ld a, c
		ldi [hl], a
		ld a, l
		sub $10
		ld l, a
		
		pop bc
		and $0F
	jr nz, .loop
	
	pop de
	ld a, e
	add LOW(letter_sizes)
	ld c, a
	adc HIGH(letter_sizes)
	sub c
	ld b, a
	ld a, [bc]
	
	ld hl, next_open_px
	add d
	and $07
	ldi [hl], a
	inc d
	sub d
	ret nc
	
	inc [hl]
	ret

POPC
