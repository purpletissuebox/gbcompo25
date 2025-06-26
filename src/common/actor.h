EXPORT DEF ACTORSIZE EQU $0020

;init, process, variable
MACRO NEWACTOR
	IF _NARG == 3
		db (\3)
		db BANK(\2)
		dw (\2)
		dw (\1)
		db BANK(\1)
		db $FF
	ELIF _NARG == 2
		db (\2)
		db BANK(\1)
		dw (\1)
		dw $0000
		db $00
		db $FF
	ELSE
		db $00
		db BANK(\1)
		dw (\1)
		dw $0000
		db $00
		db $FF
	ENDC
ENDM
