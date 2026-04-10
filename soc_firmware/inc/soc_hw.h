#ifndef SOC_HW_H
#define SOC_HW_H

#include "soc_config.h"

/* =========================================================
 * 1. AXI BUS MEMORY MAP
 * ========================================================= */
#define BOOT_ROM_BASE       0x00000000  // S0: ROM (64KB)
#define CLINT_BASE          0x02000000  // S5: Core Local Interruptor
#define SYSTEM_RAM_BASE     0x20000000  // S1: On-chip SRAM (128KB)
#define SPI_FLASH_BASE      0x30000000  // S2: External SPI Flash (16MB)
#define APB_BRIDGE_BASE     0x40000000  // S4: APB Peripherals Bridge
#define SDRAM_BASE          0x80000000  // S3: Off-chip SDRAM (64MB)

/* =========================================================
 * 2. APB PERIPHERALS BASE
 * ========================================================= */
#define UART_BASE           (APB_BRIDGE_BASE + 0x0000) // S0: UART
#define GPIO_BASE           (APB_BRIDGE_BASE + 0x1000) // S1: GPIO
#define TIMER_BASE          (APB_BRIDGE_BASE + 0x2000) // S2: Timer
#define SPI_BASE            (APB_BRIDGE_BASE + 0x3000) // S3: SPI Master
#define I2C_BASE            (APB_BRIDGE_BASE + 0x4000) // S4: I2C Master
#define WATCHDOG_BASE       (APB_BRIDGE_BASE + 0x5000) // S5: Watchdog
#define ACCELERATOR_BASE    (APB_BRIDGE_BASE + 0x6000) // S6: CORDIC
#define SYSCON_BASE         (APB_BRIDGE_BASE + 0x7000) // S7: System Control
#define DMA_CFG_BASE        (APB_BRIDGE_BASE + 0x8000) // S9: DMA Configuration

// Ngoại lệ: PLIC có địa chỉ Base nằm tách biệt
#define PLIC_BASE           0x44000000                 // S8: Platform Interrupt Controller

/* =========================================================
 * 3. PLIC IRQ MAPPING
 * ========================================================= */
#define IRQ_UART        1   //
#define IRQ_SPI         2   //

#if CONFIG_HAS_DMA
#define IRQ_DMA_CH0     4   // Kênh 0 của DMA
#define IRQ_DMA_CH1     5   // Kênh 1 của DMA
#define IRQ_DMA_CH2     6   // Kênh 2 của DMA
#define IRQ_DMA_CH3     7   // Kênh 3 của DMA
#endif

// Dự phòng cho GPIO
#define IRQ_GPIO        8

#endif // SOC_HW_H