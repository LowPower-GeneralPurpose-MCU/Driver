#include "wdt.h"

// Khởi tạo watchdog timer
void HAL_WDT_Init(WDT_TypeDef *hwdt, uint32_t timeout_ticks, uint32_t ctrl) {
    if (hwdt == NULL) return;

    // Tat truoc khi doi cau hinh
    hwdt->CTRL = 0;

    // Set thời gian timeout (đơn vị: chu kỳ RTC 32768 Hz)
    hwdt->LOAD = timeout_ticks;

    // Feed TRUOC khi bat: sau reset bo dem = 0, bat EN luc do la het gio ngay.
    HAL_WDT_Refresh(hwdt);

    // Bat WDT voi IE / RE theo yeu cau
    hwdt->CTRL = (ctrl & (WDT_CTRL_IE | WDT_CTRL_RE)) | WDT_CTRL_EN;
}

// Refresh watchdog (kick) - nap lai LOAD va xoa irq/reset dang cho
void HAL_WDT_Refresh(WDT_TypeDef *hwdt) {
    if (hwdt == NULL) return;
    hwdt->FEED = WDT_FEED_KEY;
}

void HAL_WDT_Stop(WDT_TypeDef *hwdt) {
    if (hwdt == NULL) return;
    hwdt->CTRL = 0;
    HAL_WDT_Refresh(hwdt);   // ha irq neu dang cao
}

void HAL_WDT_IRQHandler(WDT_TypeDef *hwdt) {
    if (hwdt == NULL) return;
    HAL_WDT_TimeoutCallback(hwdt);
    HAL_WDT_Refresh(hwdt);   // irq chi xoa bang feed
}

__attribute__((weak)) void HAL_WDT_TimeoutCallback(WDT_TypeDef *hwdt) {
    (void)hwdt;
}
