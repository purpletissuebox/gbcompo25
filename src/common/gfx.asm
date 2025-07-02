SECTION "GFX VARS", HRAM
redraw_screen::
	ds 1

SECTION "GFX MAP BUFFERS", WRAMX
shadow_bkg_map::
	ds $0400
shadow_win_map::
	ds $0400
shadow_bkg_attr::
	ds $0400
shadow_win_attr::
	ds $0400

SECTION "OAM BUFFER", WRAMX, ALIGN[8]
shadow_oam::
	ds $A0
	.end::

SECTION "GFX BUFFERS", WRAMX
shadow_scroll::
	ds 2
shadow_winloc::
	ds 2
