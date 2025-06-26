SECTION "JOYPAD", ROMX
readJoystick::
	
	ld hl, inputs ; point to input vars

    ;get the raw dpad data and store it in vars    
    ld a, 0x10 ; enable button input
    ld [$FF00], a
    ld a, [$FF00]
    ld c, a
    ; data likes to get stuck if not cleared
    ; skill issue likely, but do not want to fix 
    ld a, 0x00
    ld [$FF00], a 

    ;get the raw bton data 
    ld a, 0x20
    ld [$FF00], a 
    ld a, [$FF00]
    ld b, a 

    ld a, 0x00
    ld [$FF00], a 
    
    ; shuffle data into a
    ; a = low_nibble(b), low_nibble(c)
    ld a, c 
    and 0x0F 
    
    ld d, b
    ld a, d 
    and 0x0F
    swap a 
    ld d, a 
    ld a, c 
    and 0x0F
    or d
    cpl ; 1 = on/pressed

    ld [hl], a

	ret