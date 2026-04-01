OUTPUT_FORMAT(elf64-x86-64)
ENTRY(_start)

PHDRS {
    limine_requests PT_LOAD;
    text            PT_LOAD;
    rodata          PT_LOAD;
    data            PT_LOAD;
}

SECTIONS {
    . = 0xffffffff80000000;

    .limine_requests : ALIGN(0x1000) {
        KEEP(*(.limine_requests_start))
        KEEP(*(.limine_requests))
        KEEP(*(.limine_requests_end))
    } :limine_requests

    .text : ALIGN(0x1000) {
        *(.text .text.*)
    } :text

    .rodata : ALIGN(0x1000) {
        *(.rodata .rodata.*)
    } :rodata

    .data : ALIGN(0x1000) {
        *(.data .data.*)
    } :data

    .bss : ALIGN(0x1000) {
        *(COMMON)
        *(.bss .bss.*)
    } :data
}
