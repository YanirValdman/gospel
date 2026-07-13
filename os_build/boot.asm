[bits 16]
[org 0x7C00]

KERNEL_SEGMENTS equ 200

start:
jmp short main
nop

OEMName db "OSBOOT  "
BytesPerSector dw 512
SectorsPerCluster db 1
ReservedSectors dw 1
NumberOfFATs db 2
RootEntries dw 224
TotalSectors dw 2880
MediaDescriptor db 0xF0
SectorsPerFAT dw 9
SectorsPerTrack dw 18
Heads dw 2
HiddenSectors dd 0
TotalSectorsBig dd 0
DriveNumber db 0
Reserved db 0
ExtendedSignature db 0x29
SerialNumber dd 0x67676767
VolumeLabel db "MY OS      "
FileSystem db "FAT12   "

main:
    mov [boot_drive], dl

    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov ax,0x1000
    mov es,ax
    mov bx,0

    mov byte [track],0
    mov byte [head],0
    mov byte [sector],2
    mov word [count],132

next_sector:

    cmp word [count],0
    je done

    mov ah,2
    mov al,1
    mov ch,[track]
    mov cl,[sector]
    mov dh,[head]
    mov dl,[boot_drive]
    int 13h
    jc error

    add bx,512
    jnc .no_wrap

    mov ax,es
    add ax,0x1000
    mov es,ax

    .no_wrap:

        dec word [count]

    inc byte [sector]
    cmp byte [sector],19
    jne next_sector

    mov byte [sector],1

    inc byte [head]
    cmp byte [head],2
    jne next_sector

    mov byte [head],0
    inc byte [track]
    jmp next_sector

done:
    jmp 0x1000:0

error:
    hlt
    jmp error

boot_drive db 0
track db 0
head db 0
sector db 2
count dw 0

times 510-($-$$) db 0
dw 0xAA55