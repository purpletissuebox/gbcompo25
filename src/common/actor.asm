EXPORT DEF ACTORSIZE EQU $0020

SECTION "ACTORHEAP", WRAM0
next_free_actor::
	ds 2
actor_heap::
	ds ACTORSIZE*32
	.end::