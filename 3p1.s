; Day 3 Part 1 of AoC 2022
;
; Wow this took a lot of code and time to make

section .text
    global _start

%include "lib/utils.s"
%include "lib/mem.s"
%include "lib/list.s"
%include "lib/fs.s"
%include "lib/io.s"

    PROT_READ equ 0x1
    PROT_WRITE equ 0x2

    MAP_ANONYMOUS equ 0x20
    MAP_PRIVATE equ 0x2

_start:
    ; [esp+12] = total
    push 0

    ; [esp+8] = output buffer
    ; [esp+4] = buffer A
    ; [esp] = fd
    sub esp, 12

    mov eax, PATH
    call open_file
    mov dword [esp], eax

loop:
    mov eax, 48
    call new_byte_list
    mov dword [esp + 4], eax

    mov eax, 16
    call new_byte_list
    mov dword [esp + 8], eax

    mov eax, dword [esp]
    mov ebx, dword [esp + 4]
    call read_line

    cmp eax, 0
    jne after

    mov eax, dword [esp + 4]
    call byte_list_split

    mov ecx, dword [esp + 8]
    call byte_list_intersects

    push eax
    mov eax, 0
    mov al, byte [ecx + 8]
    call char_to_weight
    add dword [esp+16], eax ; +4 cause we pushed eax
    pop eax

    jmp loop
after:
    dbg dword [esp+12]

    call dealloc
    mov eax, ebx
    call dealloc
    mov eax, ecx
    call dealloc

    add esp, 12 + 4

    call exit

; argument: al = char
; returns: al = weight
char_to_weight:

    cmp al, 97 ; 'a'
    jge not_upper

    sub al, 65 ; 'A'
    add al, 26

    jmp after_calc
not_upper:
    sub al, 97 ; 'a'
after_calc:
    add al, 1
    ret

section .data
    PATH db "day3.txt", 0
