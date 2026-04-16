/* ==================================================================
 * File: src/syscon.c
 * ================================================================== */
#include "syscon.h"
#include "soc_config.h"

// --------------------------------------------------------
// CÁC HÀM ĐIỀU KHIỂN THỦ CÔNG
// --------------------------------------------------------
// Cấp xung nhịp cho một khối ngoại vi
void syscon_enable_clock(uint8_t peripheral_bit) {
    if (peripheral_bit > 6) return; // Chỉ có 7 bit (0-6)
    SYSCON_CLK_GATE |= (1 << peripheral_bit);
}

// Hàm ngắt xung nhịp để tiết kiệm điện
void syscon_disable_clock(uint8_t peripheral_bit) {
    if (peripheral_bit > 6) return;
    SYSCON_CLK_GATE &= ~(1 << peripheral_bit);
}

// Hàm đổi địa chỉ Boot (dùng cho Bootloader nhảy sang vùng nhớ khác)
void syscon_set_boot_address(uint16_t addr_offset) {
    SYSCON_RESET_VECTOR = (uint32_t)addr_offset;
}

// AUTO CLOCK-GATING FRAMEWORK
// Chỉ gọi 1 lần duy nhất ở đầu hàm main()
void syscon_init_clocks(void) {
    uint32_t clock_mask = 0;
    // 1. Luôn cấp điện cho các khối Bắt buộc (Mandatory)
    clock_mask |= (1 << SYSCON_CLK_UART);
    clock_mask |= (1 << SYSCON_CLK_DEBUG); // Cần thiết để nạp code qua JTAG/OpenOCD

    // 2. Cấp điện tự động cho các khối Tùy chọn (Optional)
    #if CONFIG_HAS_GPIO
        clock_mask |= (1 << SYSCON_CLK_GPIO);
    #endif

    #if CONFIG_HAS_TIMER
        clock_mask |= (1 << SYSCON_CLK_TIMER);
    #endif

    #if CONFIG_HAS_SPI
        clock_mask |= (1 << SYSCON_CLK_SPI);
    #endif

    #if CONFIG_HAS_I2C
        clock_mask |= (1 << SYSCON_CLK_I2C);
    #endif

    #if CONFIG_HAS_ACCEL
        clock_mask |= (1 << SYSCON_CLK_ACCEL);
    #endif

    // 3. Ghi 1 lần duy nhất xuống thanh ghi để bật đồng loạt
    SYSCON_CLK_GATE = clock_mask;
}