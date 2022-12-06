; Day 5 Part 1 of AoC 2022

section .text
    global _start

%include "lib/utils.s"
%include "lib/mem.s"
%include "lib/list.s"
%include "lib/fs.s"
%include "lib/io.s"
%include "lib/ranges.s"

_start:
    ; [esp+8] = input buffer
    ; [esp+4] = list of towers
    ; [esp] = fd
    sub esp, 12

    mov eax, PATH
    call open_file
    mov dword [esp], eax

    ; allocate the input buffer as 32 bytes
    mov eax, 64
    call new_byte_list
    mov dword [esp+8], eax
    
    ; load a line into the input buffer
    mov eax, dword [esp]
    mov ebx, dword [esp+8]
    call read_line

    mov eax, dword [esp+8] ; load input buffer
    mov eax, dword [eax] ; load input buffer length
    
    ; divide line length by 4, result in eax
    mov edx, 0
    add eax, 1
    mov ebx, 4
    div ebx

    ; eax contains the tower count
    mov ecx, eax ; store count in ecx also
    call new_list
    mov dword [esp+4], eax
    
    ; allocate towers
    ; iterate ecx
allocate_stacks_loop:
    ; allocate a tower of size 32
    mov eax, 64
    call new_byte_list
    
    ; push the tower pointer to the tower list
    mov ebx, eax
    mov eax, dword [esp+4]
    call list_push
    
    sub ecx, 1
    cmp ecx, 0
    jne allocate_stacks_loop
allocate_stacks_after:
; --------- End of Allocations ---------  

; --------- Start of "playfield" parser ---------
    ; parse the line
    mov eax, dword [esp+8]
    mov ebx, dword [esp+4] 
    call parse_line 
    
parse_field_loop:
    
    ; load a line into the (cleared) input buffer
    mov eax, dword [esp+8]
    call list_clear
    mov ebx, eax
    mov eax, dword [esp]
    call read_line
        
    ; parse the line
    mov eax, dword [esp+8]
    mov ebx, dword [esp+4] 
    call parse_line 
    
    ; loop again if it was a successful read
    cmp eax, 0
    jne parse_field_loop
; End of parse field loop
; --------- End of "playfield" parser ---------

    ; Reverse the towers since we read them in the wrong order :/
    mov eax, dword [esp+4]
    mov ebx, dword [eax]
    shr ebx, 2
field_reverse_loop:
    sub ebx, 1
    
    push eax
    call list_get
    call byte_list_reverse
    pop eax
    
    cmp ebx, 0
    jne field_reverse_loop
; End of field reverse loop


    ; discard the empty line
    mov eax, dword [esp+8]
    call list_clear
    mov ebx, eax
    mov eax, dword [esp]
    call read_line
    
main_action_line_loop:
    ; read the action line
    mov eax, dword [esp+8]
    call list_clear
    mov ebx, eax
    mov eax, dword [esp]
    call read_line
    
    cmp eax, -1
    je main_action_line_after
    
    ; parse the action line
    mov eax, dword [esp+8]
    mov ebx, dword [esp+4] 
    call run_action_line 
    
    jmp main_action_line_loop
main_action_line_after:

    mov eax, 16
    call new_byte_list
    mov edi, eax
    
    mov esi, dword [esp+4]
main_print_loop:
    cmp ecx, dword [esi]
    je main_print_after
    
    mov eax, dword [esi+8+ecx]
    call byte_list_pop
    mov ebx, eax
    mov eax, edi
    call byte_list_push
    
    add ecx, 4
    jmp main_print_loop
main_print_after:

    mov eax, edi
    mov ebx, 10 ; '\n'
    call byte_list_push
    mov ebx, dword [eax]
    lea eax, dword [eax+8]
    call print_str

; --------- Start of Deallocations ---------  

    mov eax, dword [esp+4] ; list of towers
    mov ebx, dword [eax] ; length
    
    shr ebx, 2 ; bytes -> dwords
    ; deallocate towers
    ; iterate ebx
