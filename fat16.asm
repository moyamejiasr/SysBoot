; STRUCTURE FAT16 (File Allocation Table)
struc FAT
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
    .DAP:               resb 16
    .SecondSector:      resb 496
endstruc

; MACRO EVAL_RootSector
; Calculate start sector of root directory
; FATCopies * SectorsPerFAT + Reserved + Hidden
; 1 Destination
%macro  EVAL_RootSector 1
    pusha
    xor     ax, ax
    mov     al, byte[FAT.FATCopies]
    mul     word[FAT.SectorsPerFAT]
    add     eax, dword[FAT.HiddenSectors]
    add     ax, word[FAT.ReservedSectors]
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
    mul     word[FAT.RootDirEntries]
    xor     dx, dx      ; To divide DX:AX/
    div     word[FAT.BytesPerSector]
    mov     %1, ax
    popa
%endmacro