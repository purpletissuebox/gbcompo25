#include "hello.h"
#include "common/actor.h"
#include <gb/gb.h>
#include <gb/cgb.h>

void loadBKG(Actor *self)
{
    set_bkg_data(0, INCBIN_SIZE(helloworld_tiledata) / 16, helloworld_tiledata);
    VBK_REG = 0;
    set_bkg_tiles(0, 0, 20, 18, helloworld_tilemap);
    VBK_REG = 1;
    set_bkg_tiles(0, 0, 20, 18, helloworld_attrmap);
    set_bkg_palette(0, 1, pal);

    SHOW_BKG;
    removeActor(self);
}
