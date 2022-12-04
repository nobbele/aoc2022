; Utilities
;
; exit -> !
;
; MACROS
; dbg 1
; byte_dbg 1

%ifndef UTILS_H
%define UTILS_H

%include "lib/io.s"

%macro dbg 1
    push eax
    add esp, 4
    mov eax, %1
    sub esp, 4
    call print_num
    pop eax
%endmacro

; Can't be called with `byte [..]`!, use `[..]`
%macro byte_dbg 1
    push eax
    push ebx
    add esp, 4
    mov ebx, %1
    sub esp, 4
    mov eax, 0
    mov al, bl
    call print_num
    pop ebx
    pop eax
%endmacro

%macro swap 2
    xor %1, %2
    xor %2, %1
    xor %1, %2
%endmacro

; arguments: eax = list, ebx = starting index, ecx = last index
; returns: eax = number
parse_num:
    push ebx
    push esi
    ; ebx is counter

    mov esi, eax
    mov eax, 0

parse_num_loop:
    cmp ebx, ecx
    je parse_num_after

    push ecx

    ; multiply eax by 10
    mov ecx, 10
    mul ecx

    mov ecx, 0 ; not stricly necessary since 10 < 256
    mov cl, byte [esi + 8 + ebx] ; read character from buffer
    sub ecx, 48 ; '0'

    ; add the numeric value to the total
    add eax, ecx

    pop ecx

    add ebx, 1
    jmp parse_num_loop
parse_num_after:

    pop esi
    pop ebx

    ret

; return: !
exit:
    mov eax, 1  ; sys_exit
    mov ebx, 0  ; exit code = 0
    int  0x80
    ret

%endif