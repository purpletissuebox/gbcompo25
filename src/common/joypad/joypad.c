#pragma bank 255

#include "joypad.h"
#include "common/actor.h"

#include <gb/gb.h>
#include <gbdk/far_ptr.h>

BANKREF(readJoypad_bank)
u8 input_raw, input_press, input_hold, input_release;

#pragma save
#pragma disable_warning 85
void readJoypad(Actor *self)
{
	u8 joyp = joypad();
	input_press = joyp & ~input_raw;
	input_hold = joyp & input_raw;
	input_release = ~joyp & input_raw;
	input_raw = joyp;
}
#pragma restore
