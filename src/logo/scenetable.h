#include "common/actor.h"
#include "bkg/bkg.h"
#include "common/fade.h" 

const ActorHeader logo[] = {
	{loadBKG, BANK(loadBKG_bank), 0, NULL},
	{fadeScreen, BANK(fadeScreen_bank), 0x0060, colorActor}
};
