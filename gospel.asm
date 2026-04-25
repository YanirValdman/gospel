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

    mov al, [buffer]
    and al, 7

    cmp al, 0
    je print1
    cmp al, 1
    je print2
    cmp al, 2
    je print3
    cmp al, 3
    je print4
    jmp print5

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

write:
    mov rax, 1
    mov rdi, 1
    syscall

    jmp main_loop