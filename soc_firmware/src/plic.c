/* ==================================================================
 * File: src/plic.c
 * ================================================================== */
#include "plic.h"

// Set độ ưu tiên cho 1 ngắt (0-7, số càng to ưu tiên càng cao)
void plic_set_priority(uint32_t irq_id, uint32_t priority) {
    PLIC_PRIORITY(irq_id) = priority & 0x07; // Chỉ lấy 3 bit
}

// Cho phép ngắt lọt qua PLIC
void plic_enable_interrupt(uint32_t irq_id) {
    PLIC_ENABLE |= (1 << irq_id);
}

void plic_disable_interrupt(uint32_t irq_id) {
    PLIC_ENABLE &= ~(1 << irq_id);
}

// Cấu hình ngưỡng chặn (Thường set = 0 để nhận mọi ngắt)
void plic_set_threshold(uint32_t threshold) {
    PLIC_THRESHOLD = threshold & 0x07;
}

// CPU đọc ID của ngắt vừa xảy ra
uint32_t plic_claim(void) {
    return PLIC_CLAIM;
}

// CPU báo cho PLIC đã xử lý xong ngắt đó
void plic_complete(uint32_t irq_id) {
    if (irq_id != 0) {
        PLIC_CLAIM = irq_id; 
    }
}