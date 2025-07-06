INCLUDE "common/actor.h"

SECTION "SCENE", HRAM
scene::
	ds 1

SECTION "CHANGE SCENE", ROM0
;a = desired scene
changeScene::
	ldh [scene], a
	ld de, child
	jp spawnActorVariable
	
child:
	NEWACTOR managerActor	

SECTION "MANAGER", ROMX
managerActor:
	push bc
	ld hl, VARIABLE
	add hl, bc
	ld a, [hl]
	ld hl, actor_table
	ld d, a
	add a
	add d
	add l
	ld l, a
	adc h
	sub l
	ld h, a
	
	ldi a, [hl]
	ld e, a
	ldi a, [hl]
	ld d, a
	ldi a, [hl]
	
	.spawn:
		ldh [scratch], a
		call spawnActor
		ldh a, [scratch]
		dec a
	jr nz, .spawn
	pop de
	jp removeActor



actor_table:
	dw logo_actors
	db 1

INCLUDE "logo/actorList.h"
