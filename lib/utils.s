; Utilities
;
; exit -> !
; print_num(number) -> ()

%ifndef UTILS_H
%define UTILS_H

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

; return: !
exit:
    mov eax, 1  ; sys_exit
    mov ebx, 0  ; exit code = 0
    int  0x80
    ret

; argument: eax = number
print_num:
    push eax
    push ebx
    push edi
    push edx

    push dword eax ; [esp+edi+1] = number
    sub esp, 2
    mov byte [esp+1], 0
    mov byte [esp], 10

    mov edi, 1
print_num_loop:
    mov eax, dword [esp + edi + 1]

    cmp edi, 1
    je skip_check

    cmp eax, 0
    je after_print_num
skip_check:

    mov edx, 0
    mov ebx, 10
    div ebx

    mov dword [esp + edi + 1], eax

    add edx, '0'
    sub esp, 1
    mov byte [esp], dl

    add edi, 1

    jmp print_num_loop
after_print_num:
    mov eax, esp
    mov ebx, edi
    call print_str

    add esp, edi ; deallocate string
    add esp, 5   ; deallocate NULL + number

    pop edx
    pop edi
    pop ebx
    pop eax

    ret

; arguments: eax = string, ebx = length
print_str:
    push eax
    push ebx
    push ecx
    push edx

    mov ecx, eax ; buffer
    mov edx, ebx ; len

    mov eax, 4   ; sys_write
    mov ebx, 1   ; stdout
    int 0x80

    pop edx
    pop ecx
    pop ebx
    pop eax

    ret

%endif