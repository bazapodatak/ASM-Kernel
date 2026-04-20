section .text
global keyboard_init
global keyboard_handler_main
extern video_putchar

keyboard_init:
    in al, 0x21
    and al, 0xFD
    out 0x21, al
    ret

keyboard_handler_main:
    pusha
    in al, 0x60
    test al, 0x80
    jnz .done
    movzx ebx, al
    mov al, [scancodes + ebx]
    test al, al
    jz .done
    call video_putchar
.done:
    popa
    ret

scancodes:
    db 0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0
    db 0, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0
    db 0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '`', 0
    db '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0
    times 256 db 0
