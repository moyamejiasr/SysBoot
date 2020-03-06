; STRUCTURE FAT16 (File Allocation Table)
struc FATST
    .JumpInstruction:   resb 3
    .OEMIdentifier:     resb 8
    .BytesPerSector:    resw 1
    .SectorsPerCluster: resb 1
    .ReservedSectors:   resw 1
    .FATCopies:         resb 1
    .RootDirEntries:    resw 1
    .NumSectors:        resw 1
    .MediaType:         resb 1
    .SectorsPerFAT:     resw 1
    .SectorsPerTrack:   resw 1
    .NumberOfHeads:     resw 1
    .HiddenSectors:     resd 1
    .SectorsBig:        resd 1
    ; Extended BPB (DOS 4.0)
    .DriveNumber:       resb 1
    .WinNTBit:          resb 1
    .Signature:         resb 1
    .VolumeID:          resd 1
    .VolumeIDString:    resb 11
    .SystemIDString:    resb 8
    ; After FAT16 table
    ;
    .CodeSection:       resb 448
    .SectorCheck:       resb 2
    ; Second sector (FREE)
    ;
    .SecondSector:      resb 1
endstruc

; MACRO EVAL_RootSector
; Calculate start sector of root directory
; FATCopies * SectorsPerFAT + Reserved + Hidden
; 1 Destination
%macro  EVAL_RootSector 1
    pusha
    xor     ax, ax
    mov     al, byte[FATST.FATCopies]
    mul     word[FATST.SectorsPerFAT]
    add     eax, dword[FATST.HiddenSectors]
    add     ax, word[FATST.ReservedSectors]
    mov     %1, ax
    popa
%endmacro

; MACRO EVAL_RootLength
; Calculate size in bytes of root directory
; (RootDirEntries * 0x20) / BytesPerSector
; 1 Destination
%macro  EVAL_RootLength 1
    pusha
    mov     ax, 0x20
    mul     word[FATST.RootDirEntries]
    xor     dx, dx      ; To divide DX:AX/
    div     word[FATST.BytesPerSector]
    mov     %1, ax
    popa
%endmacro

; MACRO EVAL_LBA2CHS
; This routine converts LBA (edx:eax) to CHS
; Sector   = (LBA mod SPT)+1
; Head     = (LBA  /  SPT) mod Heads
; Cylinder = (LBA  /  SPT)  /  Heads
;     (SPT = Sectors per Track)
;     (LBA = Logical Block Address (AX))
%macro  EVAL_LBA2CHS 1
    mov     ax, %1
    ; (LBA / SPT)
    xor     dx,dx       ; because dx:ax / cx
    mov     cx, word[FATST.SectorsPerTrack]
    div     cx
    push    dx
    ; (Result / Heads)
    xor     dx, dx      ; because dx:ax / cx
    mov     cx, word[FATST.NumberOfHeads]
    div     cx
    ; Sector + 1
    pop     cx          ; cx = sector
    inc     cx          ; cause one based

    ; Current register values:
    ; cx = sector (1 based)
    ; dx = head
    ; ax = cyl
    ; We need:
    ;  ch = low eight bits of cylinder number
    ;  cl = sector number 1-63 (bits 0-5)
    ;     = high two bits of cylinder (bits 6-7, hard disk only)
    ;  dh = head number
    mov     dh, dl      ; dh = head
    mov     ch, al      ; ch = low 8 bits of cyl
    shl     ah, 6       ; set hi 2 bits of cyl in cl
    or      cl, ah    
%endmacro