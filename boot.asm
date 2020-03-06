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
    mov     ax, 0x07C0  ; Set DS(0x07C0):XX
    mov     ds, ax      ; workaround inval op
    ; Stack register init
    xor     ax, ax
    mov     ss, ax
    mov     sp, 0x7C00  ; SS:SP 0x0000:0x7C00
    ; Save driveid to mem
    mov     [DriveId], dl
    ; Print init messages
    call    VGA_Init
    mov     si, MG_INI
    call    Print

    mov     ax, FATST.SecondSector
    call    Printw
    call    Printe

    EVAL_RootSector word[RootLBA]
    mov     ax, word[RootLBA]
    call    Printw
    call    Printe

    EVAL_RootLength word[RootLen]
    mov     ax, word[RootLen]
    call    Printw
    call    Printe

    mov     ax, 0x1234
    call    Printw

    EVAL_LBA2CHS word[RootLBA]
    mov     ax, 0x07C0
    mov     es, ax
    mov     bx, FATST.SecondSector
    mov     dl, byte[DriveId]
    mov     al, 0x1
    mov dh, 0x0
    mov cx, 0x1
    call    Read
    jnc     Continue
    mov     si, MG_ELD
    call    Print

Continue:
    call    Loop

%include "io.asm"
; SYS VARS
DriveId     db 0x00
RootLBA     dw 0x0000
RootLen     dw 0x0000
; MG LIST DATA [13(\r) 10(\n) 0(\0)]
MG_INI      db " v Basic-Boot startup", 13, 10, 0
MG_ELD      db " * Unable to read sector!", 13, 10, 0
;Fill bytes with 0x00 up to magic numb
;Magic Number for the BIOS check.
times (510 - 0x003E - ($ - $$)) db 0x00  
    dw 0xAA55