deallocate_stacks_loop:
    sub ebx, 1
    
    mov eax, dword [esp+4] ; list of towers
    call list_get
    call dealloc
        
    cmp ebx, 0
    jne deallocate_stacks_loop
deallocate_stacks_after:

    ; deallocate the tower list
    mov eax, dword [esp+4]
    call dealloc
    
    ; deallocate input buffer
    mov eax, dword [esp+8]
    call dealloc

    add esp, 12

    call exit
    
; arguments: eax = input buffer list, ebx = list of towers
run_action_line:
    push esi
    push edi
    push ebp
    push ecx
    push edx
    
    ; [esp+8] = to
    ; [esp+4] = from
    ; [esp] = count
    sub esp, 12
    
    mov esi, eax ; esi = input buffer
    mov edi, ebx ; edi = list of towers
    
    mov ebx, 0
    
    mov ebp, 0 ; ebp is iterator
parse_action_line_loop:
    mov eax, esi
    mov ecx, 32 ; ' '
    call byte_list_find_start
    
    mov ebx, eax
    add ebx, 1
    
    mov eax, esi
    mov ecx, 32 ; ' '
    call byte_list_find_start
    
    cmp eax, -1
    jne parse_action_line_after_nl_check
    mov eax, dword [esi]
parse_action_line_after_nl_check:

    mov ecx, eax
    mov eax, esi
    call parse_num
    mov dword [esp+ebp], eax
    
    mov ebx, ecx
    add ebx, 1
    
    cmp ebp, 8
    je parse_action_line_loop_after
    
    add ebp, 4
    jmp parse_action_line_loop
parse_action_line_loop_after:  
    ; load source tower
    mov ebx, dword [esp+4]
    sub ebx, 1 ; 0-indexed
    shl ebx, 2
    mov ebx, dword [edi+8+ebx]
    
    ; load target tower
    mov ecx, dword [esp+8]
    sub ecx, 1 ; 0-indexed
    shl ecx, 2
    mov ecx, dword [edi+8+ecx]
    
    mov edx, dword [esp]
    push ebp
    
    mov ebp, dword [ecx]
    lea ebp, [ecx+8+ebp] ; ebp = first empty element
    add dword [ecx], edx
    
run_action_line_loop:
    sub edx, 1
        
    mov eax, ebx
    call byte_list_pop
    
    ; dbg edx
    mov byte [ebp+edx], al
    
    cmp edx, 0
    jne run_action_line_loop
run_action_line_loop_after:
    pop ebp
    
    add esp, 12
    
    pop edx
    pop ecx
    pop ebp
    pop edi
    pop esi
    
    ret
    
; arguments: eax = input buffer, ebx = list of towers
; returns: eax = 1 if anything was found, otherwise 0
parse_line:
    push ecx
    push ebx
    push edi
    push 0 ; [esp] = result

    mov ecx, dword [eax] ; length
    add ecx, 1
    
    mov edi, ebx ; edi = list of towers
    mov ebx, 0
    
    ; iterate ecx
    ; ecx should be aligned to the [ of the tower entries
parse_loop:
    cmp ecx, 0
    je parse_after
    
    sub ecx, 4
    
    ; look for '['
    mov bl, byte [eax+8+ecx]
    cmp bl, 91 ; '['
    jne parse_loop
    
    ; mark successful entry
    mov dword [esp], 1
    
    push eax
    push ecx    
    mov bl, byte [eax+8+ecx+1] ; get the character
    ; ecx is 4 times larger than the index which corresponds to the entry sizes
    mov eax, dword [edi+8+ecx] ; get the right tower
    call byte_list_push
    pop ecx
    pop eax
    
    jmp parse_loop
parse_after:

    pop eax
    pop edi
    pop ebx
    pop ecx

    ret

section .data
    PATH db "day5.txt", 0