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
	updateActorMain logoTick
	ret

logoTick:
	ld hl, VARIABLE
	add hl, bc
	dec [hl]
	ret nz
	
	push bc
	ld de, .fadeout_actor
	call spawnActor
	pop de
	jp removeActor

.fadeout_actor:
	NEWACTOR colorInit, fadeActor, $01
