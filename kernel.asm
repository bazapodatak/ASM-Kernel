[BITS 16]
[ORG 0x0000]

start:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFF00
    mov ax, 0x0003
    int 0x10
    mov si, boot_menu
    call print
.menu_loop:
    xor ax, ax
    int 0x16
    cmp al, '1'
    je  .shell
    cmp al, '2'
    je  .reboot
    jmp .menu_loop
.shell:
    call newline
    jmp init_shell
.reboot:
    mov ax, 0x0040
    mov ds, ax
    mov word [0x0072], 0x1234
    jmp 0xFFFF:0x0000

init_shell:
    mov si, msg_welcome
    call print
shell_loop:
    mov si, prompt
    call print
    mov di, buffer
    xor cx, cx
.read_loop:
    xor ax, ax
    int 0x16
    cmp al, 13
    je  .done
    cmp al, 8
    je  .backspace
    cmp cx, 63
    je  .read_loop
    stosb
    inc cx
    call putchar
    jmp .read_loop
.backspace:
    cmp cx, 0
    je  .read_loop
    dec di
    dec cx
    mov al, 8
    call putchar
    mov al, ' '
    call putchar
    mov al, 8
    call putchar
    jmp .read_loop
.done:
    mov byte [di], 0
    call newline
    mov si, buffer
    call trim
    cmp byte [buffer], 0
    je  shell_loop
    mov si, buffer
    mov di, cmd_help
    call strcmp_i
    jz  do_help
    mov di, cmd_help2
    call strcmp_i
    jz  do_help
    mov di, cmd_clear
    call strcmp_i
    jz  do_clear
    mov di, cmd_cls
    call strcmp_i
    jz  do_clear
    mov di, cmd_echo
    call strcmp_i
    jz  do_echo
    mov di, cmd_reboot
    call strcmp_i
    jz  do_reboot
    mov di, cmd_about
    call strcmp_i
    jz  do_about
    mov di, cmd_info
    call strcmp_i
    jz  do_info
    mov di, cmd_color
    call strcmp_i
    jz  do_color
    mov di, cmd_beep
    call strcmp_i
    jz  do_beep
    mov di, cmd_ver
    call strcmp_i
    jz  do_ver
    mov di, cmd_hex
    call strcmp_i
    jz  do_hex
    mov di, cmd_bin
    call strcmp_i
    jz  do_bin
    mov di, cmd_rand
    call strcmp_i
    jz  do_rand
    mov di, cmd_time
    call strcmp_i
    jz  do_time
    mov di, cmd_date
    call strcmp_i
    jz  do_date
    mov di, cmd_uptime
    call strcmp_i
    jz  do_uptime
    mov di, cmd_mem
    call strcmp_i
    jz  do_mem
    mov di, cmd_whoami
    call strcmp_i
    jz  do_whoami
    mov di, cmd_calc
    call strcmp_i
    jz  do_calc
    mov di, cmd_guess
    call strcmp_i
    jz  do_guess
    mov di, cmd_fib
    call strcmp_i
    jz  do_fib
    mov di, cmd_fill
    call strcmp_i
    jz  do_fill
    mov si, msg_unknown
    call print
    jmp shell_loop

do_help:
    mov si, help_text
    call print
    jmp shell_loop
do_clear:
    mov ax, 0x0003
    int 0x10
    jmp shell_loop
do_echo:
    mov si, buffer + 5
    call trim_spaces
    call print
    call newline
    jmp shell_loop
do_reboot:
    mov ax, 0x0040
    mov ds, ax
    mov word [0x0072], 0x1234
    jmp 0xFFFF:0x0000
do_about:
    mov si, about_text
    call print
    jmp shell_loop
do_info:
    mov si, info_msg
    call print
    jmp shell_loop
do_color:
    mov si, buffer + 6
    call atoi
    cmp al, 15
    ja  .err
    mov [color_attr], al
    mov si, msg_color_ok
    call print
    jmp shell_loop
.err:
    mov si, msg_color_err
    call print
    jmp shell_loop
do_beep:
    mov al, 0xB6
    out 0x43, al
    mov ax, 0x0A00
    out 0x42, al
    mov al, ah
    out 0x42, al
    in  al, 0x61
    or  al, 0x03
    out 0x61, al
    mov cx, 0x00FF
.wait:
    loop .wait
    in  al, 0x61
    and al, 0xFC
    out 0x61, al
    jmp shell_loop
do_ver:
    mov si, msg_ver
    call print
    jmp shell_loop
