;==========================================
; Useful Macros
;==========================================

; Print string at current cursor
%macro PRINT 1
    pusha
    mov esi, %1
    call video_print
    popa
%endmacro

; Print string at specific position
%macro PRINT_AT 3
    pusha
    mov esi, %1
    mov edi, VIDEO_MEMORY
    mov eax, %2
    mov ecx, VIDEO_WIDTH * 2
    mul ecx
    add edi, eax
    add edi, %3
    call video_print_at
    popa
%endmacro

; Clear entire screen
%macro CLEAR 0
    pusha
    call video_clear
    popa
%endmacro

; Disable interrupts
%macro NO_INTERRUPTS 0
    cli
%endmacro

; Enable interrupts
%macro YES_INTERRUPTS 0
    sti
%endmacro

; Save all registers
%macro SAVE_ALL 0
    pusha
    push ds
    push es
    push fs
    push gs
%endmacro

; Restore all registers
%macro RESTORE_ALL 0
    pop gs
    pop fs
    pop es
    pop ds
    popa
%endmacro

; Halt CPU
%macro HALT 0
    hlt
%endmacro

; Debug: print register value
%macro PRINT_REG 1
    pusha
    mov esi, %1
    call video_print
    popa
%endmacro
