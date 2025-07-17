SECTION "JOYPAD", ROMX
readJoystick::

	ld hl, joypad_data ; point to input vars

    ;get the raw dpad data and store it in vars    
    ld a, JOYPAD_A
    ; Try 6 clocks for debounce
    ldh a, [IO_JOYPAD]
    ldh a, [IO_JOYPAD]

    ld c, a
    ; data likes to get stuck if not cleared
    ; skill issue likely, but do not want to fix 

    ;get the raw bton data 
    ld [IO_JOYPAD], a 
    ; 18 Clocks of debounce for btons
    ldh a, [IO_JOYPAD]
    ldh a, [IO_JOYPAD]
    ldh a, [IO_JOYPAD]
    ldh a, [IO_JOYPAD]
    ldh a, [IO_JOYPAD]
    ldh a, [IO_JOYPAD]
    ld b, a 


    ; shuffle data into a
    ; a = low_nibble(b), low_nibble(c)
    ld a, b 
    and 0x0F
    swap a 
    ld b, a 
    ld a, c 
    and 0x0F
    or b
    cpl 

    ld [hl], a

	ret 

bootstrapActors:: 
    ld hl, ACTORSIZE-2

    add hl, bc 
    xor a 
    ldi [hl], a 
    ld [hl], a 
    ret