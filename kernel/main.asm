section .text
global kernel_main
extern video_clear, video_print
extern idt_init, pic_remap
extern keyboard_init

kernel_main:
    call video_clear
    mov esi, msg1
    call video_print
    
    call idt_init
    call pic_remap
    call keyboard_init
    
    mov esi, msg2
    call video_print
    
    sti
    jmp $

msg1 db "=========================================", 10
     db "   ASM KERNEL - WORKING!                ", 10
     db "=========================================", 10, 0
msg2 db "Keyboard active. Press any key...", 10, 0
