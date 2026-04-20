;==========================================
; System Constants
;==========================================

; Video
VIDEO_MEMORY    equ 0xB8000
VIDEO_WIDTH     equ 80
VIDEO_HEIGHT    equ 25
VIDEO_SIZE      equ VIDEO_WIDTH * VIDEO_HEIGHT * 2

; Colors
COLOR_BLACK      equ 0x0
COLOR_BLUE       equ 0x1
COLOR_GREEN      equ 0x2
COLOR_CYAN       equ 0x3
COLOR_RED        equ 0x4
COLOR_MAGENTA    equ 0x5
COLOR_BROWN      equ 0x6
COLOR_GRAY       equ 0x7
COLOR_DARK_GRAY  equ 0x8
COLOR_LIGHT_BLUE equ 0x9
COLOR_LIGHT_GREEN equ 0xA
COLOR_LIGHT_CYAN equ 0xB
COLOR_LIGHT_RED  equ 0xC
COLOR_PINK       equ 0xD
COLOR_YELLOW     equ 0xE
COLOR_WHITE      equ 0xF

; Default color (white on black)
DEFAULT_COLOR    equ (COLOR_WHITE << 8)

; PIC (Programmable Interrupt Controller)
PIC1_CMD    equ 0x20
PIC1_DATA   equ 0x21
PIC2_CMD    equ 0xA0
PIC2_DATA   equ 0xA1

; PIT (Programmable Interval Timer)
PIT_CH0     equ 0x40
PIT_CMD     equ 0x43
PIT_FREQ    equ 1193180

; GDT Selectors
CODE_SEG    equ 0x08
DATA_SEG    equ 0x10

; Interrupts
IRQ0        equ 32
IRQ1        equ 33
