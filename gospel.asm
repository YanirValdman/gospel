section .data

word1 db "enlightenment", 10
len1 equ $ - word1

word2 db "power", 10
len2 equ $ - word2

word3 db "destiny", 10
len3 equ $ - word3

word4 db "dream", 10
len4 equ $ - word4

word5 db "purpose", 10
len5 equ $ - word5

word6 db "holy", 10
len6 equ $ - word6

word7 db "love", 10
len7 equ $ - word7

word8 db "believe", 10
len8 equ $ - word8

word9 db "Temple", 10
len9 equ $ - word9

word10 db "Birth", 10
len10 equ $ - word10

urandom db "/dev/urandom", 0

section .bss
buffer resb 1

section .text
global _start

_start:

main_loop:

read_input:
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, 1
    syscall

    cmp byte [buffer], 10
    jne read_input

    mov rax, 2
    mov rdi, urandom
    mov rsi, 0
    syscall

    mov rdi, rax

    mov rax, 0
    mov rsi, buffer
    mov rdx, 1
    syscall

    mov rax, 3
    syscall

    movzx rax, byte [buffer]
    xor rdx, rdx
    mov rcx, 10
    div rcx
    mov al, dl

    cmp al, 0
    je print1
    cmp al, 1
    je print2
    cmp al, 2
    je print3
    cmp al, 3
    je print4
    cmp al, 4
    je print5
    cmp al, 5
    je print6
    cmp al, 6
    je print7
    cmp al, 7
    je print8
    cmp al, 8
    je print9
    cmp al, 9
    je print10

print1:
    mov rsi, word1
    mov rdx, len1
    jmp write

print2:
    mov rsi, word2
    mov rdx, len2
    jmp write

print3:
    mov rsi, word3
    mov rdx, len3
    jmp write

print4:
    mov rsi, word4
    mov rdx, len4
    jmp write

print5:
    mov rsi, word5
    mov rdx, len5
    jmp write

print6:
    mov rsi, word6
    mov rdx, len6
    jmp write

print7:
    mov rsi, word7
    mov rdx, len7
    jmp write

print8:
    mov rsi, word8
    mov rdx, len8
    jmp write

print9:
    mov rsi, word9
    mov rdx, len9
    jmp write

print10:
    mov rsi, word10
    mov rdx, len10

write:
    mov rax, 1    
    mov rdi, 1      
    syscall

    jmp main_loop
