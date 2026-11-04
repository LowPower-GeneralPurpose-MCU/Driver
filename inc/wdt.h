#ifndef WDT_HAL_H
#define WDT_HAL_H

/*
 * Watchdog (RTL: peripheral/apb_watchdog.v). Bo dem nguoc, giam mot lan moi
 * chu ky RTC (32768 Hz), khong doi theo clock he thong.
 *
 * Khi dem ve 0 (va EN = 1): IE -> wdt_irq (CLIC ID 21, MUC), RE -> reset he
 * thong (SYSCON RST_CAUSE.WDT). Ca hai xay ra CUNG LUC - IE khong phai canh
 * bao som. Co irq chi xoa bang FEED. Sau reset bo dem = 0, nen PHAI feed
 * truoc khi bat EN (HAL_WDT_Init lam dung thu tu nay).
 */

#include <stdint.h>
#include <stddef.h>
#include "soc_hw.h"

// Cấu trúc thanh ghi của khối Watchdog (apb_watchdog.v)
typedef struct {
    volatile uint32_t LOAD;     // 0x00: RW - gia tri nap khi feed (don vi: chu ky RTC)
    volatile uint32_t CTRL;     // 0x04: RW - [0] EN [1] IE [2] RE
    volatile uint32_t FEED;     // 0x08: WO - ghi WDT_FEED_KEY de nap lai bo dem
} WDT_TypeDef;

// Ánh xạ địa chỉ phần cứng
#define WDT0 ((WDT_TypeDef *) WATCHDOG_BASE)

#define WDT_CTRL_EN         (1u << 0)
#define WDT_CTRL_IE         (1u << 1)
#define WDT_CTRL_RE         (1u << 2)
#define WDT_FEED_KEY        0x5A5A5A5Au

// timeout_ms -> so chu ky RTC
#define WDT_MS_TO_TICKS(ms) ((uint32_t)(((uint64_t)(ms) * RTC_CLOCK_HZ) / 1000u))

// Hàm API
// ctrl: WDT_CTRL_RE (reset khi het gio) va/hoac WDT_CTRL_IE (ngat); EN tu bat.
void HAL_WDT_Init(WDT_TypeDef *hwdt, uint32_t timeout_ticks, uint32_t ctrl);
void HAL_WDT_Refresh(WDT_TypeDef *hwdt);
void HAL_WDT_Stop(WDT_TypeDef *hwdt);
// Goi tu system_trap_handler (CLIC ID 21): goi callback roi feed (de ngat muc
// ha xuong). Muon dung han: goi HAL_WDT_Stop trong callback.
void HAL_WDT_IRQHandler(WDT_TypeDef *hwdt);
void HAL_WDT_TimeoutCallback(WDT_TypeDef *hwdt);   // weak

#endif // WDT_HAL_H
