EXPORT DEF ACTORSIZE EQU $0020

;init, process, variable
MACRO NEWACTOR
	db (\3)
	db BANK(\2)
	dw (\2)
	dw (\1)
	db BANK(\1)
	db $00
ENDM
