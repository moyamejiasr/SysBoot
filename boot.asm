; BasicOS Bootloader v1
; Created by Onelio
;

%include "fat16.asm"
[BITS 16]               ; 16bt Mode Processor
[ORG FATST.CodeSection] ; Jump FAT table data

; FUNCTION Main
; Main sector loader
; 
Main:
    mov     ax, 07C0h   ; Set DS(07C0h):XX
    mov     ds, ax      ; workaround inval op
    ; Stack register init
    xor     ax, ax
    mov     ss, ax
    mov     sp, 7C00h   ; SS:SP 0x0000:0x7C00
    ; Save driveid to mem
    mov     [DriveId], dl
    ; Print init messages
    call    VGA_Init
    lea     si, [MG_INI]
    call    Print

    mov     ax, FATST.SecondSector
    call    Printw
    call    Printe

    mov     ax, 0x1234
    call    Printw

Continue:
    call    Loop

%include "io.asm"
; SYS VARS
DriveId     db 0x00
; MG LIST DATA [13(\r) 10(\n) 0(\0)]
MG_INI      db " v Basic-Boot startup", 13, 10, 0
;Fill bytes with 0x00 up to magic numb
;Magic Number for the BIOS check.
times (510 - 0x003E - ($ - $$)) db 0x00  
    dw 0xAA55