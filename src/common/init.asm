INCLUDE "hwregs.h"

SECTION "ENTRY", ROM0[$0150]
init::
	di
	ld sp, $D000
	
	ld hl, oamRoutine
	ld de, oam_routine_rom
	ld c, oam_routine_rom.end - oam_routine_rom
	rst memcpy ;init oam function
	
	ld a, BANK(shadow_oam)
	ldh [IO_WRAM_BANK], a
	ld a, $A7
	ld hl, shadow_winloc + 1
	ldd [hl], a
	ldd [hl], a ;window position
	xor a
	ldd [hl], a
	ldd [hl], a ;bkg scroll
	ld hl, shadow_oam
	ld c, $A0
	rst memset ;init oam
	
	ld hl, vblankJump
	ld a, $C3
	ldi [hl], a
	ld a, LOW(VBLANK)
	ldi [hl], a
	ld a, HIGH(VBLANK)
	ldi [hl], a
	
	ld a, BANK(shadow_bkg_palettes)
	ldh [IO_WRAM_BANK], a
	
	xor a
	ld hl, shadow_bkg_palettes
	ld c, $80
	rst memset ;init colors
	
	ld a, $01
	ldh [IO_INTERRUPT_ENABLE], a ;enable vblank interrupt
	ld a, $FE
	ldh [IO_TIMER_LEN], a ;timer mod (fire every other clock)
	ld a, $07
	ldh [IO_TIMER_CTRL], a ;enable timer + set speed to 8kHz
	
	xor a
	ldh [IO_SERIAL_CTRL], a
	ldh [IO_INTERRUPT_REQUEST], a
	ldh [IO_SCROLL_Y], a
	ldh [IO_SCROLL_X], a
	ldh [IO_LCD_Y_COMPARE], a
	ldh [IO_DMG_BKG_PALETTE], a
	ldh [IO_DMG_OBJ_PALETTE1], a
	ldh [IO_DMG_OBJ_PALETTE2], a
	ldh [IO_WINDOW_X], a
	ld a, $07
	ldh [IO_WINDOW_Y], a ;zero out serial, graphical, and sound io ports
	
	ld a, $E3
	ld [IO_LCD_CTRL], a
	ldh a, [IO_LCD_STATUS]
	and $07
	or $40
	ldh [IO_LCD_STATUS], a ;enable window + sprite layers, choose memory regions, and enable stat interrupt source only for LYC
	
	ld a, $01
	ldh [rom_bank], a
	ldh [ram_bank], a
	xor a
	ldh [vram_bank], a
	ldh [redraw_screen], a ;initialize system hram variables
	
	ld hl, next_free_actor
	ld a, LOW(actor_heap)
	ld [hl], HIGH(actor_heap) ;init global linked list ptrs
	
	ld hl, actor_heap
	ld a, LOW(readJoystick)
	ldi [hl], a
	ld a, HIGH(readJoystick)
	ldi [hl], a
	ld a, $01
	ldi [hl], a
	xor a
	ld c, ACTORSIZE - 3
	rst memset ;create root node for actor linked list
	
	ld c, (actor_heap.end - actor_heap)/ACTORSIZE
	ld hl, actor_heap
	ld de, ACTORSIZE
	.clearActorSpace:
		add hl, de
		ldi [hl], a
		ldd [hl], a
		dec c
	jr nz, init.clearActorSpace ;zero out remaining actor heap
	
	ld hl, $FF24
	ld a, $77
	ldi [hl], a
	ld a, $FF
	ldi [hl], a
	ld a, $80
	ldi [hl], a ;enable global sound registers
	
	xor a
	ld bc, $1410
	.soundLoop:
		ldh [c], a
		inc c
		dec b
	jr nz, init.soundLoop ;disable individual channel sound registers
	
	ldh a, [$FF0F]
	and $FE
	ldh [$FF0F], a
	ei
	jp MAIN ;as soon as we enter vblank, start the game
