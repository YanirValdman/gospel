[bits 32]
[org 0x10000]

kernel_start:
    mov ax,0x10
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov esp,0x90000
    cld

    call idt_init
    call pic_init

    call apply_palette
    call draw_image
    call draw_hebrew

    sti

hang:
    call process_command
    hlt
    jmp hang

process_command:
    cmp dword [command_ready],1
    jne .done

    mov dword [command_ready],0

    mov esi,command_buffer

    mov ax,[esi]
    cmp ax,0x05E2
    jne .unknown

    mov ax,[esi+2]
    cmp ax,0x05D6
    jne .unknown

    mov ax,[esi+4]
    cmp ax,0x05E8
    jne .unknown

    mov ax,[esi+6]
    cmp ax,0x05D4
    jne .unknown

    mov ax,[esi+8]
    test ax,ax
    jnz .unknown

    call command_help
    jmp .done

.unknown:
    mov eax,0x05D0
    call terminal_put_char

.done:
    ret

command_help:
    mov eax,0x05E2
    call terminal_put_char

    mov eax,0x05D6
    call terminal_put_char

    mov eax,0x05E8
    call terminal_put_char

    mov eax,0x05D4
    call terminal_put_char

    mov eax,0x20
    call terminal_put_char

    mov eax,0x05E4
    call terminal_put_char

    mov eax,0x05E7
    call terminal_put_char

    mov eax,0x05D5
    call terminal_put_char

    mov eax,0x05D3
    call terminal_put_char

    mov eax,0x05D5
    call terminal_put_char

    mov eax,0x05EA
    call terminal_put_char

    ret
    
draw_image:
    mov esi,image_data
    mov edi,0xA0000
    mov ecx,16000
    rep movsd
    ret

apply_palette:
    push ax
    push dx

    mov dx,0x3C8
    mov al,0x88
    out dx,al

    inc dx

    mov al,40
    out dx,al

    xor al,al
    out dx,al

    mov al,50
    out dx,al

    pop dx
    pop ax
    ret

idt_init:
    mov edi,idt
    mov eax,default_interrupt_handler
    mov ecx,256

.fill:
    mov word [edi],ax
    mov word [edi+2],0x08
    mov byte [edi+4],0
    mov byte [edi+5],10001110b

    shr eax,16
    mov word [edi+6],ax

    mov eax,default_interrupt_handler

    add edi,8
    loop .fill

    mov edi,idt + (0x21 * 8)
    mov eax,keyboard_handler

    mov word [edi],ax
    mov word [edi+2],0x08
    mov byte [edi+4],0
    mov byte [edi+5],10001110b

    shr eax,16
    mov word [edi+6],ax

    lidt [idt_descriptor]

    ret

default_interrupt_handler:
    pusha

    mov al,0x20
    out 0x20,al

    popa
    iretd

pic_init:
    mov al,0x11
    out 0x20,al
    out 0xA0,al

    mov al,0x20
    out 0x21,al

    mov al,0x28
    out 0xA1,al

    mov al,0x04
    out 0x21,al

    mov al,0x02
    out 0xA1,al

    mov al,0x01
    out 0x21,al
    out 0xA1,al

    mov al,0xFD
    out 0x21,al

    mov al,0xFF
    out 0xA1,al

    ret

keyboard_handler:
    pusha

    in al,0x60

    test al,80h
    jnz .done

    call keyboard_translate

.done:
    mov al,0x20
    out 0x20,al

    popa
    iretd

keyboard_translate:
    cmp al,0x10
    je .q

    cmp al,0x11
    je .w

    cmp al,0x12
    je .e

    cmp al,0x13
    je .r

    cmp al,0x14
    je .t

    cmp al,0x15
    je .y

    cmp al,0x16
    je .u

    cmp al,0x17
    je .i

    cmp al,0x18
    je .o

    cmp al,0x19
    je .p

    cmp al,0x1E
    je .a

    cmp al,0x1F
    je .s

    cmp al,0x20
    je .d

    cmp al,0x21
    je .f

    cmp al,0x22
    je .g

    cmp al,0x23
    je .h

    cmp al,0x24
    je .j

    cmp al,0x25
    je .k

    cmp al,0x26
    je .l

    cmp al,0x2C
    je .z

    cmp al,0x2D
    je .x

    cmp al,0x2E
    je .c

    cmp al,0x2F
    je .v

    cmp al,0x30
    je .b

    cmp al,0x31
    je .n

    cmp al,0x32
    je .m

    cmp al,0x33
    je .comma

    cmp al,0x34
    je .period

    cmp al,0x39
    je .space

    cmp al,0x0E
    je .backspace

    cmp al,0x1C
    je .enter

    ret

.q:
    ret

.w:
    ret

.e:
    mov eax,0x5E7
    jmp .append

.r:
    mov eax,0x5E8
    jmp .append

.t:
    mov eax,0x5D0
    jmp .append

.y:
    mov eax,0x5D8
    jmp .append

.u:
    mov eax,0x5D5
    jmp .append

.i:
    mov eax,0x5DF
    jmp .append

.o:
    mov eax,0x5DD
    jmp .append

.p:
    mov eax,0x5E4
    jmp .append

.a:
    mov eax,0x5E9
    jmp .append

.s:
    mov eax,0x5D3
    jmp .append

.d:
    mov eax,0x5D2
    jmp .append

.f:
    mov eax,0x5DB
    jmp .append

.g:
    mov eax,0x5E2
    jmp .append

.h:
    mov eax,0x5D9
    jmp .append

.j:
    mov eax,0x5D7
    jmp .append

.k:
    mov eax,0x5DC
    jmp .append

.l:
    mov eax,0x5DA
    jmp .append

.z:
    mov eax,0x5D6
    jmp .append

.x:
    mov eax,0x5E1
    jmp .append

.c:
    mov eax,0x5D1
    jmp .append

.v:
    mov eax,0x5D4
    jmp .append

.b:
    mov eax,0x5E0
    jmp .append

.n:
    mov eax,0x5DE
    jmp .append

.m:
    mov eax,0x5E6
    jmp .append

.comma:
    mov eax,0x5EA
    jmp .append

.period:
    mov eax,0x5E5
    jmp .append

.space:
    mov eax,0x20
    jmp .append

.backspace:
    call remove_last_char
    ret

.enter:
    call terminal_submit_command
    ret

.append:
    call terminal_put_char
    ret

align 4

image_data:
    incbin "herev.bin"

align 8

idt:
    times 256 dq 0

idt_end:

idt_descriptor:
    dw idt_end - idt - 1
    dd idt

%include "terminal.asm"
%include "ata.asm"
%include "program.asm"