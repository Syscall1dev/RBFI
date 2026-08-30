;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;RawBootFirmwareInterface RBFI v0.1.17
;Copiright (c) 2026 $yscall-(Syscall1dev)
;More info : By default, RBFI looks for the kernel at address 0x00100000,
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
;======PROTECTED_MODE???=======
    lgdt [cs:gdt_pointer] 
     mov eax,cr0
     or eax,1
     mov cr0,eax
     jmp dword 0x08:0x00000000000e0042
;=============================
;=============================
;=============================
[bits 32]
start32: 
;======CONF======
   mov ax,0x10
   mov esp,0xFEF0FFFC
   mov ds,ax
   mov ss,ax
   mov es,ax 
;======CPU_ID======
        mov eax,1
        cpuid
        mov edx,eax
        shr edx,4 
        and edx,0x0000000F
        mov ebx,eax
        shr ebx,16
        and ebx,0x0000000F
        shl ebx,4
        add ebx,edx
cmp ebx,0x2A
je sandy_bri
cmp ebx,0x3A
je ivy_bri
cmp ebx,0x3C
je haswell

sandy_bri:
;======CAR======
  mov ecx,0x2FF
  rdmsr
  and eax,0xFFFFF3FF
  mov ecx,0x200
  mov eax,0xFEF00006
  mov edx,0x00000000
  wrmsr
  mov ecx,0x201
  mov eax,0xFFE00800
  mov edx,0x0000000F
  wrmsr
  mov ecx,0x2FF
  rdmsr
  or eax,0xC00
  wrmsr
  mov edi,0xFEF00000
  mov ecx,0x000C0000
  xor eax,eax
  rep stosd
  mov esp,0xFEF0FFFC
  mov ebp,esp  
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
;======MMIO======
mov eax,0x80000060
mov dx,0x0CF8
out dx,eax
mov eax,0xE0000001
mov dx,0x0CFC
out dx,eax
;======DDR-3======
mov edi,0xE00FB000
mov [edi+4],0xA0
mov [edi+8],byte 0x12
mov [edi+2],byte 0x48
loops:
    test [edi],2
    je loops
mov ebx,[edi+5]
push ebx
mov esi,0xE0000000
mov [esi+0x48],0xFED10001
mov ecx,0xFED10000
mov [ecx+0x2810],dword 2 
pop ebx
add ebx,1 
mov [ecx+0x4000],ebx
mov [ecx+0x5000],ebx
mov edx,[ecx+0x4010]
or edx,1
mov [ecx+4010],edx
jmp loff
;======================
;======================
;======================
ivy_bri:
 ;======CAR======
  mov ecx,0x2FF
 rdmsr
 and eax,0xFFFFF3FF
mov ecx,0x200
mov eax,0xFEF00006
mov edx,0x00000000
wrmsr
 mov ecx,0x201
 mov eax,0xFFE00800
 mov edx,0x0000000F
wrmsr
 mov ecx,0x2FF
 rdmsr
 or eax,0xC00
 wrmsr
 mov edi,0xFEF00000
 mov ecx,0x000C0000
 xor eax,eax
 rep stosd
 mov esp,0xFEF0FFFC
 mov ebp,esp   
;======PCI======
    mov dx,0x0CF8
    mov eax,0x8000083C
    out dx,eax
    mov dx,0x0CFC
    in eax,dx
    or eax,0x000000008
    out dx,eax

    mov eax,0x8000F880
    mov dx,0x0CF8
    out dx,eax
    mov eax,0x00700010
    mov dx,0x0CFC
    out dx,eax

    mov eax,0x8000F804
    mov dx,0x0CF8
    out dx,eax
    mov dx,0x0CFC
    in eax,dx
    or eax,0x00000007
    mov dx,0x0CFC
    out dx,eax

    mov al,0x80
    mov dx,0x70
    out dx,al
;======MMIO======
mov eax,0x80000060
mov dx,0x0CF8
out dx,eax
mov eax,0xE0000001
mov dx,0x0CFC
out dx,eax
;======DDR-3======
mov edi,0xE00FB000
mov [edi+4],0xA0
mov [edi+8],byte 0x12
mov [edi+2],byte 0x48
loope:
    test [edi],2
    je loope
mov ebx,[edi+5]
push ebx
mov esi,0xE0000000
mov [esi+0x48],0xFED10001
mov ecx,0xFED10000
mov [ecx+0x2810],dword 2 
pop ebx
add ebx,1 
mov [ecx+0x4000],ebx
mov [ecx+0x5000],ebx
mov edx,[ecx+0x4010]
or edx,1
mov [ecx+4010],edx
jmp loff
jmp loff
;======================
;======================
;======================
haswell:
;======MMIO======
mov eax,0x80000060
mov dx,0x0CF8
out dx,eax

mov eax,0xE0000001
mov dx,0x0CFC
out dx,eax
;======PCIe======
mov eax,[0xE000803C]
or eax,0x00000008
mov [0xE000803C],eax
;======LPC======
mov eax,0x00700010
mov [0xE00F8080],eax
;======PMBASE======
mov eax,0x00000501
mov [0xE00F80AC],eax
;======PCI_command======
mov eax,[0xE00F8004]
or eax,0x00000007
mov [0xE00F8004],eax
;======CAR======
mov ecx,0x000002FF
rdmsr
and eax,0xFFFFF3FF
wrmsr 
mov ecx,0x00000200
mov eax,0xFEF00006
xor edx,edx
wrmsr
mov ecx,0x00000201
mov eax,0xFFFF0800
mov edx,0x0000000F
wrmsr 
mov ecx,0x000002FF
rdmsr
or eax,0x00000C00
wrmsr 
mov edi,0xFEF00000
mov ecx,16386
xor eax,eax
rep stosd
mov esp,0xFEF0FFFC
mov ebp,esp
;======DDR-3======
mov edi,0xE00FB000
mov [edi+4],0xA0
mov [edi+8],byte 0x12
mov [edi+2],byte 0x48
loopq:
    test [edi],2
    je loopq
