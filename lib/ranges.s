; Utility functions for working with ranges.
;
; range_intersects(A.start, A.end, B.start, B.end) -> result
; range_overlaps(A.start, A.end, B.start, B.end) -> result
; range_contains(A.start, A.end, B.start, B.end) -> result

%ifndef RANGES_H
%define RANGES_H

; does A or B intersect at some point
; arguments: eax = A.start, ebx = A.end, ecx = B.start, edx = B.end
; returns: eax = 1 if it does, 0 if doesn't
range_intersects:
    ; A.end >= B.start
    cmp ebx, ecx
    jnge range_intersects_not

    ; A.start <= B.end
    cmp eax, edx
    jnle range_intersects_not

    mov eax, 1
    jmp range_intersects_after
range_intersects_not:
    mov eax, 0
range_intersects_after:
    ret

; does A or B overlap one another
; arguments: eax = A.start, ebx = A.end, ecx = B.start, edx = B.end
; returns: eax = 1 if it does, 0 if doesn't
range_overlaps:
    push eax ; [esp] = A.start
    call range_contains
    cmp eax, 0
    jne range_overlaps_does


    mov eax, dword [esp]
    swap eax, ecx
    swap ebx, edx

    call range_contains
    cmp eax, 0
    jne range_overlaps_does

    mov eax, 0
    jmp range_overlaps_after
range_overlaps_does:
    mov eax, 1
range_overlaps_after:
    add esp, 4
    ret

; does A contain B
; arguments: eax = A.start, ebx = A.end, ecx = B.start, edx = B.end
; returns: eax = 1 if it does, 0 if doesn't
range_contains:
    ; A.start <= B.start
    cmp eax, ecx
    jnle range_contains_not

    ; A.end >= B.end
    cmp ebx, edx
    jnge range_contains_not

    mov eax, 1
    jmp range_contains_after
range_contains_not:
    mov eax, 0
range_contains_after:
    ret

%endif