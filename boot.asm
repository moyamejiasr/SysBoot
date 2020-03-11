; SysBoot v1.0
;

%include "fat16.asm"
[BITS 16]               ; 16bt Mode Processor
[ORG FAT.CodeSection]   ; Jump FAT table data

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
    mov     si, MG_INIT
    call    Print
    ; I13 Extension check & init packet
    mov     byte[FAT.DAP + DAP.Size], 0x10
    mov     word[FAT.DAP + DAP.DestSegmnt], 0x07C0
    call    I13EXT_Check
    jc      OnNotSupported
    ; Enable A20 Line (if supported)
    call    A20_Init
    jc      OnNotSupported

    ; Calculate Root values
    EVAL_RootSector word[RootLBA] ; Starting sector (LBA)
    EVAL_RootLength word[RootLen] ; Size in sectors
    ; Modify DAP-Packet : Load Root Directory
    call    Disk_Reset
    mov     word[FAT.DAP + DAP.DestOffset], FAT.DataArea
    ; LBA && Length
    mov     ax, word[RootLBA]
    mov     word[FAT.DAP + DAP.LBA], ax
    mov     ax, word[RootLen]
    mov     word[FAT.DAP + DAP.Len], ax
    ; Set DAP and Drive
    mov     si, FAT.DAP
    call    Read
    jc      OnReadFail

    ; Find file
    ; Assuming kernel.bin IS present
    FIND_SystemFile KRNFILE, 11, FAT.DataArea, word[DESItem]

    ; Calculate Kernel values
    ; Assuming file sectors are one after the other
    mov     word[FAT.DAP + DAP.DestSegmnt], 0x07C0
    EVAL_KernSector [DESItem], [RootLBA], [RootLen], word[KrnlLBA] ; Starting sector (LBA)
    EVAL_KernLength [DESItem], word[KrnlLen] ; Size in sectors
    ; Modify DAP-Packet
    call    Disk_Reset
    mov     word[FAT.DAP + DAP.DestOffset], KRNL_LoadOffset
    ; LBA && Length
    mov     ax, word[KrnlLBA]
    mov     word[FAT.DAP + DAP.LBA], ax
    mov     ax, word[KrnlLen]
    mov     word[FAT.DAP + DAP.Len], ax
    ; Set DAP and Drive
    mov     si, FAT.DAP
    call    Read
    jc      OnReadFail

    ; Jump to kernel
    jmp     KRNL_LoadSegmnt:KRNL_LoadOffset

OnNotSupported:
    mov     si, MG_ESPT
    call    Print
    call    Loop        ; Die if no supported

OnReadFail:
    mov     si, MG_ERDN
    call    Print
    mov     cx, 0x2D
    mov     dx, 0xC6C0
    call    Sleep
    call    Reboot

%include "io.asm"
; VAR DATA
DriveId     db 0x00     ; Boot drive ID
RootLBA     dw 0x0000   ; Root logical block address (sectors)
RootLen     dw 0x0000   ; Root length (sectors)
DESItem     dw 0x0000   ; Valid Kernel DES entry
KrnlLBA     dw 0x0000   ; Kernel logical block address (sectors)
KrnlLen     dw 0x0000   ; Kernel length (sectors)
; CST DATA
KRNFILE     db "KERNEL  BIN"
; MG LIST DATA [13(\r) 10(\n) 0(\0)]
MG_INIT     db "- SysBoot v1.0 init", 13, 10, 0
MG_ESPT     db "X Not supported", 13, 10, 0
MG_ERDN     db "X Error while reading", 13, 10, "- Rebooting..", 0
; Fill bytes with 0x00 up to magic numb
; Magic Number for the BIOS check.
times (510 - 0x003E - ($ - $$)) db 0x00  
    dw 0xAA55