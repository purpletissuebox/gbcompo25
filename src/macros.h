MACRO ldsz
	ld \1, (\2.end - \2)
ENDM

MACRO lddouble
	ld \1, (LOW(\2) << 8) | LOW(\3)
ENDM

MACRO swapInRom
	ldh a, [rom_bank]
	push af
	IF STRSUB("\1", 1, 1) == "["
		ld a, \1
	ELSE
		ld a, BANK(\1)
	ENDC
	ldh [rom_bank], a
	ld [MBC_ROM_BANK], a
ENDM

MACRO swapInRam
	ldh a, [ram_bank]
	push af
	ld a, BANK(\1)
	ldh [ram_bank], a
	ldh [IO_WRAM_BANK], a
ENDM

MACRO restoreBankRom
	pop af
	ldh [rom_bank], a
	ld [MBC_ROM_BANK], a
ENDM

MACRO restoreBankRam
	pop af
	ldh [ram_bank], a
	ldh [IO_WRAM_BANK], a
ENDM
