#include "../inc/gpio.h"
#include "../inc/pinmux.h"

/**
 * Khởi tạo cấu hình cho các chân GPIO
 */
void HAL_GPIO_Init(GPIO_TypeDef *GPIOx, GPIO_InitTypeDef *GPIO_Init) {
    if (GPIOx == NULL || GPIO_Init == NULL) return;

    uint32_t pins = GPIO_Init->Pin;
    uint32_t mode = GPIO_Init->Mode;

    // Tat ngat cua cac chan nay truoc khi doi cau hinh.
    GPIOx->INT_EN &= ~pins;

    if (mode == GPIO_MODE_OUTPUT) {
        GPIOx->DIR |= pins;
    } else {
        GPIOx->DIR &= ~pins;

        if (mode != GPIO_MODE_INPUT) {
            uint32_t type = 0, pol = 0, both = 0;
            switch (mode) {
                case GPIO_MODE_IT_RISING:     pol  = pins; break;
                case GPIO_MODE_IT_BOTH:       both = pins; break;
                case GPIO_MODE_IT_LEVEL_HIGH: type = pins; pol = pins; break;
                case GPIO_MODE_IT_LEVEL_LOW:  type = pins; break;
                default: /* GPIO_MODE_IT_FALLING */ break;
            }
            GPIOx->INT_TYPE     = (GPIOx->INT_TYPE     & ~pins) | type;
            GPIOx->INT_POL      = (GPIOx->INT_POL      & ~pins) | pol;
            GPIOx->INT_BOTHEDGE = (GPIOx->INT_BOTHEDGE & ~pins) | both;
            // INT_STAT dat ca khi INT_EN = 0: xoa co cu roi moi bat.
            GPIOx->INT_STAT = pins;
            GPIOx->INT_EN  |= pins;
        }
    }

    // Pad PAn ve chuc nang GPIO (pinmux).
    pinmux_set_mask(pins, PIN_AF_GPIO);
}

/**
 * Ghi giá trị ra chân GPIO
 */
void HAL_GPIO_WritePin(GPIO_TypeDef *GPIOx, uint32_t GPIO_Pin, GPIO_PinState PinState) {
    if (GPIOx == NULL) return;

    if (PinState == GPIO_PIN_SET) {
        GPIOx->DATA_OUT |= GPIO_Pin;
    } else {
        GPIOx->DATA_OUT &= ~GPIO_Pin;
    }
}

/**
 * Đảo trạng thái chân (hay dùng để blink LED)
 */
void HAL_GPIO_TogglePin(GPIO_TypeDef *GPIOx, uint32_t GPIO_Pin) {
    if (GPIOx == NULL) return;
    GPIOx->DATA_OUT ^= GPIO_Pin; // đảo bit bằng XOR
}

/**
 * Đọc giá trị từ chân GPIO
 */
GPIO_PinState HAL_GPIO_ReadPin(GPIO_TypeDef *GPIOx, uint32_t GPIO_Pin) {
    if (GPIOx == NULL) return GPIO_PIN_RESET;

    if ((GPIOx->DATA_IN & GPIO_Pin) != 0) {
        return GPIO_PIN_SET;
    } else {
        return GPIO_PIN_RESET;
    }
}

/**
 * Xử lý interrupt cho GPIO (gọi từ trap handler, CLIC ID 18)
 */
void HAL_GPIO_IRQHandler(GPIO_TypeDef *GPIOx) {
    if (GPIOx == NULL) return;

    uint32_t valid_it = GPIOx->INT_STAT & GPIOx->INT_EN;
    if (valid_it == 0) return;

    // Xoa mot lan (W1C) truoc khi goi callback. Voi ngat MUC co se dat lai
    // ngay neu chan van o muc kich - callback phai tat INT_EN hoac xu ly nguon.
    GPIOx->INT_STAT = valid_it;

    for (int i = 0; i < 32; i++) {
        uint32_t current_pin = (1u << i);
        if (valid_it & current_pin) {
            HAL_GPIO_EXTI_Callback(current_pin);
        }
    }
}


__attribute__((weak)) void HAL_GPIO_EXTI_Callback(uint32_t GPIO_Pin) {
    (void)GPIO_Pin;
}
