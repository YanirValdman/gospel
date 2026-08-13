[bits 32]

ATA_DATA         equ 0x1F0
ATA_SECTOR_COUNT equ 0x1F2
ATA_LBA_LOW      equ 0x1F3
ATA_LBA_MID      equ 0x1F4
ATA_LBA_HIGH     equ 0x1F5
ATA_DRIVE        equ 0x1F6
ATA_STATUS       equ 0x1F7
ATA_COMMAND      equ 0x1F7
ATA_PRIMARY_CTRL equ 0x3F6
ATA_CMD_READ     equ 0x20


; EAX = starting LBA
; ECX = number of sectors
; EDI = destination

disk_read:

    push ebx
    push edx
    push esi

    mov esi,eax          ; current LBA
    mov ebx,ecx          ; remaining sectors

.next_sector:

    test ebx,ebx
    jz .done

    ; Select drive
    mov edx,esi
    shr edx,24
    and dl,0x0F
    or dl,0xE0

    mov al,dl
    mov dx,ATA_DRIVE
    out dx,al

    ; 400ns delay
    mov dx,ATA_PRIMARY_CTRL
    in al,dx
    in al,dx
    in al,dx
    in al,dx

    ; Read one sector
    mov dx,ATA_SECTOR_COUNT
    mov al,1
    out dx,al

    ; LBA low
    mov edx,esi
    mov al,dl
    mov dx,ATA_LBA_LOW
    out dx,al

    ; LBA mid
    mov edx,esi
    shr edx,8
    mov al,dl
    mov dx,ATA_LBA_MID
    out dx,al

    ; LBA high
    mov edx,esi
    shr edx,16
    mov al,dl
    mov dx,ATA_LBA_HIGH
    out dx,al

    ; Command
    mov dx,ATA_COMMAND
    mov al,ATA_CMD_READ
    out dx,al


.wait:

    mov dx,ATA_STATUS
    in al,dx

    test al,80h
    jnz .wait

    test al,01h
    jnz .error

    test al,08h
    jz .wait

    ; 512 bytes
    mov dx,ATA_DATA
    mov ecx,256
    rep insw

    ; Next destination
    add edi,512

    ; Next sector
    inc esi
    dec ebx

    jmp .next_sector


.error:

    cli

.error_loop:
    hlt
    jmp .error_loop


.done:

    pop esi
    pop edx
    pop ebx

    ret