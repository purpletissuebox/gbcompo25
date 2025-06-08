#include "common/init.h"
#include "common/actor.h"
#include <gb/gb.h>

void main(void)
{
	init();
    while(1)
    {
        runAllActors();
        vsync();
    }
}
