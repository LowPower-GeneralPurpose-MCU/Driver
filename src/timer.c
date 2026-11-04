/* ==================================================================
 * File: src/timer.c
 * Mô tả: HAL cho TIM0 / TIM1 (RTL: peripheral/apb_timer.v)
 * ================================================================== */
#include "soc_config.h"

#if CONFIG_HAS_TIMER
#include "timer.h"

#define TIM_SR_ALL   0x1FFu   /* UIF + CC0..3IF + CC0..3OF */

void HAL_TIM_Base_Init(TIM_TypeDef *t, uint32_t psc, uint32_t arr)
{
    t->CR   = 0;               /* CEN = 0, OPM = 0 */
    t->DIER = 0;
    t->PSC  = psc & 0xFFFFu;
    t->ARR  = arr;
    t->EGR  = TIM_EGR_UG;      /* CNT = 0, prescaler = 0 - va DAT UIF */
    t->SR   = TIM_SR_ALL;      /* xoa UIF vua dat boi UG */
}

void HAL_TIM_Base_Start(TIM_TypeDef *t)
{
    t->CR |= TIM_CR_CEN;
}

void HAL_TIM_Base_Start_IT(TIM_TypeDef *t)
{
    t->SR    = TIM_SR_UIF;
    t->DIER |= TIM_DIER_UIE;
    t->CR   |= TIM_CR_CEN;
}

void HAL_TIM_Base_Stop(TIM_TypeDef *t)
{
    t->CR   &= ~TIM_CR_CEN;
    t->DIER &= ~TIM_DIER_UIE;
}

void HAL_TIM_OnePulse_Enable(TIM_TypeDef *t, uint32_t enable)
{
    if (enable) t->CR |= TIM_CR_OPM;
    else        t->CR &= ~TIM_CR_OPM;
}

void HAL_TIM_PWM_Start(TIM_TypeDef *t, uint32_t ch, uint32_t ccr)
{
    ch &= 3u;
    t->CCR[ch] = ccr;
    tim_set_ccmr(t, ch, TIM_OCM_PWM1);
    t->CCER = (t->CCER & ~TIM_CCER_CCP(ch)) | TIM_CCER_CCE(ch);
}

void HAL_TIM_PWM_Stop(TIM_TypeDef *t, uint32_t ch)
{
    t->CCER &= ~TIM_CCER_CCE(ch & 3u);   /* chan tha noi (oe = 0) */
}

void HAL_TIM_SetCompare(TIM_TypeDef *t, uint32_t ch, uint32_t ccr)
{
    t->CCR[ch & 3u] = ccr;
}

void HAL_TIM_OC_Start(TIM_TypeDef *t, uint32_t ch, uint32_t ocm, uint32_t ccr, uint32_t irq)
{
    ch &= 3u;
    t->CCR[ch] = ccr;
    tim_set_ccmr(t, ch, ocm & 7u);       /* CCS = 0: compare */
    t->CCER |= TIM_CCER_CCE(ch);
    t->SR    = TIM_SR_CCIF(ch);
    if (irq) t->DIER |= TIM_DIER_CCIE(ch);
}

void HAL_TIM_IC_Start(TIM_TypeDef *t, uint32_t ch, uint32_t edge, uint32_t filter, uint32_t irq)
{
    ch &= 3u;
    tim_set_ccmr(t, ch, TIM_CCS_CAPTURE | (edge & (3u << 4)) | TIM_ICF(filter));
    t->SR    = TIM_SR_CCIF(ch) | TIM_SR_CCOF(ch);
    t->CCER |= TIM_CCER_CCE(ch);         /* capture: CCxE = cho phep chup */
    if (irq) t->DIER |= TIM_DIER_CCIE(ch);
}

void HAL_TIM_IC_Stop(TIM_TypeDef *t, uint32_t ch)
{
    ch &= 3u;
    t->CCER &= ~TIM_CCER_CCE(ch);
    t->DIER &= ~TIM_DIER_CCIE(ch);
}

void HAL_TIM_IRQHandler(TIM_TypeDef *t)
{
    /* Chi cac co dang bat ngat (irq = |(SR[4:0] & DIER)). Xoa TRUOC khi goi
       callback: su kien moi toi trong callback se dat lai co va gay ngat moi. */
    uint32_t pend = t->SR & t->DIER & 0x1Fu;
    uint32_t ch;

    if (pend == 0u) return;
    t->SR = pend;   /* W1C */

    if (pend & TIM_SR_UIF) {
        HAL_TIM_PeriodElapsedCallback(t);
    }
    for (ch = 0; ch < 4u; ch++) {
        if (pend & TIM_SR_CCIF(ch)) {
            HAL_TIM_CaptureCompareCallback(t, ch);
        }
    }
}

__attribute__((weak)) void HAL_TIM_PeriodElapsedCallback(TIM_TypeDef *t)
{
    (void)t;
}

__attribute__((weak)) void HAL_TIM_CaptureCompareCallback(TIM_TypeDef *t, uint32_t ch)
{
    (void)t; (void)ch;
}

#endif /* CONFIG_HAS_TIMER */
