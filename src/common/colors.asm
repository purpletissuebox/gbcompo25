INCLUDE "common/colors.h"
INCLUDE "macros.h"

SECTION "SHADOW_PALETTES", WRAMX
shadow_bkg_palettes::
	ds $40
	.end::
shadow_oam_palettes::
	ds $40

align 8
bkg_color_buf:
	ds $60
oam_color_buf:
	ds $60

fade_amt:
	ds 2
fade_complete::
	ds 1

SECTION "FADE ACTOR", ROMX, ALIGN[5]
fade_LUT:
	FOR FADE, 32
		FOR COLOR, 32
			db ROUND( DIV( COLOR*FADE*1.0, 32.0) ) >> 16
		ENDR
	ENDR

;num colors - speed - ptr - ptr
color_table:
	FADEENTRY 4, logo_colors, 0.5
	FADEENTRY 4, logo_colors, -0.5

logo_colors:
	RGB5 6,13,10
	RGB5 28, 31, 26
	RGB5 17,24,14
	RGB5 1,3,4

;a = FXXN NNNN
; N = number of colors to copy
; F = 0 for bkg, 1 for obj
;de = ptr to colors
loadColors:
	ld hl, bkg_color_buf
	ld b, a
	and $1F
	cp b
	ld b, a
	jr z, .loop
		ld hl, oam_color_buf
	
	.loop:
		ld a, [de]
		inc de
		ld c, a
		and $1F
		ldi [hl], a ;save off red channel
		
		ld a, [de]
		rl c
		adc a
		rl c
		adc a
		rl c
		adc a
		and $1F
		ldi [hl], a ;green
		
		ld a, [de]
		inc de
		rra
		rra
		and $1F
		ldi [hl], a ;blue
		
		dec b
	jr nz, .loop
	ret

;a = FXXI IIII
; F = 0 for bkg, 1 for obj
; I = fade intensity (0-1F)
updateScreenColors:
	ld de, shadow_bkg_palettes
	ld c, LOW(bkg_color_buf)
	add a
	jr nc, .bkg
		ld de, shadow_oam_palettes
		ld c, LOW(oam_color_buf)
	.bkg:
	add a
	add a
	ld b, 0
	add a
	rl b
	add a
	rl b
	add LOW(fade_LUT)
	ld l, a
	ld a, b
	adc HIGH(fade_LUT)
	ld h, a
	ld b, HIGH(bkg_color_buf)
	
	.loop:
		push de
		ld a, [bc]
		inc c
		add l
		ld l, a
		ld e, [hl]
		and $E0
		ld l, a
		
		ld a, [bc]
		inc c
		add l
		ld l, a
		ld d, [hl]
		and $E0
		ld l, a
		
		ld a, [bc]
		inc c
		add l
		ld l, a
		ld b, [hl]
		and $E0
		ld l, a
		
		ld a, b
		add a
		add a
		ld b, a
		ld a, d
		rrca
		rrca
		rrca
		ld d, a
		and $07
		or b
		ld b, a
		ld a, d
		and $C0
		or e
		
		pop de
		ld [de], a
		inc e
		ld a, b
		ld [de], a
		inc e
		
		ld b, HIGH(bkg_color_buf)
		ld a, e
		and $3F
	jr nz, .loop
	ret

colorInit::
	swapInRam shadow_bkg_palettes
	;get ptr to color table entry
	ld hl, ACTORSIZE-6
	add hl, bc
	ld a, [hl]
	add a
	add a
	add LOW(color_table)
	ld l, a
	ld a, HIGH(color_table)
	adc $00
	ld h, a
	
	;get number of colors and speed
	ldi a, [hl]
	ld d, a
	and $80
	ld [bc], a
	inc c
	ldi a, [hl]
	ld [bc], a
	push bc
	
	;get ptr to colors and load them
	ldi a, [hl]
	ld e, a
	ld a, d
	ld d, [hl]
	call loadColors
	
	;check for special values and fade immediately if set
	pop bc
	ld a, [bc]
	inc a
	cp $02
	dec a
	jr nc, .fadeNormal
		cpl
		and $1F
		ld e, a ;set fade_amt to 1F/00 for speed=00/FF
		dec c
		ld a, [bc]
		or e ;get obj flag
		push bc
		call updateScreenColors
		pop de
		jp removeActor
	
	.fadeNormal:
	ld e, a
	ld hl, fade_amt
	ld d, $1F
	cp $80
	sbc a
	ldi [hl], a
	cpl
	and d
	ld [hl], a ;set fade_amt to 00FF/1F00 for speed <80 / >=80
	ld a, e
	cp $80
	sbc a
	cpl
	xor e
	ld d, a ;d = abs(speed) / e = raw speed
	
	ld l, c
	ld h, b
	
	cp $70
	jr c, .slower
		add a
		swap a
		ld l, a
		and $0F
		ld d, a
		ld a, l
		and $F0
		ld l, c
		sub $FA
		ldi [hl], a
		ld a, d
		sub $0C
		ld [hl], a
		jr .done
	.slower:
	cp $60
	jr c, .slowerr
		add a
		ld d, $00
		add a
		rl d
		add a
		rl d
		sub $7A
		ldi [hl], a
		ld a, d
		sbc $02
		ld [hl], a
		jr .done
	.slowerr:
	cp $40
	jr c, .slowerrr
		add a
		sub $40
		ldi [hl], a
		ld [hl], $00
		jr .done
	.slowerrr:
		ccf
		rra
		add $20
		ldi [hl], a
		ld [hl], $00
	
	.done:
	xor a
	ld [fade_complete], a
	inc a
	ldh [redraw_screen], a
	restoreBankRam
	bit 7, e
	ret z
	
	ld a, [hl]
	cpl
	ldd [hl], a
	ld a, [hl]
	cpl 
	inc a
	ldi [hl], a
	ret nz
	inc [hl]
	ret

fadeScreen:
	ld a, [bc]
	inc c
	ld d, a
	ld hl, fade_amt
	ld a, [bc]
	inc c
	add [hl]
	ldi [hl], a
	ld a, [bc]
	adc [hl]
	cp $20
	call nc, fadeClamp
	ld [hl], a
	jp updateScreenColors

fadeClamp:
	cp $80
	ld a, $01
	ld [fade_complete], a
	sbc a
	and $1F
	ret
	
fadeActor::
	swapInRam shadow_bkg_palettes
	push bc
	call fadeScreen
	pop de
	ld a, [fade_complete]
	ld c, a
	restoreBankRam
	ld a, c
	and a
	jp nz, removeActor
	ret
