;==========================================
; FULL SHELL KERNEL
;==========================================

[BITS 32]
org 0x100000

align 4
    dd 0x1BADB002
    dd 0x03
    dd -(0x1BADB002 + 0x03)

start:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000
    mov ebp, esp
    
    ; Clear screen
    mov edi, 0xB8000
    mov ecx, 2000
    mov ax, 0x0720
    rep stosw
    
    call setup_idt
    call setup_pic
    sti
    
    call shell
    
    hlt

shell:
    mov esi, banner
    mov edi, 0xB8000
    call print
    
.prompt:
    mov esi, prompt_str
    mov edi, [cursor]
    call print
    
    ; Read command
    mov edi, cmd_buffer
    call readline
    
    ; Parse command
    mov esi, cmd_buffer
    
    ; Check "help"
    mov edi, cmd_help
    call compare
    cmp eax, 0
    je .help
    
    ; Check "clear"
    mov esi, cmd_buffer
    mov edi, cmd_clear
    call compare
    cmp eax, 0
    je .clear
    
    ; Check "info"
    mov esi, cmd_buffer
    mov edi, cmd_info
    call compare
    cmp eax, 0
    je .info
    
    ; Unknown
    mov esi, unknown
    mov edi, [cursor]
    call print
    jmp .prompt
    
.help:
    mov esi, help_text
    mov edi, [cursor]
    call print
    jmp .prompt
    
.clear:
    mov edi, 0xB8000
    mov ecx, 2000
    mov ax, 0x0720
    rep stosw
    mov dword [cursor], 0xB8000
    jmp .prompt
    
.info:
    mov esi, info_text
    mov edi, [cursor]
    call print
    jmp .prompt

readline:
    pusha
    xor ecx, ecx
.rl:
    call getchar
    cmp al, 13
    je .done
    cmp al, 8
    je .bs
    stosb
    inc ecx
    jmp .rl
.bs:
    cmp ecx, 0
    je .rl
    dec edi
    dec ecx
    jmp .rl
.done:
    mov byte [edi], 0
    popa
    ret

getchar:
    push ebx
.gc:
    mov eax, [buf_head]
    cmp eax, [buf_tail]
    je .gc
    mov ebx, [buf_tail]
    mov al, [kb_buffer + ebx]
    inc ebx
    cmp ebx, 256
    jl .nw
    xor ebx, ebx
.nw:
    mov [buf_tail], ebx
    ; Echo
    pusha
    mov edi, [cursor]
    mov ah, 0x0F
    stosw
    mov [cursor], edi
    popa
    pop ebx
    ret

print:
    pusha
.pl:
    lodsb
    test al, al
    jz .pd
    mov ah, 0x07
    stosw
    jmp .pl
.pd:
    mov [cursor], edi
    popa
    ret

compare:
.lp:
    mov al, [esi]
    mov bl, [edi]
    cmp al, bl
    jne .ne
    test al, al
    jz .eq
    inc esi
    inc edi
    jmp .lp
.eq:
    mov eax, 0
    ret
.ne:
    mov eax, 1
    ret

setup_idt:
    mov edi, idt
    mov ecx, 256
.f:
    mov eax, dummy
    mov bx, 0x08
    mov dx, 0x8E00
    mov [edi], ax
    mov [edi+2], bx
    mov [edi+4], dx
    shr eax, 16
    mov [edi+6], ax
    add edi, 8
    loop .f
    
    mov edi, idt + 33*8
    mov eax, keyboard
    mov bx, 0x08
    mov dx, 0x8E00
    mov [edi], ax
    mov [edi+2], bx
    mov [edi+4], dx
    shr eax, 16
    mov [edi+6], ax
    
    lidt [idt_desc]
    ret

setup_pic:
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
    mov al, 0xFD
    out 0x21, al
    ret

dummy:
    pusha
    mov al, 0x20
    out 0x20, al
    popa
    iret

keyboard:
    pusha
    in al, 0x60
    test al, 0x80
    jnz .kend
    movzx ebx, al
    mov al, [scancodes + ebx]
    test al, al
    jz .kend
    mov ebx, [buf_head]
    mov [kb_buffer + ebx], al
    inc ebx
    cmp ebx, 256
    jl .knw
    xor ebx, ebx
.knw:
    mov [buf_head], ebx
.kend:
    mov al, 0x20
    out 0x20, al
    popa
    iret

scancodes:
    db 0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0
    db 0, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0
    db 0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '`', 0
    db '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0
    times 256 db 0

section .data
banner db "=========================================", 10
       db "   ASM KERNEL WITH SHELL                 ", 10
       db "   Commands: help, clear, info           ", 10
       db "=========================================", 10, 0
prompt_str db 10, "> ", 0
unknown db "Unknown command. Type 'help'", 10, 0
help_text db "Commands: help, clear, info", 10, 0
info_text db "ASM Kernel - Keyboard Working!", 10, 0
cmd_help db "help", 0
cmd_clear db "clear", 0
cmd_info db "info", 0
cursor dd 0xB8000

section .bss
idt resb 256*8
idt_desc:
    resw 1
    resd 1
kb_buffer resb 256
buf_head resd 1
buf_tail resd 1
cmd_buffer resb 256
