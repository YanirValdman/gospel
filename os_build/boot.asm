[bits 16]
[org 0x7C00]

KERNEL_LOAD_SEG equ 0x1000
KERNEL_LBA      equ 1
KERNEL_SECTORS  equ 126

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov [boot_drive], dl


enable_a20:
    in al, 0x92
    or al, 00000010b
    out 0x92, al
    mov ax, 0x0013
    int 0x10

load_kernel:
    mov si, dap
    mov ah, 0x42
    mov dl, [boot_drive]
    int 0x13

    jc disk_error
    cli
    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:protected_mode

dap:

    db 0x10
    db 0
    dw KERNEL_SECTORS
    dw 0x0000
    dw KERNEL_LOAD_SEG

    dq KERNEL_LBA

[bits 32]

protected_mode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000
    cld
    jmp 0x10000

disk_error:
    cli
.error:
    hlt
    jmp .error

[bits 16]

gdt_start:
    dq 0

gdt_code:

    dw 0xFFFF
    dw 0
    db 0
    db 10011010b
    db 11001111b
    db 0

gdt_data:

    dw 0xFFFF
    dw 0
    db 0
    db 10010010b
    db 11001111b
    db 0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

boot_drive db 0
times 510-($-$$) db 0
dw 0xAA55
