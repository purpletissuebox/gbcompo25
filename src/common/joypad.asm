SECTION "JOYPAD", ROMX
readJoystick::
	ret

bootstrapActors::
	ld hl, ACTORSIZE-2
	add hl, bc
	xor a
	ldi [hl], a
	ld [hl], a
	ret
