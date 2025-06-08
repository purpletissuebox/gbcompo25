#include "hello.h"
#include <gb/cgb.h>

const palette_color_t pal[] = { RGB(6,13,10), RGB(28,31,26), RGB(17,24,14), RGB(1,3,4) };
INCBIN(helloworld_tiledata, "res/tiles.bin")
INCBIN(helloworld_tilemap, "res/map.bin")
INCBIN(helloworld_attrmap, "res/attr.bin")
