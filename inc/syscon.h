/* ==================================================================
 * File: inc/syscon.h
 * Mô tả: Điều khiển hệ thống (Reset Vector & Clock Gating)
 * ================================================================== */
#ifndef SYSCON_H
#define SYSCON_H

#include <stdint.h>
#include "soc_hw.h" // Chứa SYSCON_BASE

/* Các thanh ghi của SYSCON - xem register map trong RTL peripheral/apb_syscon.v */
#define SYSCON_RESET_VECTOR  (*(volatile uint32_t*)(SYSCON_BASE + 0x000)) /* giu qua warm reset */
#define SYSCON_CLK_GATE      (*(volatile uint32_t*)(SYSCON_BASE + 0x004))
#define SYSCON_RST_CAUSE     (*(volatile uint32_t*)(SYSCON_BASE + 0x008)) /* R/W1C, giu qua warm reset */
#define SYSCON_SW_RESET      (*(volatile uint32_t*)(SYSCON_BASE + 0x00C)) /* W: SYSCON_SW_RESET_KEY */
#define SYSCON_SEC_CTRL      (*(volatile uint32_t*)(SYSCON_BASE + 0x010)) /* RW1S, chi xoa bang POR */

#define SYSCON_CLK_PWM      0   // RTL: clk_gate_reg[0]
#define SYSCON_CLK_UART     1   // RTL: clk_gate_reg[1]
#define SYSCON_CLK_SPI      2   // RTL: clk_gate_reg[2]
#define SYSCON_CLK_I2C      3   // RTL: clk_gate_reg[3]
#define SYSCON_CLK_GPIO     4   // RTL: clk_gate_reg[4]
#define SYSCON_CLK_ACCEL    5   // RTL: clk_gate_reg[5]
/* Bit 6 CHI DOC tu RTL 2026-09-11: 1 = clock Debug Module dang chay. Clock DM do
 * debugger bat/tat (dmactive), firmware khong tat duoc nua - ghi bit nay khong
 * co tac dung. Truoc day firmware xoa bit 6 la tu khoa JTAG. */
#define SYSCON_CLK_DEBUG    6
#define SYSCON_CLK_ASCON    7   // RTL: clk_gate_reg[7] (TAT sau reset; o_active/psel van giu clock khi can)
#define SYSCON_CLK_UART1    8   // RTL: clk_gate_reg[8]  (TAT sau reset)
#define SYSCON_CLK_TIM0     9   // RTL: clk_gate_reg[9]  (TAT sau reset)
#define SYSCON_CLK_TIM1     10  // RTL: clk_gate_reg[10] (TAT sau reset)
#define SYSCON_CLK_MAX_BIT  10  // CLK_GATE_CTRL chi co [10:0]
#define SYSCON_CLK_CPU      31

/* RST_CAUSE - cac co cong don toi khi ghi 1 de xoa */
#define SYSCON_RST_EXT      (1u << 0)   /* chan rst_n / POR */
#define SYSCON_RST_WDT      (1u << 1)   /* watchdog */
#define SYSCON_RST_NDM      (1u << 2)   /* debugger (dmcontrol.ndmreset) */
#define SYSCON_RST_SW       (1u << 3)   /* syscon_system_reset() */

#define SYSCON_SW_RESET_KEY 0x05FA0001u

/* SEC_CTRL - chi dat duoc, xoa bang POR */
#define SYSCON_SEC_BOOT_LOCK (1u << 0)  /* khoa RESET_VECTOR */
#define SYSCON_SEC_DBG_OPEN  (1u << 1)  /* mo debug som (chi tu trang thai UNDECIDED) */
#define SYSCON_SEC_DBG_LOCK  (1u << 2)  /* khoa debug toi POR */

/* Khai báo API */
void syscon_enable_clock(uint8_t peripheral_bit);
void syscon_disable_clock(uint8_t peripheral_bit);
void syscon_set_boot_address(uint32_t addr);

/* Doc va xoa nguyen nhan reset (goi mot lan dau main). */
uint32_t syscon_take_reset_cause(void);
/* Warm reset toan chip tru Debug Module - khong tra ve. */
void syscon_system_reset(void) __attribute__((noreturn));
/* Khoa RESET_VECTOR / khoa debug toi POR - boot ROM goi. */
void syscon_lock_boot_vector(void);
void syscon_lock_debug(void);

/* API Tự động hóa cấp nguồn toàn hệ thống */
void syscon_init_clocks(void);

#endif // SYSCON_H
