;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;RawBootFirmwareInterface RBFI v0.1.17
;Copiright (c) 2026 $yscall-(Syscall1dev)
;More info : By default, HYFI looks for the kernel at address 0x00100000,
;exactly one megabyte of memory in 64-bit mode.
;You can use the 'real mode' command and RBFI will switch to 16-bit mode, or 'protected mode' for 32-bit mode.
;To hand over control to the kernel, you need to use the 'launch' command, BUT MAKE SURE YOU CHOOSE THE MODE FIRST!!!
;=========
;=========
HYFI:
[bits 16]
[org 0xFFFF0000]
startcli:
    cli
    xor ax,ax
    mov ds,ax
    mov es,ax
    mov ss,ax
    jmp lol
    align 4
    gdt:
        dq 0x0000000000000000
        dq 0x00CF9A000000FFFF
        dq 0x00CF92000000FFFF
    gdt_end:
    gdt_pointer:
    dw gdt_end - gdt - 1
    dd 0x000f000C
    lol:
;======CAR======
    mov ecx,0x2FF
    rdmsr
    and eax,0xFFFFF3FF
    mov ecx,0x200
    mov eax,0xFEF00006
    mov edx,0x00000000
    wrmsr
    mov ecx,0x201
    mov eax,0xFFFF0800
    wrmsr
    mov ecx,0x2FF
    rdmsr
    or eax,0xC00
    wrmsr
    mov edi,0xFEF00000
    mov ecx,16384
    xor eax,eax
    rep stosd
    mov esp,0xFEF0FFFC
    mov ebp,esp 
;======PROTECTED_MODE???=======
    lgdt [cs:gdt_pointer] 
     mov eax,cr0
     or eax,1
     mov cr0,eax
     jmp dword 0x08:0x00000000000F009D
;=============================
;=============================
;=============================
[bits 32]
start32: 
;======PCI======
   mov eax,0x8000083E
   out 0x0CF8,eax
   in eax,0xCFC
   or eax,0x0008
   out 0x0CFC,eax

   mov eax,0x8000F880
   out 0x0CF8,eax
   mov eax,0x00700010
   out 0x0CFC,eax

   mov al,0x80
   out 0x70,al
   mov eax,0x8000F804
   out 0x0CF8,eax
   in eax,0x0CFC
   or eax,0x07
   out 0x0CFC,eax
;======CONF======
   mov ax,0x10
   mov esp,0x8000FFFF
   mov ds,ax
   mov ss,ax
   mov es,ax
;======APIC======
mov dx,0x21
mov al,0xFF
out dx,al
mov dx,0xA1
mov al,0xFF

mov ecx,0x1B
rdmsr
or eax,1<<11
wrmsr
;======MMIO======
mov eax,0xFEE00230
mov ebx,0x00000000
mov [eax],ebx
mov eax,0xFEE000F0
mov ebx,0x1FF
mov [eax],ebx

mov eax,0xFEC00000
mov ebx,0x13
mov [eax],ebx
mov eax,0xFEC00010
mov ebx,0x00000000
mov [eax],ebx

mov eax,0xFEC00000
mov ebx,0x12
mov [eax],ebx

mov eax,0xFEC00010
mov ebx,0x00000021
mov [eax],ebx

mov ecx,0x1B
rdmsr
or eax,1<<11
wrmsr

mov eax,0xFEE00230
mov ebx,0x00000000
mov [eax],ebx
mov eax,0xFEE000F0
mov ebx,0x1FF
mov [eax],ebx

mov eax,0xFEC00000
mov ebx,0x13
mov [eax],ebx
mov eax,0xFEC00010
mov ebx,0x00000000
mov [eax],ebx

mov eax,0xFEC00000
mov ebx,0x12
mov [eax],ebx

mov eax,0xFEC00010
mov ebx,0x00000021
mov [eax],ebx
;======LONG_MODE======

   mov eax,cr4
   or eax,0x30
   mov cr4,eax
   mov edi,0x00010000
   xor eax,eax
   mov ecx,0x1000
   rep stosd
   mov dword [0x00010000],0x00011003
   mov dword [0x00010004],0x00000000
   mov dword [0x00011000],0x00012003
   mov dword [0x00011004],0x00000000
   mov dword [0x00012000],0x0000019B
   mov dword [0x00012004],0x00000000
   mov eax,0x00010000
   mov cr3,eax
   mov ecx,0xC0000080
   rdmsr
   or eax,0x100
   wrmsr
   lgdt[0x000F0000+(gdt64_ptr-startcli)]
   mov eax,cr0
   or eax,0x80000000
   mov cr0,eax
   jmp dword 0x08:0x00000000000f0215

;=============================
;=============================
;=============================
[bits 64]
long_mode:
;======LONG_MODE======
    mov ax,0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    jmp HYFI_MAIN
;======CONF======
align 8

gdt64:
dq 0x0000000000000000

dq 0x00AF9A000000FFFF

dq 0x00AF92000000FFFF

gdt64_end:

gdt64_ptr:
dw gdt64_end - gdt64 - 1
dq (0x000f0000+(gdt64-startcli))

align 16
stack:
times 8192 db 0
gdt32:
dq 0
dq 0x00CF9A000000FFFF   
dq 0x00CF92000000FFFF   

gdt32_ptr:
dw gdt32_end - gdt32 - 1
dd gdt32
gdt32_end:

stack_top:
;+=+=+=+=+=+=+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;=+=+=+=+=+=+=+=+=+=+=+=+=+=+==+=+=+=+=+=+=+=+=+=+=+=+=+=+=

HYFI_MAIN:
[bits 64]
;======DISPLAY_640x480======
xor rsi,rsi
mov rax,0x60000
mov rbx,0x03F027F
mov [rsi+rax],rbx

mov rax,0x60010
mov rbx,0x02C01DF
mov [rsi+rax],rbx

mov rax,0x70180
mov rbx,0x86100000
mov [rsi+rax],rbx

mov rax,0x70184
mov rbx,0x01000000
mov [rax],rbx

mov rax, 0x7008
or rax,1<<31
mov r10,0x1488
;-------------------
;=+=+=+=+=+=+=+=+=+=+=+=+=+=+==+=+=+=+=+=+=+=+=+=+=+=+=+=+=
;+=+=+=+=+=+=+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;=+=+=+=+=+=+=+=+=+=+=+=+=+=+==+=+=+=+=+=+=+=+=+=+=+=+=+=+=
section .data
cmd_x16 db 'real mode',0
cmd_x32 db 'protected mode',0
cmd_x64 db 'long mode',0
cmd_cullers_on db 'cullers on',0
cmd_cullers_on1 db 'cullers fifty',0
cmd_cullers_off db 'cullers off',0
;-----
section .bss

;======DISPLAY======
   section .text
    
apic_find:
    mov dx,0x0CF8
    mov eax,0x80001010
    out dx,eax

    mov dx,0x0CFC
    in eax,dx
    and eax,0xFFFFFFF0
    mov ebx,eax

    mov dx,0x0CF8
    mov eax,0x80001014
    out dx,eax

    mov dx,0x0CFC
    in eax,dx

    shl rax,32
    or rax,rbx 
    mov r9,1488
;======DISPLAY_640x480======
xor rsi,rsi
mov rax,0x60000
mov rbx,0x03F027F
mov [rsi+rax],rbx

mov rax,0x60010
mov rbx,0x02C01DF
mov [rsi+rax],rbx

mov rax,0x70180
mov rbx,0x86100000
mov [rsi+rax],rbx

mov rax,0x70184
mov rbx,0x01000000
mov [rax],rbx

mov rax, 0x7008
or rax,1<<31
mov r10,0x1488
;-------------------

jmp _start
    global _start
;===================
[bits 64]
    _start:     
;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;--------------------
jmp launch

align 8 
rwfi_bud db 2
launch:
    cmp byte [rel rwfi_bud],0
    je none
    cmp byte [rel rwfi_bud],1
    je launch16bit
    cmp byte [rel rwfi_bud],2
    je launch32bit
    cmp byte [rel rwfi_bud],3
    je launch64bit
    ret
;----------------------------------------
launch64bit:
    mov rax,0x00100000
    jmp rax
launch32bit:
[bits 32]
compat32:
mov eax,0xC0000080
and eax,0>>8
lgdt [cs:CODE32] 
 mov eax,cr0
 or eax,1
mov cr0,eax
mov eax,cr0
and eax,0x7FFFFFFF
mov cr0,eax
mov eax,cr4
and eax,0xFFFFFFDF
mov cr4,eax
cli
xor ax,ax
mov ds,ax
mov es,ax
mov ss,ax
mov fs,ax
mov gs,ax
mov esp,0x8000FFFF

jmp dword 0x018:0x0100000
launch16bit:
    hlt
    jmp launch16bit
    [bits 64]
none:
hlt
jmp none 
    [bits 64]
    gdt_gg:
dq 0

dq 0x00209A0000000000

dq 0x0000920000000000

dq 0x00CF9A000000FFFF

dq 0x00CF92000000FFFF
CODE64 equ 0x08
DATA64 equ 0x10 
CODE32 equ 0x18
;=============================
[bits 16]
TIMES 65536-16-($-$$) db 0
starthd:
    db 0xEA
    dw 0x0000
    dw 0xF000
TIMES 65536 - ($-$$) db 0 
;=============================