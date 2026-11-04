#ifndef PINMUX_H
#define PINMUX_H

/*
 * PINMUX 32 pad PA0..PA31 (RTL: peripheral/apb_pinmux.v, 2026-09-11).
 * 2 bit / pad: 0 = GPIO, 1..3 = AF1..AF3. Bang AF cua PA0-15 va PA16-31 giong
 * nhau (q = pad % 16):
 *
 *    q | AF1       | AF2       | AF3
 *    0 | UART0_TX  | TIM0_CH0  |  -
 *    1 | UART0_RX  | TIM0_CH1  |  -
 *    2 | UART1_TX  | TIM0_CH2  |  -
 *    3 | UART1_RX  | TIM0_CH3  |  -
 *    4 | SPI_SCK   | TIM1_CH0  |  -
 *    5 | SPI_MOSI  | TIM1_CH1  |  -
 *    6 | SPI_MISO  | TIM1_CH2  |  -
 *    7 | SPI_SS    | TIM1_CH3  |  -
 *    8 | I2C_SCL   | PWM_OUT   | UART1_TX
 *    9 | I2C_SDA   |  -        | UART1_RX
 *   10 |  -        | TIM0_CH0  | UART0_TX
 *   11 |  -        | TIM0_CH1  | UART0_RX
 *   12 |  -        | TIM1_CH0  | I2C_SCL
 *   13 |  -        | TIM1_CH1  | I2C_SDA
 *   14 |  -        | PWM_OUT   | SPI_SS
 *   15 |  -        |  -        |  -
 *
 * Sau reset: PA0 = UART0_TX, PA1 = UART0_RX, con lai GPIO vao.
 * GPIO_IN luon doc duoc moi pad bat ke AF.
 */

#include <stdint.h>
#include "soc_hw.h"

#define PINMUX_AFSEL0   (*(volatile uint32_t *)(PINMUX_BASE + 0x0))
#define PINMUX_AFSEL1   (*(volatile uint32_t *)(PINMUX_BASE + 0x4))

#define PIN_AF_GPIO 0u
#define PIN_AF1     1u
#define PIN_AF2     2u
#define PIN_AF3     3u

/* pad: 0..31 (PAn). af: PIN_AF_GPIO / PIN_AF1..3. pad >= 32 bi bo qua. */
static inline void pinmux_set(uint32_t pad, uint32_t af)
{
    if (pad > 31u) return;
    volatile uint32_t *reg = (pad < 16) ? &PINMUX_AFSEL0 : &PINMUX_AFSEL1;
    uint32_t sh = (pad & 15u) * 2u;
    *reg = (*reg & ~(3u << sh)) | ((af & 3u) << sh);
}

static inline uint32_t pinmux_get(uint32_t pad)
{
    if (pad > 31u) return PIN_AF_GPIO;
    uint32_t v = (pad < 16) ? PINMUX_AFSEL0 : PINMUX_AFSEL1;
    return (v >> ((pad & 15u) * 2u)) & 3u;
}

/* Dat cung mot AF cho moi pad co bit trong pad_mask (bit n = PAn). */
static inline void pinmux_set_mask(uint32_t pad_mask, uint32_t af)
{
    uint32_t p;
    for (p = 0; p < 32u; p++) {
        if (pad_mask & (1u << p)) pinmux_set(p, af);
    }
}

#endif /* PINMUX_H */
