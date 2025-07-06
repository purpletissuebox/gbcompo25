INCLUDE "macros.h"
INCLUDE "common/gfx.h"

SECTION "GFX VARS", HRAM
redraw_screen::
	ds 1

SECTION "GFX MAP BUFFERS", WRAMX
shadow_bkg_map::
	ds $0400
shadow_win_map::
	ds $0400
shadow_bkg_attr::
	ds $0400
shadow_win_attr::
	ds $0400

SECTION "OAM BUFFER", WRAMX, ALIGN[8]
shadow_oam::
	ds $A0
	.end::
shadow_scroll::
	ds 2
shadow_winloc::
	ds 2

SECTION "GFX ROUTINES", ROM0
;hl = ptr to gfx task
loadTiles::
	;get ptr to src and dest
	swapInRom [hl+]
	ldi a, [hl]
	ld e, a
	ldi a, [hl]
	ld d, a
	ldi a, [hl]
	and $01
	ldh [IO_VRAM_BANK], a
	ld c, a
	ldi a, [hl]
	ld b, a
	
	;we will copy tiles in batches of 4 via a loop, then one final copy for the remainder
	ld a, [hl]
	and $03
	ldh [scratch], a ;scratch = remainder
	ldi a, [hl]
	and $FC
	rrca
	rrca
	ld l, c
	ld h, b
	ld b, a ;b = number of batches
	inc b
	ld c, LOW(IO_DMA_TRIGGER)
	jr .entry ;handle "remainder only" copies by doing an inc-dec
	
	.loop:
		dec c
		;write and increment destination
		ld a, l
		ldh [c], a
		dec c
		add $40
		ld l, a
		ld a, h
		ldh [c], a
		dec c
		adc $00
		ld h, a
		
		;write and increment source
		ld a, e
		ldh [c], a
		dec c
		add $40
		ld e, a
		ld a, d
		ldh [c], a
		adc $00
		ld d, a
		
		;copy 4 tiles
		ld c, LOW(IO_DMA_TRIGGER)
		waitVRAM
		ld a, $03
		ldh [c], a
		
		.entry:
		dec b
	jr nz, .loop
	
	ldh a, [scratch]
	ld b, a
	waitVRAM
	ld a, b
	ldh [c], a ;copy remainder
	restoreBankRom
	ret
