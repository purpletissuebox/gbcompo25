#pragma once

#include "common.h"
#include <gb/gb.h>

typedef struct actor_t
{
	u8 process_flag; //1
	void (*process_func)(struct actor_t*); //3
	u8 bank; //4
	u16 variable; //6
	u8 _actor_memory[24]; //30
	struct actor_t *next; //32
} Actor;

typedef struct actor_header_t
{
	void (*process_func)(struct actor_t *);
	u8 bank;
	u16 variable;
	void (*actor_init)(struct actor_t *);
} ActorHeader;

extern Actor ACTORHEAP[32];
extern Actor *next_free;

void spawnActor(void (*)(Actor*), u8, u16, void (*)(Actor *));
void spawnActorH(ActorHeader *);
void removeActor(Actor *);
void runAllActors(void);
