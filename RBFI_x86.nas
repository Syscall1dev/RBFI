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
[org 0xFFFE0000]
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
    dd 0x000E000C
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
     jmp dword 0x08:0x00000000000E009D
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
   lgdt[0x000E0000+(gdt64_ptr-startcli)]
   mov eax,cr0
   or eax,0x80000000
   mov cr0,eax
   jmp dword 0x08:0x00000000000E0215

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
dq (0x000e0000+(gdt64-startcli))

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
section .text
HYFI_MAIN:
[bits 64]
;======IDT======
align 16
idt_table:
times 256 dq 0, 0
idt_end:

align 16
    align 16
idt_ptr:
dw idt_end - idt_table - 1
dq (0xFFFE0000+(idt_table-startcli))
lol2:
xor rcx, rcx
mov rdi,0x000F2210
.fill_idt:
    lea rax,[rel fault]
    mov rbx, rdi
    mov r8, rcx
    shl r8, 4
    add rbx, r8
    mov [rbx], ax
    
    mov word [rbx+2], 0x08
    mov byte [rbx+5], 0x8E
    mov rdx, rax
    shr rdx, 16
    mov [rbx+6], dx
mov [rbx+4],byte 0
    mov rdx,rax
    shr rdx,32
    mov dword[rbx+8],edx
    mov dword [rbx+12], 0
    inc rcx
    cmp rcx, 256
    jne .fill_idt
    lidt [rel idt_ptr]
;======CULLERS======
    mov dx,0x002E
    mov al,0x87
    out dx,al
    out dx,al

    mov dx,0x002E
    mov al,0x07
    out dx,al
    
    mov dx,0x002F
    mov al,0x0B
    out dx,al
;======DISPLAY======
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
;======HDMI======
mov [rax+0x06014],dword 0x80000000
mov [rax+0x6000C],dword 0x800C0000
mov [rax+0x7200C],dword 0x80000000
mov [rax+0x72008],dword 0x80000000
mov [rax+0xE1140],dword 0x84000000
mov [rax+0xC400C],dword 0x00000200
;======DISPLAY_640x480======
mov rsi,rax
mov r8,0x60000
mov rbx,0x03F027F
mov [rsi+r8],rbx

mov r8,0x60010
mov rbx,0x02C01DF
mov [rsi+r8],rbx

mov r8,0x70180
mov rbx,0x86100000
mov [rsi+r8],rbx

mov r8,0x70184
mov rbx,0x01000000
mov [rsi+r8],rbx

mov r8,0x7008
or rbx,1<<31
mov [rsi+r8],rbx
        fff:
        cld
        mov rdi,rax
        add rdi,0x6E400
        lea rsi,[rel logo] 
        mov rcx,8193
        rep movsd
        hlt
;======USB-2======
mov eax,0x0CF8
mov al,0x10
out eax,al

mov eax,0x0CFC
in ebx,eax

and ebx,0xFFFFFFF0
mov r15,ebx
;--------
mov al,[r15]
mov r14,r15
movzx rax,al 
add r14,rax
usb_ff:
mov [eax],r14
or rax,1<<1
mov [r14],eax
cmp rax,0x02 
je usb_ff
mov eax,[r14]
or eax,1
mov [r14],eax
mov [r14+0x40],0x1
mov eax,[r14+0x40]
cmp eax,0
je ussb
hlt 
;======USB_BOOT======
ussb:
mov eax,[r14+0x40]
or eax,1<<8
mov [r14+0x40],eax
usb_boot:
mov eax,[r14+0x44]
test eax,0x05
jne usb_boot

mov [0x20000], dword 0x20002
mov [0x20004], dword 0x00402001
mov [0x20008], dword 0x40000000
mov [0x2000C], dword 0x20040

mov [0x20040],0x1
mov [0x20044],0x1
mov [0x20048],0x001F0080

lea rax,[usb_cbw]
mov [rax],dword 0x43425355
mov [rax+4],dword 0x01
mov [rax+8],dword 512
mov [rax+12],byte 0x80
mov [rax+13],byte 0
mov [rax+14],byte 10

mov [rax+15],byte 0x28
mov [rax+16],byte 0
mov [rax+17],dword 0
mov [rax+21],byte 0
mov [rax+22],word 0x0100
mov [rax+24],byte 0

mov [0x2004C],rax
mov [r14+0x18],0x20000
mov r12,[r14+0x00]
or r12,0x21
mov [r14+0x00],r12
.loop_ff:
    mov r11,[0x20048]
    test r11,0x80
    jnz .loop_ff
;======BOOTING======
mov [0x20040],dword 0x20060
mov [0x20060],dword 0x1
mov [0x20064],dword 0x1
mov [0x20068],0x02000180
mov [0x2006C],0x00100000

mov r10,[r14+0x00]
or r10,1<<6
mov [r14+0x00],r10
.loopd:
    mov rax,[0x20068]
    test rax,0x80
    jne .loopd

mov [0x20060],dword 0x20080
mov [0x20080],dword 0x1
mov [0x20084],dword 0x1
mov [0x20088],dword 0x000D0180
mov [0x2008C],dword 0x20200

mov rax,[r14+0x00]
or rax,1<<6
mov [r14+0x00],rax

.loopz:
    mov rax,[0x20088]
    test rax,0x80
    jne .loopz
;=+=+=+=+=+=+=+=+=+=+=+=+=+=+==+=+=+=+=+=+=+=+=+=+=+=+=+=+=
;+=+=+=+=+=+=+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;=+=+=+=+=+=+=+=+=+=+=+=+=+=+==+=+=+=+=+=+=+=+=+=+=+=+=+=+=
align 4
logo:
    incbin "RBFI.raw"
logo_end:

fault:
    hlt 
    jmp fault
;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
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
;======BOOT======
launch64bit:
    mov rax,0x00100000
    jmp rax
launch32bit:
[bits 32]
compat32:
lgdt [gdt_pointer]
compat322:
mov eax,cr0
and eax,0x7FFFFFFF
jmp far dword [gdt_poiii]
mov cr0,eax
mov ecx,0xC0000080
rdmsr 
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
jmp dword 0x08:0x0100000
launch16bit:
    hlt
    jmp launch16bit
    [bits 64]
none:
hlt
jmp none 
    [bits 64]
;======GDTs======
    gdt_gg:
dq 0

dq 0x00209A0000000000

dq 0x0000920000000000

dq 0x00CF9A000000FFFF

dq 0x00CF92000000FFFF

gdt_gg_end:
CODE64 equ 0x08
DATA64 equ 0x10 
CODE32 equ 0x18
gdt_gg_ptr:
    dw gdt_gg_ptr - gdt_gg -1 
    dq gdt_gg
gdt_poiii:
    dd compat322
    dw gdt_pointer
;======BSS======
section .bss
usb_cbw resb 31
[bits 16]
    align 4
    gdt2:
        dq 0x0000000000000000
        dq 0x00CF9A000000FFFF
        dq 0x00CF92000000FFFF
    gdt_end2:
    gdt_pointer2:
    dw gdt_end2 - gdt2 - 1
    dd gdt2
;=============================
[bits 16]
TIMES 131072-16-($-$$) db 0
starthd:
    db 0xEA
    dw 0x0000
    dw 0xE000
TIMES 131072 - ($-$$) db 0 
;=============================