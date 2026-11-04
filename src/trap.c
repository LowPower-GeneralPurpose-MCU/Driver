/* ==================================================================
 * File: src/trap.c
 * Mô tả: Phân luồng và xử lý mọi Ngắt/Lỗi (Interrupt & Exception)
 * Chuẩn hóa: RISC-V HAL Architecture
 *
 * Moi trap vao day qua trap_entry (startup/trap_handler.S):
 *   - che do CLIC  (main.c): mcause[31] = 1, mcause[11:0] = CLIC ID
 *                            (inc/soc_hw.h, CLIC_ID_*). mcause doc ra con
 *                            mang mpp/mpie/mpil o [29:16] -> LUON lay
 *                            MCAUSE_CODE(), khong so sanh nguyen mcause.
 *   - che do CLINT (crt0 truoc khi main bat CLIC): chi co ma 3 (msip) va 7
 *                            (mtip) - trung so voi CLIC_ID_MSIP / MTIP, nen
 *                            mot bang phan luong dung cho ca hai che do.
 * PLIC da bo khoi RTL: khong con claim/complete.
 * ================================================================== */

#include <stdint.h>
#include <stdio.h>
#include "../inc/soc_hw.h"
#include "../inc/clic.h"
#include "../inc/uart.h"
#include "../inc/clint.h"
#include "../inc/dma.h"
#include "../inc/gpio.h"
#include "../inc/wdt.h"
#include "../inc/timer.h"
#include "../inc/ascon.h"
#include "soc_config.h"

/* Mã exception đồng bộ - phải khớp với `trap_cause` trong riscv_pipeline.v */
#define CAUSE_INSTR_MISALIGNED      0u   // mtval = địa chỉ
#define CAUSE_INSTR_ACCESS_FAULT    1u   // mtval = PC gây lỗi
#define CAUSE_ILLEGAL_INSTR         2u   // mtval = mã lệnh
#define CAUSE_BREAKPOINT            3u
#define CAUSE_LOAD_MISALIGNED       4u   // mtval = địa chỉ
#define CAUSE_LOAD_ACCESS_FAULT     5u   // mtval = địa chỉ
#define CAUSE_STORE_MISALIGNED      6u   // mtval = địa chỉ
#define CAUSE_STORE_ACCESS_FAULT    7u   // mtval = địa chỉ
#define CAUSE_ECALL_M              11u

/* ==================================================================
 * PANIC OUTPUT - ghi thẳng vào thanh ghi UART, KHÔNG qua HAL/printf.
 *
 * Lý do không dùng printf/HAL_UART_Transmit trong đường lỗi:
 *  - HAL_UART_Transmit return ngay nếu huart->State != READY. Nếu exception
 *    xảy ra ĐANG GIỮA một lần printf (State == BUSY_TX) thì toàn bộ thông tin
 *    lỗi bị nuốt im lặng - đúng lúc cần nó nhất.
 *  - printf kéo theo malloc/_sbrk và vài trăm byte stack ngay trong trap
 *    handler, nơi stack có thể đã là thứ vừa gây ra lỗi.
 * ================================================================== */
static void trap_putc(char c) {
    while ((UART0->STATUS & UART_STATUS_TX_FULL) != 0u) { }
    UART0->TX_DATA = (uint32_t)(uint8_t)c;
}

static void trap_puts(const char *s) {
    while (*s) trap_putc(*s++);
}

static void trap_puthex(uint32_t v) {
    static const char hexdig[] = "0123456789ABCDEF";
    int i;
    trap_putc('0'); trap_putc('x');
    for (i = 28; i >= 0; i -= 4) {
        trap_putc(hexdig[(v >> i) & 0xFu]);
    }
}

static uint32_t read_mtval(void) {
    uint32_t v;
    __asm__ volatile ("csrr %0, mtval" : "=r"(v));
    return v;
}

/* Dừng hẳn, có chủ đích, sau khi đã in được nguyên nhân.
   MIE đã bị phần cứng xóa lúc vào trap nên wfi không tự bật lại ngắt. */
