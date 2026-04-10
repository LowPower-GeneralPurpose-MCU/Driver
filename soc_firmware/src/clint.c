#include "clint.h"

void clint_init(void) {
    CLINT_MTIMECMP_HI = 0xFFFFFFFF;
    CLINT_MTIMECMP_LO = 0xFFFFFFFF;
    CLINT_MSIP = 0;
}

uint64_t clint_get_mtime(void) {
    uint32_t mtime_hi, mtime_lo;
    do {
        mtime_hi = CLINT_MTIME_HI;
        mtime_lo = CLINT_MTIME_LO;
    } while (mtime_hi != CLINT_MTIME_HI); 
    
    return (((uint64_t)mtime_hi) << 32) | mtime_lo;
}

void clint_set_timer_ms(uint32_t ms, uint32_t timer_freq_hz) {
    uint64_t current_time = clint_get_mtime();
    
    uint32_t ticks_per_ms = timer_freq_hz / 1000;
    uint64_t target = current_time + ((uint64_t)ms * ticks_per_ms);

    CLINT_MTIMECMP_HI = 0xFFFFFFFF; 
    CLINT_MTIMECMP_LO = (uint32_t)(target & 0xFFFFFFFF);
    CLINT_MTIMECMP_HI = (uint32_t)(target >> 32);
}

void clint_trigger_soft_irq(void) {
    CLINT_MSIP = 1;
}

void clint_clear_soft_irq(void) {
    CLINT_MSIP = 0;
}

void HAL_Delay(uint32_t ms, uint32_t timer_freq_hz) {
    uint64_t start_time = clint_get_mtime();
    
    uint32_t ticks_per_ms = timer_freq_hz / 1000;
    uint64_t ticks_to_wait = (uint64_t)ms * ticks_per_ms;
    
    while ((clint_get_mtime() - start_time) < ticks_to_wait) {
        __asm__ volatile ("nop"); 
    }
}