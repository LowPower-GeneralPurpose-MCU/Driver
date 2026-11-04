#include <stdint.h>
#include <stdio.h>
#include "../inc/soc_config.h"
#include "../inc/soc_hw.h"
#include "../inc/clint.h"
#include "../inc/clic.h"

#if CONFIG_HAS_SYSCON
#include "../inc/syscon.h"
#endif

#if CONFIG_HAS_UART
#include "../inc/uart.h"
// UART chay bang clock he thong duy nhat 250 MHz (SYSTEM_BUS_CLOCK) tu
// 2026-09-11. 115200 baud -> TX_DIV 2170, RX_DIV 135.
UART_HandleTypeDef huart0;
#endif

#if CONFIG_HAS_GPIO
#include "../inc/gpio.h"
// LED o PA15: pad nay khong co AF nao (inc/pinmux.h), nen khong dung cham
// UART0 o PA0/PA1. GPIO_PIN_0 = PA0 = UART0_TX sau reset.
#define LED_PIN GPIO_PIN(15)
#endif

extern void trap_entry(void);

int main(void)
{
    // Che do CLIC (PLIC da bo khoi RTL): moi ngat va ngoai le vao trap_entry
    // (shv = 0), system_trap_handler phan luong theo CLIC ID. crt0.S da dat
    // mtvec = trap_entry o che do CLINT; doi sang CLIC truoc khi bat MIE.
    // trap_entry can le 64 byte (startup/trap_handler.S).
    clic_mode_enable((uintptr_t)trap_entry);

#if CONFIG_HAS_SYSCON
    syscon_init_clocks();
#endif

#if CONFIG_HAS_FPU
    __asm__ volatile("csrs mstatus, %0" :: "r"(0x6000));
#endif

#if CONFIG_HAS_GPIO
    GPIO_InitTypeDef GPIO_InitStruct;

    GPIO_InitStruct.Pin = LED_PIN;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT;

    HAL_GPIO_Init(GPIO0, &GPIO_InitStruct);
#endif

#if CONFIG_HAS_UART
    huart0.Instance = UART0;

    HAL_UART_Init(&huart0, SYSTEM_BUS_CLOCK, 115200);

    // RX UART0 -> CLIC ID 16, muc 1. uart_irq la MUC (RX FIFO khong rong).
    clic_irq_enable(CLIC_ID_UART0, 1, CLIC_TRIG_LEVEL_HIGH);

    uint8_t test_msg[] = "HELLO RISC-V UART TEST!\n";

    HAL_UART_Transmit(&huart0, test_msg, sizeof(test_msg) - 1);
#endif

    // Che do CLIC: mie khong con tac dung, chi can mstatus.MIE.
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
            HAL_GPIO_WritePin(GPIO0, LED_PIN, GPIO_PIN_SET);
        }
        else if (rx_data == '0')
        {
            HAL_GPIO_WritePin(GPIO0, LED_PIN, GPIO_PIN_RESET);
        }
#else
        (void)rx_data;
#endif
    }
}
#endif
