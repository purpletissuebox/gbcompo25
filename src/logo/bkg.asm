INCLUDE "common/gfx.h"

SECTION "LOGO BKG", ROMX
logoGfx::
	ld e, c
	ld d, b
	call removeActor
	
	ld hl, logo_tiles
	call loadTiles
	ld hl, logo_map
	call loadTiles
	ld hl, logo_attr
	jp loadTiles

logo_tiles:
	GFXTASK logo_tiles_data, $9000
logo_map:
	GFXTASK logo_map_data, $9800
logo_attr:
	GFXTASK logo_attr_data, $9801

align 4
logo_tiles_data:
	INCBIN "logo/gfx/tiles.bin"
	.end
logo_map_data:
	INCBIN "logo/gfx/map.bin"
	.end
logo_attr_data:
	INCBIN "logo/gfx/attr.bin"
	.end
