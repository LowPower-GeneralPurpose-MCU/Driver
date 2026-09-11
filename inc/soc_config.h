/* ==================================================================
 * File: inc/soc_config.h
 * Mô tả: File cấu hình tổng của hệ thống SoC Framework
 * ================================================================== */
#ifndef SOC_CONFIG_H
#define SOC_CONFIG_H

// ==========================================
// CẤU HÌNH CLOCK (MANDATORY)
// ==========================================
#define SYSTEM_BUS_CLOCK    200000000  // 200MHz
#define RTC_CLOCK_HZ        32768      // 32.768kHz

// ==========================================
// CẤU HÌNH CÁC BLOCK TÙY CHỌN (OPTIONAL)
// 1 = Bật (Có compile C Code & Khởi tạo) | 0 = Tắt
// ==========================================
// --- Core & Co-processors ---
// PHAI la 0. Core nay KHONG co F extension:
//   - riscv_pipeline.v  : execute #(.ENABLE_FPU(0)), moi cong f_* noi 1'b0/32'd0
//   - register_file.v   : MISA khong khai bit F (xem ghi chu "F1")
//   - control_unit.v    : ENABLE_F_EXTENSION = 0
//
// De 1 thi crt0.S phat `csrw fcsr, zero` (CSR 0x003). Truoc day nhanh `default`
// cua bang CSR nuot lenh do im lang. Tu khi register_file.v bao illegal cho CSR
// khong hien thuc (C5 trong CORE_FIX_PLAN.md) thi no trap ngay o lenh thu 4 cua
// crt0 - TRUOC khi mtvec duoc set - nen CPU nhay vao dia chi 0 va di lang thang.
//
// Day la nua con lai cua chinh bug MISA da sua: MISA da bo bit F, con build
// config thi chua.
#define CONFIG_HAS_FPU      0   // RISC-V 'F' Extension - KHONG co trong RTL
#define CONFIG_HAS_MPU      0   // RISC-V Physical Memory Protection (PMP)
#define CONFIG_HAS_CORDIC   0   // Hardware CORDIC Coprocessor (Chưa viết driver)

// --- Memory & Bus Masters ---
#define CONFIG_HAS_DMA      0   // Direct Memory Access (Đã tích hợp)
#define CONFIG_HAS_SDRAM    0   // External SDRAM Controller
#define CONFIG_HAS_QSPI     0   // External SPI Flash Controller

// --- Standard Peripherals ---
#define CONFIG_HAS_ACCEL    0   // Bộ tăng tốc phần cứng
#define CONFIG_HAS_CORDIC   0   // Bộ tính toán lượng giác
#define CONFIG_HAS_GPIO     0   
#define CONFIG_HAS_I2C      1   
#define CONFIG_HAS_SPI      1  
#define CONFIG_HAS_SYSCON   1   
#define CONFIG_HAS_TIMER    0   //APB Hardware Timer
#define CONFIG_HAS_UART     1   // Debug Console
#define CONFIG_HAS_WATCHDOG 0
#endif // SOC_CONFIG_H