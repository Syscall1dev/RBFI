# RBFI - (Raw Boot Firmware Interface)
RBFI is an ultra-fast, small, 64-bit firmware designed for backward compatibility in terms of rolling back from 64-bit mode to 32-bit to run old programs.
# Info:
![Assembly(Nasm)](https://img.shields.io/badge/Ready-98%25-red)
![Assembly(Nasm)](https://img.shields.io/badge/In-developered-blue)
![Assembly(Nasm)](https://img.shields.io/badge/Platform-x86-orange)
![Assembly(Nasm)](https://img.shields.io/badge/Socket-LGA--1155-green)
![Assembly(Nasm)](https://img.shields.io/badge/Socket-LGA--1150-green)
# More info:
RBFI - 64-bit firmware with the ability to revert to 32 and 16 bits for backward compatibility, running old programs, and DOS
For the OS to run, the RBFI program has to be at address 0x0100000, and the program needs to get into memory via USB 2
To specify the bitness of your program, the rbfi_bud label in the RBFI code should be under a certain number: 64-bit mode - rbfi_bud db 3, 32-bit mode - rbfi_bud db 2
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
romimage: file=hyfi.bin, address=0xfffe0000
panic: action=fatal
```

*launch:*
``bochs -f bochsrc.txt -q``

**Qemu:**

*launch:*
``qemu-system-x86_64 -bios hyfi.bin -monitor stdio``


