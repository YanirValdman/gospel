[bits 32]
[org 0x10000]
kernel_start:
    mov ax,0x10
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov esp,0x90000
    cld
    call apply_palette
    call draw_image
    call draw_text

hang:
    hlt
    jmp hang
draw_image:

    mov esi,image_data
    mov edi,0xA0000
    mov ecx,16000
    rep movsd
    ret

%macro DRAW_CHAR_AT 3
    push dword %1
    push dword %2
    push dword %3
    call draw_char
    add esp,12
%endmacro

draw_text:

    DRAW_CHAR_AT 0x5D4,10,10
    DRAW_CHAR_AT 0x5E8,18,10
    DRAW_CHAR_AT 0x5D5,26,10
    DRAW_CHAR_AT 0x5E9,34,10
    DRAW_CHAR_AT 0x5D1,42,10
    DRAW_CHAR_AT 0x5D4,50,10

    ret
draw_char:

    push ebp
    mov ebp,esp


    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov eax,[ebp+16]
    sub eax,0x5D0
    shl eax,3
    mov esi,font_start
    add esi,eax
    mov ebx,[ebp+12]
    mov edx,[ebp+8]    
    mov edi,0xA0000
    mov ecx,8          

row_loop:
    push ecx
    mov al,[esi]
    mov ecx,8
column_loop:
    test al,80h
    jz no_pixel
    push eax
    push edx
    mov eax,edx
    imul eax,320
    add eax,ebx
    add eax,edi
    mov byte [eax],15
    pop edx
    pop eax
no_pixel:
    shl al,1
    inc ebx
    loop column_loop
    sub ebx,8
    inc edx
    inc esi
    pop ecx
    loop row_loop
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret

apply_palette:
    push ax
    push dx
    mov dx, 0x3C8
    mov al, 0x88
    out dx, al
    inc dx
.default:
    mov al, 40
    out dx, al
    xor al, al
    out dx, al
    mov al, 50
    out dx, al
    jmp .done

.done:
    pop dx
    pop ax
    ret
data_start db 0
align 4
image_data:

    incbin "herev.bin"

align 4

font_start:

    incbin "font.bin"
