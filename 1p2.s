; Day 1 Part 2 of AoC 2022

section	.text
   global _start

%include "lib/utils.s"
%include "lib/io.s"

_start:
   mov eax, 5      ; sys_open
   mov ebx, PATH   ; path parameter
   mov ecx, 0      ; flags parameter
   int 0x80

   call read_highest_elf
   add eax, ebx
   add eax, ecx

   call print_num

   call exit

; argument: eax = fd
; return: eax = highest, ebx = second highest, edx = third highest
read_highest_elf:
   push eax  ; [esp+12] = fd
   push dword 0 ; [esp+8] = third highest calories
   push dword 0 ; [esp+4] = second highest calories
   push dword 0 ; [esp] = highest calories

read_highest_elf_loop:
   mov eax, dword [esp+12] ; load file descriptor
   call read_single_elf
   ; eax = calories or -1 if EOF
   cmp eax, -1
   je after_read_highest_elf

   cmp eax, dword [esp+8]
   jl after_checks ; jump away if calories < third highest

   cmp eax, dword [esp+4]
   jg higher_than_second

   mov dword [esp+8], eax
   jmp read_highest_elf_loop
higher_than_second:
   mov ebx, dword [esp+4]
   mov dword [esp+8], ebx
   cmp eax, dword [esp]
   jg highest

   mov dword [esp+4], eax
   jmp read_highest_elf_loop
highest:
   mov ebx, dword [esp]
   mov dword [esp+4], ebx
   mov dword [esp], eax
after_checks:
   jmp read_highest_elf_loop
after_read_highest_elf:
   mov eax, dword [esp]
   mov ebx, dword [esp+4]
   mov ecx, dword [esp+8]
   add esp, 16 ; deallocate 8 bytes
   ret

; argument: eax = fd
; return: eax = value or -1 if EOF
read_single_elf:
   push eax ; [esp + 4] = fd
   push dword 0 ; [esp] = calories

read_single_elf_loop:
   mov eax, dword [esp+4] ; load file descriptor
   call read_line

   cmp eax, 0 ; if received number was 0 (new elf) or EOF (done)
   jle after_read_single_elf

   add dword [esp], eax ; add read received number to current calories for this elf

   jmp read_single_elf_loop
after_read_single_elf:
   cmp eax, -1
   jne read_single_elf_valid ; return if not EOF

   cmp dword [esp], 0
   jne read_single_elf_valid ; return if calories != 0 even if EOF

   mov dword [esp], -1 ; set calories to -1
read_single_elf_valid:
   mov eax, dword [esp] ; load calories into eax
   add esp, 8 ; deallocate 8 bytes
   ret

; argument: eax = fd
; return: eax = value, -1 if EOF
read_line:
   push eax ; [esp+5] = dword (fd)
   push dword 0 ; [esp+1] = dword (current number)
   sub esp, 1 ; [esp] = byte (buffer)

read_line_loop:
   mov eax, 3       ; sys_read
   mov ebx, [esp+5] ; fd
   mov ecx, esp     ; buffer
   mov edx, 1       ; len
   int 0x80

   cmp eax, 0
   je read_line_eof ; exit if eof found

   cmp byte [esp], 10
   je read_line_after ; exit if character = '\n'

   mov eax, dword [esp + 1] ; contains stored number

   mov ecx, 0
   mov cl, byte [esp] ; contains read character
   sub ecx, '0' ; subtract by '0' to get number from ascii

   ; multiply eax by 10
   mov ebx, 10
   mul ebx

   add eax, ecx
   mov dword [esp + 1], eax

   jmp read_line_loop
read_line_eof:
   cmp dword [esp + 1], 0
   jne read_line_after ; ignore EOF this time, if we are on a valid line
   mov dword [esp + 1], -1
read_line_after:
   mov eax, dword [esp + 1]
   add esp, 9 ; deallocate 4 + 4 + 1 bytes
   ret

section	.data
   PATH db "day1.txt", 0
