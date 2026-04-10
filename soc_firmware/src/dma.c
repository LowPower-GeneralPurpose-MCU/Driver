#include "dma.h"

// Reset toàn bộ DMA về trạng thái ban đầu
void HAL_DMA_Init(void) {
    // Ghi bit reset để clear toàn bộ logic bên trong
    DMA_GLOBAL_CTRL = 1;
}

// Cấu hình cho 1 channel DMA trước khi chạy
void HAL_DMA_Config(DMA_Channel_TypeDef *dma_ch, uint32_t src, uint32_t dst, uint16_t len, 
                    uint8_t src_inc, uint8_t dst_inc, uint8_t burst_size, uint8_t periph_num) {
    
    // Nếu chưa cấp phát channel thì thôi
    if (dma_ch == NULL) return;

    // Set địa chỉ nguồn và đích
    dma_ch->SRC_ADDR = src;
    dma_ch->DST_ADDR = dst;
    
    // Set độ dài cần copy
    dma_ch->LEN = len;

    // Build giá trị thanh ghi control
    uint32_t ctrl_val = 0;
    
    // Giới hạn burst để tránh vượt quá phần cứng hỗ trợ
    if (burst_size > 64) burst_size = 64;
    ctrl_val |= (burst_size << DMA_CTRL_BURST_Pos);
    
    // Bật auto increment nếu cần
    if (src_inc) ctrl_val |= DMA_CTRL_SRC_INCR_Msk;
    if (dst_inc) ctrl_val |= DMA_CTRL_DST_INCR_Msk;
    
    // Chọn peripheral nếu có dùng
    ctrl_val |= (periph_num << DMA_CTRL_PERIPH_Pos);

    // Ghi cấu hình (chưa start)
    dma_ch->CTRL = ctrl_val;

    // Mặc định bật interrupt khi done hoặc lỗi
    dma_ch->INT_EN = DMA_INT_DONE | DMA_INT_ERR;
}

// Bắt đầu truyền DMA
void HAL_DMA_Start(DMA_Channel_TypeDef *dma_ch) {
    if (dma_ch == NULL) return;
    
    // Set bit START để kick DMA
    dma_ch->CTRL |= DMA_CTRL_START_Msk;
}

// Chờ DMA chạy xong (polling)
void HAL_DMA_Wait_Done(DMA_Channel_TypeDef *dma_ch) {
    if (dma_ch == NULL) return;

    // Loop cho đến khi DONE = 1
    while ((dma_ch->STATUS & (1 << 1)) == 0) {
    }

    // Clear cờ DONE (W1C)
    dma_ch->INT_STAT = DMA_INT_DONE;
}

// Handler xử lý interrupt từ DMA
void HAL_DMA_IRQHandler(DMA_Channel_TypeDef *dma_ch) {
    if (dma_ch == NULL) return;

    // Nếu hoàn thành truyền
    if (dma_ch->INT_STAT & DMA_INT_DONE) {
        // Clear flag trước
        dma_ch->INT_STAT = DMA_INT_DONE;

        // Gọi callback
        HAL_DMA_TransferCompleteCallback(dma_ch);
    }
    
    // Nếu có lỗi thì clear luôn để tránh bị kẹt IRQ
    if (dma_ch->INT_STAT & DMA_INT_ERR) {
        dma_ch->INT_STAT = DMA_INT_ERR;
    }
}

// Callback mặc định (có thể override ở file khác)
__attribute__((weak)) void HAL_DMA_TransferCompleteCallback(DMA_Channel_TypeDef *dma_ch) {
}