do_hex:
    mov si, buffer + 4
    call atoi
    call print_hex_word
    call newline
    jmp shell_loop
do_bin:
    mov si, buffer + 4
    call atoi
    call print_bin_word
    call newline
    jmp shell_loop
do_rand:
    mov ah, 0
    int 0x1A
    mov ax, dx
    xor dx, dx
    mov cx, 100
    div cx
    inc dl
    xor ah, ah
    mov al, dl
    call print_num
    call newline
    jmp shell_loop
do_time:
    mov ah, 0x02
    int 0x1A
    jc  .error
    mov al, ch
    call print_byte_two
    mov al, ':'
    call putchar
    mov al, cl
    call print_byte_two
    mov al, ':'
    call putchar
    mov al, dh
    call print_byte_two
    call newline
    jmp shell_loop
.error:
    mov si, msg_time_err
    call print
    jmp shell_loop
do_date:
    mov ah, 0x04
    int 0x1A
    jc  .error
    mov ax, cx
    call print_num
    mov al, '-'
    call putchar
    mov al, dh
    call print_byte_two
    mov al, '-'
    call putchar
    mov al, dl
    call print_byte_two
    call newline
    jmp shell_loop
.error:
    mov si, msg_date_err
    call print
    jmp shell_loop
do_uptime:
    push ds
    mov ax, 0x0040
    mov ds, ax
    mov ax, [0x006C]
    pop ds
    mov cx, 18
    xor dx, dx
    div cx
    call print_num
    mov si, msg_uptime
    call print
    jmp shell_loop
do_mem:
    mov si, buffer + 4
    call atoi
    mov bx, ax
    mov si, msg_mem_dump
    call print
    call print_hex_word
    mov si, msg_colon
    call print
    mov cx, 16
.loop:
    mov al, [bx]
    call print_byte_hex
    mov al, ' '
    call putchar
    inc bx
    loop .loop
    call newline
    jmp shell_loop
do_whoami:
    mov si, msg_whoami
    call print
    jmp shell_loop
do_calc:
    mov si, buffer + 5
    call trim_spaces
    call atoi
    mov [num1], ax
    call skip_spaces
    lodsb
    mov [op], al
    call skip_spaces
    mov si, di
    call atoi
    mov bx, ax
    mov ax, [num1]
    cmp byte [op], '+'
    je  .add
    cmp byte [op], '-'
    je  .sub
    cmp byte [op], '*'
    je  .mul
    cmp byte [op], '/'
    je  .div
    mov si, msg_calc_err
    call print
    jmp shell_loop
.add:
    add ax, bx
    jmp .show
.sub:
    sub ax, bx
    jmp .show
.mul:
    mul bx
    jmp .show
.div:
    test bx, bx
    jz  .div_err
    xor dx, dx
    div bx
.show:
    call print_num
    call newline
    jmp shell_loop
.div_err:
    mov si, msg_div_zero
    call print
    jmp shell_loop
do_guess:
    mov ax, 0x0003
    int 0x10
    mov si, msg_guess_welcome
    call print
    mov ah, 0
    int 0x1A
    mov ax, dx
    xor dx, dx
    mov cx, 100
    div cx
    inc dl
    mov [secret], dl
    mov word [attempts], 0
.guess_loop:
    mov si, msg_guess_prompt
    call print
    call read_num
    cmp ax, 0
    je  .exit
    inc word [attempts]
    cmp al, [secret]
    je  .correct
    jl  .low
    mov si, msg_guess_high
    call print
    jmp .guess_loop
.low:
    mov si, msg_guess_low
    call print
    jmp .guess_loop
.correct:
    mov si, msg_guess_correct
    call print
    mov ax, [attempts]
    call print_num
    call newline
    mov si, msg_play_again
    call print
    call read_yn
    cmp al, 'y'
    je  do_guess
.exit:
    jmp shell_loop
do_fib:
    mov si, buffer + 4
    call atoi
    cmp ax, 24
    ja  .err
    call fib
    call print_num
    call newline
    jmp shell_loop
.err:
    mov si, msg_fib_err
    call print
    jmp shell_loop
do_fill:
    mov si, buffer + 5
    call trim_spaces
    lodsb
    test al, al
    jz  .err
    mov ah, 0x02
    mov bh, 0
    xor dx, dx
    int 0x10
    mov ah, 0x09
    mov bh, 0
    mov bl, [color_attr]
    mov cx, 2000
    int 0x10
    jmp shell_loop
.err:
    mov si, msg_fill_err
    call print
    jmp shell_loop

