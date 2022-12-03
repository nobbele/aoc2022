; Memory
;
; alloc(size) -> address
; dealloc(address) -> success

%ifndef MEM_H
%define MEM_H

; arguments: eax = address
; returns: eax = success (0) or error (non-0)
dealloc:
    push ebx
    push ecx

    mov ebx, eax
    mov eax, 91 ; sys_munmap
    mov ecx, 4
    int 0x80

    pop ecx
    pop ebx

    ret

; arguments: eax = size
; returns: eax = address
alloc:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp

    mov ecx, eax ; len
    mov eax, 192 ; sys_mmap2
    mov ebx, 0 ; addr
    mov edx, (PROT_READ | PROT_WRITE)
    mov esi, (MAP_ANONYMOUS | MAP_PRIVATE)
    mov edi, -1 ; fd
    mov ebp, 0 ; offset
    int 0x80

    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx

    ret

%endif