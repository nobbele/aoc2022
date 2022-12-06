; functions to help with the filesystem such as reading from files
;
; open_file(path string) -> fd
; read_line(fd, list) -> success

%ifndef FS_H
%define FS_H

%include "lib/byte_list.s"

; TODO investigate why this only works at 1 (aka no buffering)
READ_BUFFER_SIZE equ 1

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
    
; arguments: eax = fd, ebx = list, ecx = count
; returns: eax = bytes read
read_n:
    push ebx
    push ecx
    push edx
    push esi
    
    mov esi, ebx ; store list in esi
    
    mov edx, ecx ; len
    mov ebx, dword [esi] ; load list length
    lea ecx, [esi+8+ebx] ; buffer

    mov ebx, eax ; fd
    mov eax, 3   ; sys_read
    int 0x80
    
    add dword [esi], eax
    
    pop esi
    pop edx
    pop ecx
    pop ebx

    ret

; arguments: eax = fd, ebx = list
; returns: eax = 0 if success, -1 if failure
read_line:
    push ebx
    push ecx
    push edx
    push ebp
    push edi
    
    push eax                  ; [esp+READ_BUFFER_SIZE+4] = fd
    push ebx                  ; [esp+READ_BUFFER_SIZE] = list
    sub esp, READ_BUFFER_SIZE ; [esp] = buffer
    
    mov ebp, READ_BUFFER_SIZE
read_line_loop:
    cmp ebp, READ_BUFFER_SIZE
    jne read_line_after_sys
    
    mov ebp, 0
    
    mov eax, 3                        ; sys_read
    mov ebx, [esp+READ_BUFFER_SIZE+4] ; fd
    mov ecx, esp                      ; buffer
    mov edx, READ_BUFFER_SIZE         ; len
    int 0x80
    
    mov edi, eax
read_line_after_sys:
    cmp edi, READ_BUFFER_SIZE
    je read_line_after_eof_check
    
    cmp ebp, edi
    je read_line_eof ; exit if eof found
read_line_after_eof_check:

    cmp byte [esp+ebp], 10
    je read_line_success ; exit if character = '\n'

    mov eax, dword [esp+READ_BUFFER_SIZE]
    mov ebx, 0
    mov bl, byte [esp+ebp]
    call byte_list_push

    add ebp, 1
    jmp read_line_loop
read_line_eof:
    mov eax, dword [esp+READ_BUFFER_SIZE] ; load list

    ; treat EOF as newline if list.size == 0
    cmp dword [eax], 0
    jne read_line_success
    
    mov eax, -1
    jmp read_line_after
read_line_success:
    mov eax, 0
read_line_after:
    sub ebp, (READ_BUFFER_SIZE - 1)
    ; ebp = bytes left in the input buffer
    
    
    push eax
    mov eax, 19       ; sys_lseek
    mov ebx, [esp+4+READ_BUFFER_SIZE+4] ; fd
    mov ecx, ebp ; offset = READ_BUFFER_SIZE - 1 - (bytes read)
    mov edx, 1 ; SEEK_CUR
    int 0x80
    pop eax
    
    add esp, 8+READ_BUFFER_SIZE

    pop edi
    pop ebp
    pop edx
    pop ecx
    pop ebx

    ret

%endif