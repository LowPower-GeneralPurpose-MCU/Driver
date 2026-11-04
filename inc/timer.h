#ifndef TIMER_H
#define TIMER_H

/*
 * TIM0 / TIM1 - timer 32 bit 4 kenh capture/compare/PWM
 * (RTL: peripheral/apb_timer.v, 2026-09-11). Clock: SYSCON CLK_GATE_CTRL
 * bit 9 (TIM0) / bit 10 (TIM1) - TAT sau reset. Ngat: CLIC ID 28 / 29, kich
 * MUC: irq = |(SR[4:0] & DIER), ISR phai ghi W1C vao SR.
 *
 * Bo dem tang moi (PSC + 1) chu ky clk, dem 0..ARR roi ve 0 (su kien UPDATE).
 * Chan kenh di qua pinmux AF2 (inc/pinmux.h): TIM0_CHc o PA0..PA3 (va PA10/11
 * cho CH0/CH1), TIM1_CHc o PA4..PA7 (va PA12/13 cho CH0/CH1).
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
#define TIM_DIER_UIE        0x1u
#define TIM_DIER_CCIE(c)    (1u << (1 + (c)))
#define TIM_EGR_UG          0x1u
#define TIM_EGR_CCG(c)      (1u << (1 + (c)))
#define TIM_CCER_CCE(c)     (1u << (2u * (c)))
#define TIM_CCER_CCP(c)     (1u << (2u * (c) + 1u))

/* CCMR (theo kenh) */
#define TIM_OCM_FROZEN      0u
#define TIM_OCM_ACTIVE      1u
#define TIM_OCM_INACTIVE    2u
#define TIM_OCM_TOGGLE      3u
#define TIM_OCM_FORCE_LOW   4u
#define TIM_OCM_FORCE_HIGH  5u
#define TIM_OCM_PWM1        6u   /* 1 khi CNT <  CCR */
#define TIM_OCM_PWM2        7u   /* 1 khi CNT >= CCR */
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

/* ---------------------------------------------------------------------
 * HAL (src/timer.c) - chi bien dich khi CONFIG_HAS_TIMER = 1.
 * --------------------------------------------------------------------- */
/* Dung bo dem, nap PSC/ARR, UG (CNT = 0) va xoa moi co. Khong bat ngat. */
void HAL_TIM_Base_Init(TIM_TypeDef *t, uint32_t psc, uint32_t arr);
void HAL_TIM_Base_Start(TIM_TypeDef *t);
/* Bat ngat UPDATE (tran) roi chay. Nho clic_irq_enable(CLIC_ID_TIMx, ...). */
void HAL_TIM_Base_Start_IT(TIM_TypeDef *t);
void HAL_TIM_Base_Stop(TIM_TypeDef *t);
/* One-pulse: bo dem tu tat CEN o lan tran ke tiep. */
void HAL_TIM_OnePulse_Enable(TIM_TypeDef *t, uint32_t enable);

/* Kenh ch o PWM1, duty = ccr / (ARR + 1). Goi sau HAL_TIM_Base_Init. Nho
 * pinmux_set(pad, PIN_AF2) cho chan ra. Khong tu bat bo dem. */
void HAL_TIM_PWM_Start(TIM_TypeDef *t, uint32_t ch, uint32_t ccr);
void HAL_TIM_PWM_Stop(TIM_TypeDef *t, uint32_t ch);
void HAL_TIM_SetCompare(TIM_TypeDef *t, uint32_t ch, uint32_t ccr);
/* Compare thuan (khong PWM): ocm = TIM_OCM_*, irq != 0 -> bat CCxIE. */
void HAL_TIM_OC_Start(TIM_TypeDef *t, uint32_t ch, uint32_t ocm, uint32_t ccr, uint32_t irq);

/* Input capture: edge = TIM_ICE_*, filter 0..3. irq != 0 -> bat CCxIE.
 * Gia tri chup doc bang HAL_TIM_ReadCapture. */
void HAL_TIM_IC_Start(TIM_TypeDef *t, uint32_t ch, uint32_t edge, uint32_t filter, uint32_t irq);
void HAL_TIM_IC_Stop(TIM_TypeDef *t, uint32_t ch);
static inline uint32_t HAL_TIM_ReadCapture(TIM_TypeDef *t, uint32_t ch) { return t->CCR[ch & 3u]; }
static inline uint32_t HAL_TIM_GetCounter(TIM_TypeDef *t) { return t->CNT; }

/* Goi tu system_trap_handler (CLIC ID 28 / 29). Xoa cac co dang bat ngat roi
 * goi callback. Co CCxOF (chup de len) KHONG bi xoa - doc t->SR neu can. */
void HAL_TIM_IRQHandler(TIM_TypeDef *t);
void HAL_TIM_PeriodElapsedCallback(TIM_TypeDef *t);                 /* weak */
void HAL_TIM_CaptureCompareCallback(TIM_TypeDef *t, uint32_t ch);   /* weak */

#endif /* TIMER_H */
