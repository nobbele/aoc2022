; functions to help with the filesystem such as reading from files
;
; open_file(path string) -> fd
; read_line(fd, list) -> success

%ifndef FS_H
%define FS_H

%include "lib/byte_list.s"

; arguments: eax = path string
; returns: eax = fd
open_file:
    push ebx
    push ecx

    mov ebx, eax   ; path parameter
    mov eax, 5      ; sys_open
    mov ecx, 0      ; flags parameter
    int 0x80

    pop ecx
    pop ebx
    ret

; arguments: eax = fd, ebx = list
; returns: eax = 0 if success, -1 if failure
read_line:
    push ebx
    push ecx
    push edx

    push eax ; [esp+5] = fd
    push ebx ; [esp+1] = list
    sub esp, 1 ; [esp] = buffer

read_line_loop:
    mov eax, 3       ; sys_read
    mov ebx, [esp+5] ; fd
    mov ecx, esp     ; buffer
    mov edx, 1       ; len
    int 0x80

    cmp eax, 0
    je read_line_eof ; exit if eof found

    cmp byte [esp], 10
    je read_line_success ; exit if character = '\n'

    mov eax, dword [esp+1]
    mov ebx, 0
    mov bl, byte [esp]
    call byte_list_push

    jmp read_line_loop
read_line_eof:
    mov eax, dword [esp+1] ; load list

    ; treat EOF as newline if list.size == 0
    cmp dword [eax], 0
    jne read_line_success

    mov eax, -1
    jmp read_line_after
read_line_success:
    mov eax, 0
read_line_after:
    add esp, 9 ; deallocate 4 + 4 + 1 bytes

    pop edx
    pop ecx
    pop ebx

    ret

%endif