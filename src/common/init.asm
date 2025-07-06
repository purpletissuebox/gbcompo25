INCLUDE "hwregs.h"
INCLUDE "macros.h"
INCLUDE "common/actor.h"

SECTION "ENTRY", ROM0[$0150]
init::
	di
	ld sp, $D000
	
	ld hl, oamRoutine
	ld de, oam_routine_rom
	ldsz c, oam_routine_rom
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
	ldsz c, shadow_oam
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
	ldsz c, shadow_bkg_palettes
	rst memset ;init colors
	
	ld a, INTERRUPT_VBLANK
	ldh [IO_INTERRUPT_ENABLE], a ;enable vblank interrupt
	ld a, $FE
	ldh [IO_TIMER_LEN], a ;timer mod (fire every other clock)
	ld a, TIMER_ENABLE | TIMER_SPEED
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
	
	ld a, LCD_ENABLE | WIN_MAP_SELECT | WIN_ENABLE | SPRITE_ENABLE | SPRITE_PRIORITY
	ld [IO_LCD_CTRL], a
	ld a, STAT_IRQ_LYC
	ldh [IO_LCD_STATUS], a ;enable window + sprite layers, choose memory regions, and enable stat interrupt source only for LYC
	
	ld a, $01
	ldh [rom_bank], a
	ld [MBC_ROM_BANK], a
	ldh [ram_bank], a
	ldh [IO_WRAM_BANK], a
	xor a
	ldh [vram_bank], a
	ldh [IO_VRAM_BANK], a
	ldh [redraw_screen], a ;initialize system hram variables
	
	ld hl, next_free_actor
	ld a, LOW(actor_heap+ACTORSIZE-5)
	ldi [hl], a
	ld [hl], HIGH(actor_heap+ACTORSIZE-5) ;init global linked list ptrs
	
	ld c, (actor_heap.end - actor_heap)/ACTORSIZE
	ld hl, actor_heap - 4
	ld de, ACTORSIZE
	xor a
	.clearActorSpace:
		add hl, de
		ldi [hl], a
		ldd [hl], a
		dec c
	jr nz, init.clearActorSpace ;zero out actor heap
	
	ld de, first_actor
	call spawnActor
	
	ld hl, IO_SOUND_MAIN_VOLUME
	ld a, $77
	ldi [hl], a
	ld a, $FF
	ldi [hl], a
	ld a, SPEAKERS_ENABLE
	ldi [hl], a ;enable global sound registers
	
	xor a
	lddouble bc, 1+(IO_SOUND4_PITCHH - IO_SOUND1_SWEEP), LOW(IO_SOUND1_SWEEP)
	.soundLoop:
		ldh [c], a
		inc c
		dec b
	jr nz, init.soundLoop ;disable individual channel sound registers
	
	xor a
	call changeScene
	
	ldh a, [IO_INTERRUPT_REQUEST]
	and ~INTERRUPT_VBLANK
	ldh [IO_INTERRUPT_REQUEST], a
	ei
	jp MAIN ;as soon as we enter vblank, start the game

first_actor:
	NEWACTOR bootstrapActors, readJoystick, $00
