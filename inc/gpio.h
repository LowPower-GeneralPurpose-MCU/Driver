/* ==================================================================
 * File: inc/gpio.h
 * Mô tả: Thư viện HAL cho ngoại vi GPIO
 * ================================================================== */
#ifndef GPIO_HAL_H
#define GPIO_HAL_H

#include <stdint.h>
#include <stddef.h>
#include "soc_hw.h"

// ---------------------------------------------------------
// 1. CẤU TRÚC THANH GHI GPIO
// ---------------------------------------------------------
typedef struct {
    volatile uint32_t DATA_IN;   // 0x00: Read Only - Trạng thái thực tế từ Pad
    volatile uint32_t DATA_OUT;  // 0x04: Read/Write - Giá trị xuất ra chân
    volatile uint32_t DIR;       // 0x08: Read/Write - Hướng (1: Out, 0: In)
    volatile uint32_t INT_MASK;  // 0x0C: Read/Write - Kích hoạt ngắt cho chân
    volatile uint32_t INT_STAT;  // 0x10: Read/W1C - Trạng thái ngắt (Ghi 1 để xóa)
} GPIO_TypeDef;

#define GPIO0 ((GPIO_TypeDef *) GPIO_BASE)

// ---------------------------------------------------------
// 2. ĐỊNH NGHĨA CÁC CHÂN (PIN BITMASKS)
// ---------------------------------------------------------
#define GPIO_PIN_0   ((uint32_t)0x00000001)
#define GPIO_PIN_1   ((uint32_t)0x00000002)
#define GPIO_PIN_2   ((uint32_t)0x00000004)
#define GPIO_PIN_3   ((uint32_t)0x00000008)
// ... Bạn có thể tự điền đến PIN_31 ...
#define GPIO_PIN_ALL ((uint32_t)0xFFFFFFFF)

// ---------------------------------------------------------
// 3. CÁC KIỂU DỮ LIỆU (ENUMS & STRUCTS)
// ---------------------------------------------------------
typedef enum {
    GPIO_PIN_RESET = 0,
    GPIO_PIN_SET   = 1
} GPIO_PinState;

// Chế độ hoạt động
#define GPIO_MODE_INPUT     0x00  // Đầu vào bình thường
#define GPIO_MODE_OUTPUT    0x01  // Đầu ra
#define GPIO_MODE_IT        0x02  // Đầu vào + Bật ngắt (Interrupt)

// Cấu trúc khởi tạo (Dùng để truyền tham số vào hàm Init)
typedef struct {
    uint32_t Pin;       // Chọn chân (Có thể OR nhiều chân lại: GPIO_PIN_0 | GPIO_PIN_1)
    uint32_t Mode;      // Chế độ (GPIO_MODE_OUTPUT, GPIO_MODE_INPUT, GPIO_MODE_IT)
} GPIO_InitTypeDef;

// ---------------------------------------------------------
// 4. CÁC HÀM API
// ---------------------------------------------------------
void HAL_GPIO_Init(GPIO_TypeDef *GPIOx, GPIO_InitTypeDef *GPIO_Init);
void HAL_GPIO_WritePin(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin, GPIO_PinState PinState);
void HAL_GPIO_TogglePin(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin);
GPIO_PinState HAL_GPIO_ReadPin(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin);

// Hàm ngắt
void HAL_GPIO_IRQHandler(GPIO_TypeDef *GPIOx);
void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin);

#endif // GPIO_HAL_H