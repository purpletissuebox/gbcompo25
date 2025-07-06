INCLUDE "common/actor.h"
INCLUDE "macros.h"

SECTION "ACTORHEAP", WRAM0
next_free_actor::
	ds 2
align 5
actor_heap::
	ds ACTORSIZE*32
	.end::

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SECTION "ACTOR MANAGEMENT", ROM0
;de = ptr to actorheader
spawnActor::
	;get hl = ptr to actor slot
	ld hl, next_free_actor
	ldi a, [hl]
	ld h, [hl]
	ld l, a
	push hl
	
	;copy variable, main function, and bank
	dec l
	ld a, [de]
	inc de
	ldi [hl], a
	.variableEntry:
	ld a, [de]
	inc de
	ldi [hl], a
	ld a, [de]
	inc de
	ldi [hl], a
	ld a, [de]
	inc de
	ldi [hl], a
	
	;set actor.next = NULL
	xor a
	ldi [hl], a
	ld [hl], a
	
	;find end of linked list
	ld hl, actor_heap + ACTORSIZE - 2
	ld bc, $0003
	jr .traverse+4
	.traverse:
		ldd a, [hl]
		ld l, [hl]
		ld h, a
		add hl, bc
		ldi a, [hl]
		or [hl]
	jr nz, .traverse
	
	;set end.next = us
	pop bc
	push bc
	ld a, b
	ldd [hl], a
	ld [hl], c
	
	;find an empty slot for an actor to go
	ld hl, actor_heap - 3
	ld bc, ACTORSIZE-1
	.search:
		add hl, bc
		ldi a, [hl]
		or [hl]
	jr nz, .search
	
	;flag empty slot as next available
	ld a, l
	dec a
	dec a
	ld b, h
	ld hl, next_free_actor
	ldi [hl], a
	ld [hl], b
	
	;get ptr to init function
	ld a, [de]
	inc de
	ld l, a
	ld a, [de]
	inc de
	ld h, a
	or l
	jr nz, .callInit
	
	pop bc
	inc de
	inc de
	ret
	
	.callInit:
	;get ptr to start of actor
	pop bc
	ld a, c
	and ~(ACTORSIZE-1)
	ld c, a
	swapInRom [de]
	inc de
	inc de
	push de
	rst callHL
	pop de
	restoreBankRom
	ret

;de = ptr to actor header
;a = variable
spawnActorVariable::
	ld c, a
	ld hl, next_free_actor
	ldi a, [hl]
	ld h, [hl]
	ld l, a
	push hl
	
	dec l
	ld a, c
	ldi [hl], a
	inc de
	jp spawnActor.variableEntry

;de = actor to remove
removeActor::
	ld a, e
	and ~(ACTORSIZE-1)
	ld e, a
	ld hl, actor_heap + ACTORMAIN
	ld bc, $0003
	
	.search:
		add hl, bc
		ldi a, [hl]
		and ~(ACTORSIZE-1)
		sub e
		jr nz, removeActor.keepLookin
			ld a, [hl]
			sub d
				jr z, .targetFound
	.keepLookin:
		ldd a, [hl]
		ld l, [hl]
		ld h, a
	jr .search
	
	.targetFound:
	ld c, l
	ld b, h
	ld hl, ACTORSIZE-1
	add hl, de
	
	ldd a, [hl]
	ld [bc], a
	dec c
	ldd a, [hl]
	ld [bc], a
	
	xor a
	ldd [hl], a
	ld [hl], a
	ret
