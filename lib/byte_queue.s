; Byte Queue, like a list but with FILO functions.
;
; You can use sometimes use this with list functions by adding +4 to the address.
; Doesn't work if the functions assumes index 0 is the start.
;
; byte_queue_print(address)
; byte_queue_deque(address) -> value
; byte_queue_has_dups(address)
; byte_queue_find_excluded(address, number, excluded) -> index
; new_byte_queue(capacity) -> address

%ifndef BYTE_QUEUE
%define BYTE_QUEUE

; arguments: eax = list A, bl = number, ecx = excluded index
; returns: eax = index or -1
byte_queue_find_excluded:
    push ecx
    push edx
    
    mov edx, dword [eax] ; edx = index
byte_queue_find_excluded_loop:
    cmp dword [eax + 4], edx
    je byte_queue_find_excluded_not_found ; jump out if list.size = index
    
    cmp edx, ecx
    je byte_queue_find_excluded_repeat ; repeat loop if index = excluded index

    cmp byte [eax + 12 + edx], bl
    je byte_queue_find_excluded_after

byte_queue_find_excluded_repeat:
    add edx, 1
    jmp byte_queue_find_excluded_loop
byte_queue_find_excluded_not_found:
    mov edx, -1

    jmp byte_queue_find_excluded_after
byte_queue_find_excluded_after:
    mov eax, edx
    
    pop edx
    pop ecx

    ret
    
; arguments: eax = queue
byte_queue_has_dups:
    push ebx
    push ecx
    push esi
    
    mov esi, eax
    
    mov ecx, dword [esi] ; ecx = index
byte_queue_has_dups_loop:
    cmp dword [esi + 4], ecx
    je byte_queue_has_dups_not_found ; jump out if list.size = index

    mov eax, esi
    mov bl, byte [esi + 12 + ecx]
    call byte_queue_find_excluded
        
    cmp eax, -1
    jne byte_queue_has_dups_after

    add ecx, 1
    jmp byte_queue_has_dups_loop
byte_queue_has_dups_not_found:
    mov ecx, -1

    jmp byte_queue_has_dups_after
byte_queue_has_dups_after:
    mov eax, ecx

    pop esi
    pop ecx
    pop ebx

    ret
    
; arguments: eax = queue
byte_queue_print:
    push ebx

    mov ebx, dword [eax]
byte_queue_print_loop:
    cmp dword [eax+4], ebx
    je byte_queue_print_after

    push eax
    push ecx

    mov ecx, eax
    mov eax, 0
    mov al, byte [ecx + 12 + ebx]
    call print_num

    pop ecx
    pop eax

    add ebx, 1
    jmp byte_queue_print_loop
byte_queue_print_after:
    pop ebx

    ret
    
; arguments: eax = address
; returns: eax = value
byte_queue_deque:
    push ebx
    push esi
    
    mov esi, eax

    mov ebx, dword [esi]
    add dword [esi], 1
    
    mov eax, 0
    mov al, byte[esi+12+ebx]
    
    pop esi
    pop ebx

    ret
    
; arguments: eax = capacity (in dwords)
; structure Queue
;     index   :  unit4  (+0)
;     size    :  uint4  (+4)
;     capacity:  uint4  (+8)
;     data    : [uint4] (+12)
; returns: eax = address
new_byte_queue:    
    push ebx

    mov ebx, eax

    ; 3 dword header
    add eax, 4 + 4 + 4
    call alloc

    mov dword [eax], 0
    mov dword [eax + 4], 0
    mov dword [eax + 8], ebx

    pop ebx

    ret

%endif