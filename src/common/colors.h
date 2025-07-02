MACRO RGB5
	dw LOW(\3) << 10 | LOW(\2) << 5 | LOW(\1)
ENDM

MACRO RGB8
	RGB5( ROUND((\1)*31.0/255)>>16, ROUND((\2)*31.0/255)>>16, ROUND((\3)*31.0/255)>>16 )
ENDM

;num_colors, ptr to colors, fade time, obj flag
MACRO FADEENTRY
	IF(_NARG < 4)
		db (\1)
	ELIF \4 == "obj"
		db $80 | (\1)
	ELSE
		db (\1)
	ENDC
	
	FADESPEED \3
	dw (\2)
ENDM

MACRO FADESPEED
	  IF (\1) < -2.0
		($FF ^ (ROUND(-64.0   +DIV(-256.0, (\1))) >> 16))
	ELIF (\1) < -1.0
		db $FF ^ (ROUND( 32.0   +DIV( -64.0, (\1))) >> 16)
	ELIF (\1) < -0.5
		db $FF ^ (ROUND( 79.25  +DIV( -16.0, (\1))) >> 16)
	ELIF (\1) < 0.0
		db $FF ^ (ROUND(103.8125+DIV(  -4.0, (\1))) >> 16)
	ELIF (\1) < 0.5
		db        ROUND(103.8125+DIV(   4.0, (\1))) >> 16
	ELIF (\1) < 1.0
		db        ROUND( 79.25  +DIV(  16.0, (\1))) >> 16
	ELIF (\1) < 2.0
		db        ROUND( 32.0   +DIV(  64.0, (\1))) >> 16
	ELIF (\1) < 4.0
		db        ROUND(-64.0   +DIV( 256.0, (\1))) >> 16
	ENDC
ENDM
