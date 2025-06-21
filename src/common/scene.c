#include "scene.h"
#include "actor.h"

#define SCENETABLE(x) {x, sizeof(x)/sizeof(*x)}

struct sceneListing
{
	ActorHeader *list;
	u8 size;
};

#include "logo/scenetable.h"

const struct sceneListing scene_table[] = {
	SCENETABLE(logo)
};

void switchScene(u8 i)
{
	Actor *a = ACTORHEAP->next;
	Actor *b = a;
	while(b)
	{
		b = a->next;
		removeActor(a);
		a = b;
	}
	spawnAll(scene_table[i].list, scene_table[i].size);
}

void spawnAll(ActorHeader *list, u8 N)
{
	do spawnActorH(list++);
	while (--N);
}
