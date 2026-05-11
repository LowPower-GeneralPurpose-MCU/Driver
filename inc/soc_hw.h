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
#define PLIC_BASE           (APB_BRIDGE_BASE + 0x8000) // S8: PLIC
#define DMA_CFG_BASE        (APB_BRIDGE_BASE + 0x9000)


/* =========================================================
 * 3. PLIC IRQ MAPPING
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