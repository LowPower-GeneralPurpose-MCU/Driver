#include "uart.h"

// Handle da Init, theo instance - de trap.c khong phai biet bien huart nao.
static UART_HandleTypeDef *uart_handle[2];

static int uart_index(const UART_TypeDef *inst) {
    if (inst == UART0) return 0;
    if (inst == UART1) return 1;
    return -1;
}

// =========================================================
// KHỞI TẠO UART
// =========================================================
void HAL_UART_Init(UART_HandleTypeDef *huart, uint32_t sys_clk, uint32_t baudrate) {
    if (huart == NULL || huart->Instance == NULL) return;

    huart->State = HAL_UART_STATE_BUSY;

    // 1. Tính bộ chia cho TX (Chạy 1x - mỗi nhịp 1 bit)
    uint32_t tx_divisor = sys_clk / baudrate;

    // 2. Tính bộ chia cho RX (Chạy 16x - 16 nhịp mới được 1 bit)
    uint32_t rx_divisor = sys_clk / (baudrate * 16);

    // 3. Ghi vào thanh ghi: [31:16] là RX_DIV, [15:0] là TX_DIV
    huart->Instance->CLK_DIV = (rx_divisor << 16) | (tx_divisor & 0xFFFF);

    // Bật RX interrupt, tắt TX interrupt và DMA
    huart->Instance->DMA_INT = UART_DMA_INT_RX_INT_EN;

    int idx = uart_index(huart->Instance);
    if (idx >= 0) uart_handle[idx] = huart;

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
        while ((huart->Instance->STATUS & UART_STATUS_TX_FULL) != 0) {
        }

        // Ghi từng byte vào TX
        huart->Instance->TX_DATA = pData[i];
    }

    // Chờ gửi xong hẳn (shift register rỗng)
    while ((huart->Instance->STATUS & UART_STATUS_TX_BUSY) != 0);

    huart->State = HAL_UART_STATE_READY;
}

// =========================================================
// NHẬN MỘT BYTE (POLLING)
// =========================================================
int HAL_UART_ReceiveByte(UART_HandleTypeDef *huart, uint32_t timeout) {
    if (huart == NULL || huart->Instance == NULL) return -1;

    while ((huart->Instance->STATUS & UART_STATUS_RX_EMPTY) != 0) {
        if (timeout-- == 0) return -1;
    }
    return (int)(huart->Instance->RX_DATA & 0xFF);
}

// =========================================================
// INTERRUPT HANDLER
// =========================================================
void HAL_UART_IRQHandler(UART_HandleTypeDef *huart) {
    // Ngat MUC: xa het RX FIFO, neu khong CLIC nhan lai ngay sau mret.
    while ((huart->Instance->STATUS & UART_STATUS_RX_EMPTY) == 0) {

        // Đọc pop FIFO
        uint8_t rx_data = (uint8_t)(huart->Instance->RX_DATA & 0xFF);

        // Đẩy lên callback cho tầng trên xử lý
        HAL_UART_RxCallback(huart, rx_data);
    }
}

void HAL_UART_IRQDispatch(UART_TypeDef *instance) {
    int idx = uart_index(instance);
    if (idx >= 0 && uart_handle[idx] != NULL) {
        HAL_UART_IRQHandler(uart_handle[idx]);
        return;
    }
    // Khong co handle: bo du lieu de ngat muc ha xuong.
    if (instance != NULL) {
        while ((instance->STATUS & UART_STATUS_RX_EMPTY) == 0) {
            (void)instance->RX_DATA;
        }
    }
}

// =========================================================
// TRUYỀN BẰNG DMA (NON-BLOCKING)
// =========================================================
void HAL_UART_Transmit_DMA(UART_HandleTypeDef *huart, DMA_Channel_TypeDef *dma_ch,  uint8_t *pData, uint16_t Size, uint8_t periph_num) {
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
    huart->Instance->DMA_INT |= UART_DMA_INT_TX_DMA_EN;
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
    huart->Instance->DMA_INT |= UART_DMA_INT_RX_DMA_EN;
}

__attribute__((weak)) void HAL_UART_RxCallback(UART_HandleTypeDef *huart, uint8_t rx_data) {
    // Để trống cho user override ở main
    (void)huart; (void)rx_data;
}
