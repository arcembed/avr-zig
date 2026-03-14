MEMORY
{
    flash (rx) : ORIGIN = 0, LENGTH = 256K
    ram (rw!x) : ORIGIN = 0x800200, LENGTH = 8K
}

SECTIONS
{
    .text :
    {
        KEEP(*(.vectors))

        *(.text*)
    } > flash

    .data :
    {
        __data_start = .;
        *(.rodata*)
        *(.data*)
        __data_end = .;
    } > ram AT> flash

    .bss (NOLOAD) :
    {
        __bss_start = .;
        *(.bss*)
        __bss_end = .;
    } > ram

    __data_load_start = LOADADDR(.data);
}
