/* ==================================================================
 * File: startup/crt0.S
 * Descripe: Mã khởi động cấp thấp cho lõi RISC-V RV32IMF-CSR
 * Chạy ngay khi chân Reset được thả.
 * ================================================================== */
#include "soc_config.h"


.section .init, "ax"    /* Nằm ở .init để Linker đặt lên đầu Flash */
.global _start          /* Hàm _start toàn cục để Linker nhìn thấy */

_start:
    /* 1. Initiate Reg and enable FPU*/
    /* Tắt toàn bộ ngắt toàn cục (Tránh ngắt rác lúc đang boot) */
    csrw mstatus, zero  
    csrw mie, zero      

    /* Enable Floating Point Unit
       Bit 13, 14 của mstatus là trường FS (Floating Point status). FS = 01 (Initial) hoặc 11 (Dirty) 
       0x00006000 tương đương với dịch bit 11 vào vị trí 13, 14 */
    #if CONFIG_HAS_FPU
    
    li t0, 0x00006000   # 0x6000 = 0110 0000 0000 0000
    csrs mstatus, t0    #csrw = control and status register set (Set cac bit trong mstatus theo t0)
    #endif
    
    /* Khởi tạo thanh ghi Floating point Control (fcsr) về 0 (Mặc định la Round to Nearest) */
    csrw fcsr, zero       

    /* ----------------------------------------------------------------
     * 2. Thiet lap moi truong C (C ENVIRONMENT)
     * ---------------------------------------------------------------- */
    /* Nạp Stack Pointer (sp) từ biến _estack trong linker.ld 
       sp sẽ trỏ vào đỉnh của On chip SRAM (0x80010000) */
    la sp, _estack

    /* ----------------------------------------------------------------
     * 3. DDon dep RAM (COPY .DATA VÀ XÓA .BSS)
     * ---------------------------------------------------------------- */
    /* Bước 3.1: Copy vùng .data từ Flash sang RAM */
    la a0, _sdata       /* a0 = Bắt đầu vùng .data trên RAM */
    la a1, _edata       /* a1 = Kết thúc vùng .data trên RAM */
    la a2, _sidata     /* a2 = Bắt đầu vùng dữ liệu nguồn trên Flash */
    
copy_data_loop:
    bge a0, a1, copy_data_done  /* Nếu a0 >= a1 thì thoát vòng lặp */
    lw t0, 0(a2)                /* Đọc 1 word (4 byte) từ Flash */
    sw t0, 0(a0)                /* Ghi 1 word đó xuống RAM */
    addi a0, a0, 4              /* Tăng con trỏ RAM thêm 4 byte */
    addi a2, a2, 4              /* Tăng con trỏ Flash thêm 4 byte */
    j copy_data_loop            /* Lặp lại */

copy_data_done:
    /* Bước 3.2: Xóa vùng .bss (Biến toàn cục bằng 0) trên RAM */
    la a0, _sbss        /* a0 = Bắt đầu vùng .bss */
    la a1, _ebss        /* a1 = Kết thúc vùng .bss */
    
clear_bss_loop:
    bge a0, a1, clear_bss_done  /* Nếu a0 >= a1 thì thoát vòng lặp */
    sw zero, 0(a0)              /* Ghi 32 bit số 0 xuống RAM */
    addi a0, a0, 4              /* Tăng con trỏ RAM thêm 4 byte */
    j clear_bss_loop            /* Lặp lại */

clear_bss_done:
    /* ----------------------------------------------------------------
     * 4. Giao lai quyen dieu khien cho phan mem C Code
     * ---------------------------------------------------------------- */
    /* Trỏ thanh ghi ngắt mtvec về 0 tạm thời (Sẽ được C code cấu hình sau) */
    #csrw mtvec, zero #Machine Trap Vector Base Address Register (noi Cpu nhay toi khi interupt, exception)
    la t0, trap_entry 
    csrw mtvec, t0
    /* Nhảy vào hàm main() */
    call main

    /* ----------------------------------------------------------------
     * 5. Safy net (Vong lap chet)
     * ---------------------------------------------------------------- */
    /* Nếu hàm main() bị return, CPU sẽ rớt xuống đây và kẹt lại, 
       tránh chay sang vùng nhớ rác gây undefined behavior */
hang:
    j hang