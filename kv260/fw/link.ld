/* Bring-up firmware cho KV260: chay thang trong boot ROM (bake luc build).
 *
 *   ROM  0x0001_0000  32 KiB  - axi_rom, PC reset = SYSCON RESET_VECTOR_POR
 *   RAM  0x2000_0000 128 KiB  - nua LO cua system RAM (cacheable)
 *
 * Khong dung ITCM (Erratum E1, MEMORY_ARCHITECTURE.md muc 3).
 */
OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
    ROM (rx)  : ORIGIN = 0x00010000, LENGTH = 32K
    RAM (rwx) : ORIGIN = 0x20000000, LENGTH = 128K
}

__stack_top = ORIGIN(RAM) + LENGTH(RAM);

SECTIONS
{
    .text : ALIGN(4)
    {
        KEEP(*(.text.init))
        *(.text .text.*)
        *(.rodata .rodata.* .srodata .srodata.*)
        . = ALIGN(4);
    } > ROM

    .data : ALIGN(4)
    {
        __data_start = .;
        *(.data .data.* .sdata .sdata.*)
        . = ALIGN(4);
        __data_end = .;
    } > RAM AT > ROM
    __data_lma = LOADADDR(.data);

    .bss (NOLOAD) : ALIGN(4)
    {
        __bss_start = .;
        *(.bss .bss.* .sbss .sbss.* COMMON)
        . = ALIGN(4);
        __bss_end = .;
    } > RAM

    /DISCARD/ : { *(.comment) *(.riscv.attributes) *(.note*) *(.eh_frame*) }
}
