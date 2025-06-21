#pragma bank 255

#include "common/actor.h"
#include <gb/gb.h>
#include <gb/cgb.h>
#include <gbdk/incbin.h>

BANKREF(loadBKG_bank)

INCBIN(helloworld_tiledata, "res/logo/tiles.bin")
INCBIN_EXTERN(helloworld_tiledata)
INCBIN(helloworld_tilemap, "res/logo/map.bin")
INCBIN_EXTERN(helloworld_tilemap)
INCBIN(helloworld_attrmap, "res/logo/attr.bin")
INCBIN_EXTERN(helloworld_attrmap)

void loadBKG(Actor *self)
{
    set_bkg_data(0, INCBIN_SIZE(helloworld_tiledata) / 16, helloworld_tiledata);
    VBK_REG = 0;
    set_bkg_tiles(0, 0, 20, 18, helloworld_tilemap);
    VBK_REG = 1;
    set_bkg_tiles(0, 0, 20, 18, helloworld_attrmap);

    SHOW_BKG;
    removeActor(self);
}