mov ebx,[edi+5]
push ebx
mov esi,0xE0000000
mov [esi+0x48],0xFED10001
mov ecx,0xFED10000
mov [ecx+0x2810],dword 2 
pop ebx
add ebx,1 
mov [ecx+0x4000],ebx
mov [ecx+0x5000],ebx
mov edx,[ecx+0x4010]
or edx,1
mov [ecx+4010],edx
jmp loff
;======LONG_MODE======
loff:
;======SATA======
mov esi,0xE00FA000
mov [esi+0x24],dword 0xFE044000
mov edx,[esi+0x06]
or edx,0x06
mov [esi+0x04],edx
mov edx,0xFE044000
mov [edx+0x100],0x00200000
mov [edx+0x108],0x00100000
mov [edx+0x138],dword 1

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
   mov dword [0x00012FB0],0xFEC0019B
   mov dword [0x00012FB8],0xFEE0019B
   mov dword [0x00012004],0x00000000
   mov dword [0x00011FF8],0xFFC00083
   mov dword [0x00011FFC],0x00000000
   mov dword [0x00011018],0xE000019B
   mov dword [0x0001101C],0x00000001
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
   jmp dword 0x08:0x00000000000e02e6
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
    jmp RBFI_MAIN
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
RBFI_MAIN:
;+=+=+=+=+=+=+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;=+=+=+=+=+=+=+=+=+=+=+=+=+=+==+=+=+=+=+=+=+=+=+=+=+=+=+=+=
section .text
[bits 64]
;======IDT======
jmp lol2
align 16
idt_table:
times 256 dq 0, 0
idt_end:

align 16
    align 16
idt_ptr:
dw idt_end - idt_table - 1
dq (0xFFFE0000+(idt_table-startcli))

xor rcx, rcx
mov rdi,0x000E2210
add rdi,(idt_table-startcli)
.fill_idt:
    lea rax,[rel fault]
    mov rbx, rdi
    mov r8, rcx
    shl r8, 4
    add rbx, r8
    mov [rbx],ax
    
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
    lol2:
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
;======COM======
jmp HDMI
engine:
push rax
push rsi
mov rsi,0xE0018014
.loopw:
    mov al,[rsi]
    test al,0x20
    jz .loopw
    mov rsi,0xE0018000
    mov [rsi],al
    pop rsi
    pop rax
    ret
;======HDMI======
HDMI:
xor rax,rax
mov [rax+0x06014],dword 0x80000000
mov [rax+0x6000C],dword 0x800C0000
mov [rax+0x7200C],dword 0x80000000
mov [rax+0x72008],dword 0x80000000
mov [rax+0xE1140],dword 0x84000000
mov [rax+0xC400C],dword 0x00000200
;======VGA======
mov r11,0xE0000000
add r11,0x2000
mov eax,[r11]
and eax,0x0000FFFF
cmp eax,0x8086
jne speaker 

mov rdx,[r11+0x18]
mov r8,rdx
and rdx,0xFFFFFFF0

add rdi,0x04
mov r9,rdi 
or r9,0x02

speaker:
    hlt
    jmp speaker 
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
logo:
        fff:
        cld
        mov rdi,rax
        add rdi,0x6E400
        lea rsi,[rel logo] 
        mov rcx,8193
        rep movsd
        hlt
;======USB-2======
mov dx,0x0CF8
mov eax, 0x80001810
out dx,eax

mov dx,0x0CFC
in eax,dx

and rax,0xFFFFFFFFFFFFFFF0
mov r15,rax

mov rbx,[r15]
mov r14,r15
movzx rax,ebx 
add r14,rax

usb_ff:
mov [rax],r15
movzx rbx,byte [rax]
mov r14,r15
add r14,rbx


mov rax,[r14]
or rax,1
mov [r14],rax
mov [r14+0x40],0x1
mov rax,[r14+0x40]
cmp rax,0
jne ussb
hlt
;======BSS======
usb_cbw_size equ 0x00020100
usb_cbw equ 31
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

lea rax,[abs usb_cbw_size]
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
mov [rax+22],word 0x0002
mov [rax+24],byte 0

mov [0x2004C],rax
mov [r14+0x18],0x20000
mov r12,[r14+0x00]
or r12,0x21
mov [r14+0x00],r12
.loop_ff:
    mov r11,[0x20048]
    mov eax,r11d
    test eax,0x80
    je .loop_ff
;======BOOTING======
;mov al,'B'        ;+
;call engine       ;=
;mov al,'o'        ;+ 
;call engine       ;=
;mov al,'o'        ;+ 
;call engine       ;= 
;mov al,'t'        ;+ 
;call engine       ;=
;mov al,'i'        ;+ 
;call engine       ;=
;mov al,'n'        ;+
;call engine       ;=
;mov al,'g'        ;+
;call engine       ;=
;mov al,'.'        ;+
;call engine       ;=
;mov al,'.'        ;+
;call engine       ;=
;mov al,'.'        ;+
;call engine       ;=
;===================
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
    je .loopd

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
    je .loopz
;=+=+=+=+=+=+=+=+=+=+=+=+=+=+==+=+=+=+=+=+=+=+=+=+=+=+=+=+=
;+=+=+=+=+=+=+=+=+=+=+=+=+=+=++=+=+=+=+=+=+=+=+=+=+=+=+=+=+
;=+=+=+=+=+=+=+=+=+=+=+=+=+=+==+=+=+=+=+=+=+=+=+=+=+=+=+=+=
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