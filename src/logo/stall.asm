INCLUDE "common/actor.h"

SECTION "LOGO STALL", ROMX
logoStall::
	ld hl, VARIABLE
	add hl, bc
	dec [hl]
	ret z
	
	push bc
	ld de, .fadeout_actor
	call spawnActor
	pop de
	jp removeActor

.fadeout_actor:
	NEWACTOR colorInit, fadeActor, $01
