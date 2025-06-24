#pragma bank 255

const u8 vwf_fontdata[26][16];
const u8 vwf_lettersizes[26];
u8 tilebuf[63];
u8 next_open_px = 0;
u8 active_tile = ((int)(tilebuf) + 31)&0xE0;

void vwfPrint(u8 first_tile, u8 *s)
{
    first_tile;
    __asm
        dec a
        ldh (_scratch), a
    __endasm
    while (*s) vwfPrintLetter(*s++);
}

void vwfPrintLetter(u8 letter) __naked
{
    letter;
    __asm
        ld e, a
        swap a
        add #<(_vwf_fontdata)
        ld c, a
        adc #>(_vwf_fontdata)
        sub c
        ld b, a

        ld hl, #_next_open_px
        ld a, (hl+)
        ld l, (hl)
        ld h, #>(_tilebuf + 31)
        ld d, a
        push de
        cpl
        inc a
        and #7
        
        sub #4
        jr c, VWFPRINTLETTER_BIG
        add #2
        adc #3
        jr VWFPRINTLETTER_DAA
        VWFPRINTLETTER_BIG:
        add #254
        adc 3
        swap a
        VWFPRINTLETTER_DAA:
        add a
        daa
        rra
        dec a
        ld e, a

        VWFPRINTLETTER_LOOP:
            ld a, (bc)
                inc bc
                ld d, a
                ld a, (bc)
                inc bc
                push bc

                push hl
                ld l, d
                ld h, a
                xor a
                bit 0, e
                jr z, VWFPRINTLETTER_SKIPSHIFT
                ld d, e
                VWFPRINTLETTER_DOSHIFT:
                    add hl, hl
                    rla
                    rr d
                    jr nc, VWFPRINTLETTER_DOSHIFT
                VWFPRINTLETTER_SKIPSHIFT:
                ld c, l
                ld b, h
                pop hl

                or (hl)
                ld (hl+), a
                ld a, b
                and e
                or (hl)
                ld (hl-), a
                ld a, l
                xor #16
                ld l, a

                ld a, e
                cpl
                and b
                ld (hl+), a
                ld a, c
                ld (hl+), a
                ld a, l
                xor #16
                ld l, a

                pop bc
                and #15
            jr nz, VWFPRINTLETTER_LOOP

        pop de
        ld a, e
        add #<(_vwf_lettersizes)
        ld c, a
        adc #>(_vwf_lettersizes)
        sub c
        ld b, a
        ld a, (bc)

        ld hl, _next_open_px
        add d
        and #7
        ld (hl+), a
        inc d
        sub d
        ret nc

        ld a, (hl)
        ld c, a
        ld b, #>(_tilebuf + 31)
        xor #16
        ld (hl), a
        ldh a, (_scratch)
        inc a
        ldh (_scratch), a
        ld e, #1
        push bc
        jp _set_bkg_data
    __endasm;
}
    u16 *tile = vwf_fontdata[letter];
    u8 *print = tilebuf[active_tile];

    u8 shift_amt = ~next_open_px & 7;
    u8 mask = (1 << shift_amt) - 1;

    u32 shift_buf;
    u8 i, *p;

    for (i = 0; i < 8; i++)
    {
        shift_buf = *tile++ << shift_amt;
        p = shift_buf + 2;

        *print++ |= *p--;
        *print-- |= *p & mask;
        print ^= 16;
        *print++ = *p-- & ~mask;
        *print++ = *p;
    }

    next_open_px += vwf_lettersizes[letter];
    if (next_open_px & 8)
    {
        next_open_px &= 7;
        Send2VRAM(tilebuf[active_tile]);
        active_tile ^= 1;
    }
}