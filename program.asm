[bits 32]
PROGRAM_HEADER_BUFFER equ 0x80000

program_lba:
    dd 0

program_size:
    dd 0

program_load_address:
    dd 0

program_entry:
    dd 0

program_sectors:
    dd 0

load_program:
    mov [program_lba],eax

    mov eax,[program_lba]
    mov ecx,1
    mov edi,PROGRAM_HEADER_BUFFER

    call disk_read

    cmp dword [PROGRAM_HEADER_BUFFER],0x31534F47
    jne .invalid_program

    mov eax,[PROGRAM_HEADER_BUFFER + 4]


    cmp eax,16
    jb .invalid_program

    mov [program_size],eax

    mov eax,[PROGRAM_HEADER_BUFFER + 8]
    mov [program_load_address],eax

    mov eax,[PROGRAM_HEADER_BUFFER + 12]

    cmp eax,[program_size]
    jae .invalid_program

    mov [program_entry],eax


    mov eax,[program_size]
    add eax,511
    shr eax,9

    mov [program_sectors],eax

    mov eax,[program_lba]
    mov ecx,[program_sectors]
    mov edi,[program_load_address]

    call disk_read

    mov eax,[program_load_address]
    add eax,[program_entry]
    jmp eax

.invalid_program:

    cli

.hang:

    hlt
    jmp .hang