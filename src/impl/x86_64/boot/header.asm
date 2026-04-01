section .text
global _start
extern kernel_main

_start:
    cld
    mov rsp, stack_top
    xor rbp, rbp
    call kernel_main
.hang:
    hlt
    jmp .hang

section .bss
align 16
stack_bottom:
    resb 16384
stack_top:
