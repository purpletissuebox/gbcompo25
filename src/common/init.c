#include "init.h"
#include "common/actor.h"
#include "common/joypad/joypad.h"
#include "common/scene.h"

void init(void)
{
	Actor *a = ACTORHEAP + sizeof(ACTORHEAP)/sizeof(*ACTORHEAP);
	do (--a)->process_flag = 0xFF;
	while (a != ACTORHEAP);

	a->process_flag = 1;
	a->process_func = readJoypad;
	a->bank = 0;
	a->next = NULL;

	switchScene(0);
}
