[bits 16]
[org 0x7C00]

KERNEL_LOAD_SEG equ 0x1000
KERNEL_LBA      equ 1
KERNEL_SECTORS  equ 134
CHUNK_SECTORS   equ 64

start:
    cli

    xor ax,ax
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov sp,0x7C00

    mov [boot_drive],dl

    call enable_a20

    mov ax,0x0013
    int 0x10

    call load_kernel

    cli

    lgdt [gdt_descriptor]

    mov eax,cr0
    or eax,1
    mov cr0,eax

    jmp 0x08:protected_mode


enable_a20:
    in al,0x92
    or al,00000010b
    out 0x92,al
    ret


load_kernel:
    mov word [sectors_left],KERNEL_SECTORS

    mov dword [current_lba],KERNEL_LBA

    mov word [current_segment],KERNEL_LOAD_SEG

.load_chunk:

    mov ax,[sectors_left]

    cmp ax,CHUNK_SECTORS
    jbe .use_remaining

    mov ax,CHUNK_SECTORS

.use_remaining:
    mov [dap+2],ax

    mov word [dap+4],0

    mov ax,[current_segment]
    mov [dap+6],ax

    mov eax,[current_lba]
    mov [dap+8],eax

    mov dword [dap+12],0

    mov si,dap
    mov dl,[boot_drive]
    mov ah,0x42
    int 0x13

    jc disk_error

    xor eax,eax
    mov ax,[dap+2]

    sub [sectors_left],ax

    add [current_lba],eax

    mov bx,ax
    shl bx,5

    mov ax,[current_segment]
    add ax,bx
    mov [current_segment],ax

    cmp word [sectors_left],0
    jne .load_chunk

    ret


disk_error:
    cli

.error:
    hlt
    jmp .error


[bits 32]

protected_mode:
    mov ax,0x10

    mov ds,ax
    mov es,ax
    mov fs,ax
    mov gs,ax
    mov ss,ax

    mov esp,0x90000

    cld

    jmp 0x10000


[bits 16]

dap:
    db 0x10
    db 0
    dw 0
    dw 0
    dw KERNEL_LOAD_SEG
    dq KERNEL_LBA


sectors_left:
    dw KERNEL_SECTORS

current_lba:
    dd KERNEL_LBA

current_segment:
    dw KERNEL_LOAD_SEG

boot_drive:
    db 0


align 8

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
    dw gdt_end-gdt_start-1
    dd gdt_start


times 510-($-$$) db 0
dw 0xAA55