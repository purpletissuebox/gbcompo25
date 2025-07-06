INCLUDE "hwregs.h"

SECTION "VBLANK HANDLER", ROM0
VBLANK::
	push hl
	ld a, BANK(shadow_scroll)
	ldh [IO_WRAM_BANK], a
	ld hl, shadow_scroll
	ldi a, [hl]
	ldh [IO_SCROLL_Y], a
	ldi a, [hl]
	ldh [IO_SCROLL_X], a
	ldi a, [hl]
	ldh [IO_WINDOW_Y], a
	ldi a, [hl]
	ldh [IO_WINDOW_X], a
	
	ld a, BANK(shadow_bkg_palettes)
	ldh [IO_WRAM_BANK], a
	ld a, CRAM_INCREMENT
	ldh [IO_CRAM_BKG_SELECT], a
	ld hl, shadow_bkg_palettes
	.loop:
		ldi a, [hl]
		ldh [IO_CRAM_BKG_DATA], a
		bit 6, l
	jr z, .loop
	ldh a, [ram_bank]
	ldh [IO_WRAM_BANK], a
	pop hl
	pop af
	reti

SECTION "VBLANK JUMP", ROM0
vblankJump::
	ds 3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SECTION "OAM ROUTINE ROM", ROM0
;a = pointer to shadow oam >> 8
;the dma takes 160 cycles to execute, so we need to wait that long before exiting.
;conveniently, dec + jr nz takes 4 cycles, so we just loop 40 times.
oam_routine_rom::
	ld [IO_OAM_DMA], a
	ld a, $28
		.oamStall:
		dec a
		jr nz, oam_routine_rom.oamStall
	ret
	.end::

SECTION "OAM DMA", HRAM
oamRoutine::
	ds oam_routine_rom.end - oam_routine_rom
