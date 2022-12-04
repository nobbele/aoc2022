; Input / Output library
;
; print_num(number) -> ()
; print_str(address, length)

%ifndef IO_H
%define IO_H

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