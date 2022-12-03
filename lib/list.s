; Double-Word List
;
; list_get(address, index) -> number
; list_push(address, number)
; new_list(capacity) -> address

%ifndef LIST_H
%define LIST_H

%include "lib/mem.s"
%include "lib/byte_list.s"

; arguments: eax = address, ebx = index
; returns: eax = number
list_get:
    push ebx

    shl ebx, 2
    mov eax, dword [eax + 8 + ebx]

    pop ebx

    ret

; arguments: eax = address, ebx = number
; returns: -1 if invalid
list_push:
    push ecx
    push edi

    mov ecx, dword [eax] ; size

    cmp dword [eax + 4], ecx
    je list_push_oob ; if capacity = size: OOB error

    mov dword [eax + 8 + ecx], ebx
    add dword [eax], 4

    jmp list_push_after
list_push_oob:
    mov eax, -1
list_push_after:
    pop edi
    pop ecx

    ret

; arguments: eax = capacity (in dwords)
; structure List
;     size    :  uint4  (+0)
;     capacity:  uint4  (+4) (in bytes)
;     data    : [uint4] (+8)
; returns: eax = address
new_list:
    shl eax, 2
    call new_byte_list

    ret


%endif