; Day 1 Part 1 of AoC 2022

section .text
    global _start

%include "lib/utils.s"

_start:
    mov eax, 5      ; sys_open
    mov ebx, PATH   ; path parameter
    mov ecx, 0      ; flags parameter
    int 0x80

    call read_highest_elf
    call print_num

    call exit

; argument: eax = fd
; return: eax = highest
read_highest_elf:
    push eax  ; [esp+4] = fd
    push dword 0 ; [esp] = highest_calories

read_highest_elf_loop:
    mov eax, dword [esp+4] ; load file descriptor
    call read_single_elf
    ; eax = calories or -1 if EOF
    cmp eax, -1
    je after_read_highest_elf

    cmp eax, dword [esp]
    jl read_highest_elf_not_larger ; jump away if calories < highest

    mov dword [esp], eax
read_highest_elf_not_larger:
    jmp read_highest_elf_loop
after_read_highest_elf:
    mov eax, dword [esp]
    add esp, 8 ; deallocate 8 bytes
    ret

; argument: eax = fd
; return: eax = value or -1 if EOF
read_single_elf:
    push eax ; [esp + 4] = fd
    push dword 0 ; [esp] = calories

read_single_elf_loop:
    mov eax, dword [esp+4] ; load file descriptor
    call read_line

    cmp eax, 0 ; if received number was 0 (new elf) or EOF (done)
    jle after_read_single_elf

    add dword [esp], eax ; add read received number to current calories for this elf

    jmp read_single_elf_loop
after_read_single_elf:
    cmp eax, -1
    jne read_single_elf_valid ; return if not EOF

    cmp dword [esp], 0
    jne read_single_elf_valid ; return if calories != 0 even if EOF

    mov dword [esp], -1 ; set calories to -1
read_single_elf_valid:
    mov eax, dword [esp] ; load calories into eax
    add esp, 8 ; deallocate 8 bytes
    ret

; argument: eax = fd
; return: eax = value, -1 if EOF
read_line:
    push eax ; [esp+5] = dword (fd)
    push dword 0 ; [esp+1] = dword (current number)
    sub esp, 1 ; [esp] = byte (buffer)

read_line_loop:
    ; sys_read(*(esp+BUFFER_SIZE), esp, BUFFER_SIZE);
    mov eax, 3 ; sys_read
    mov ebx, [esp+5] ; fd
    mov ecx, esp
    mov edx, 1
    int 0x80

    cmp eax, 0
    je read_line_eof ; exit if eof found

    cmp byte [esp], 10
    je read_line_after ; exit if character = '\n'

    mov eax, dword [esp + 1] ; contains stored number

    mov ecx, 0
    mov cl, byte [esp] ; contains read character
    sub ecx, '0' ; subtract by '0' to get number from ascii

    ; multiply eax by 10
    mov ebx, 10
    mul ebx

    add eax, ecx
    mov dword [esp + 1], eax

    jmp read_line_loop
read_line_eof:
    cmp dword [esp + 1], 0
    jne read_line_after ; ignore EOF this time, if we are on a valid line
    mov dword [esp + 1], -1
read_line_after:
    mov eax, dword [esp + 1]
    add esp, 9 ; deallocate 4 + 4 + 1 bytes
    ret


section .data
    PATH db "day1.txt", 0