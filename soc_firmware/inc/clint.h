/* ==================================================================
 * File: inc/clint.h
 * Mô tả: Thư viện điều khiển Core Local Interruptor (CLINT)
 * Khớp 100% với file clint_defines.vh của team RTL
 * ================================================================== */
#ifndef CLINT_H
#define CLINT_H

#include <stdint.h>
#include "soc_hw.h" // Chứa CLINT_BASE (0x02000000)

/* Các offset lấy chuẩn từ clint_defines.vh */
#define CLINT_MSIP_OFFSET       0x000000
#define CLINT_MTIMECMP_OFFSET   0x004000
#define CLINT_MTIME_LO_OFFSET   0x00BFF8
#define CLINT_MTIME_HI_OFFSET   0x00BFFC

/* Định nghĩa con trỏ ép kiểu tới các thanh ghi vật lý */
// Thanh ghi kích hoạt ngắt phần mềm (Software Interrupt)
#define CLINT_MSIP          (*(volatile uint32_t*)(CLINT_BASE + CLINT_MSIP_OFFSET))

// Thanh ghi MTIMECMP (So sánh thời gian) - Bản thân nó là 64-bit nhưng tách làm 2 mảnh 32-bit
#define CLINT_MTIMECMP_LO   (*(volatile uint32_t*)(CLINT_BASE + CLINT_MTIMECMP_OFFSET))
#define CLINT_MTIMECMP_HI   (*(volatile uint32_t*)(CLINT_BASE + CLINT_MTIMECMP_OFFSET + 4))

// Thanh ghi MTIME (Đồng hồ đếm liên tục của hệ thống)
#define CLINT_MTIME_LO      (*(volatile uint32_t*)(CLINT_BASE + CLINT_MTIME_LO_OFFSET))
#define CLINT_MTIME_HI      (*(volatile uint32_t*)(CLINT_BASE + CLINT_MTIME_HI_OFFSET))

/* Các hàm điều khiển */
void clint_init(void);
uint64_t clint_get_mtime(void);
void clint_set_timer_ms(uint32_t ms, uint32_t timer_freq_hz);
void clint_trigger_soft_irq(void);
void clint_clear_soft_irq(void);
void HAL_Delay(uint32_t ms, uint32_t timer_freq_hz);
#endif // CLINT_H