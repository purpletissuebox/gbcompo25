#pragma once
#include "common/actor.h"
#include <gb/gb.h>

extern u8 input_raw, input_press, input_hold, input_release;
void readJoypad(Actor *);
