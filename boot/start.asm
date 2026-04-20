[BITS 32]
section .text
global start
extern kernel_main

start:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, stack_top
    call kernel_main
    cli
.hang:
    hlt
    jmp .hang

section .bss
stack_bottom:
    resb 16384
stack_top:
