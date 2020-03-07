[BITS 16]
[ORG 0x8400]
Main:
    mov     ah, 0x0E
    mov     si, MG_INI
Repeat:
    lodsb
    cmp     al, 00h
    jz      Loop
    int     0x10
    jmp     Repeat

Loop:
    jmp    Loop

MG_INI db "- Kernel Loaded!", 13, 10, 0

JUNK2 db "Although the changes in the previous section will eliminate the warnings during linking, when run things may not work as expected (including crashes). On an 80386+ you can generate 16-bit real mode code that uses 32-bit addresses for the data but the CPU has to be put into a mode that allows such access. The mode that allows 32-bit pointers accessed via the DS segment with values above 0xFFFF is called Unreal Mode. OSDev Wiki has some code that could be used as a basis for such support. Assuming the PICs haven't been remapped and are in their initial configuration then the usual way to implement on demand Unreal Mode is to replace the 0x0d Interrupt handler with something that does"
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       ; Up till this point