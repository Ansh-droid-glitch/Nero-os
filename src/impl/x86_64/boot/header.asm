section .limine_requests

limine_base_revision:
    dq 0xf9562b2d
    dq 0x07ab71e5
    dq 2

section .text
global _start
extern kernel_main

_start:
    cld
    ; Point rsp to our own stack
    mov rsp, stack_top
    ; Reset base pointer
    xor rbp, rbp
    call kernel_main
.hang:
    hlt
    jmp .hang

section .bss
align 16
stack_bottom:
    resb 16384      ; 16 KiB stack
stack_top:
