#include "wdt.h"

// Khởi tạo watchdog timer
void HAL_WDT_Init(WDT_TypeDef *hwdt, uint32_t timeout_ticks) {
    if (hwdt == NULL) return;

    // Set thời gian timeout (tính theo số tick của clock)
    hwdt->LOAD = timeout_ticks;

    // Enable WDT + cho phép reset khi hết thời gian
    hwdt->CTRL = 0x03; 
    
    // Feed lần đầu để bắt đầu đếm
    HAL_WDT_Refresh(hwdt);
}

// Refresh watchdog (kick)
void HAL_WDT_Refresh(WDT_TypeDef *hwdt) {
    if (hwdt == NULL) return;
    
    // Ghi giá trị vào FEED để reset bộ đếm
    hwdt->FEED = 0x1; 
}