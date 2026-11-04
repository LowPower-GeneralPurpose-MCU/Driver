/* ==================================================================
 * File: inc/gpio.h
 * Mô tả: Thư viện HAL cho ngoại vi GPIO (RTL: peripheral/apb_gpio.v)
 *
 * Chan GPIO n = pad PAn CHI KHI pinmux cua pad do = GPIO (inc/pinmux.h).
 * Sau reset PA0/PA1 la UART0 - HAL_GPIO_Init tu dua pad ve GPIO, nen dung
 * GPIO_PIN_0/1 se lay mat console UART0.
 * Ngat: CLIC ID 18, kich MUC = |(INT_STAT & INT_EN).
 * ================================================================== */
#ifndef GPIO_HAL_H
#define GPIO_HAL_H

#include <stdint.h>
#include <stddef.h>
#include "soc_hw.h"

// ---------------------------------------------------------
// 1. CẤU TRÚC THANH GHI GPIO (apb_gpio.v)
// ---------------------------------------------------------
typedef struct {
    volatile uint32_t DATA_IN;      // 0x00: RO - muc thuc te cua pad (qua 2FF)
    volatile uint32_t DATA_OUT;     // 0x04: RW - giá trị xuất ra chân
    volatile uint32_t DIR;          // 0x08: RW - hướng (1: Out, 0: In)
    volatile uint32_t INT_EN;       // 0x0C: RW - bat ngat theo chan
    volatile uint32_t INT_TYPE;     // 0x10: RW - 1 = muc, 0 = canh
    volatile uint32_t INT_POL;      // 0x14: RW - 1 = muc cao / canh len, 0 = muc thap / canh xuong
    volatile uint32_t INT_BOTHEDGE; // 0x18: RW - 1 = ca hai canh (khi INT_TYPE = 0)
    volatile uint32_t INT_STAT;     // 0x1C: R/W1C - co ngat (chi chan vao, dat ca khi INT_EN = 0)
} GPIO_TypeDef;

#define GPIO0 ((GPIO_TypeDef *) GPIO_BASE)

// ---------------------------------------------------------
// 2. ĐỊNH NGHĨA CÁC CHÂN (PIN BITMASKS)
// ---------------------------------------------------------
#define GPIO_PIN(n)  ((uint32_t)1u << (n))
#define GPIO_PIN_0   ((uint32_t)0x00000001)
#define GPIO_PIN_1   ((uint32_t)0x00000002)
#define GPIO_PIN_2   ((uint32_t)0x00000004)
#define GPIO_PIN_3   ((uint32_t)0x00000008)
#define GPIO_PIN_ALL ((uint32_t)0xFFFFFFFF)

// ---------------------------------------------------------
// 3. CÁC KIỂU DỮ LIỆU (ENUMS & STRUCTS)
// ---------------------------------------------------------
typedef enum {
    GPIO_PIN_RESET = 0,
    GPIO_PIN_SET   = 1
} GPIO_PinState;

// Chế độ hoạt động
#define GPIO_MODE_INPUT          0x00  // Đầu vào bình thường
#define GPIO_MODE_OUTPUT         0x01  // Đầu ra
#define GPIO_MODE_IT_FALLING     0x02  // Vào + ngắt cạnh xuống
#define GPIO_MODE_IT_RISING      0x03  // Vào + ngắt cạnh lên
#define GPIO_MODE_IT_BOTH        0x04  // Vào + ngắt cả hai cạnh
#define GPIO_MODE_IT_LEVEL_HIGH  0x05  // Vào + ngắt mức cao
#define GPIO_MODE_IT_LEVEL_LOW   0x06  // Vào + ngắt mức thấp
#define GPIO_MODE_IT             GPIO_MODE_IT_FALLING  // nhu cu: mac dinh RTL sau reset

// Cấu trúc khởi tạo (Dùng để truyền tham số vào hàm Init)
typedef struct {
    uint32_t Pin;       // Chọn chân (Có thể OR nhiều chân lại: GPIO_PIN_0 | GPIO_PIN_1)
    uint32_t Mode;      // GPIO_MODE_*
} GPIO_InitTypeDef;

// ---------------------------------------------------------
// 4. CÁC HÀM API
// ---------------------------------------------------------
void HAL_GPIO_Init(GPIO_TypeDef *GPIOx, GPIO_InitTypeDef *GPIO_Init);
void HAL_GPIO_WritePin(GPIO_TypeDef *GPIOx, uint32_t GPIO_Pin, GPIO_PinState PinState);
void HAL_GPIO_TogglePin(GPIO_TypeDef *GPIOx, uint32_t GPIO_Pin);
GPIO_PinState HAL_GPIO_ReadPin(GPIO_TypeDef *GPIOx, uint32_t GPIO_Pin);

// Hàm ngắt
void HAL_GPIO_IRQHandler(GPIO_TypeDef *GPIOx);
void HAL_GPIO_EXTI_Callback(uint32_t GPIO_Pin);

#endif // GPIO_HAL_H
