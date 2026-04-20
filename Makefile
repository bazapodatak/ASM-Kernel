all:
	nasm -f bin kernel.asm -o kernel.bin

shell:
	nasm -f bin shell.asm -o kernel.bin

run:
	qemu-system-i386 -kernel kernel.bin

clean:
	rm -f kernel.bin

.PHONY: all shell run clean
