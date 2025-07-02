INCLUDE "hwregs.h"
INCLUDE "common/actor.h"

SECTION "MAIN", ROM0
MAIN::
	ld hl, actor_heap + ACTORSIZE - 5
	.loop:
		ldi a, [hl]
		ldh [rom_bank], a
		ld [MBC_ROM_BANK], a
		ldi a, [hl]
		ld e, a
		ldi a, [hl]
		push hl
		ld b, h
		ld h, a
		ld a, l
		ld l, e
		and $E0
		ld c, a
		rst callHL
		pop hl
		ldi a, [hl]
		or [hl]
		ldd a, [hl]
		ld l, [hl]
		ld h, a
	jr nz, .loop
	halt
    jr MAIN
