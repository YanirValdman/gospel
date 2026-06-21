[bits 16]
org 0x7C00

start:
    mov ax, 0x0013
    int 0x10

    mov ax, 0x1000
    mov es, ax
    xor bx, bx

    mov ah, 0x02
    mov al, 125
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0x80
    int 0x13
    jc error

    mov ax, 0x1000
    mov ds, ax
    xor si, si

    mov ax, 0xA000
    mov es, ax
    xor di, di

    mov cx, 64000
    rep movsb

    mov dx, 0x3C8
    mov al, 0x88
    out dx, al
    
    inc dx
    mov al, 40
    out dx, al
    mov al, 0
    out dx, al
    mov al, 50
    out dx, al

hang:
    jmp hang

error:
    jmp error

times 510-($-$$) db 0
dw 0xAA55