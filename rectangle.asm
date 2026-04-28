org 100h

start:
    mov ax, 0013h     
    int 10h

    mov ah, 0Ch      
    mov al, 0Fh      

    mov cx, 100      
    mov dx, 50        

top_line:
    int 10h
    inc cx
    cmp cx, 300       
    jl top_line

    mov cx, 100        
    mov dx, 150     

bottom_line:
    int 10h
    inc cx
    cmp cx, 300       
    jl bottom_line

    mov cx, 100       
    mov dx, 50       
left_line:
    int 10h
    inc dx
    cmp dx, 150
    jl left_line

    mov cx, 300
    mov dx, 50

right_line:
    int 10h
    inc dx
    cmp dx, 150
    jl right_line

    mov ah, 4Ch     
    int 21h