#include "actor.h"
#include "common.h"
#include <string.h>
#include <gb/gb.h>

Actor ACTORHEAP[32];
Actor *next_free = ACTORHEAP + 1;

void spawnActor(void (*actor_func)(Actor*), u8 bankID, u16 actor_var, void (*actor_init)(Actor*))
{
	//copy actor data into the list
	next_free->process_flag = 1;
	next_free->bank = bankID;
	next_free->process_func = actor_func;
	next_free->variable = actor_var;
	#if DEBUG
		memset(next_free->_actor_memory, 0, sizeof(next_free->_actor_memory));
	#endif
	next_free->next = NULL;

	//init actor
	if (actor_init)
		actor_init(next_free);

	//find end of list and append new actor
	Actor *a = ACTORHEAP;
	while (a->next)
		a = a->next;
	a->next = next_free;
	
	//find empty slot in heap somewhere
	a = ACTORHEAP;
	do ++a;
	while(a->process_flag != 0xFF);
	next_free = a;
}

void spawnActorH(ActorHeader *a)
{
	spawnActor(a->process_func, a->bank, a->variable, a->actor_init);
}

void removeActor(Actor *target)
{
	Actor *a = ACTORHEAP;
	while (a->next != target)
		a = a->next;
	a->next = target->next;

	target->process_flag = 0xFF;
}

void runAllActors(void)
{
	Actor *a = ACTORHEAP;
	do
	{
		if (a->process_flag)
		{
			SWITCH_ROM(a->bank);
			a->process_func(a);
		}
		a = a->next;
	} while (a);
}
