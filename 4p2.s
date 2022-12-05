; Day 4 Part 1 of AoC 2022

section .text
    global _start

%include "lib/utils.s"
%include "lib/mem.s"
%include "lib/list.s"
%include "lib/fs.s"
%include "lib/io.s"
%include "lib/ranges.s"

_start:
    ; [esp+8] = total
    push 0

    ; [esp+4] = input list
    ; [esp] = fd
    sub esp, 8

    mov eax, PATH
    call open_file
    mov dword [esp], eax

    mov eax, 32
    call new_byte_list
    mov dword [esp+4], eax

loop:
    mov eax, dword [esp+4]
    call byte_list_clear

    mov ebx, eax
    mov eax, dword [esp]
    call read_line

    cmp eax, 0
    jne after

    mov eax, dword [esp+4]
    call parse_line
    mov esi, eax

    mov eax, dword [esi+8+0]
    mov ebx, dword [esi+8+4]
    mov ecx, dword [esi+8+8]
    mov edx, dword [esi+8+12]
    call range_intersects
    add dword [esp+8], eax

    jmp loop
after:
    dbg dword [esp+8]

    mov eax, dword [esp+4]
    call dealloc
    mov eax, esi
    call dealloc

    add esp, 12

    call exit

; arguments: eax = input string
; returns: eax = list
parse_line:
    push ebx
    push ecx
    push esi

    mov esi, eax

    ; [esp] = list
    mov eax, 32
    call new_list
    push eax

    mov eax, esi

    mov ebx, 0

; --------- start of parse first number ---------
    push eax
    mov ecx, 45 ; '-'
    call byte_list_find_start
    mov ecx, eax
    pop eax
    ; ecx = index of '-'

    push eax
    call parse_num
    mov ebx, eax
    mov eax, dword [esp+4] ; +4 since we pushed eax
    call list_push
    pop eax
; --------- end of parse first number ---------

    mov ebx, ecx
    add ebx, 1

; --------- start of parse second number ---------
    push eax
    mov ecx, 44 ; ','
    call byte_list_find_start
    mov ecx, eax
    pop eax
    ; ecx = index of ','

    push eax
    call parse_num
    mov ebx, eax
    mov eax, dword [esp+4] ; +4 since we pushed eax
    call list_push
    pop eax
; --------- end of parse second number ---------

    mov ebx, ecx
    add ebx, 1

; --------- start of parse third number ---------
    push eax
    mov ecx, 45 ; '-'
    call byte_list_find_start
    mov ecx, eax
    pop eax
    ; ecx = index of '-'

    push eax
    call parse_num
    mov ebx, eax
    mov eax, dword [esp+4] ; +4 since we pushed eax
    call list_push
    pop eax
; --------- end of parse third number ---------

    mov ebx, ecx
    add ebx, 1

; --------- start of parse fourth number ---------
    mov ecx, dword [eax]
    ; ecx = index of end

    push eax
    call parse_num
    mov ebx, eax
    mov eax, dword [esp+4] ; +4 since we pushed eax
    call list_push
    pop eax
; --------- end of parse fourth number ---------
    ; [esp] = list
    pop eax

    pop esi
    pop ecx
    pop ebx

    ret

section .data
    PATH db "day4.txt", 0