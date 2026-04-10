// File: uart.h
#ifndef UART_HAL_H
#define UART_HAL_H

#include <stdint.h>
#include "soc_hw.h"
#include "dma.h"
// 1. Cấu trúc Thanh ghi (Khớp tuyệt đối với apb_uart.v)
typedef struct {
    volatile uint32_t CLK_DIV;  // Offset 0x00: Bộ chia xung nhịp TX/RX
    volatile uint32_t TX_DATA;  // Offset 0x04: Ghi vào TX FIFO
    volatile uint32_t RX_DATA;  // Offset 0x08: Đọc từ RX FIFO
    volatile uint32_t STATUS;   // Offset 0x0C: Trạng thái (RX_BUSY, TX_BUSY, RX_EMPTY, TX_FULL...)
    volatile uint32_t DMA_INT;  // Offset 0x10: Cấu hình DMA và Ngắt
} UART_TypeDef;

#define UART0 ((UART_TypeDef *) UART_BASE)

// 2. Trạng thái của UART (State Machine)
typedef enum {
    HAL_UART_STATE_RESET      = 0x00,
    HAL_UART_STATE_READY      = 0x01,
    HAL_UART_STATE_BUSY       = 0x02,
    HAL_UART_STATE_BUSY_TX    = 0x03,
    HAL_UART_STATE_BUSY_RX    = 0x04,
    HAL_UART_STATE_ERROR      = 0x05
} HAL_UART_StateTypeDef;

// 3. Handle Structure
typedef struct {
    UART_TypeDef             *Instance;
    HAL_UART_StateTypeDef    State;
} UART_HandleTypeDef;

// API
void HAL_UART_Init(UART_HandleTypeDef *huart, uint32_t sys_clk, uint32_t baudrate);
void HAL_UART_Transmit(UART_HandleTypeDef *huart, uint8_t *pData, uint16_t Size);
void HAL_UART_IRQHandler(UART_HandleTypeDef *huart);
void HAL_UART_RxCallback(UART_HandleTypeDef *huart, uint8_t rx_data);
void HAL_UART_Transmit_DMA(UART_HandleTypeDef *huart, DMA_Channel_TypeDef *dma_ch, uint8_t *pData, uint16_t Size, uint8_t periph_num);
void HAL_UART_Receive_DMA(UART_HandleTypeDef *huart, DMA_Channel_TypeDef *dma_ch, uint8_t *pData, uint16_t Size, uint8_t periph_num);
#endif