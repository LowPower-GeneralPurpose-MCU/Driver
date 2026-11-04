#ifndef SPI_H
#define SPI_H

#include <stdint.h>
#include "soc_hw.h"
#include "soc_config.h"

#if CONFIG_HAS_SPI

/* RTL: peripheral/apb_spi.v. Chan qua pinmux AF1: PA4 SCK, PA5 MOSI,
 * PA6 MISO, PA7 SS (hoac PA20..23). Ngat CLIC ID 19 (MUC). */
typedef struct {
    volatile uint32_t CTRL;    // 0x00: [1] CPOL, [0] CPHA
    volatile uint32_t CS;      // 0x04: [0] Chip Select (0 = chon slave)
    volatile uint32_t DIV;     // 0x08: SCLK Divider
    volatile uint32_t TXDATA;  // 0x0C: Ghi vào đây sẽ tự động truyền (TX FIFO)
    volatile uint32_t RXDATA;  // 0x10: Đọc dữ liệu nhận được (pop RX FIFO)
    volatile uint32_t STATUS;  // 0x14: [3] RX_EMPTY [2] TX_FULL [1] DONE (W1C) [0] BUSY
    volatile uint32_t DMA_INT; // 0x18: [3:0] - [0] ngat khi DONE, [1] ngat khi RX khong rong
} SPI_TypeDef;

#define SPI0 ((SPI_TypeDef *)SPI_BASE)

// Các Macro hỗ trợ
#define SPI_STATUS_BUSY     (1 << 0)
#define SPI_STATUS_DONE     (1 << 1)   // sticky - PHAI ghi 1 de xoa, doc RXDATA KHONG xoa
#define SPI_STATUS_TX_FULL  (1 << 2)
#define SPI_STATUS_RX_EMPTY (1 << 3)

// API Functions
void spi_init(uint8_t cpol, uint8_t cpha, uint32_t clock_div);
void spi_set_cs(uint8_t state);
uint8_t spi_transfer(uint8_t data);

#endif // CONFIG_HAS_SPI
#endif // SPI_H
