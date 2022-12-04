; Day 2 Part 2 of AoC 2022
;
; This one uses modulo rather than a bunch of conditionals but
; ends up being about the same length due to needing to
; fix edx and saving eax and moving from/to eax
; (saves 14 lines)

section .text
    global _start

%include "lib/io.s"
%include "lib/utils.s"

_start:
    call open_file

    ; allocate 8 bytes
    push eax ; [esp+4] = fd
    push dword 0 ; [esp] = sum

loop:
    mov eax, dword [esp+4]
    call read_line
    cmp eax, -1
    je eof

    call calc_score
    add dword [esp], eax

    jmp loop
eof:
    mov eax, dword [esp]
    call print_num

    add esp, 8 ; deallocate the 8 bytes
    call exit

; argument: eax = opponent, ebx = outcome
; return: eax = score
calc_score:
    push ebx
    push ecx
    push edx
    push edi

    cmp ebx, 0
    jne not_lose_fix

    ; lose
    push eax
    mov edx, 0
    add eax, 2
    mov edi, 3
    div edi
    mov ebx, edx
    pop eax

    jmp after_fixing
not_lose_fix:
    cmp ebx, 1
    jne not_tie_fix

    mov ebx, eax

    jmp after_fixing
not_tie_fix:
    ; win
    push eax
    mov edx, 0
    add eax, 1
    mov edi, 3
    div edi
    mov ebx, edx
    pop eax
after_fixing:

    ; let ecx = score
    ; which starts at the bonus for "shape"
    mov ecx, ebx
    add ecx, 1

    cmp ebx, eax
    jne not_tie

    add ecx, 3

    jmp after_scoring
not_tie:
    mov edx, 0
    add eax, 1
    mov edi, 3
    div edi
    ; edx = (opponent + 1) % 3

    cmp edx, ebx
    jne after_scoring

    add ecx, 6
after_scoring:
    mov eax, ecx

    pop edi
    pop edx
    pop ecx
    pop ebx

    ret



; arguments: eax = fd
; return: eax = opponent, ebx = "outcome"
; 0 = rock / lose
; 1 = paper / tie
; 2 = scissors / win
read_line:
    ; [esp] = opponent
    sub esp, 1 ; allocate 1 byte

    ; read opponent
    mov ebx, eax ; fd
    mov eax, 3 ; sys_read
    mov ecx, esp ; buffer
    mov edx, 1 ; buffer size
    int 0x80

    cmp eax, 0
    je read_line_eof

    ; [esp+1] = opponent
    ; [esp] = recommended
    sub esp, 1 ; allocate 1 byte

    ; read space
    mov eax, 3 ; sys_read
    mov ecx, esp ; buffer
    mov edx, 1 ; buffer size
    int 0x80

    ; read recommended
    mov eax, 3 ; sys_read
    mov ecx, esp ; buffer
    mov edx, 1 ; buffer size
    int 0x80

    sub esp, 1 ; allocate 1 byte

    ; try read new_line
    mov eax, 3 ; sys_read
    mov ecx, esp ; buffer
    mov edx, 1 ; buffer size
    int 0x80

    add esp, 1 ; deallocate 1 byte

    mov eax, 0
    mov al, byte [esp+1]
    sub eax, 65 ; subtract 'A'

    mov ebx, 0
    mov bl, byte [esp]
    sub ebx, 88 ; subtract 'X'

    jmp read_line_end
read_line_eof:
    mov eax, -1
    sub esp, 1 ; allocate 1 byte (to fix the deallocation)
read_line_end:
    add esp, 2 ; deallocate 2 byte
    ret

; return: eax = fd
open_file:
    mov eax, 5      ; sys_open
    mov ebx, PATH   ; path parameter
    mov ecx, 0      ; flags parameter
    int 0x80
    ret

section .data
    PATH db "day2.txt", 0