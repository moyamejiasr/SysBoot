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