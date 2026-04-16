/* ==================================================================
 * File: inc/plic.h
 * Mô tả: Thư viện điều khiển Platform-Level Interrupt Controller
 * ================================================================== */
#ifndef PLIC_H
#define PLIC_H

#include <stdint.h>
#include "soc_hw.h" // Kéo PLIC_BASE (0x0C000000) vào

/* Macros trỏ thẳng vào thanh ghi vật lý của PLIC */
// Độ ưu tiên của từng ngắt (id từ 1 đến 31)
#define PLIC_PRIORITY(id)  (*(volatile uint32_t*)(PLIC_BASE + (id) * 4))

// Thanh ghi Pending (Đọc để biết ngắt nào đang chờ)
#define PLIC_PENDING       (*(volatile uint32_t*)(PLIC_BASE + 0x1000))

// Thanh ghi Enable (Bật/tắt ngắt)
#define PLIC_ENABLE        (*(volatile uint32_t*)(PLIC_BASE + 0x2000))

// Thanh ghi Threshold (Ngưỡng chặn ngắt)
#define PLIC_THRESHOLD     (*(volatile uint32_t*)(PLIC_BASE + 0x4000))

// Thanh ghi Claim/Complete
#define PLIC_CLAIM         (*(volatile uint32_t*)(PLIC_BASE + 0x4004))

/* Khai báo các hàm điều khiển */
void plic_set_priority(uint32_t irq_id, uint32_t priority);
void plic_enable_interrupt(uint32_t irq_id);
void plic_set_threshold(uint32_t threshold);
uint32_t plic_claim(void);
void plic_complete(uint32_t irq_id);

#endif // PLIC_H