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


command_ready:
    dd 0

command_buffer:
    times 128 dw 0

command_buffer_end:


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

    sub ebx,8
    add esi,2
    jmp .next

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

    cmp ax,0x000A
    je .newline

    sub dword [terminal_cursor_x],8
    call redraw_terminal
    jmp .done

.newline:
    mov dword [terminal_cursor_x],TERMINAL_RIGHT
    add dword [terminal_cursor_y],8

    cmp dword [terminal_cursor_y],TERMINAL_TOP+TERMINAL_HEIGHT
    jb .redraw

    mov dword [terminal_cursor_y],TERMINAL_TOP

.redraw:
    call redraw_terminal

.done:
    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

terminal_print_text:
    push eax
    push esi

.next:
    movzx eax,word [esi]

    test eax,eax
    jz .done

    call terminal_put_char

    add esi,2
    jmp .next

.done:
    pop esi
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

.next:
    movzx eax,word [esi]

    test eax,eax
    jz .done

    cmp eax,0x000A
    je .newline

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
    jae .continue

    mov ebx,TERMINAL_RIGHT
    add edx,8

    cmp edx,TERMINAL_TOP+TERMINAL_HEIGHT
    jae .done

.continue:
    add esi,2
    jmp .next

.newline:
    mov ebx,TERMINAL_RIGHT
    add edx,8

    cmp edx,TERMINAL_TOP+TERMINAL_HEIGHT
    jae .done

    add esi,2
    jmp .next

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret


remove_last_char:
    push eax
    push edi

    mov edi,terminal_text

.find_end:
    mov ax,[edi]

    test ax,ax
    jz .found_end

    add edi,2

    cmp edi,terminal_text_end
    jb .find_end

    jmp .done

.found_end:
    cmp edi,terminal_text
    je .done

    sub edi,2

    mov word [edi],0

    call terminal_recalculate_cursor
    call redraw_terminal

.done:
    pop edi
    pop eax
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


terminal_submit_command:
    push eax
    push esi
    push edi
    push ecx

    mov esi,terminal_text
    mov edi,command_buffer

.copy:
    mov ax,[esi]

    test ax,ax
    jz .finished

    mov [edi],ax

    add esi,2
    add edi,2

    jmp .copy

.finished:
    mov word [edi],0

    mov dword [command_ready],1

    mov esi,terminal_text
    mov ecx,128

.clear:
    mov word [esi],0
    add esi,2
    loop .clear

    mov dword [terminal_cursor_x],TERMINAL_RIGHT
    add dword [terminal_cursor_y],8

    cmp dword [terminal_cursor_y],TERMINAL_TOP+TERMINAL_HEIGHT
    jb .redraw

    mov dword [terminal_cursor_y],TERMINAL_TOP

.redraw:
    call redraw_terminal

    pop ecx
    pop edi
    pop esi
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


align 4

font_start:
    incbin "font.bin"