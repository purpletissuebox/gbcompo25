#include "common/actor.h"
#include "bkg/bkg.h"
#include "common/fade.h" 

const ActorHeader logo[] = {
	{loadBKG, 0, 0, NULL},
	{fadeScreen, 0, 0x0060, colorActor}
};