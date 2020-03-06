; FUNCTION VGA_Init
; Initialize VGA video mode
; 
VGA_Init:
    pusha
    mov     ax, 0x03    ; 0x03 (80x25, 4-bit)
    int     0x10        ; Change video mode
    popa
    ret

; PROCEDURE Printb
; Prints hex number to screen
; AL number value
Printb:
    xor     ah, ah      ; Clear junk from ax

; FUNCTION Printw
; Prints hex number to screen
; AX number value
Printw:
    pusha
    mov     di, HX_STR  ; Temp store pointer
    mov     si, HX_LST  ; Keep Char List
    mov     cx, 4
    .PRINTHLOOP:
    rol     ax, 4       ; move to left by 4
    mov     bx, ax      ; copy to edit
    and     bx, 0x0f    ; get index
    mov     bl, [si + bx]
    mov     [di], bl
    inc     di
    dec     cx
    jnz     .PRINTHLOOP
    mov     si, HX_PRF
    call    Print
    popa
    ret

; PROCEDURE Printe
; Prints an endl
;
Printe:
    mov     si, HX_JMP

; FUNCTION Print
; Print Text to screen using BIOS int 0x10 in Real Mode
; SI ptr message
Print:
    pusha
    mov     ah, 0x0E
    .PRINTLOOP:
    lodsb               ; [DS:SI] to al, inc si
    cmp     al, 00h
    jz      .PRINTEND
    int     0x10
    jmp     .PRINTLOOP
    .PRINTEND:
    popa
    ret

; FUNCTION Loop
; Forever loop system
;
Loop:
    jmp     Loop

; STR LIST DATA
HX_PRF      db "0x"
HX_STR      db "0000", 0
HX_LST      db '0123456789ABCDEF'
HX_JMP      db 13, 10, 0