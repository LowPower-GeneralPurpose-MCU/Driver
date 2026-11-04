/* ==================================================================
 * File: inc/soc_config.h
 * Mô tả: File cấu hình tổng của hệ thống SoC Framework
 * ================================================================== */
#ifndef SOC_CONFIG_H
#define SOC_CONFIG_H

// ==========================================
// CẤU HÌNH CLOCK (MANDATORY)
// ==========================================
// Mot clock he thong duy nhat 250 MHz tu 2026-09-11 (top_soc.v: chan `clk`).
// CPU, bus va moi ngoai vi (UART, SPI, I2C, TIMx...) deu chay bang clock nay.
#define SYSTEM_BUS_CLOCK    250000000  // 250MHz
#define RTC_CLOCK_HZ        32768      // 32.768kHz - mtime cua CLINT va WDT dem theo RTC

// ==========================================
// CẤU HÌNH CÁC BLOCK TÙY CHỌN (OPTIONAL)
// 1 = Bật (Có compile C Code & Khởi tạo) | 0 = Tắt
// ==========================================
// --- Core & Co-processors ---
// PHAI la 0. Core nay KHONG co F extension (riscv_pipeline.v: ENABLE_F = 0,
// MISA khong khai bit F). De 1 thi crt0.S phat `csrw fcsr, zero` (CSR 0x003);
// register_file.v bao illegal cho CSR khong hien thuc nen no trap ngay o lenh
// thu 4 cua crt0 - TRUOC khi mtvec duoc set - va CPU nhay vao dia chi 0.
#define CONFIG_HAS_FPU      0   // RISC-V 'F' Extension - KHONG co trong RTL
#define CONFIG_HAS_MPU      0   // RISC-V PMP (inc/pmp.h, chi co header)
#define CONFIG_HAS_CORDIC   0   // Hardware CORDIC Coprocessor (Chưa viết driver)

// --- Memory & Bus Masters ---
#define CONFIG_HAS_DMA      0   // DMA v2, 4 kenh (src/dma.c)
#define CONFIG_HAS_SDRAM    0   // External SDRAM Controller
#define CONFIG_HAS_QSPI     0   // External SPI Flash Controller

// --- Standard Peripherals ---
#define CONFIG_HAS_ACCEL    0   // Bộ tăng tốc phần cứng
#define CONFIG_HAS_GPIO     0
#define CONFIG_HAS_I2C      1
#define CONFIG_HAS_SPI      1
#define CONFIG_HAS_SYSCON   1
#define CONFIG_HAS_TIMER    0   // TIM0 + TIM1, 4 kenh capture/compare/PWM (src/timer.c)
#define CONFIG_HAS_UART     1   // UART0 - Debug Console
#define CONFIG_HAS_UART1    0   // UART1 (cung thanh ghi voi UART0)
#define CONFIG_HAS_WATCHDOG 0
#define CONFIG_HAS_ASCON    0   // ASCON-128 / ASCON-Hash + TRNG (src/ascon.c)
#endif // SOC_CONFIG_H
