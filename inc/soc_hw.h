#ifndef SOC_HW_H
#define SOC_HW_H

#include "soc_config.h"

/* =========================================================
 * 1. AXI BUS MEMORY MAP
 * ========================================================= */
#define BOOT_ROM_BASE       0x00010000  // S0: Boot ROM
#define SYSTEM_RAM_BASE     0x20000000  // S1: On-chip SRAM (AXI RAM nội bộ)
#define SPI_FLASH_BASE      0x30000000  // S2: External SPI Flash (16MB)
#define SDRAM_BASE          0x80000000  // S3: Off-chip SDRAM (RAM ngoài)
#define APB_BRIDGE_BASE     0x40000000  // S4: APB Peripherals Bridge
#define CLINT_BASE          0x02000000  // S5: Core Local Interruptor
/* =========================================================
 * 2. APB PERIPHERALS BASE
 * ========================================================= */
#define UART_BASE           (APB_BRIDGE_BASE + 0x0000) // S0: UART
#define GPIO_BASE           (APB_BRIDGE_BASE + 0x1000) // S1: GPIO
#define TIMER_BASE          (APB_BRIDGE_BASE + 0x2000) // S2: PWM/Timer
#define SPI_BASE            (APB_BRIDGE_BASE + 0x3000) // S3: SPI Master
#define I2C_BASE            (APB_BRIDGE_BASE + 0x4000) // S4: I2C Master
#define WATCHDOG_BASE       (APB_BRIDGE_BASE + 0x5000) // S5: Watchdog
#define ACCELERATOR_BASE    (APB_BRIDGE_BASE + 0x6000) // S6: CORDIC
#define SYSCON_BASE         (APB_BRIDGE_BASE + 0x7000) // S7: System Control
#define PLIC_BASE           0x44000000  // S8: (cu) - tu 2026-09-11 la CLIC, xem duoi
#define DMA_CFG_BASE        (APB_BRIDGE_BASE + 0x8000)
#define ASCON_BASE          (APB_BRIDGE_BASE + 0xC000) // S10: ASCON + TRNG
// 2026-09-11 - muc 8 review
#define UART1_BASE          (APB_BRIDGE_BASE + 0xD000) // S11: UART1 (cung thanh ghi voi UART0)
#define TIM0_BASE           (APB_BRIDGE_BASE + 0xE000) // S12: timer 4 kenh (inc/timer.h)
#define TIM1_BASE           (APB_BRIDGE_BASE + 0xF000) // S13: timer 4 kenh
#define PINMUX_BASE         0x40020000                 // S14: pinmux 32 pad (inc/pinmux.h)
#define CLIC_BASE           0x44000000                 // S8 : CLIC (inc/clic.h), thay PLIC

/* =========================================================
 * 2b. CLIC INTERRUPT ID (2026-09-11) - mcause.exccode = ID,
 *     vector = mtvec_base + 4 * ID khi clicintattr.shv = 1.
 * ========================================================= */
#define CLIC_ID_MSIP        3
#define CLIC_ID_MTIP        7
#define CLIC_ID_UART0       16
#define CLIC_ID_UART1       17
#define CLIC_ID_GPIO        18
#define CLIC_ID_SPI         19
#define CLIC_ID_I2C         20
#define CLIC_ID_WDT         21
#define CLIC_ID_DMA_CH0     22   // moi kenh DMA mot ID rieng
#define CLIC_ID_DMA_CH1     23
#define CLIC_ID_DMA_CH2     24
#define CLIC_ID_DMA_CH3     25
#define CLIC_ID_DCACHE_BERR 26   // loi bus cua store buffer D$ (mac dinh canh len)
#define CLIC_ID_ASCON       27
#define CLIC_ID_TIM0        28
#define CLIC_ID_TIM1        29


/* =========================================================
 * 3. PLIC IRQ MAPPING - CU. RTL khong con PLIC tu 2026-09-11: lenh ghi toi
 *    0x4400_xxxx ngoai 8 KB dau cua CLIC bi bo qua, doc ra 0 (plic_claim tra
 *    0). Giu lai de plic.c / trap.c hien tai van bien dich; chuyen sang
 *    inc/clic.h va CLIC_ID_* o tren.
 * ========================================================= */
#define IRQ_UART        1   // Ngắt UART
#define IRQ_GPIO        2   // Ngắt GPIO
#define IRQ_SPI         3   // Ngắt SPI
#define IRQ_I2C         4   // Ngắt I2C
#define IRQ_WDT         5   // Ngắt Watchdog
#define IRQ_DMA         6   // Ngắt DMA

#if CONFIG_HAS_DMA
#define IRQ_DMA_CH0     IRQ_DMA
#define IRQ_DMA_CH1     IRQ_DMA
#define IRQ_DMA_CH2     IRQ_DMA
#define IRQ_DMA_CH3     IRQ_DMA
#endif

#endif // SOC_HW_H
