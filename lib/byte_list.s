; Byte List
;
; byte_list_get(address, index) -> al = number
; byte_list_push(address, bl = number)
; byte_list_clear(address)
; byte_list_intersects(A, B, out)
; byte_list_split(list) -> (A, B)
; byte_list_print(list)
; new_byte_list(capacity) -> address

%ifndef BYTE_LIST_H
%define BYTE_LIST_H

; arguments: eax = list
byte_list_print:
    push ebx

    mov ebx, 0
byte_list_print_loop:
    cmp dword [eax], ebx
    je byte_list_print_after

    push eax
    push ecx

    mov ecx, eax
    mov eax, 0
    mov al, byte [ecx + 8 + ebx]
    call print_num

    pop ecx
    pop eax

    add ebx, 1
    jmp byte_list_print_loop
byte_list_print_after:
    pop ebx

    ret

; Assumes the list is even and at least 1 (aka 2) elements long!
; arguments: eax = list
; returns: eax = list A, ebx = list B
byte_list_split:
    push esi
    push edi
    push ecx

    mov esi, eax

    mov ecx, dword [esi] ; size
    shr ecx, 1 ; divide size by 2

    mov eax, ecx
    call new_byte_list
    mov edi, eax


    mov dword [esi], ecx
    mov dword [edi], ecx

    push esi
    ; start copy esi+8+ecx.. to edi

    add esi, 8
    add esi, ecx

    mov eax, 0
byte_list_split_loop:
    mov al, byte [esi + ecx - 1]
    mov byte [edi + 8 + ecx - 1], al

    sub ecx, 1
    cmp ecx, 0
    jne byte_list_split_loop

    ; end of copy
    pop esi

    mov eax, esi
    mov ebx, edi

    pop ecx
    pop edi
    pop esi

    ret

; arguments: eax = list A, ebx = list B, ecx = buffer
byte_list_intersects:
    push eax
    push ebx
    push edi
    push esi
    push ecx ; [esp] = buffer

    mov edi, eax
    mov eax, 0

    mov esi, ebx
    mov ebx, 0

    mov ecx, 0 ; ecx = index
byte_list_intersects_loop:
    cmp dword [edi], ecx
    je byte_list_intersects_after ; jump out if list.size = index

    mov eax, edi
    mov ebx, ecx
    call byte_list_get

    mov ebx, eax
    mov eax, esi
    call byte_list_find

    cmp eax, -1
    je byte_list_intersects_after_same

    mov eax, dword [esp]
    call byte_list_push
byte_list_intersects_after_same:

    add ecx, 1
    jmp byte_list_intersects_loop
byte_list_intersects_after:
    pop ecx
    pop esi
    pop edi
    pop ebx
    pop eax

    ret

; arguments: eax = list A, bl = number
; returns: eax = index or -1
byte_list_find:
    push ecx

    mov ecx, 0 ; ecx = index
byte_list_find_loop:
    cmp dword [eax], ecx
    je byte_list_find_not_found ; jump out if list.size = index

    cmp byte [eax + 8 + ecx], bl
    je byte_list_find_after

    add ecx, 1
    jmp byte_list_find_loop
byte_list_find_not_found:
    mov ecx, -1

    jmp byte_list_find_after
byte_list_find_after:
    mov eax, ecx

    pop ecx

    ret

; arguments: eax = address
byte_list_clear:
    mov dword [eax], 0
    ret

; arguments: eax = address, ebx = index
; returns: al = number (or -1 if invalid)
byte_list_get:
    push ebx
    push ecx

    mov ecx, dword [eax] ; size
    cmp dword [eax + 4], ecx
    je byte_list_push_oob ; if capacity = size: OOB error

    mov ecx, eax
    mov eax, 0
    mov al, byte [ecx + 8 + ebx]

    jmp byte_list_get_after
byte_list_get_oob:
    push eax
    push ebx
    mov eax, OOB
    mov ebx, OOB_LEN
    call print_str
    pop ebx
    pop eax
    mov eax, -1
byte_list_get_after:
    pop ecx
    pop ebx

    ret

; arguments: eax = address, bl = number
; returns: eax = -1 if invalid
byte_list_push:
    push ecx
    push edi

    mov ecx, dword [eax] ; size

    cmp dword [eax + 4], ecx
    je byte_list_push_oob ; if capacity = size: OOB error

    mov byte [eax + 8 + ecx], bl
    add dword [eax], 1

    jmp byte_list_push_after
byte_list_push_oob:
    push eax
    push ebx
    mov eax, OOB
    mov ebx, OOB_LEN
    call print_str
    pop ebx
    pop eax
    mov eax, -1
byte_list_push_after:
    pop edi
    pop ecx

    ret

; arguments: eax = capacity (in bytes)
; structure List
;     size    :  uint4  (+0)
;     capacity:  uint4  (+4) (in bytes)
;     data    : [uint1] (+8)
; returns: eax = address
new_byte_list:
    push ebx

    mov ebx, eax

    ; 2 dword header
    add eax, 4 + 4
    call alloc

    mov dword [eax], 0
    mov dword [eax + 4], ebx

    pop ebx

    ret

%endif