#ifndef SOC_HW_H
#define SOC_HW_H

#include "soc_config.h"

/* =========================================================
 * 1. AXI BUS MEMORY MAP (khop ld/soc.ld va top_soc.v)
 * ========================================================= */
#define BOOT_ROM_BASE       0x00010000  // S0: Boot ROM 32 KiB
#define ITCM_BASE           0x00020000  // ITCM 16 KiB
#define DTCM_BASE           0x00024000  // DTCM 16 KiB
#define SYSTEM_RAM_BASE     0x20000000  // S1: SRAM 128 KiB, CACHEABLE
#define DMA_POOL_BASE       0x20020000  // SRAM 128 KiB, UNCACHED - buffer DMA
#define SPI_FLASH_BASE      0x30000000  // S2: External SPI Flash (16MB)
#define SDRAM_BASE          0x80000000  // S3: Off-chip SDRAM (RAM ngoài)
#define APB_BRIDGE_BASE     0x40000000  // S4: APB Peripherals Bridge
#define CLINT_BASE          0x02000000  // S5: Core Local Interruptor
/* =========================================================
 * 2. APB PERIPHERALS BASE (top_soc.v, apb_interconnect)
 * ========================================================= */
#define UART_BASE           (APB_BRIDGE_BASE + 0x0000) // S0: UART0
#define UART0_BASE          UART_BASE
#define GPIO_BASE           (APB_BRIDGE_BASE + 0x1000) // S1: GPIO
#define TIMER_BASE          (APB_BRIDGE_BASE + 0x2000) // S2: PWM (apb_pwm, 1 kenh)
#define SPI_BASE            (APB_BRIDGE_BASE + 0x3000) // S3: SPI Master
#define I2C_BASE            (APB_BRIDGE_BASE + 0x4000) // S4: I2C Master
#define WATCHDOG_BASE       (APB_BRIDGE_BASE + 0x5000) // S5: Watchdog
#define ACCELERATOR_BASE    (APB_BRIDGE_BASE + 0x6000) // S6: CORDIC
#define SYSCON_BASE         (APB_BRIDGE_BASE + 0x7000) // S7: System Control
#define DMA_CFG_BASE        (APB_BRIDGE_BASE + 0x8000) // S9: DMA v2, 16 KiB
#define ASCON_BASE          (APB_BRIDGE_BASE + 0xC000) // S10: ASCON + TRNG
#define UART1_BASE          (APB_BRIDGE_BASE + 0xD000) // S11: UART1 (cung thanh ghi voi UART0)
#define TIM0_BASE           (APB_BRIDGE_BASE + 0xE000) // S12: timer 4 kenh (inc/timer.h)
#define TIM1_BASE           (APB_BRIDGE_BASE + 0xF000) // S13: timer 4 kenh
#define PINMUX_BASE         0x40020000                 // S14: pinmux 32 pad (inc/pinmux.h)
#define CLIC_BASE           0x44000000                 // S8 : CLIC (inc/clic.h)

/* =========================================================
 * 3. CLIC INTERRUPT ID (top_soc.v, clic_irq_src).
 *    Che do CLIC (mtvec.mode = 11): mcause[11:0] = ID.
 *    Che do CLINT (mtvec.mode = 0x): chi co msip (3) / mtip (7), qua mie.
 *
 *    PLIC da bo khoi RTL tu 2026-09-11 - khong con claim/complete. Moi ngat
 *    ngoai vi deu di qua CLIC (inc/clic.h).
 * ========================================================= */
#define CLIC_ID_MSIP        3    // CLINT software interrupt (muc)
#define CLIC_ID_MTIP        7    // CLINT timer interrupt (muc)
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
#define CLIC_NUM_IRQ        32

#endif // SOC_HW_H
