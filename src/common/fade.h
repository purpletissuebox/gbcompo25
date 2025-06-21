#pragma once

#include "actor.h"

BANKREF_EXTERN(fadeScreen_bank)

void loadColors(u16 *);
void updateScreenColors(u8);
u8 tickFade(u16);
void fadeScreen(Actor *self);
void colorActor(Actor *self);
