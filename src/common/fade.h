#pragma once

#include "actor.h"

void loadColors(u16*, u8, u8);
void updateScreenColors(u8);
u8 tickFade(u16);
void fadeScreen(Actor *self);
