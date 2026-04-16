#include "../inc/gpio.h"

/**
 * Khởi tạo cấu hình cho các chân GPIO
 */
void HAL_GPIO_Init(GPIO_TypeDef *GPIOx, GPIO_InitTypeDef *GPIO_Init) {
    if (GPIOx == NULL || GPIO_Init == NULL) return;

    for (int i = 0; i < 32; i++) {
        uint32_t current_pin = (1 << i);
        
        if (GPIO_Init->Pin & current_pin) {
            if (GPIO_Init->Mode == GPIO_MODE_OUTPUT) {
                GPIOx->DIR |= current_pin;       // set output
                GPIOx->INT_MASK &= ~current_pin; // không dùng ngắt
            } 
            else if (GPIO_Init->Mode == GPIO_MODE_INPUT) {
                GPIOx->DIR &= ~current_pin;      // set input
                GPIOx->INT_MASK &= ~current_pin; // không dùng ngắt
            } 
            else if (GPIO_Init->Mode == GPIO_MODE_IT) {
                GPIOx->DIR &= ~current_pin;      // input mode
                GPIOx->INT_MASK |= current_pin;  // bật interrupt
            }
        }
    }
}

/**
 * Ghi giá trị ra chân GPIO
 */
void HAL_GPIO_WritePin(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin, GPIO_PinState PinState) {
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
void HAL_GPIO_TogglePin(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin) {
    if (GPIOx == NULL) return;
    GPIOx->DATA_OUT ^= GPIO_Pin; // đảo bit bằng XOR
}

/**
 * Đọc giá trị từ chân GPIO
 */
GPIO_PinState HAL_GPIO_ReadPin(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin) {
    if (GPIOx == NULL) return GPIO_PIN_RESET;

    if ((GPIOx->DATA_IN & GPIO_Pin) != 0) {
        return GPIO_PIN_SET;
    } else {
        return GPIO_PIN_RESET;
    }
}

/**
 * Xử lý interrupt cho GPIO (gọi từ trap handler)
 */
void HAL_GPIO_IRQHandler(GPIO_TypeDef *GPIOx) {
    if (GPIOx == NULL) return;

    uint32_t it_status = GPIOx->INT_STAT;
    uint32_t valid_it = it_status & GPIOx->INT_MASK;

    for (int i = 0; i < 32; i++) {
        uint32_t current_pin = (1 << i);
        if (valid_it & current_pin) {
            // clear cờ ngắt
            GPIOx->INT_STAT = current_pin;
            
            // gọi callback 
            HAL_GPIO_EXTI_Callback(current_pin);
        }
    }
}


__attribute__((weak)) void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin) {
}