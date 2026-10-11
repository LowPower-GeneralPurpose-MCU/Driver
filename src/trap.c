/* ==================================================================
 * File: src/trap.c
 * Mô tả: Phân luồng và xử lý mọi Ngắt/Lỗi (Interrupt & Exception)
 * Chuẩn hóa: RISC-V HAL Architecture
 * ================================================================== */

#include <stdint.h>
#include <stdio.h>
#include "../inc/soc_hw.h"
#include "../inc/uart.h"
#include "../inc/plic.h"
#include "../inc/clint.h"
#include "../inc/dma.h"
#include "../inc/gpio.h"
#include "soc_config.h"

/* Định nghĩa các nguyên nhân ngắt theo chuẩn RISC-V Privilege */
#define CAUSE_MACHINE_SOFTWARE_INT  0x80000003 // Ngắt phần mềm (CLINT)
#define CAUSE_MACHINE_TIMER_INT     0x80000007 // Ngắt thời gian (CLINT)
#define CAUSE_MACHINE_EXTERNAL_INT  0x8000000B // Ngắt ngoại vi (PLIC)

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

/* "Mượn" người quản lý UART0 từ file main.c */
extern UART_HandleTypeDef huart0;

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
#define UART_STATUS_TX_FULL  (1u << 2)   // xem HAL_UART_Transmit trong uart.c
#define UART_STATUS_TX_BUSY  (1u << 4)

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

/**
 * @brief Hàm xử lý Trap tổng của hệ thống
 * @param mcause: Nguyên nhân sinh ra ngắt/bẫy
 * @param mepc: Địa chỉ lệnh bị ngắt
 */
void system_trap_handler(uint32_t mcause, uint32_t mepc) {
    
    // ---------------------------------------------------------
    // LUỒNG 1: NGẮT NGOẠI VI TỪ PLIC (UART, DMA, GPIO...)
    // ---------------------------------------------------------
    if (mcause == CAUSE_MACHINE_EXTERNAL_INT) {
        
        // 1. Lấy ID của ngắt đang có mức ưu tiên cao nhất từ PLIC
        uint32_t irq_id = plic_claim();

        // 2. Phân phối xử lý dựa trên ID
        if (irq_id == IRQ_UART) {
            /* Gọi hàm xử lý ngắt chuẩn HAL cho UART. 
               Hàm này sẽ tự đọc data và kích hoạt HAL_UART_RxCallback */
            HAL_UART_IRQHandler(&huart0);
        }
        
        #if CONFIG_HAS_DMA
        else if (irq_id == IRQ_DMA_CH0) {
            /* Gọi hàm xử lý ngắt chuẩn HAL cho DMA.
               Hàm này sẽ xóa cờ DONE và kích hoạt HAL_DMA_TransferCompleteCallback */
            HAL_DMA_IRQHandler(DMA_CH0);
        }
        #endif

        else if (irq_id == IRQ_GPIO) {
            /* Xử lý ngắt GPIO: Quét chân và xóa cờ */
            HAL_GPIO_IRQHandler(GPIO0);
        }

        // 3. Báo cho PLIC biết đã xử lý xong ngắt này
        if (irq_id != 0) {
            plic_complete(irq_id);
        }
    } 
    
    // ---------------------------------------------------------
    // LUỒNG 2: NGẮT THỜI GIAN TỪ CLINT (SYSTEM TICK)
    // ---------------------------------------------------------
    else if (mcause == CAUSE_MACHINE_TIMER_INT) {
        // Log thông báo hoặc cập nhật biến đếm thời gian
        // Lưu ý: // printf trong ngắt sẽ làm chậm hệ thống, chỉ dùng khi debug
        // printf("[TICK] 1 second passed\n");

        // Đặt lại thời điểm ngắt tiếp theo (1000ms sau).
        //
        // PHẢI là RTC_CLOCK_HZ, KHÔNG phải clock hệ thống. mtime của CLINT đếm
        // theo `rtc_tick` - xung bắt cạnh lên của chân rtc_clk, lấy mẫu 2FF bằng
        // clk 250 MHz (top_soc.v, mục 1). Tức mtime chạy 32768 Hz.
        // Truyền 250 MHz vào đây đặt mtimecmp cách hiện tại 250e6 tick, ở
        // 32.768 kHz là ~7629 giây (~2.1 giờ) chứ không phải 1 giây.
        clint_set_timer_ms(1000, RTC_CLOCK_HZ); 
    } 
    
    // ---------------------------------------------------------
    // LUỒNG 3: NGẮT PHẦN MỀM TỪ CLINT
    // ---------------------------------------------------------
    else if (mcause == CAUSE_MACHINE_SOFTWARE_INT) {
        // printf("[SOFT] Software interrupt received\n");
        clint_clear_soft_irq();
    }

    // ---------------------------------------------------------
    // LUỒNG 4: CÁC LỖI NGOẠI LỆ (EXCEPTIONS)
    // ---------------------------------------------------------
    else {
        /* Phần cứng giờ báo lỗi chính xác (mcause 1/2/4/5/6/7, mtval = địa chỉ
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
         * Phân luồng theo mcause TRƯỚC khi chạm vào mepc.
         *
         * mcause 0/1: mepc trỏ vào địa chỉ không fetch được (hoặc lệch). Đọc
         * lệnh ở đó sẽ sinh tiếp mcause 5 NGAY TRONG handler này -> lần trap
         * thứ hai ghi đè mepc, handler quay lại chính nó -> treo (double
         * fault). Và cũng không có cách nào biết lệnh dài 2 hay 4 byte để nhảy
         * qua. Không có đường phục hồi hợp lệ: dừng hẳn.
         * ----------------------------------------------------------------- */
        if (mcause == CAUSE_INSTR_MISALIGNED || mcause == CAUSE_INSTR_ACCESS_FAULT) {
            trap_puts("[TRAP] FATAL: khong the fetch tai mepc - dung.\n");
            trap_halt();
        }

        /* -----------------------------------------------------------------
         * Các cause còn lại (2,3,4,5,6,7,11): lệnh tại mepc ĐỌC ĐƯỢC, lỗi nằm
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
        return;
    }
}