SECTION "GLOBALS COMMON", HRAM
rom_bank:: ds 1
ram_bank:: ds 1
vram_bank:: ds 1
scratch:: ds 1

ENDSECTION
; input variables, aligned like input data
; 8 bytes, going to through them all in 1 block
SECTION "INPUT DATA", HRAM[$FF81]
EXPORT inputs
inputs::
    input_down:: ds 1
    input_up:: ds 1
    input_left:: ds 1
    input_right:: ds 1
    input_a:: ds 1
    input_b:: ds 1
    input_select:: ds 1
    input_start:: ds 1
ENDSECTION