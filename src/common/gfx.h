INCLUDE "hwregs.h"

;src, dest
;src, dest, size
;src, off, dest, off
;src, off, dest, off, size

MACRO GFXTASK
	db BANK(\1)
	IF _NARG >= 4
		dw (\1 + \2) | (BANK(\1) & $07)
		dw (\3 + \4) | BANK(\3)
	ELSE
		dw (\1) | (BANK(\1) & $07)
		IF STRSUB("\2", 1, 1) == "$"
			dw (\2)
		ELSE
			dw (\2) | BANK(\2)
		ENDC
	ENDC
	
	IF (_NARG & 1) == 0
		db ((\1.end - \1) >> 4)-1
	ELIF _NARG == 3
		db (\3) - 1
	ELSE
		db (\5) - 1
	ENDC
ENDM

MACRO waitVRAM
	.mode3\@:
		ldh a, [IO_LCD_STATUS]
		inc a
		and PPU_MODE
	jr nz, .mode3\@
	.mode0\@:
		ldh a, [IO_LCD_STATUS]
		and PPU_MODE
	jr nz, .mode0\@
ENDM
