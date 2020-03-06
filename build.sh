# Stop on error
set -e

# Build binaries
nasm -fbin boot.asm -o bin/boot.bin
nasm -fbin kernel.asm -o bin/kernel.bin

# Create disk image fs
dd if=/dev/zero of=bin/system.iso bs=1M count=10
mkfs.vfat -v -n FAT16 -F16 bin/system.iso

# Port kernel to root
mcopy -i bin/system.iso bin/kernel.bin ::kernel.bin

# Copy bootloader code
dd bs=1 conv=notrunc if=bin/boot.bin of=bin/system.iso seek=62

# Remove bin data
rm bin/boot.bin
rm bin/kernel.bin