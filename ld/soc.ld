OUTPUT_ARCH( "riscv" )
ENTRY( _start ) /* Điểm bắt đầu là _start trong file crt0.S */

/* Physical Memory Map chuẩn hóa theo AXI Interconnect */
MEMORY
{
  ROM (rx)   : ORIGIN = 0x00010000, LENGTH = 16K   /* S0: Boot ROM dành cho crt0.S */
  RAM (rwx)  : ORIGIN = 0x20000000, LENGTH = 128K 
  FLASH (rx) : ORIGIN = 0x30000000, LENGTH = 16M  
}

/* Initiate Stack: Nằm ở cuối cùng của 128KB RAM vật lý (0x20020000) */
_estack = ORIGIN(RAM) + LENGTH(RAM);

SECTIONS
{
  .text :
  {
    . = ALIGN(4);
    *(.init)          /* Code assembly crt0.S */
    *(.text.startup)  /* Điểm khởi đầu của main */
    *(.text)          /* Các hàm C */
    *(.text.*)
    *(.rodata*) 
    . = ALIGN(4);
    _etext = .;
  } > ROM

  /* 3. Vùng dữ liệu có khởi tạo (Lưu ở FLASH, nhưng lúc boot sẽ copy sang RAM) */
  .data : AT(ADDR(.text) + SIZEOF(.text))
  {
    . = ALIGN(16);
    _sdata = .;
    *(.data)
    *(.sdata)
    . = ALIGN(16);
    _edata = .;
  } > RAM

  _sidata = LOADADDR(.data); /* Trỏ tới FLASH nơi lưu dữ liệu gốc để copy */

  /* 4. Vùng biến rỗng  */
  .bss :
  {
    . = ALIGN(16);
    _sbss = .;     /* Cột mốc bắt đầu vùng BSS */
    *(.bss)
    *(.bss.*)
    *(.sbss)
    *(.sbss.*)
    *(COMMON)
    . = ALIGN(16);
    _ebss = .;     /* Cột mốc kết thúc vùng BSS */
  } > RAM
}