; Day 2 Part 2 of AoC 2022
;
; This one uses conditionals instead of modulo

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

; argument: eax = opponent, ebx = "outcome"
; return: eax = score
calc_score:
    push ebx
    push ecx

    ; let ecx = score
    mov ecx, 0

    cmp ebx, 0
    jne not_lose

    ; it's a lose
    cmp eax, 0
    jne lose_not_rock

    ; lose to rock = scissors
    add ecx, 3

    jmp after_scoring
lose_not_rock:
    cmp eax, 1
    jne lose_not_paper

    ; lose to paper = rock
    add ecx, 1

    jmp after_scoring
lose_not_paper:
    ; lose to scissors = paper
    add ecx, 2
    jmp after_scoring
not_lose:
    cmp ebx, 1
    jne not_tie

    ; it's a tie
    add ecx, 3

    cmp eax, 0
    jne tie_not_rock

    ; tie to rock = rock
    add ecx, 1

    jmp after_scoring
tie_not_rock:
    cmp eax, 1
    jne tie_not_paper

    ; tie to paper = paper
    add ecx, 2

    jmp after_scoring
tie_not_paper:
    ; tie to scissors = scissors
    add ecx, 3

    jmp after_scoring
not_tie:
    ; it's a win
    add ecx, 6

    cmp eax, 0
    jne win_not_rock

    ; win to rock = paper
    add ecx, 2

    jmp after_scoring
win_not_rock:
    cmp eax, 1
    jne win_not_paper

    ; win to paper = scissors
    add ecx, 3

    jmp after_scoring
win_not_paper:
    ; win to scissors = rock
    add ecx, 1

after_scoring:
    mov eax, ecx

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