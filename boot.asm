; BasicOS Bootloader v1
; Created by Onelio
;

%include "fat16.asm"
[BITS 16]               ; 16bt Mode Processor
[ORG FAT.CodeSection] ; Jump FAT table data

; FUNCTION Main
; Main sector loader
; 
Main:
    mov     ax, 0x07C0  ; Set DS(0x07C0):XX
    mov     ds, ax      ; workaround inval op
    ; Stack register init
    xor     ax, ax
    mov     ss, ax
    mov     sp, 0x7C00  ; SS:SP 0x0000:0x7C00
    ; Save DriveId to mem
    mov     [DriveId], dl
    ; Print init messages
    call    VGA_Init
    mov     si, MG_INI
    call    Print
    ; Hard disk reset
    call    Disk_Reset
    ; I13 Extension check
    call    I13EXT_Check
    jnc     EXTSupported
    mov     si, MG_ESP
    call    Print
    call    Loop        ; Die if no supported

EXTSupported:
    ; Calculate RootSector
    EVAL_RootSector word[RootLBA]
    mov     ax, word[RootLBA]
    ; Calculate RootLength
    EVAL_RootLength word[RootLen]
    mov     ax, word[RootLen]

    ; Initialize DAP Packet
    ;
    mov     byte[FAT.DAP + DAP.Size], 0x10
    mov     word[FAT.DAP + DAP.Len], 0x1
    ; ES:BX
    mov     word[FAT.DAP + DAP.DestSegment], 0x07C0
    mov     word[FAT.DAP + DAP.DestOffset], FAT.SecondSector
    ; LBA
    mov     ax, word[RootLBA]
    mov     word[FAT.DAP + DAP.LBA], ax

    ; Set DAP and Drive
    mov     si, FAT.DAP
    mov     dl, byte[DriveId]
    call    Read
    jnc     Continue
    mov     si, MG_ELD
    call    Print
    mov     cx, 0x2D
    mov     dx, 0xC6C0
    call    Sleep
    call    Reboot

Continue:
    call    Loop

%include "io.asm"
; SYS VARS
DriveId     db 0x00
RootLBA     dw 0x0000
RootLen     dw 0x0000
; MG LIST DATA [13(\r) 10(\n) 0(\0)]
MG_INI      db " v Basic-Boot startup", 13, 10, 0
MG_ESP      db " * Bios not supported!", 13, 10, 0
MG_ELD      db " * Error reading sector. Rebooting...", 13, 10, 0
;Fill bytes with 0x00 up to magic numb
;Magic Number for the BIOS check.
times (510 - 0x003E - ($ - $$)) db 0x00  
    dw 0xAA55