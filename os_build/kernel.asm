[bits 16]
[org 0]

jmp init

init:
    cli
    mov ax, 0x1000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFFFE
    sti

    mov ax, 0x0013
    int 0x10

    call apply_palette
    call draw_image
    call draw_text

main_loop:
    mov ah, 0
    int 0x16
    cmp al, '*'
    jne main_loop

    inc byte [data_start]
    cmp byte [data_start], 4
    jl .ok
    mov byte [data_start], 0

.ok:
    call apply_palette
    jmp main_loop

draw_image:
    push ds          
    mov ax, 0x1000
    mov ds, ax   
    mov ax, 0xA000
    mov es, ax
    mov si, image_data
    xor di, di
    mov cx, 32000
    rep movsw
    pop ds
    ret

%macro DRAW_CHAR_AT 3
    mov al, %1
    mov bx, %2
    mov dx, %3
    call .draw_single_char
%endmacro

draw_text:
    DRAW_CHAR_AT 'g', 10, 10
    DRAW_CHAR_AT 'o', 18, 10
    DRAW_CHAR_AT 's', 26, 10
    DRAW_CHAR_AT 'p', 34, 10
    DRAW_CHAR_AT 'e', 42, 10
    DRAW_CHAR_AT 'l', 50, 10
    DRAW_CHAR_AT 'o', 58, 10
    DRAW_CHAR_AT 's', 66, 10
    ret

.draw_single_char:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    push ds
    push bp

    mov ax, 0x1130
    mov bx, 0x0600
    int 0x10

    mov ax, 0xA000
    mov es, ax

    sub al, 32
    xor ah, ah
    shl ax, 3
    add bp, ax     

    mov cx, 8      
.row_loop:
    push cx
    mov al, [es:bp] 
    mov cx, 8
.bit_loop:
    push cx
    test al, 0x80
    jz .no_pixel
    
    push ax
    mov ax, dx
    mov di, 320
    mul di
    add ax, bx
    mov di, ax
    mov [es:di], byte 15
    pop ax
.no_pixel:
    shl al, 1
    inc bx
    pop cx
    loop .bit_loop
    
    sub bx, 8
    inc dx
    inc bp   
    pop cx
    loop .row_loop

    pop bp
    pop ds
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

apply_palette:
    push ax
    push dx
    mov dx, 0x3C8
    mov al, 0x88
    out dx, al
    inc dx
    mov al, [data_start]
    cmp al, 1
    je .blood
    cmp al, 2
    je .grass
    cmp al, 3
    je .sea
.default:
    mov al, 40
    out dx, al
    xor al, al
    out dx, al
    mov al, 50
    out dx, al
    jmp .done
.blood:
    mov al, 63
    out dx, al
    xor al, al
    out dx, al
    xor al, al
    out dx, al
    jmp .done
.grass:
    xor al, al
    out dx, al
    mov al, 63
    out dx, al
    xor al, al
    out dx, al
    jmp .done
.sea:
    xor al, al
    out dx, al
    xor al, al
    out dx, al
    mov al, 63
    out dx, al
.done:
    pop dx
    pop ax
    ret

data_start db 0

align 2
image_data:
    incbin "herev.bin"