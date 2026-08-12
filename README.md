# HYFI
RBFI is a 64-bit firmware that can roll back from 64-bit to 32 and 16 bits, and also has a command shell
# Info:
![Assembly(Nasm)](https://img.shields.io/badge/Ready-90%25-orange)
![Assembly(Nasm)](https://img.shields.io/badge/In-developered-blue)
![Assembly(Nasm)](https://img.shields.io/badge/Platform-x86--64-blue)
![Assembly(Nasm)](https://img.shields.io/badge/Socket-LGA--1155-blue)
# More info:
RBFI - 64-bit firmware with the ability to revert to 32 and 16 bits for backward compatibility, running old programs, and DOS
For the OS to run, the RBFI program has to be at address 0x0100000, and the program needs to get into memory via USB 2
To specify the bitness of your program, the rbfi_bud label in the RBFI code should be under a certain number: 64-bit mode - rbfi_bud db 3, 32-bit mode - rbfi_bud db 2, 16-bit mode - rbfi_bud db 1
# Build code:
When compiling RBFI, be sure to specify the value of rbfi_bud
**For example : **
`nasm -f bin hyfi.asm -Drbfi_bud=3 -o hyfi.bin`
# Launch:
**Bochs:**

bochsct.txt:
``` Bash
cpu: model=corei7_haswell_4770, count=1, ips=50000000, reset_on_triple_fault=1
megs:128
romimage: file=hyfi.bin, address=0xffff0000
vga: extension=vbe, update_freq=60
vgaromimage: file=/usr/share/bochs/VGABIOS-lgpl-latest
com1: enabled=1, mode=file, dev=com1.txt
panic: action=fatal
```
**SIZE :**
``truncate -s 64K hyfi.bin``
*launch:*
``bochs -f bochsrc.txt -q``

**Qemu:**

*launch:*
``qemu-system-x86_64 -bios hyfi.bin -monitor stdio``


