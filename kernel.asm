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

; Fill with junk for testing
times 1024 db 0xFF