print:
    lodsb
    test al, al
    jz  .done
    mov ah, 0x0E
    mov bx, 0x0007
    int 0x10
    jmp print
.done:
    ret
putchar:
    mov ah, 0x0E
    mov bx, 0x0007
    int 0x10
    ret
newline:
    mov al, 13
    call putchar
    mov al, 10
    call putchar
    ret
trim:
    push si
    mov cx, -1
.len:
    inc cx
    lodsb
    test al, al
    jnz .len
    dec si
.trim_loop:
    cmp cx, 0
    je  .done
    dec si
    mov al, [si]
    cmp al, ' '
    je  .is_space
    cmp al, 13
    je  .is_space
    cmp al, 10
    je  .is_space
    inc si
    jmp .done
.is_space:
    mov byte [si], 0
    dec cx
    jmp .trim_loop
.done:
    pop si
    ret
trim_spaces:
    cmp byte [si], ' '
    jne .done
    inc si
    jmp trim_spaces
.done:
    ret
strcmp_i:
    push si
    push di
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, 'A'
    jb  .no_up1
    cmp al, 'Z'
    ja  .no_up1
    add al, 32
.no_up1:
    cmp bl, 'A'
    jb  .no_up2
    cmp bl, 'Z'
    ja  .no_up2
    add bl, 32
.no_up2:
    cmp al, bl
    jne .not_equal
    test al, al
    jz  .equal
    inc si
    inc di
    jmp .loop
.not_equal:
    pop di
    pop si
    mov ax, 1
    ret
.equal:
    pop di
    pop si
    xor ax, ax
    ret
atoi:
    xor ax, ax
    xor bx, bx
.next:
    mov bl, [si]
    cmp bl, '0'
    jb  .done
    cmp bl, '9'
    ja  .done
    sub bl, '0'
    imul ax, 10
    add ax, bx
    inc si
    jmp .next
.done:
    ret
print_num:
    pusha
    mov cx, 10
    xor bx, bx
    push bx
.loop:
    xor dx, dx
    div cx
    add dl, '0'
    push dx
    inc bx
    test ax, ax
    jnz .loop
.print:
    pop ax
    call putchar
    dec bx
    jnz .print
    popa
    ret
print_hex_word:
    pusha
    mov cx, 4
    mov bx, ax
.loop:
    rol bx, 4
    mov al, bl
    and al, 0x0F
    cmp al, 10
    sbb al, 0x69
    das
    call putchar
    loop .loop
    popa
    ret
print_byte_hex:
    pusha
    mov ah, al
    shr al, 4
    call print_nibble
    mov al, ah
    and al, 0x0F
    call print_nibble
    popa
    ret
print_nibble:
    cmp al, 10
    sbb al, 0x69
    das
    call putchar
    ret
print_byte_two:
    pusha
    aam
    add ax, 0x3030
    xchg ah, al
    cmp ah, '0'
    jne .both
    mov al, ah
    call putchar
    mov al, '0'
    call putchar
    jmp .done
.both:
    call putchar
    mov al, ah
    call putchar
.done:
    popa
    ret
print_bin_word:
    pusha
    mov cx, 16
    mov bx, ax
.loop:
    rol bx, 1
    mov al, '0'
    test bl, 1
    jz  .b0
    mov al, '1'
.b0:
    call putchar
    loop .loop
    popa
    ret
skip_spaces:
    cmp byte [si], ' '
    jne .done
    inc si
    jmp skip_spaces
.done:
    ret
read_num:
    mov di, num_buf
    xor cx, cx
.loop:
    xor ax, ax
    int 0x16
    cmp al, 13
    je  .done
    cmp al, 8
    je  .bs
    cmp al, '0'
    jb  .loop
    cmp al, '9'
    ja  .loop
    stosb
    inc cx
    call putchar
    jmp .loop
.bs:
    cmp cx, 0
    je  .loop
    dec di
    dec cx
    mov al, 8
    call putchar
    mov al, ' '
    call putchar
    mov al, 8
    call putchar
    jmp .loop
.done:
    mov byte [di], 0
    call newline
    mov si, num_buf
    call atoi
    ret
read_yn:
.wait:
    xor ax, ax
    int 0x16
    or al, 0x20
    cmp al, 'y'
    je  .ok
    cmp al, 'n'
    je  .ok
    jmp .wait
.ok:
    call putchar
    call newline
    ret
fib:
    push bx
    push cx
    cmp ax, 1
    jbe .base
    mov cx, ax
    dec cx
    xor ax, ax
    mov bx, 1
