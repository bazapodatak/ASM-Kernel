section .text
global video_clear, video_print, video_putchar

video_clear:
    pusha
    mov edi, 0xB8000
    mov ecx, 2000
    mov ax, 0x0720
    rep stosw
    popa
    ret

video_print:
    pusha
    mov edi, [cursor]
.loop:
    lodsb
    test al, al
    jz .done
    cmp al, 10
    je .newline
    mov ah, 0x07
    stosw
    jmp .loop
.newline:
    mov eax, edi
    sub eax, 0xB8000
    mov ecx, 160
    div ecx
    inc eax
    mul ecx
    add eax, 0xB8000
    mov edi, eax
    jmp .loop
.done:
    mov [cursor], edi
    popa
    ret

video_putchar:
    pusha
    mov edi, [cursor]
    cmp al, 10
    je .newline
    cmp al, 8
    je .backspace
    mov ah, 0x07
    stosw
    mov [cursor], edi
    jmp .done
.newline:
    mov eax, edi
    sub eax, 0xB8000
    mov ecx, 160
    div ecx
    inc eax
    mul ecx
    add eax, 0xB8000
    mov [cursor], eax
    jmp .done
.backspace:
    cmp edi, 0xB8000
    je .done
    sub edi, 2
    mov word [edi], 0x0720
    mov [cursor], edi
.done:
    popa
    ret

section .data
cursor dd 0xB8000
