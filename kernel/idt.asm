section .text
global idt_init, pic_remap
global keyboard_handler_stub
extern keyboard_handler_main

idt_init:
    mov edi, idt
    mov ecx, 256
    mov eax, 0
.fill:
    mov eax, dummy_handler
    mov bx, 0x08
    mov dx, 0x8E00
    mov [edi], ax
    mov [edi+2], bx
    mov [edi+4], dx
    shr eax, 16
    mov [edi+6], ax
    add edi, 8
    loop .fill
    
    mov edi, idt + 33*8
    mov eax, keyboard_handler_stub
    mov bx, 0x08
    mov dx, 0x8E00
    mov [edi], ax
    mov [edi+2], bx
    mov [edi+4], dx
    shr eax, 16
    mov [edi+6], ax
    
    lidt [idt_desc]
    ret

pic_remap:
    mov al, 0x11
    out 0x20, al
    out 0xA0, al
    mov al, 0x20
    out 0x21, al
    mov al, 0x28
    out 0xA1, al
    mov al, 0x04
    out 0x21, al
    mov al, 0x02
    out 0xA1, al
    mov al, 0x01
    out 0x21, al
    out 0xA1, al
    ret

dummy_handler:
    pusha
    mov al, 0x20
    out 0x20, al
    popa
    iret

keyboard_handler_stub:
    pusha
    call keyboard_handler_main
    mov al, 0x20
    out 0x20, al
    popa
    iret

section .data
idt times 256*8 db 0
idt_desc:
    dw 256*8 - 1
    dd idt
