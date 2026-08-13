[bits 32]
[org 0x30000]

PROGRAM_LOAD_ADDRESS equ 0x30000

program_header:
    db 'G','O','S','1'

    dd program_end - program_header
    dd PROGRAM_LOAD_ADDRESS
    dd shell_start - program_header


shell_start:

    mov edi,0xA0000
    mov ecx,10000
    mov al,15
    rep stosb

.hang:
    hlt
    jmp .hang


program_end: