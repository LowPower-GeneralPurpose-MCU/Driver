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
    //if (peripheral_bit > 7) return;
    SYSCON_CLK_GATE |= (1 << peripheral_bit);
    
}

// Hàm ngắt xung nhịp để tiết kiệm điện
void syscon_disable_clock(uint8_t peripheral_bit) {
    if (peripheral_bit > 7) return;
    if (peripheral_bit == SYSCON_CLK_CPU) return;
    
    SYSCON_CLK_GATE &= ~(1 << peripheral_bit);
}
// Hàm đổi địa chỉ Boot (dùng cho Bootloader nhảy sang vùng nhớ khác).
// Co tac dung o lan warm reset KE TIEP (watchdog, syscon_system_reset,
// ndmreset); POR luon ve boot ROM. Bi bo qua sau syscon_lock_boot_vector().
void syscon_set_boot_address(uint32_t addr) {
    SYSCON_RESET_VECTOR = addr;
}

// Doc nguyen nhan reset roi xoa, de lan reset sau khong lan voi lan nay.
uint32_t syscon_take_reset_cause(void) {
    uint32_t cause = SYSCON_RST_CAUSE;
    SYSCON_RST_CAUSE = cause;           // W1C
    return cause;
}

void syscon_system_reset(void) {
    SYSCON_SW_RESET = SYSCON_SW_RESET_KEY;
    for (;;) { }                        // reset xay ra sau vai chu ky
}

void syscon_lock_boot_vector(void) {
    SYSCON_SEC_CTRL = SYSCON_SEC_BOOT_LOCK;
}

// Khoa debug toi POR: Debug Module bi giu reset, JTAG khong halt / doc bo nho
// / ndmreset duoc nua. Chi boot ROM cua anh san pham nen goi.
void syscon_lock_debug(void) {
    SYSCON_SEC_CTRL = SYSCON_SEC_DBG_LOCK;
}

// AUTO CLOCK-GATING FRAMEWORK
// Chỉ gọi 1 lần duy nhất ở đầu hàm main()
void syscon_init_clocks(void) {
    uint32_t clock_mask = 0;
    // 1. Luôn cấp điện cho các khối Bắt buộc (Mandatory) 
    clock_mask |= (1 << SYSCON_CLK_UART);
    // Khong con SYSCON_CLK_DEBUG: clock Debug Module do debugger tu bat (RTL
    // 2026-09-11), bit 6 chi doc.

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
