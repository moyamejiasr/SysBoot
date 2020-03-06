[BITS 16]

;SysIO Functions load
    jmp     Main
%include "io.asm"

Main:
    lea     si,[MG_INI]
    call    Print

    call    Loop

MG_INI db " - OK!", 13, 10, 0

;Fill bytes with 0x00 up to end sector
times (512 - ($ - $$)) db 0x00