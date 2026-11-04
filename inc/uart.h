// File: uart.h
#ifndef UART_HAL_H
#define UART_HAL_H

#include <stdint.h>
#include "soc_hw.h"
#include "dma.h"
// 1. Cấu trúc Thanh ghi (Khớp tuyệt đối với apb_uart.v)
typedef struct {
    volatile uint32_t CLK_DIV;  // Offset 0x00: [31:16] RX_DIV (16x), [15:0] TX_DIV
    volatile uint32_t TX_DATA;  // Offset 0x04: Ghi vào TX FIFO
    volatile uint32_t RX_DATA;  // Offset 0x08: Đọc từ RX FIFO (pop)
    volatile uint32_t STATUS;   // Offset 0x0C: Trạng thái (UART_STATUS_*)
    volatile uint32_t DMA_INT;  // Offset 0x10: Cấu hình DMA và Ngắt (UART_DMA_INT_*)
} UART_TypeDef;

#define UART0 ((UART_TypeDef *) UART0_BASE)
#define UART1 ((UART_TypeDef *) UART1_BASE)   // cung thanh ghi; CLIC ID 17, SYSCON bit 8

// STATUS (apb_uart.v)
#define UART_STATUS_TIMEOUT    (1u << 0)
#define UART_STATUS_FRAME_ERR  (1u << 1)
#define UART_STATUS_TX_FULL    (1u << 2)
#define UART_STATUS_RX_EMPTY   (1u << 3)
#define UART_STATUS_TX_BUSY    (1u << 4)   // dang truyen HOAC TX FIFO con du lieu
#define UART_STATUS_RX_BUSY    (1u << 5)

// DMA_INT (apb_uart.v). Ngat la MUC: (TX FIFO rong & TX_INT_EN) | (RX FIFO
// khong rong & RX_INT_EN) - ISR phai doc RX_DATA cho toi khi RX_EMPTY.
#define UART_DMA_INT_TX_INT_EN (1u << 0)
#define UART_DMA_INT_RX_INT_EN (1u << 1)
#define UART_DMA_INT_TX_DMA_EN (1u << 2)
#define UART_DMA_INT_RX_DMA_EN (1u << 3)

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
// sys_clk: SYSTEM_BUS_CLOCK (250 MHz). HAL_UART_Init bat RX interrupt o phia
// UART va ghi nho handle de HAL_UART_IRQDispatch tim lai. Ngat chi toi CPU
// khi CLIC ID 16 (UART0) / 17 (UART1) duoc bat (inc/clic.h).
// UART1 di qua pinmux: PA2/PA3 = AF1 (hoac PA8/PA9 = AF3) - UART0 mac dinh
// o PA0/PA1 sau reset.
void HAL_UART_Init(UART_HandleTypeDef *huart, uint32_t sys_clk, uint32_t baudrate);
void HAL_UART_Transmit(UART_HandleTypeDef *huart, uint8_t *pData, uint16_t Size);
// Doc mot byte, cho toi khi co. Tra ve -1 neu het timeout (so lan thu).
int  HAL_UART_ReceiveByte(UART_HandleTypeDef *huart, uint32_t timeout);
void HAL_UART_IRQHandler(UART_HandleTypeDef *huart);
// Goi tu system_trap_handler: tim handle da Init cho Instance roi goi
// HAL_UART_IRQHandler. Instance chua Init: xa RX FIFO de ngat muc khong treo.
void HAL_UART_IRQDispatch(UART_TypeDef *instance);
void HAL_UART_RxCallback(UART_HandleTypeDef *huart, uint8_t rx_data);
void HAL_UART_Transmit_DMA(UART_HandleTypeDef *huart, DMA_Channel_TypeDef *dma_ch,  uint8_t *pData, uint16_t Size, uint8_t periph_num);
void HAL_UART_Receive_DMA(UART_HandleTypeDef *huart, DMA_Channel_TypeDef *dma_ch,  uint8_t *pData, uint16_t Size, uint8_t periph_num);
#endif
