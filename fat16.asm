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

; MACRO FIND_SystemFile
; Find file given a valid 11b len name in directory
; 3 Filename, Size, DES
%macro  FIND_SystemFile 3
    pusha
    ; ES:DI = Directory entry address
    mov     ax, ds
    mov     es, ax
    mov     di, %3
    ; DS:SI = Filename address
    mov     ax, %1
    mov     si, ax
Check_Entry:
    mov     cx, %2      ; Directory entries filenames are 11 bytes.
    repz cmpsb          ; Compare filename to memory.
    add     di, 0x15    ; Move to next entry. 32-11=0x15 (Just in case)
    jne     Check_Entry
    popa
%endmacro