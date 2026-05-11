#include <stdint.h>
#include <stdio.h>
#include "../inc/soc_config.h"
#include "../inc/soc_hw.h"
#include "../inc/clint.h"
#include "../inc/plic.h"

#if CONFIG_HAS_SYSCON
#include "../inc/syscon.h"
#endif

#if CONFIG_HAS_UART
#include "../inc/uart.h"
#define UART_CLK 100000000
UART_HandleTypeDef huart0;
#endif

#if CONFIG_HAS_GPIO
#include "../inc/gpio.h"
#endif

extern void trap_entry(void);

int main(void)
{
    __asm__ volatile("csrw mtvec, %0" :: "r"(trap_entry));

#if CONFIG_HAS_SYSCON
    syscon_init_clocks();
#endif

#if CONFIG_HAS_FPU
    __asm__ volatile("csrs mstatus, %0" :: "r"(0x6000));
#endif

    plic_set_threshold(0);

#if CONFIG_HAS_GPIO
    GPIO_InitTypeDef GPIO_InitStruct;

    GPIO_InitStruct.Pin = GPIO_PIN_0;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT;

    HAL_GPIO_Init(GPIO0, &GPIO_InitStruct);
#endif

#if CONFIG_HAS_UART
    huart0.Instance = UART0;

    HAL_UART_Init(&huart0, UART_CLK, 115200);

    plic_set_priority(IRQ_UART, 7);
    plic_enable_interrupt(IRQ_UART);

    uint8_t test_msg[] = "HELLO RISC-V UART TEST!\n";

    HAL_UART_Transmit(&huart0, test_msg, sizeof(test_msg) - 1);
#endif

    __asm__ volatile("csrs mie, %0" ::"r"(0x800));
    __asm__ volatile("csrs mstatus, %0" ::"r"(0x8));

    while (1)
    {
        __asm__ volatile("wfi");
    }

    return 0;
}

#if CONFIG_HAS_UART
void HAL_UART_RxCallback(UART_HandleTypeDef *huart, uint8_t rx_data)
{
    if (huart->Instance == UART0)
    {
#if CONFIG_HAS_GPIO
        if (rx_data == '1')
        {
            HAL_GPIO_WritePin(GPIO0, GPIO_PIN_0, GPIO_PIN_SET);
        }
        else if (rx_data == '0')
        {
            HAL_GPIO_WritePin(GPIO0, GPIO_PIN_0, GPIO_PIN_RESET);
        }
#endif
    }
}
#endif