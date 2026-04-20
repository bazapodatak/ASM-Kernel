[BITS 16]
[ORG 0x7C00]
start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    mov si, msg
    call print
    mov ah, 0x02
    mov al, 18
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0
    mov bx, 0x1000
    mov es, bx
    xor bx, bx
    int 0x13
    jc error
    jmp 0x1000:0x0000
error:
    mov si, err_msg
    call print
    jmp $
print:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print
.done:
    ret
msg db "Loading kernel...", 13, 10, 0
err_msg db "Error!", 0
times 510-($-$$) db 0
dw 0xAA55
