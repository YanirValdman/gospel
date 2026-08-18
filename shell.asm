[bits 32]
[org 0x30000]

PROGRAM_LOAD_ADDRESS equ 0x30000

GOS_SYSCALL_PUTC       equ 1
GOS_SYSCALL_SHELL_START equ 6
GOS_SYSCALL_TANACH     equ 7
GOS_SYSCALL_GET_COMMAND equ 8

program_header:
    db 'G','O','S','1'
    dd program_end - program_header
    dd PROGRAM_LOAD_ADDRESS
    dd shell_start - program_header

shell_start:

    mov eax,GOS_SYSCALL_SHELL_START
    int 0x80

    mov eax,0x05D4
    call shell_putchar

    mov eax,0x05D1
    call shell_putchar

    mov eax,0x05E9
    call shell_putchar

    mov eax,0x05D5
    call shell_putchar

    mov eax,0x05E8
    call shell_putchar

    mov eax,0x05D4
    call shell_putchar

    mov eax,0x20
    call shell_putchar

    mov eax,0x2D
    call shell_putchar

    mov eax,0x3E
    call shell_putchar

    mov eax,0x20
    call shell_putchar

shell_loop:
    mov eax,GOS_SYSCALL_GET_COMMAND
    int 0x80

    cmp eax,2
    je .tanach

    hlt
    jmp shell_loop


.tanach:
    mov eax,GOS_SYSCALL_TANACH
    int 0x80

    mov eax,0x20
    call shell_putchar

    mov eax,0x2D
    call shell_putchar

    mov eax,0x3E
    call shell_putchar

    mov eax,0x20
    call shell_putchar

    jmp shell_loop

shell_putchar:
    push ebx

    mov ebx,eax
    mov eax,GOS_SYSCALL_PUTC
    int 0x80

    pop ebx
    ret


program_end: