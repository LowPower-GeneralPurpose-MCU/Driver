OUTPUT_ARCH( "riscv" )
ENTRY( _start ) /* Điểm bắt đầu là _start trong file crt0.S */

/* Physical Memory Map chuẩn hóa theo AXI Interconnect */
MEMORY
{
  ROM (rx)      : ORIGIN = 0x00010000, LENGTH = 32K   /* S0: Boot ROM 32 KiB - khop MEM_DEPTH 8192 / mask FFFF_8000 trong top_soc.v; 0x0001_8000+ la DECERR */

  /* Tightly Coupled Memory - noi THANG vao core, khong qua cache, khong qua AXI.
     Truy cap luon 2 chu ky, khong bao gio miss, khong bao gio xep hang sau mot
     burst DMA.  Danh cho ISR va vong lap trong cua DSP/CNN.
     CANH BAO: SRAM macro khong co reset -> noi dung la X luc power-up.  Phai
     copy code vao ITCM XONG roi moi duoc nhay vao do (xem crt0.S).
     CANH BAO 2: DMA va debugger KHONG voi toi duoc TCM (no nam ngoai AXI).
     Dung dat stack o DTCM neu con muon xem backtrace bang GDB. */
  ITCM (rx)     : ORIGIN = 0x00020000, LENGTH = 16K
  DTCM (rw)     : ORIGIN = 0x00024000, LENGTH = 16K

  /* System RAM duoc tach lam hai slave AXI rieng de CPU va DMA chay song song.
     Hai nua co THUOC TINH KHAC NHAU - xem ghi chu SOC_IS_UNCACHED trong
     rtl/top_soc.v: */
  RAM (rwx)     : ORIGIN = 0x20000000, LENGTH = 128K  /* CACHEABLE - CPU dung */
  DMAPOOL (rw)  : ORIGIN = 0x20020000, LENGTH = 128K  /* UNCACHED  - buffer DMA */

  FLASH (rx)    : ORIGIN = 0x30000000, LENGTH = 16M
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

  /* ---------------------------------------------------------------------
   * 5. Vung buffer DMA - NAM O NUA UNCACHED CUA SYSTEM RAM
   *
   * Moi buffer ma DMA GHI VAO roi CPU DOC RA deu PHAI nam o day.  Chip nay
   * khong co snoop va D-cache khong co lenh invalidate, nen mot buffer DMA
   * dat trong .bss (vung cacheable) se lam CPU doc ra du lieu CU vinh vien.
   *
   * Cach dung trong C:
   *     __attribute__((section(".dmabuf"), aligned(16)))
   *     static uint8_t rx_ring[512];
   *
   * Khong can khoi tao - vung nay khong duoc crt0 xoa, driver tu lo.
   * --------------------------------------------------------------------- */
  .dmabuf (NOLOAD) :
  {
    . = ALIGN(16);
    _sdmabuf = .;
    *(.dmabuf)
    *(.dmabuf.*)
    . = ALIGN(16);
    _edmabuf = .;
  } > DMAPOOL

  /* ---------------------------------------------------------------------
   * 6. Code va du lieu dat trong TCM
   *
   * .itcm_text duoc LUU o ROM va phai duoc crt0 COPY sang ITCM truoc khi goi
   * bat cu ham nao trong do - giong het cach .data duoc copy sang RAM.  Dung
   * _sitcm_load / _sitcm / _eitcm cho vong copy.
   *
   *     __attribute__((section(".itcm_text"), noinline)) void isr_fast(void);
   *     __attribute__((section(".dtcm_data")))           static int32_t taps[64];
   * --------------------------------------------------------------------- */
  .itcm_text : AT(ADDR(.text) + SIZEOF(.text) + SIZEOF(.data))
  {
    . = ALIGN(4);
    _sitcm = .;
    *(.itcm_text)
    *(.itcm_text.*)
    . = ALIGN(4);
    _eitcm = .;
  } > ITCM
  _sitcm_load = LOADADDR(.itcm_text);

  .dtcm_data (NOLOAD) :
  {
    . = ALIGN(16);
    _sdtcm = .;
    *(.dtcm_data)
    *(.dtcm_data.*)
    . = ALIGN(16);
    _edtcm = .;
  } > DTCM
}