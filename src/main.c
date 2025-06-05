
#include "res/hello.h"
#include <gb/gb.h>
#include <gb/cgb.h>
#include <gbdk/incbin.h>

const palette_color_t pal[] = { RGB(6,13,10), RGB(28,31,26), RGB(17,24,14), RGB(1,3,4) };

void init_gfx(void) {
    set_bkg_data(0, INCBIN_SIZE(helloworld_tiledata)/16, helloworld_tiledata);
    VBK_REG = 0;
    set_bkg_tiles(0, 0, 20, 18, helloworld_tilemap);
    VBK_REG = 1;
    set_bkg_tiles(0, 0, 20, 18, helloworld_attrmap);
    set_bkg_palette(0, 1, pal);

    SHOW_BKG;
}


void main(void)
{
	init_gfx();
    while(1)
    {
        vsync();
    }
}
