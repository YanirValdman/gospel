global _start

section .data
    hello db 10, "God_Calculator", 10
    hello_length equ $ - hello

    choice db "Please make your choice:", 10
    choice_length equ $ - choice

    operator db "1. Add", 10, "2. Subtract", 10, "3. Exit", 10
    operator_length equ $ - operator

    first_number db "Enter first number:", 10
    first_number_length equ $ - first_number

    second_number db "Enter second number:", 10
    second_number_length equ $ - second_number

    plus db " + "
    plus_length equ $ - plus

    minus db " - "
    minus_length equ $ - minus

    equals db " = "
    equals_length equ $ - equals

    newline db 10

section .bss
    tmp resb 2
    first_temp resb 2
    second_temp resb 2
    result resb 1

section .text
global _start

print:
    mov rax, 1
    mov rdi, 1
    syscall
    ret

read_input:
    mov rax, 0
    mov rdi, 0
    mov rdx, 2
    syscall
    ret

_start:
LOOP:
    mov rsi, hello
    mov rdx, hello_length
    call print

    mov rsi, choice
    mov rdx, choice_length
    call print

    mov rsi, operator
    mov rdx, operator_length
    call print

    mov rsi, tmp
    call read_input

    cmp byte [tmp], '1'
    je Add
    cmp byte [tmp], '2'
    je Subtract
    cmp byte [tmp], '3'
    je Exit

    jmp LOOP

Add:
    mov rsi, first_number
    mov rdx, first_number_length
    call print

    mov rsi, first_temp
    call read_input

    mov rsi, second_number
    mov rdx, second_number_length
    call print

    mov rsi, second_temp
    call read_input

    movzx r8, byte [first_temp]
    sub r8, '0'

    movzx r9, byte [second_temp]
    sub r9, '0'

    add r8, r9
    add r8, '0'

    mov byte [result], r8b

    mov rsi, first_temp
    mov rdx, 1
    call print

    mov rsi, plus
    mov rdx, plus_length
    call print

    mov rsi, second_temp
    mov rdx, 1
    call print

    mov rsi, equals
    mov rdx, equals_length
    call print

    mov rsi, result
    mov rdx, 1
    call print

    mov rsi, newline
    mov rdx, 1
    call print

    jmp LOOP

Subtract:
    mov rsi, first_number
    mov rdx, first_number_length
    call print

    mov rsi, first_temp
    call read_input

    mov rsi, second_number
    mov rdx, second_number_length
    call print

    mov rsi, second_temp
    call read_input

    movzx r8, byte [first_temp]
    sub r8, '0'

    movzx r9, byte [second_temp]
    sub r9, '0'

    sub r8, r9
    add r8, '0'

    mov byte [result], r8b

    mov rsi, first_temp
    mov rdx, 1
    call print

    mov rsi, minus
    mov rdx, minus_length
    call print

    mov rsi, second_temp
    mov rdx, 1
    call print

    mov rsi, equals
    mov rdx, equals_length
    call print

    mov rsi, result
    mov rdx, 1
    call print

    mov rsi, newline
    mov rdx, 1
    call print

    jmp LOOP

Exit:
    mov rax, 60
    xor rdi, rdi
    syscall