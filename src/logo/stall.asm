INCLUDE "common/actor.h"
INCLUDE "macros.h"

SECTION "LOGO STALL", ROMX
logoStall::
	swapInRam fade_complete
	ld a, [fade_complete]
	ld e, a
	restoreBankRam
	ld a, e
	and a
	ret z
	updateActorMain fadeout
	ret

fadeout:
	ld hl, VARIABLE
	add hl, bc
	dec [hl]
	ret nz
	
	updateActorMain awaitDeath
	ld de, fadeout_actor
	jp spawnActor

awaitDeath:
	swapInRam fade_complete
	ld a, [fade_complete]
	ld e, a
	restoreBankRam
	ld a, e
	and a
	ret z
	
	ld e, c
	ld d, b
	call removeActor
	ld a, 1
	jp changeScene

fadeout_actor:
	NEWACTOR colorInit, fadeActor, $01
