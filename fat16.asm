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
    .DataArea:          resb 496
endstruc

; STRUCTURE DES (Directory Entry Structure)
struc DES
    .FileName:      resb 8
    .Extension:     resb 3
    .Attribute:     resb 1
    .Reserved:      resb 1
    .Creation:      resb 5
    .LastAccess:    resw 1
    .Reserved2:     resw 1
    .LastChange:    resd 1
    .Cluster:       resw 1
    .FileSize:      resd 1
endstruc

; DEFINITION Kernel Load Address
; 0xF7C0 * 0x10 + 0x8400 = 0x100000
%define KRNL_LoadSegmnt 0x07C0
%define KRNL_LoadOffset 0x8400

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
; Calculate lenght in sectors of root directory
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

; MACRO EVAL_KernSector
; Calculate start sector of kernel file
; RootSector + RootLength + KernCluster - 2
; 4 KernDES, RootLBA, RootLen, Destination
%macro  EVAL_KernSector 4
    pusha
    mov     bx, %1
    mov     ax, [bx + DES.Cluster]
    add     ax, %2
    add     ax, %3
    sub     ax, 2
    mov     %4, ax
    popa
%endmacro

; MACRO EVAL_KernLength
; Calculate lenght in sectors of root directory
; FileSize(B) / BytesPerSector + 1
; 2 KernDES, Destination
%macro  EVAL_KernLength 2
    pusha
    mov     bx, %1
    mov     eax, [bx + DES.FileSize]
    xor     dx, dx      ; To divide DX:AX/
    div     word[FAT.BytesPerSector]
    add     ax, 0x01
    mov     %2, ax
    popa
%endmacro

; MACRO FIND_SystemFile
; Find file given a valid 11b len name in directory
; 4 Filename, Size, DESListItem, DESKRNItem
%macro  FIND_SystemFile 4
    pusha
    ; ES:BX(DI) = Directory entry address
    mov     ax, ds
    mov     es, ax
    mov     bx, %3
Check_DES:
    mov     cx, %2      ; Directory entries filenames size
    mov     si, %1      ; Valid Filename address (DS:SI)
    mov     di, bx
    repz cmpsb
    add     bx, 0x20    ; Move to next DES if not valid
    cmp     cx, 0x00
    jne     Check_DES
    sub     bx, 0x20
    mov     %4, bx
    popa
%endmacro