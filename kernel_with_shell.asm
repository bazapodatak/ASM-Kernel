;==========================================
; KERNEL WITH WORKING SHELL
;==========================================

[BITS 32]
[ORG 0x100000]

; Multiboot header
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
    
    ; Run shell
    call shell
    
    hlt

shell:
    mov esi, shell_banner
    mov edi, 0xB8000
    call print_string
    
shell_prompt:
    mov esi, prompt_str
    mov edi, [cursor_pos]
    call print_string
    
    ; Read command
    mov edi, cmd_buffer
    call read_line
    
    ; Check commands
    mov esi, cmd_buffer
    mov edi, cmd_help
    call strcmp
    cmp eax, 0
    je do_help
    
    mov esi, cmd_buffer
    mov edi, cmd_clear
    call strcmp
    cmp eax, 0
    je do_clear
    
    mov esi, cmd_buffer
    mov edi, cmd_info
    call strcmp
    cmp eax, 0
    je do_info
    
    ; Unknown command
    mov esi, unknown_msg
    mov edi, [cursor_pos]
    call print_string
    jmp shell_prompt

do_help:
    mov esi, help_msg
    mov edi, [cursor_pos]
    call print_string
    jmp shell_prompt

do_clear:
    mov edi, 0xB8000
    mov ecx, 2000
    mov ax, 0x0720
    rep stosw
    mov dword [cursor_pos], 0xB8000
    jmp shell_prompt

do_info:
    mov esi, info_msg
    mov edi, [cursor_pos]
    call print_string
    jmp shell_prompt

; Read a line from keyboard
read_line:
    pusha
    xor ecx, ecx
.read_loop:
    call getchar
    cmp al, 13        ; Enter
    je .done
    cmp al, 8         ; Backspace
    je .backspace
    
    stosb
    inc ecx
    jmp .read_loop
    
.backspace:
    cmp ecx, 0
    je .read_loop
    dec edi
    dec ecx
    jmp .read_loop
    
.done:
    mov byte [edi], 0
    popa
    ret

; Get a character from keyboard
getchar:
    push ebx
.wait:
    mov eax, [buffer_head]
    cmp eax, [buffer_tail]
    je .wait
    
    mov ebx, [buffer_tail]
    movzx eax, byte [key_buffer + ebx]
    inc ebx
    cmp ebx, 256
    jl .no_wrap
    xor ebx, ebx
.no_wrap:
    mov [buffer_tail], ebx
    
    ; Echo character
    pusha
    mov ah, 0x0F
    mov edi, [cursor_pos]
    stosw
    mov [cursor_pos], edi
    popa
    
    pop ebx
    ret

; String compare
strcmp:
.loop:
    mov al, [esi]
    mov bl, [edi]
    cmp al, bl
    jne .not_equal
    test al, al
    jz .equal
    inc esi
    inc edi
    jmp .loop
.equal:
    mov eax, 0
    ret
.not_equal:
    mov eax, 1
    ret

print_string:
    pusha
.print_loop:
    lodsb
    test al, al
    jz .done
    mov ah, 0x07
    stosw
    jmp .print_loop
.done:
    mov [cursor_pos], edi
    popa
    ret

; Setup IDT
setup_idt:
    mov edi, idt
    mov ecx, 256
    mov eax, 0
    
.fill_idt:
    mov eax, dummy_handler
    mov bx, 0x08
    mov dx, 0x8E00
    
    mov [edi], ax
    mov [edi+2], bx
    mov [edi+4], dx
    shr eax, 16
    mov [edi+6], ax
    
    add edi, 8
    loop .fill_idt
    
    ; Keyboard interrupt
    mov edi, idt + 33*8
    mov eax, keyboard_handler
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

dummy_handler:
    pusha
    mov al, 0x20
    out 0x20, al
    popa
    iret

keyboard_handler:
    pusha
    
    in al, 0x60
    test al, 0x80
    jnz .done
    
    movzx ebx, al
    mov al, [scancode_table + ebx]
    test al, al
    jz .done
    
    ; Store in buffer
    mov ebx, [buffer_head]
    mov [key_buffer + ebx], al
    inc ebx
    cmp ebx, 256
    jl .no_wrap
    xor ebx, ebx
.no_wrap:
    mov [buffer_head], ebx
    
.done:
    mov al, 0x20
    out 0x20, al
    popa
    iret

scancode_table:
    db 0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0
    db 0, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0
    db 0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", '`', 0
    db '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0
    times 128 db 0

section .data
shell_banner db "=========================================", 10
             db "   ASM KERNEL SHELL - TYPE COMMANDS     ", 10
             db "   Commands: help, clear, info          ", 10
             db "=========================================", 10, 0
prompt_str   db 10, "> ", 0
unknown_msg  db "Unknown command. Type 'help'", 10, 0
help_msg     db "Available: help, clear, info", 10, 0
info_msg     db "ASM Kernel - Keyboard Working!", 10, 0
cmd_help     db "help", 0
cmd_clear    db "clear", 0
cmd_info     db "info", 0
cursor_pos   dd 0xB8000

section .bss
idt resb 256*8
idt_desc:
    resw 1
    resd 1
key_buffer resb 256
buffer_head resd 1
buffer_tail resd 1
cmd_buffer resb 256
