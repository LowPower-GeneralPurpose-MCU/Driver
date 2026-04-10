#include "uart.h"

// =========================================================
// KHỞI TẠO UART
// =========================================================
void HAL_UART_Init(UART_HandleTypeDef *huart, uint32_t sys_clk, uint32_t baudrate) {
    if (huart == NULL || huart->Instance == NULL) return; 

    huart->State = HAL_UART_STATE_BUSY;

    // Tính divisor cho baudrate
    uint32_t divisor = sys_clk / baudrate;
    
    // Ghi cho cả RX và TX
    huart->Instance->CLK_DIV = (divisor << 16) | (divisor & 0xFFFF);

    // Bật RX interrupt, tắt TX interrupt và DMA
    huart->Instance->DMA_INT = 0x02;

    huart->State = HAL_UART_STATE_READY;
}

// =========================================================
// TRUYỀN DỮ LIỆU (POLLING)
// =========================================================
void HAL_UART_Transmit(UART_HandleTypeDef *huart, uint8_t *pData, uint16_t Size) {
    if (huart->State != HAL_UART_STATE_READY) return; 
    if (pData == NULL || Size == 0) return;

    huart->State = HAL_UART_STATE_BUSY_TX;

    for (uint16_t i = 0; i < Size; i++) {
        // Nếu FIFO đầy thì chờ
        while ((huart->Instance->STATUS & (1 << 2)) != 0) {
        }
        
        // Ghi từng byte vào TX
        huart->Instance->TX_DATA = pData[i];
    }

    // Chờ gửi xong hẳn (shift register rỗng)
    while ((huart->Instance->STATUS & (1 << 4)) != 0);

    huart->State = HAL_UART_STATE_READY;
}

// =========================================================
// INTERRUPT HANDLER
// =========================================================
void HAL_UART_IRQHandler(UART_HandleTypeDef *huart) {
    // Nếu RX FIFO còn data thì xử lý
    if ((huart->Instance->STATUS & (1 << 3)) == 0) {
        
        // Đọc pop FIFO
        uint8_t rx_data = (uint8_t)(huart->Instance->RX_DATA & 0xFF);
        
        // Đẩy lên callback cho tầng trên xử lý
        HAL_UART_RxCallback(huart, rx_data);
    }
}

// =========================================================
// TRUYỀN BẰNG DMA (NON-BLOCKING)
// =========================================================
void HAL_UART_Transmit_DMA(UART_HandleTypeDef *huart, DMA_Channel_TypeDef *dma_ch, uint8_t *pData, uint16_t Size, uint8_t periph_num) {
    if (huart->State != HAL_UART_STATE_READY) return;
    if (pData == NULL || Size == 0 || dma_ch == NULL) return;

    huart->State = HAL_UART_STATE_BUSY_TX;

    // src: RAM (tăng địa chỉ), dst: TX register (giữ nguyên)
    HAL_DMA_Config(dma_ch, 
                   (uint32_t)pData, 
                   (uint32_t)&(huart->Instance->TX_DATA), 
                   Size, 
                   1, 0, 1, periph_num);

    // Start DMA
    HAL_DMA_Start(dma_ch);

    // Bật TX DMA request
    huart->Instance->DMA_INT |= (1 << 2);
}

// =========================================================
// NHẬN BẰNG DMA
// =========================================================
void HAL_UART_Receive_DMA(UART_HandleTypeDef *huart, DMA_Channel_TypeDef *dma_ch, uint8_t *pData, uint16_t Size, uint8_t periph_num) {
    if (huart->State != HAL_UART_STATE_READY) return;
    if (pData == NULL || Size == 0 || dma_ch == NULL) return;

    huart->State = HAL_UART_STATE_BUSY_RX;

    // src: RX register (fix), dst: RAM (tăng)
    HAL_DMA_Config(dma_ch, 
                   (uint32_t)&(huart->Instance->RX_DATA), 
                   (uint32_t)pData, 
                   Size, 
                   0, 1, 1, periph_num);

    // Start DMA
    HAL_DMA_Start(dma_ch);

    // Bật RX DMA request
    huart->Instance->DMA_INT |= (1 << 3);
}


__attribute__((weak)) void HAL_UART_RxCallback(UART_HandleTypeDef *huart, uint8_t rx_data) {

}