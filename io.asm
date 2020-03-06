; STRUCTURE DAP (Disk Address Packet)
struc DAP
    .Size:          resb 1
    .Reserved:      resb 1
    .Len:           resw 1
    .DestOffset:    resw 1
    .DestSegment:   resw 1
    .LBA:           resd 1
endstruc

; FUNCTION VGA_Init
; Initialize VGA video mode
; 
VGA_Init:
    pusha
    mov     ax, 0x03    ; 0x03 (80x25, 4-bit)
    int     0x10        ; Change video mode
    popa
    ret

; FUNCTION Printb
; Prints hex byte to screen
; AL number value
Printb:
    xor     ah, ah      ; Clear junk from ax

; FUNCTION Printw
; Prints hex word to screen
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

; FUNCTION Sleep
; Waits the desgined time
; (CX HiWord, DX LoWord) Microseconds 1M=1Sec
Sleep:
    mov     ah, 0x86    ; Specify 0x15 WAIT
    int     0x15
    ret

; FUNCTION Disk_Reset
; Reset disk position
; 
Disk_Reset:
    pusha
    xor     ah, ah
    int     0x13
    popa
    ret

; FUNCTION I13EXT_Check
; Check if INT13 extensions are available
; DL DriveId
I13EXT_Check:
    pusha
    mov     ah, 41h
    mov     bx, 55AAh
    int     13h
    popa
    ret

; FUNCTION Read
; Read from drive
; DL DriveId
; AX DAP
;
; output:   cf (0 = success, 1 = failure)
Read:
    pusha
    mov     ah, 0x42
    int     0x13
    popa
    ret

; FUNCTION Reboot
; Reboot the entire system
;
Reboot:
    int     0x19        ; Reboot Services

; FUNCTION Loop
; Forever loop system
;
Loop:
    jmp     Loop

; STR LIST DATA
HX_PRF      db "0x"
HX_STR      db "0000", 0
HX_LST      db '0123456789ABCDEF'