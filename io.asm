; STRUCTURE DAP (Disk Address Packet)
struc DAP
    .Size:          resb 1
    .Reserved:      resb 1
    .Len:           resw 1
    .DestOffset:    resw 1
    .DestSegmnt:    resw 1
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
    xor     ah, ah
    int     0x13
    ret

; FUNCTION I13EXT_Check
; Check if INT13 extensions are available
; DL DriveId
I13EXT_Check:
    mov     ah, 41h
    mov     bx, 55AAh
    int     13h
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

; FUNCTION A20_Init
; Initialize A20 Line for full Real-mode memory access
; 
A20_Init:
    pusha
    mov     ax, 0x2401
    int     0x15
    popa
    ret

; FUNCTION Reboot
; Reboot the entire system
;
Reboot:
    int     0x19        ; Reboot Services

; FUNCTION Loop
; Loop forever
;
Loop:
    jmp     Loop