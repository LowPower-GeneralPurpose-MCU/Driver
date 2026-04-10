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
#define CONFIG_HAS_FPU      1   // RISC-V 'F' Extension
#define CONFIG_HAS_MPU      0   // RISC-V Physical Memory Protection (PMP)
#define CONFIG_HAS_CORDIC   0   // Hardware CORDIC Coprocessor (Chưa viết driver)

// --- Memory & Bus Masters ---
#define CONFIG_HAS_DMA      1   // Direct Memory Access (Đã tích hợp)
#define CONFIG_HAS_SDRAM    0   // External SDRAM Controller
#define CONFIG_HAS_QSPI     0   // External SPI Flash Controller

// --- Standard Peripherals ---
#define CONFIG_HAS_ACCEL    0   // Bộ tăng tốc phần cứng
#define CONFIG_HAS_CORDIC   0   // Bộ tính toán lượng giác
#define CONFIG_HAS_GPIO     1   // Luôn bật
#define CONFIG_HAS_I2C      1   
#define CONFIG_HAS_SPI      1  
#define CONFIG_HAS_SYSCON   1   
#define CONFIG_HAS_TIMER    0   //APB Hardware Timer
#define CONFIG_HAS_UART     1   // Debug Console
#define CONFIG_HAS_WATCHDOG 0
#endif // SOC_CONFIG_H