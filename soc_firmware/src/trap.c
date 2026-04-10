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

/* "Mượn" người quản lý UART0 từ file main.c */
extern UART_HandleTypeDef huart0;

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
        // Lưu ý: printf trong ngắt sẽ làm chậm hệ thống, chỉ dùng khi debug
        printf("[TICK] 1 second passed\n");

        // Đặt lại thời điểm ngắt tiếp theo (1000ms sau)
        // Lưu ý: Dùng hằng số CLOCK từ soc_hw.h để chính xác
        clint_set_timer_ms(1000, 200000000); 
    } 
    
    // ---------------------------------------------------------
    // LUỒNG 3: NGẮT PHẦN MỀM TỪ CLINT
    // ---------------------------------------------------------
    else if (mcause == CAUSE_MACHINE_SOFTWARE_INT) {
        printf("[SOFT] Software interrupt received\n");
        clint_clear_soft_irq();
    }

    // ---------------------------------------------------------
    // LUỒNG 4: CÁC LỖI NGOẠI LỆ (EXCEPTIONS)
    // ---------------------------------------------------------
    else {
        printf("\n!!! CPU EXCEPTION DETECTED !!!\n");
        printf("MCAUSE: 0x%08lx | MEPC: 0x%08lx\n", mcause, mepc);
        
        if (mcause == 2)      printf("Error: Illegal Instruction (Check FPU/Extensions)\n");
        else if (mcause == 5) printf("Error: Load Access Fault (Invalid Read Address)\n");
        else if (mcause == 7) printf("Error: Store Access Fault (Invalid Write Address)\n");
        
        // Treo hệ thống để bảo vệ phần cứng
        while(1) {
            __asm__ volatile ("wfi");
        }
    }
}