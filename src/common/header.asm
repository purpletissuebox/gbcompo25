INCLUDE "hwregs.h"

SECTION "VECTORS", ROM0[0x0000]
callHL::
	jp hl
	ds 0x0008 - @
memcpy::
	ld a, [de]
	inc de
	ldi [hl], a
	dec c
	jr nz, memcpy
	ret
	ds 0x0010 - @
strcpy::
	ld a, [de]
	inc de
	and a
	ret z
	ldi [hl], a
	jr strcpy
	ds 0x0018 - @
waitVRAM::
	;routine takes 44 dots at most, ppu takes 167 dots at least.
	;so worst case you have 123 dots = 30 clocks of vram time after calling this
	ldh a, [IO_LCD_STATUS]
	and (PPU_MODE & 2)
	jr nz, waitVRAM
	ret
	ds 0x0020 - @
memset::
	ldi [hl], a
	dec c
	jr nz, memset
	ret
	ds 0x0028 - @
rst_28::
	ret
	ds 0x0030 - @
rst_30::
	ret
	ds 0x0038 - @
rst_38::
	jr rst_38
	ds 0x0040 - @
	
int_vblank::
	push af
	ldh a, [redraw_screen]
	and a
	jp nz, VBLANK
	pop af
	ds 0x0048 - @
int_lcd::
	reti
	ds 0x0050 - @
int_timer::
	reti
	ds 0x0058 - @
int_serial::
	reti
	ds 0x0060 - @
int_joypad::
	reti

SECTION "HEADER", ROM0[0x0100]
entryPoint:
	nop
	jp init

ds $150-@ ;reserve space for logo, etc
