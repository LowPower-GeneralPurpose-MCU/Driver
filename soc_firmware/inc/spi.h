#ifndef SPI_H
#define SPI_H

#include <stdint.h>
#include "soc_hw.h"
#include "soc_config.h"

#if CONFIG_HAS_SPI

typedef struct {
    volatile uint32_t CTRL;   // 0x00: [1] CPOL, [0] CPHA
    volatile uint32_t CS;     // 0x04: [0] Chip Select
    volatile uint32_t DIV;    // 0x08: SCLK Divider
    volatile uint32_t TXDATA; // 0x0C: Ghi vào đây sẽ tự động truyền
    volatile uint32_t RXDATA; // 0x10: Đọc dữ liệu nhận được (Tự động clear DONE)
    volatile uint32_t STATUS; // 0x14: [1] DONE, [0] BUSY
} SPI_TypeDef;

#define SPI0 ((SPI_TypeDef *)SPI_BASE)

// Các Macro hỗ trợ
#define SPI_STATUS_BUSY (1 << 0)
#define SPI_STATUS_DONE (1 << 1)

// API Functions
void spi_init(uint8_t cpol, uint8_t cpha, uint32_t clock_div);
void spi_set_cs(uint8_t state);
uint8_t spi_transfer(uint8_t data);

#endif // CONFIG_HAS_SPI
#endif // SPI_H