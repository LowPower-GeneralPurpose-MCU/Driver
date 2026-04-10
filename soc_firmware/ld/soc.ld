OUTPUT_ARCH( "riscv" )
ENTRY( _start ) /* Điểm bắt đầu là _start trong file crt0.S */

/* Physical Memory Map*/
MEMORY
{
  /* Text/ROData nằm trên SPI Flash qua bộ điều khiển AXI QSPI */
  ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 64K
  
  /* Data/BSS/Stack nằm trên On-chip SRAM (S1) */
  RAM (rwx) : ORIGIN = 0x20000000, LENGTH = 128K

  FLASH (rx) : ORIGIN = 0x30000000, LENGTH = 16M
}

/* Initiate Stack:  Nằm ở cuối cùng của 64KB RAM */
_estack = ORIGIN(RAM) + LENGTH(RAM); /* 0x80010000 */

SECTIONS
{
  /* 1. Vùng Code và Hằng số (Lưu và chạy trực tiếp trên Flash) */
  .text :
  {
    . = ALIGN(4);
    *(.init)       /* Ép code khởi động (crt0.S) phải nằm đầu tiên */
    *(.text)       /* Các hàm C bình thường */
    *(.text.*)      /*Phan vung mo rong GCC*/
    *(.text.startup)
    *(.rodata*)    /* Hằng số, chuỗi ký tự */
    . = ALIGN(4);
    _etext = .;    /* Cột mốc đánh dấu hết vùng Code trên ROM */
  } > ROM

  /* 2. Vùng dữ liệu có khởi tạo (Lưu ở Flash, nhưng lúc boot sẽ copy sang RAM) */
  .data : AT(ADDR(.text) + SIZEOF(.text))
  {
    . = ALIGN(4);
    _sdata = .;
    *(.data)
    *(.sdata)
    . = ALIGN(4);
    _edata = .;
  } > RAM

  _sidata = LOADADDR(.data);

  /* 3. Vùng biến rỗng (Chỉ tốn chỗ trên RAM, cần được xóa về 0 lúc boot) */
  .bss :
  {
    . = ALIGN(4);
    _sbss = .;     /* Cột mốc bắt đầu vùng BSS */
    *(.bss)
    *(.bss.*)
    *(.sbss)
    *(.sbss.*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;     /* Cột mốc kết thúc vùng BSS */
  } > RAM
}