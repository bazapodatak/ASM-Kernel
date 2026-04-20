# ASM Kernel v2.0

<div align="center">

![Version](https://img.shields.io/badge/version-2.0-blue)
![Architecture](https://img.shields.io/badge/arch-x86%2016--bit-red)
![Language](https://img.shields.io/badge/language-Assembly-orange)
![License](https://img.shields.io/badge/license-MIT-green)

**A 16-bit real-mode operating system written entirely in x86 assembly**

[Features](#-features) •
[Commands](#-commands) •
[Build](#-build--run) •
[About](#-about)

</div>

---

## Overview

ASM Kernel v2.0 is a fully functional operating system written from scratch in NASM assembly. It boots directly from a floppy disk, presents a boot menu, and offers both a command-line shell and a graphical demo. The kernel runs in **real mode** (16-bit) and interacts directly with BIOS interrupts and VGA hardware.

This project demonstrates:
- Bare-metal x86 programming
- Custom boot menu
- Shell with 20+ commands
- VGA Mode 13h graphics engine (shapes, pixels, window)
- Terminal scrollback buffer
- PC speaker sound
- Interactive guessing game

---

## Boot Menu

+---------------------------------------------+
| ASM KERNEL v2.0 |
+---------------------------------------------+
| 1. Shell |
| 2. Reboot |
+---------------------------------------------+
Choice:

## Screenshots

<div align="center">

| Boot Menu | Shell |
|-----------|-------|
| ![Boot] ( https://ibb.co/mVjNqk8Z ) | ![Shell] ( https://ibb.co/twtf78cM ) |

</div>

---

## Commands (20 Total)

### System Commands
| Command | Description |
|---------|-------------|
| `help` | Show available commands |
| `clear` | Clear the screen |
| `about` | Display creator info |
| `info` | Show kernel information |
| `ver` | Display version |
| `whoami` | Show current user |
| `reboot` | Warm reboot the system |

### Text Commands
| Command | Description |
|---------|-------------|
| `echo <text>` | Print text to screen |

### Math Commands
| Command | Description |
|---------|-------------|
| `calc` | Interactive calculator (+, -, *, /) |
| `hex <n>` | Convert decimal to hexadecimal |
| `bin <n>` | Convert decimal to binary |
| `fib <n>` | Calculate Fibonacci number (0-24) |
| `rand` | Generate random number 1-100 |

### Hardware Commands
| Command | Description |
|---------|-------------|
| `time` | Show current system time |
| `date` | Show current system date |
| `uptime` | Show ticks since boot |
| `mem <addr>` | Dump 16 bytes from memory address |
| `beep` | Play PC speaker beep |

### Screen Commands
| Command | Description |
|---------|-------------|
| `color <0-15>` | Change text color |
| `fill <char>` | Fill entire screen with character |

## PC Speaker

- `beep` command plays a tone
- Works in QEMU with `-audiodev` flag

---

## Build & Run

### Requirements

| Tool | Version | Purpose |
|------|---------|---------|
| NASM | 2.15+ | Assemble the kernel |
| QEMU | 5.0+ | Emulation (recommended) |
| dd | Any | Create floppy image |
| Linux/WSL/macOS | - | Build environment |

### Quick Start

```bash
# Clone the repository
git clone https://github.com/bazapodatak/asm-kernel.git
cd asm-kernel

# Assemble the kernel
nasm -f bin kernel.asm -o kernel.bin

# Create a 1.44 MB floppy image
dd if=/dev/zero of=floppy.img bs=512 count=2880

# Write kernel to floppy
dd if=kernel.bin of=floppy.img conv=notrunc

# Run in QEMU (with PC speaker support)
qemu-system-i386 -fda floppy.img -audiodev pa,id=speaker -machine pcspk-audiodev=speaker
