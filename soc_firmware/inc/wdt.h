#ifndef WDT_HAL_H
#define WDT_HAL_H

#include <stdint.h>
#include <stddef.h>
#include "soc_hw.h"

// Cấu trúc thanh ghi của khối Watchdog
typedef struct {
    volatile uint32_t LOAD;     // 0x00: Nạp giá trị đếm ngược ban đầu
    volatile uint32_t VALUE;    // 0x04: Giá trị đếm hiện tại (Read-only)
    volatile uint32_t CTRL;     // 0x08: Thanh ghi điều khiển (Bật/Tắt WDT, Bật Reset)
    volatile uint32_t FEED;     // 0x0C: Thanh ghi feed (Clear/Refresh)
} WDT_TypeDef;

// Ánh xạ địa chỉ phần cứng
#define WDT0 ((WDT_TypeDef *) WATCHDOG_BASE)

// Hàm API
void HAL_WDT_Init(WDT_TypeDef *hwdt, uint32_t timeout_ticks);
void HAL_WDT_Refresh(WDT_TypeDef *hwdt);

#endif // WDT_HAL_H