static void trap_halt(void) __attribute__((noreturn));
static void trap_halt(void) {
    while ((UART0->STATUS & UART_STATUS_TX_BUSY) != 0u) { }  // xả nốt FIFO
    for (;;) {
        __asm__ volatile ("wfi");
    }
}

/* ==================================================================
 * Callback mac dinh (weak) - ung dung override khi can.
 * ================================================================== */
__attribute__((weak)) void HAL_SysTick_Callback(void) { }
__attribute__((weak)) void HAL_SoftIRQ_Callback(void) { }

/* Loi bus cua store buffer D-cache (CLIC 26, kich canh): mot lenh store da
   duoc buffer bi SLVERR/DECERR - luc nay lenh do da qua tu lau, khong co mepc
   chinh xac. Mac dinh: in ra roi chay tiep. */
__attribute__((weak)) void HAL_BusError_Callback(void) {
    trap_puts("\n[TRAP] D-cache store buffer: bus error tren mot store da buffer\n");
}

/* Nguon ngat khong co handler: tat no o CLIC (ngat MUC khong co ai xoa se
   lap vo han) va bao mot lan. */
__attribute__((weak)) void HAL_IRQ_Unhandled(uint32_t id) {
    clic_disable(id);
    trap_puts("\n[TRAP] ngat khong co handler, da tat CLIC id=");
    trap_puthex(id);
    trap_putc('\n');
}

static void irq_dispatch(uint32_t id) {
    switch (id) {
    case CLIC_ID_MTIP:
        // Đặt lại thời điểm ngắt tiếp theo (1000ms sau).
        //
        // PHẢI là RTC_CLOCK_HZ, KHÔNG phải clock hệ thống. mtime của CLINT đếm
        // theo `rtc_tick` - xung bắt cạnh lên của chân rtc_clk, lấy mẫu 2FF bằng
        // clk 250 MHz (top_soc.v, mục 1). Tức mtime chạy 32768 Hz.
        // Truyền 250 MHz vào đây đặt mtimecmp cách hiện tại 250e6 tick, ở
        // 32.768 kHz là ~7629 giây (~2.1 giờ) chứ không phải 1 giây.
        // mtip la ngat MUC: ghi mtimecmp moi la cach duy nhat ha no xuong.
        clint_set_timer_ms(1000, RTC_CLOCK_HZ);
        HAL_SysTick_Callback();
        break;

    case CLIC_ID_MSIP:
        clint_clear_soft_irq();
        HAL_SoftIRQ_Callback();
        break;

#if CONFIG_HAS_UART
    case CLIC_ID_UART0:
        // Đọc hết RX FIFO và gọi HAL_UART_RxCallback cho từng byte
        HAL_UART_IRQDispatch(UART0);
        break;
#endif

#if CONFIG_HAS_UART1
    case CLIC_ID_UART1:
        HAL_UART_IRQDispatch(UART1);
        break;
#endif

#if CONFIG_HAS_GPIO
    case CLIC_ID_GPIO:
        /* Xử lý ngắt GPIO: Quét chân và xóa cờ */
        HAL_GPIO_IRQHandler(GPIO0);
        break;
#endif

#if CONFIG_HAS_WATCHDOG
    case CLIC_ID_WDT:
        HAL_WDT_IRQHandler(WDT0);
        break;
#endif

#if CONFIG_HAS_DMA
    /* Moi kenh mot ID rieng. Hàm này xóa cờ DONE/ERR và kích hoạt
       HAL_DMA_TransferCompleteCallback. */
    case CLIC_ID_DMA_CH0: HAL_DMA_IRQHandler(DMA_CH0); break;
    case CLIC_ID_DMA_CH1: HAL_DMA_IRQHandler(DMA_CH1); break;
    case CLIC_ID_DMA_CH2: HAL_DMA_IRQHandler(DMA_CH2); break;
    case CLIC_ID_DMA_CH3: HAL_DMA_IRQHandler(DMA_CH3); break;
#endif

    case CLIC_ID_DCACHE_BERR:
        HAL_BusError_Callback();   // kich canh: CLIC tu xoa pending khi nhan
        break;

#if CONFIG_HAS_ASCON
    case CLIC_ID_ASCON:
        HAL_ASCON_IRQHandler();
        break;
#endif

#if CONFIG_HAS_TIMER
    case CLIC_ID_TIM0: HAL_TIM_IRQHandler(TIM0); break;
    case CLIC_ID_TIM1: HAL_TIM_IRQHandler(TIM1); break;
#endif

    default:
        // SPI (19) / I2C (20) va moi nguon chua co handler o tren.
        HAL_IRQ_Unhandled(id);
        break;
    }
}

