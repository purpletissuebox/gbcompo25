#include "hello.h"
#include "common/actor.h"
#include "common/fade.h"
#include <gb/gb.h>
#include <gb/cgb.h>

void loadBKG(Actor *self)
{
    set_bkg_data(0, INCBIN_SIZE(helloworld_tiledata) / 16, helloworld_tiledata);
    VBK_REG = 0;
    set_bkg_tiles(0, 0, 20, 18, helloworld_tilemap);
    VBK_REG = 1;
    set_bkg_tiles(0, 0, 20, 18, helloworld_attrmap);
    
    loadColors(pal);

    SHOW_BKG;
    removeActor(self);
}
