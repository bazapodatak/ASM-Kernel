#!/bin/bash

echo "Building My ASM Kernel..."

# Clean old files
rm -f build/obj/*.o
rm -f kernel.bin

# Assemble all files
echo "Assembling boot files..."
nasm -f elf32 boot/multiboot.asm -o build/obj/multiboot.o
nasm -f elf32 boot/boot.asm -o build/obj/boot.o

echo "Assembling kernel files..."
nasm -f elf32 kernel/main.asm -o build/obj/main.o
nasm -f elf32 kernel/screen.asm -o build/obj/screen.o
nasm -f elf32 kernel/gdt.asm -o build/obj/gdt.o
nasm -f elf32 kernel/idt.asm -o build/obj/idt.o
nasm -f elf32 kernel/isr.asm -o build/obj/isr.o
nasm -f elf32 kernel/timer.asm -o build/obj/timer.o
nasm -f elf32 kernel/keyboard.asm -o build/obj/keyboard.o

# Link
echo "Linking..."
ld -m elf_i386 -T build/linker.ld -o kernel.bin build/obj/*.o

if [ $? -eq 0 ]; then
    echo "✓ Build successful!"
    
    # Create ISO
    echo "Creating ISO..."
    cp kernel.bin iso/boot/
    
    cat > iso/boot/grub/grub.cfg << EOF
set timeout=0
set default=0

menuentry "My ASM Kernel" {
    multiboot /boot/kernel.bin
    boot
}
EOF
    
    grub-mkrescue -o kernel.iso iso/ 2>/dev/null
    
    echo "✓ Done!"
    echo ""
    echo "To run:"
    echo "  qemu-system-i386 -kernel kernel.bin"
    echo "  qemu-system-i386 -cdrom kernel.iso"
else
    echo "✗ Build failed!"
    exit 1
fi
