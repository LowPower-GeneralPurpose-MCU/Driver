// File: dma.h
#ifndef DMA_HAL_H
#define DMA_HAL_H

#include <stdint.h>
#include <stddef.h>
#include "soc_hw.h"

// ---------------------------------------------------------
// 1. CẤU TRÚC THANH GHI CỦA 1 KÊNH DMA
// ---------------------------------------------------------
typedef struct {
    volatile uint32_t SRC_ADDR;  // 0x00: Địa chỉ nguồn
    volatile uint32_t DST_ADDR;  // 0x04: Địa chỉ đích
    volatile uint32_t LEN;       // 0x08: Số lượng byte cần truyền (Max 64KB)
    volatile uint32_t CTRL;      // 0x0C: Điều khiển (START, BURST, INCR, PERIPH)
    volatile uint32_t STATUS;    // 0x10: Trạng thái (ACTIVE, DONE, ERR)
    volatile uint32_t INT_EN;    // 0x14: Kích hoạt ngắt
    volatile uint32_t INT_STAT;  // 0x18: Cờ ngắt (Ghi 1 để xóa - W1C)
} DMA_Channel_TypeDef;

// ---------------------------------------------------------
// 2. KHAI BÁO CÁC KÊNH DMA
// ---------------------------------------------------------
// Mỗi kênh cách nhau 0x1000 byte
#define DMA_CH0 ((DMA_Channel_TypeDef *) (DMA_CFG_BASE + 0x0000))
#define DMA_CH1 ((DMA_Channel_TypeDef *) (DMA_CFG_BASE + 0x1000))
#define DMA_CH2 ((DMA_Channel_TypeDef *) (DMA_CFG_BASE + 0x2000))
#define DMA_CH3 ((DMA_Channel_TypeDef *) (DMA_CFG_BASE + 0x3000))

// Thanh ghi Reset toàn cục (Global Control ở Offset 0xF00)
#define DMA_GLOBAL_CTRL (*(volatile uint32_t *)(DMA_CFG_BASE + 0x0F00))

// ---------------------------------------------------------
// 3. ĐỊNH NGHĨA CÁC THAM SỐ CHO THANH GHI CTRL
// ---------------------------------------------------------
// Theo RTL: [0]=start, [7:1]=burst_max, [8]=src_incr, [9]=dst_incr, [14:10]=periph_num
#define DMA_CTRL_START_Msk      (1 << 0)
#define DMA_CTRL_BURST_Pos      1
#define DMA_CTRL_SRC_INCR_Msk   (1 << 8)
#define DMA_CTRL_DST_INCR_Msk   (1 << 9)
#define DMA_CTRL_PERIPH_Pos     10

// Cờ ngắt (INT_STAT)
#define DMA_INT_DONE            (1 << 0)
#define DMA_INT_ERR             (1 << 1)

// ---------------------------------------------------------
// 4. API (HAL) CHO TẦNG ỨNG DỤNG
// ---------------------------------------------------------

// Khởi tạo và Reset DMA
void HAL_DMA_Init(void);

// Cấu hình một kênh DMA
// - src_inc / dst_inc: 1 (Tự động cộng địa chỉ), 0 (Giữ nguyên địa chỉ, ví dụ ghi vào UART_TX_DATA)
// - burst_size: Tối đa 64 (theo RTL MAX_BURST = 64)
// - periph_num: 0 (Memory to Memory), >0 (Nhận tín hiệu kích hoạt từ ngoại vi, ví dụ UART)
void HAL_DMA_Config(DMA_Channel_TypeDef *dma_ch, uint32_t src, uint32_t dst, uint16_t len, 
                    uint8_t src_inc, uint8_t dst_inc, uint8_t burst_size, uint8_t periph_num);

// Kích hoạt kênh (Bắt đầu truyền)
void HAL_DMA_Start(DMA_Channel_TypeDef *dma_ch);

// Đợi kênh truyền xong (Chặn CPU - Polling)
void HAL_DMA_Wait_Done(DMA_Channel_TypeDef *dma_ch);

// Hàm xử lý ngắt (Dùng trong trap_handler)
void HAL_DMA_IRQHandler(DMA_Channel_TypeDef *dma_ch);

// Hàm Callback báo hoàn thành
void HAL_DMA_TransferCompleteCallback(DMA_Channel_TypeDef *dma_ch);

#endif // DMA_HAL_H