.loop:
    push ax
    add ax, bx
    xchg ax, bx
    pop ax
    loop .loop
    mov ax, bx
    jmp .done
.base:
    test ax, ax
    jz .zero
    mov ax, 1
    jmp .done
.zero:
    xor ax, ax
.done:
    pop cx
    pop bx
    ret

boot_menu:
    db 13,10,"+-------------------------+",13,10
    db "|    ASM KERNEL v2.3     |",13,10
    db "+-------------------------+",13,10
    db "| 1. Shell               |",13,10
    db "| 2. Reboot              |",13,10
    db "+-------------------------+",13,10
    db "Choice: ",0
msg_welcome:
    db "ASM Kernel v2.3",13,10
    db "Type 'help' or '?' for commands.",13,10,0
prompt: db "> ",0
msg_unknown: db "Unknown command.",13,10,0
msg_color_ok: db "Color changed.",13,10,0
msg_color_err: db "Invalid color (0-15).",13,10,0
msg_ver: db "ASM Kernel v2.3",13,10,0
msg_time_err: db "Time not available.",13,10,0
msg_date_err: db "Date not available.",13,10,0
msg_uptime: db " seconds",13,10,0
msg_mem_dump: db "Memory at 0x",0
msg_colon: db ": ",0
msg_whoami: db "Kernel Author, Bosnia",13,10,0
msg_calc_err: db "Invalid expression.",13,10,0
msg_div_zero: db "Division by zero.",13,10,0
msg_guess_welcome: db "Guess number 1-100 (0 to quit)",13,10,0
msg_guess_prompt: db "Guess: ",0
msg_guess_low: db "Too low!",13,10,0
msg_guess_high: db "Too high!",13,10,0
msg_guess_correct: db "Correct! Attempts: ",0
msg_play_again: db "Play again? (y/n): ",0
msg_fib_err: db "Usage: fib <0-24>",13,10,0
msg_fill_err: db "Usage: fill <char>",13,10,0
about_text:
    db 13,10,"+-------------------------+",13,10
    db "|    ASM Kernel v1.0    |",13,10
    db "|  16-bit Real Mode OS   |",13,10
    db "|  Author: Baza          |",13,10
    db "|  Country: Bosnia       |",13,10
    db "+-------------------------+",13,10,0
info_msg:
    db "16-bit Real Mode Kernel.",13,10,0
help_text:
    db 13,10,"Commands:",13,10
    db " help, ?       - Show this",13,10
    db " clear, cls    - Clear screen",13,10
    db " echo <text>   - Print text",13,10
    db " reboot        - Warm reboot",13,10
    db " about         - About kernel",13,10
    db " info          - Kernel info",13,10
    db " ver           - Version",13,10
    db " color <0-15>  - Text color",13,10
    db " beep          - PC speaker beep",13,10
    db " hex <num>     - Decimal to hex",13,10
    db " bin <num>     - Decimal to binary",13,10
    db " rand          - Random 1-100",13,10
    db " time          - Show current time",13,10
    db " date          - Show current date",13,10
    db " uptime        - Seconds since boot",13,10
    db " mem <addr>    - Dump 16 bytes",13,10
    db " whoami        - Show user",13,10
    db " calc <a> <op> <b> - Calculate",13,10
    db " guess         - Number guessing",13,10
    db " fib <n>       - Fibonacci (0-24)",13,10
    db " fill <char>   - Fill screen",13,10,0

cmd_help:   db "help",0
cmd_help2:  db "?",0
cmd_clear:  db "clear",0
cmd_cls:    db "cls",0
cmd_echo:   db "echo",0
cmd_reboot: db "reboot",0
cmd_about:  db "about",0
cmd_info:   db "info",0
cmd_color:  db "color",0
cmd_beep:   db "beep",0
cmd_ver:    db "ver",0
cmd_hex:    db "hex",0
cmd_bin:    db "bin",0
cmd_rand:   db "rand",0
cmd_time:   db "time",0
cmd_date:   db "date",0
cmd_uptime: db "uptime",0
cmd_mem:    db "mem",0
cmd_whoami: db "whoami",0
cmd_calc:   db "calc",0
cmd_guess:  db "guess",0
cmd_fib:    db "fib",0
cmd_fill:   db "fill",0

color_attr: db 0x07
buffer:     times 64 db 0
num_buf:    times 16 db 0
num1:       dw 0
op:         db 0
secret:     db 0
attempts:   dw 0