/**
 * @brief Hàm xử lý Trap tổng của hệ thống
 * @param mcause: Nguyên nhân sinh ra ngắt/bẫy
 * @param mepc: Địa chỉ lệnh bị ngắt
 */
void system_trap_handler(uint32_t mcause, uint32_t mepc) {
    uint32_t code = MCAUSE_CODE(mcause);

    // ---------------------------------------------------------
    // LUỒNG 1: NGẮT (CLIC hoac CLINT) - phan luong theo ID
    // ---------------------------------------------------------
    if (MCAUSE_IS_INT(mcause)) {
        irq_dispatch(code);
        return;
    }

    // ---------------------------------------------------------
    // LUỒNG 2: CÁC LỖI NGOẠI LỆ (EXCEPTIONS)
    // ---------------------------------------------------------
    /* Phần cứng báo lỗi chính xác (mcause 1/2/4/5/6/7, mtval = địa chỉ
       hoặc mã lệnh). In ra TRƯỚC khi làm bất cứ việc gì khác - với con trỏ
       hỏng thì địa chỉ gây lỗi là thứ có giá trị nhất. */
    uint32_t mtval = read_mtval();

    trap_puts("\n[TRAP] mcause=");
    trap_puthex(mcause);
    trap_puts(" mepc=");
    trap_puthex(mepc);
    trap_puts(" mtval=");
    trap_puthex(mtval);
    trap_putc('\n');

    /* -----------------------------------------------------------------
     * Phân luồng theo mã lỗi TRƯỚC khi chạm vào mepc.
     *
     * mã 0/1: mepc trỏ vào địa chỉ không fetch được (hoặc lệch). Đọc
     * lệnh ở đó sẽ sinh tiếp mcause 5 NGAY TRONG handler này -> lần trap
     * thứ hai ghi đè mepc, handler quay lại chính nó -> treo (double
     * fault). Và cũng không có cách nào biết lệnh dài 2 hay 4 byte để nhảy
     * qua. Không có đường phục hồi hợp lệ: dừng hẳn.
     * ----------------------------------------------------------------- */
    if (code == CAUSE_INSTR_MISALIGNED || code == CAUSE_INSTR_ACCESS_FAULT) {
        trap_puts("[TRAP] FATAL: khong the fetch tai mepc - dung.\n");
        trap_halt();
    }

    /* -----------------------------------------------------------------
     * Các mã còn lại (2,3,4,5,6,7,11): lệnh tại mepc ĐỌC ĐƯỢC, lỗi nằm
     * ở dữ liệu hoặc ở chính mã lệnh. Nhảy qua nó để mret chạy tiếp.
     *
     * Đọc bằng uint16_t, KHÔNG phải uint32_t: với RVC bật, mepc chỉ đảm
     * bảo căn lề 2 byte - đó chính là lý do phải kiểm tra lệnh nén ở dòng
     * dưới. `*(uint32_t*)mepc` từ nửa word lẻ là một misaligned word load,
     * mà RTL bây giờ raise mcause 4 cho nó -> lại double fault. Nửa word
     * thấp luôn hợp lệ và đã đủ để biết độ dài lệnh (bits[1:0] == 2'b11
     * là lệnh 32-bit, còn lại là lệnh nén 16-bit).
     * ----------------------------------------------------------------- */
    uint16_t instr_lo = *(volatile uint16_t *)mepc;
    uint32_t advance  = ((instr_lo & 0x3u) == 0x3u) ? 4u : 2u;

    __asm__ volatile ("csrw mepc, %0" :: "r"(mepc + advance));
    // Return to trap_entry which will execute mret and resume after the fault.
}
