[bits 32]

TITLE_X         equ 310
TITLE_Y         equ 10

TERMINAL_RIGHT  equ 302
TERMINAL_LEFT   equ 10
TERMINAL_TOP    equ 120
TERMINAL_WIDTH  equ 300
TERMINAL_HEIGHT equ 72

TERMINAL_LINES  equ 9


terminal_cursor_x:
    dd TERMINAL_RIGHT

terminal_cursor_y:
    dd TERMINAL_TOP


title_text:
    dw 0x05D4
    dw 0x05D1
    dw 0x05E9
    dw 0x05D5
    dw 0x05E8
    dw 0x05D4
    dw 0


terminal_text:
    times 128 dw 0

terminal_text_end:


draw_hebrew:
    push eax
    push ebx
    push edx
    push esi

    mov esi,title_text
    mov ebx,TITLE_X
    mov edx,TITLE_Y

.next:
    movzx eax,word [esi]

    test eax,eax
    jz .done

    cmp eax,0x20
    je .space

    push edx
    push ebx
    push eax
    call draw_char
    add esp,12

.space:
    sub ebx,8
    add esi,2
    jmp .next

.done:
    pop esi
    pop edx
    pop ebx
    pop eax
    ret


terminal_put_char:
    push eax
    push ebx
    push ecx
    push edx
    push edi

    cmp dword [terminal_cursor_x],TERMINAL_LEFT+8
    ja .space_available

    mov dword [terminal_cursor_x],TERMINAL_RIGHT
    add dword [terminal_cursor_y],8

    cmp dword [terminal_cursor_y],TERMINAL_TOP+TERMINAL_HEIGHT
    jb .space_available

    mov dword [terminal_cursor_y],TERMINAL_TOP

.space_available:

    mov edi,terminal_text

.find_end:
    mov bx,[edi]

    test bx,bx
    jz .found

    add edi,2

    cmp edi,terminal_text_end
    jb .find_end

    jmp .done

.found:
    cmp edi,terminal_text_end-2
    jae .done

    mov [edi],ax
    mov word [edi+2],0

    sub dword [terminal_cursor_x],8

    call redraw_terminal

.done:
    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret


redraw_terminal:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov edx,TERMINAL_TOP

.clear_rows:
    mov edi,0xA0000

    mov eax,edx
    imul eax,320
    add edi,eax
    add edi,TERMINAL_LEFT

    mov ecx,TERMINAL_WIDTH
    xor eax,eax

    rep stosb

    inc edx

    mov eax,TERMINAL_TOP
    add eax,TERMINAL_HEIGHT

    cmp edx,eax
    jb .clear_rows

    mov esi,terminal_text
    mov ebx,TERMINAL_RIGHT
    mov edx,TERMINAL_TOP

.draw_text:
    movzx eax,word [esi]

    test eax,eax
    jz .done

    cmp eax,0x20
    je .space

    push edx
    push ebx
    push eax

    call draw_char

    add esp,12

.space:
    sub ebx,8

    cmp ebx,TERMINAL_LEFT+8
    jae .next_char

    mov ebx,TERMINAL_RIGHT
    add edx,8

    cmp edx,TERMINAL_TOP+TERMINAL_HEIGHT
    jae .done

.next_char:
    add esi,2
    jmp .draw_text

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
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

    mov eax,[ebp+8]
    sub eax,0x5D0
    shl eax,3

    mov esi,font_start
    add esi,eax

    mov ebx,[ebp+12]
    mov edx,[ebp+16]

    mov edi,0xA0000
    mov ecx,8

.row_loop:
    push ecx

    mov al,[esi]
    mov ecx,8

.column_loop:
    test al,80h
    jz .no_pixel

    push eax
    push edx

    mov eax,edx
    imul eax,320
    add eax,ebx
    add eax,edi

    mov byte [eax],15

    pop edx
    pop eax

.no_pixel:
    shl al,1
    inc ebx

    loop .column_loop

    sub ebx,8
    inc edx
    inc esi

    pop ecx
    loop .row_loop

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret

terminal_recalculate_cursor:
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov esi,terminal_text
    xor ecx,ecx

.count:
    mov ax,[esi]

    test ax,ax
    jz .calculate

    inc ecx
    add esi,2

    cmp esi,terminal_text_end
    jb .count

.calculate:
    mov eax,TERMINAL_RIGHT
    sub eax,TERMINAL_LEFT
    sub eax,8

    xor edx,edx
    mov ebx,eax

    mov eax,ecx
    xor edx,edx

    mov ebx,36
    div ebx

    mov eax,edx
    shl eax,3
    mov ebx,TERMINAL_RIGHT
    sub ebx,eax

    mov [terminal_cursor_x],ebx

    mov eax,ecx
    xor edx,edx
    mov ebx,36
    div ebx

    shl eax,3
    add eax,TERMINAL_TOP

    mov [terminal_cursor_y],eax

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

    align 4

font_start:
    incbin "font.bin"