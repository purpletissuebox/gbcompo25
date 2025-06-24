#pragma bank 255

#include "common/actor.h"
#include <gb/gb.h>
#include <gb/cgb.h>
#include <gbdk/incbin.h>

BANKREF(loadBKG_bank)

INCBIN(menu_tiledata, "res/menu/tiles.bin")
INCBIN_EXTERN(menu_tiledata)
INCBIN(menu_tilemap, "res/logo/map.bin")
INCBIN_EXTERN(menu_tilemap)

void loadBKG(Actor *self)
{
    VBK_REG = 0;
    set_bkg_data(0, INCBIN_SIZE(menu_tiledata) / 16, menu_tiledata);
    set_bkg_tiles(0, 0, 20, 18, menu_tilemap);
    removeActor(self);
}
