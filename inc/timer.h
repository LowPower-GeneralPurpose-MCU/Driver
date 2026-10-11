#ifndef TIMER_H
#define TIMER_H

/*
 * TIM0 / TIM1 - timer 32 bit 4 kenh capture/compare/PWM
 * (RTL: peripheral/apb_timer.v, 2026-09-11). Clock: SYSCON CLK_GATE_CTRL
 * bit 9 (TIM0) / bit 10 (TIM1). Ngat: CLIC ID 28 / 29.
 */

#include <stdint.h>
#include "soc_hw.h"

typedef struct {
    volatile uint32_t CR;      /* 0x00 [0] CEN [1] OPM                        */
    volatile uint32_t PSC;     /* 0x04 [15:0]                                 */
    volatile uint32_t ARR;     /* 0x08                                        */
    volatile uint32_t CNT;     /* 0x0C                                        */
    volatile uint32_t SR;      /* 0x10 W1C [0] UIF [4:1] CCxIF [8:5] CCxOF    */
    volatile uint32_t DIER;    /* 0x14 [0] UIE [4:1] CCxIE                    */
    volatile uint32_t EGR;     /* 0x18 W  [0] UG [4:1] CCxG                   */
    volatile uint32_t CCMR;    /* 0x1C 1 byte / kenh: [2:0] OCM [3] CCS
                                        [5:4] ICE [7:6] ICF                   */
    volatile uint32_t CCER;    /* 0x20 kenh c: [2c] CCxE [2c+1] CCxP          */
    volatile uint32_t CCR[4];  /* 0x24..0x30                                  */
} TIM_TypeDef;

#define TIM0    ((TIM_TypeDef *)TIM0_BASE)
#define TIM1    ((TIM_TypeDef *)TIM1_BASE)

#define TIM_CR_CEN          0x1u
#define TIM_CR_OPM          0x2u
#define TIM_SR_UIF          0x1u
#define TIM_SR_CCIF(c)      (1u << (1 + (c)))
#define TIM_SR_CCOF(c)      (1u << (5 + (c)))

/* CCMR (theo kenh) */
#define TIM_OCM_FROZEN      0u
#define TIM_OCM_ACTIVE      1u
#define TIM_OCM_INACTIVE    2u
#define TIM_OCM_TOGGLE      3u
#define TIM_OCM_FORCE_LOW   4u
#define TIM_OCM_FORCE_HIGH  5u
#define TIM_OCM_PWM1        6u
#define TIM_OCM_PWM2        7u
#define TIM_CCS_CAPTURE     (1u << 3)
#define TIM_ICE_RISE        (0u << 4)
#define TIM_ICE_FALL        (1u << 4)
#define TIM_ICE_BOTH        (2u << 4)
#define TIM_ICF(n)          (((n) & 3u) << 6)   /* 0: khong, 1: 2, 2: 4, 3: 8 mau */

static inline void tim_set_ccmr(TIM_TypeDef *t, uint32_t ch, uint32_t mode)
{
    uint32_t sh = (ch & 3u) * 8u;
    t->CCMR = (t->CCMR & ~(0xFFu << sh)) | ((mode & 0xFFu) << sh);
}

/* PWM: tan so = f_clk / ((psc + 1) * (arr + 1)), duty = ccr / (arr + 1). */
static inline void tim_pwm_start(TIM_TypeDef *t, uint32_t ch, uint32_t psc,
                                 uint32_t arr, uint32_t ccr)
{
    t->CR  = 0;
    t->PSC = psc;
    t->ARR = arr;
    t->CCR[ch & 3u] = ccr;
    tim_set_ccmr(t, ch, TIM_OCM_PWM1);
    t->CCER |= 1u << (2u * (ch & 3u));
    t->EGR  = 1u;                       /* UG: CNT = 0 */
    t->CR   = TIM_CR_CEN;
}

#endif /* TIMER_H */
