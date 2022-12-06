; Day 5 Part 2 of AoC 2022
;
; Changed two number from 4 to 14 lol

section .text
    global _start

%include "lib/utils.s"
%include "lib/mem.s"
%include "lib/list.s"
%include "lib/fs.s"
%include "lib/io.s"
%include "lib/ranges.s"
%include "lib/byte_queue.s"

_start:
    ; [esp+4] = queue
    ; [esp] = fd
    sub esp, 8

    mov eax, PATH
    call open_file
    mov dword [esp], eax
    
    ; allocate the queue
    mov eax, 2048
    call new_byte_queue
    mov dword [esp+4], eax

    mov eax, dword [esp]
    mov ebx, dword [esp+4]
    add ebx, 4
    mov ecx, 14
    call read_n
    
    mov edi, 14
loop: 
    mov eax, dword [esp+4]
    call byte_queue_has_dups
    cmp eax, -1
    je after
    
    mov eax, dword [esp+4]
    call byte_queue_deque
    
    mov eax, dword [esp]
    mov ebx, dword [esp+4]
    add ebx, 4 ; skip index in header
    mov ecx, 1
    call read_n
        
    cmp eax, 0
    je after
    
    add edi, 1
    jmp loop
after:
    dbg edi
    
    mov eax, dword [esp+4]
    call dealloc
    
    add esp, 8

    call exit

section .data
    PATH db "day6.txt", 0