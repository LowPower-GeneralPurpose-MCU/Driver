/* ==================================================================
 * File: inc/syscon.h
 * Mô tả: Điều khiển hệ thống (Reset Vector & Clock Gating)
 * ================================================================== */
#ifndef SYSCON_H
#define SYSCON_H

#include <stdint.h>
#include "soc_hw.h" // Chứa SYSCON_BASE

/* Các thanh ghi của SYSCON */
#define SYSCON_RESET_VECTOR  (*(volatile uint32_t*)(SYSCON_BASE + 0x000))
#define SYSCON_CLK_GATE      (*(volatile uint32_t*)(SYSCON_BASE + 0x004))



#define SYSCON_CLK_PWM      0   // RTL: clk_gate_reg[0]
#define SYSCON_CLK_UART     1   // RTL: clk_gate_reg[1]
#define SYSCON_CLK_SPI      2   // RTL: clk_gate_reg[2]
#define SYSCON_CLK_I2C      3   // RTL: clk_gate_reg[3]
#define SYSCON_CLK_GPIO     4   // RTL: clk_gate_reg[4]
#define SYSCON_CLK_ACCEL    5   // RTL: clk_gate_reg[5]
#define SYSCON_CLK_DEBUG    6   // RTL: clk_gate_reg[6]
#define SYSCON_CLK_CPU      31
/* Khai báo API */
void syscon_enable_clock(uint8_t peripheral_bit);
void syscon_disable_clock(uint8_t peripheral_bit);
void syscon_set_boot_address(uint16_t addr_offset);

/* API Tự động hóa cấp nguồn toàn hệ thống */
void syscon_init_clocks(void);

#endif // SYSCON_H