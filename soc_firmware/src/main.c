/* ==================================================================
 * File: src/main.c
 * Mô tả: Chương trình chính - Kích hoạt hệ thống Event-Driven
 * Chuẩn hóa: RISC-V HAL Architecture (Application Layer)
 * ================================================================== */
#include <stdint.h>
#include <stdio.h>    
#include "../inc/soc_hw.h"
#include "../inc/syscon.h" 
#include "../inc/uart.h"
#include "../inc/plic.h"
#include "../inc/clint.h"
#include "../inc/gpio.h"   
#include "../inc/dma.h"
#include "../inc/wdt.h"
#include "soc_config.h"

#define SYSTEM_BUS_CLOCK 200000000 
#define RTC_CLOCK_HZ     32768     // Tần số thật của RTC

/* ==================================================================
 * 1. KHAI BÁO CÁC ĐỐI TƯỢNG QUẢN LÝ (HANDLES) & BIẾN TOÀN CỤC
 * ================================================================== */
UART_HandleTypeDef huart0;

#if CONFIG_HAS_DMA
volatile uint32_t *src_arr = (volatile uint32_t *)0x20010000; 
volatile uint32_t *dst_arr = (volatile uint32_t *)0x20010040;
#endif

/* ==================================================================
 * 2. HÀM MAIN - NHẠC TRƯỞNG CỦA HỆ THỐNG
 * ================================================================== */
int main(void) {
    // A. CẤP NGUỒN TỰ ĐỘNG QUA SYSCON
    syscon_init_clocks();

    // B. KHỞI TẠO NGOẠI VI GIAO TIẾP 
    huart0.Instance = UART0; 
    HAL_UART_Init(&huart0, SYSTEM_BUS_CLOCK, 115200);
    
    clint_init();

    printf("\n=========================================\n");
    printf("   RISC-V SOC INTERRUPT SYSTEM BOOTING   \n");
    printf("     - Industry Standard HAL Applied -   \n");
    printf("=========================================\n");

    // C. CẤU HÌNH NGOẠI VI CƠ BẢN (SỬ DỤNG HAL_GPIO)
    GPIO_InitTypeDef GPIO_InitStruct;

    // Chân 0: Gắn LED (Output)
    GPIO_InitStruct.Pin = GPIO_PIN_0;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT;
    HAL_GPIO_Init(GPIO0, &GPIO_InitStruct);

    // Chân 1: Gắn Nút nhấn (Input + Bật ngắt)
    GPIO_InitStruct.Pin = GPIO_PIN_1;
    GPIO_InitStruct.Mode = GPIO_MODE_IT;
    HAL_GPIO_Init(GPIO0, &GPIO_InitStruct);

    // D. CẤU HÌNH TỔNG ĐÀI NGẮT (PLIC)
    plic_set_threshold(0); 
    
    plic_set_priority(IRQ_UART, 7); 
    plic_enable_interrupt(IRQ_UART);

    plic_set_priority(IRQ_GPIO, 5);  
    plic_enable_interrupt(IRQ_GPIO);

    // E. KHỞI TẠO KHỐI DMA
    #if CONFIG_HAS_DMA
        HAL_DMA_Init();
        plic_set_priority(IRQ_DMA_CH0, 6);  
        plic_enable_interrupt(IRQ_DMA_CH0);
        printf("[INFO] DMA Module Enabled & Configured.\n");
    #endif

    // F. KHỞI TẠO BỘ TÍNH TOÁN DẤU PHẨY ĐỘNG
    #if CONFIG_HAS_FPU
        __asm__ volatile ("li t0, 0x00006000; csrs mstatus, t0");
        printf("[INFO] Hardware FPU is ENABLED.\n");
    #endif

    // G. LÊN ĐẠN CHO NHỊP TIM HỆ THỐNG (CLINT TIMER)
    clint_set_timer_ms(1000, RTC_CLOCK_HZ);
    printf("[INFO] PLIC, CLINT & GPIO Configured.\n");

    // H. MỞ KHÓA NGẮT TOÀN CỤC
    __asm__ volatile ("csrs mie, %0" :: "r"(0x880)); 
    __asm__ volatile ("csrs mstatus, %0" :: "r"(0x8)); 
    printf("[INFO] Global Interrupts ENABLED! System is running.\n");

    // I. PHÁT LỆNH TEST DMA
    #if CONFIG_HAS_DMA
        for(int i=0; i<10; i++) {
            src_arr[i] = i + 1; 
            dst_arr[i] = 0;     
        }
        printf("[TEST] Triggering DMA transfer (40 bytes)...\n");
        HAL_DMA_Config(DMA_CH0, (uint32_t)src_arr, (uint32_t)dst_arr, 40, 1, 1, 16, 0);
        HAL_DMA_Start(DMA_CH0);
    #endif

    // Kích hoạt Watchdog Timer (400,000,000 cycles ~ 2 giây nếu clock 200MHz)
    HAL_WDT_Init(WDT0, 400000000);
    printf("[INFO] Watchdog Armed!\n");

    // J. VÒNG LẶP CHÍNH (THE SUPER LOOP)
    while (1) {
        // NUÔI CHÓ TRƯỚC KHI ĐI NGỦ! (Cực kỳ quan trọng để chống Reset)
        HAL_WDT_Refresh(WDT0);

        // Ngủ chờ ngắt (Tiết kiệm điện)
        __asm__ volatile ("wfi"); 
    }

    return 0; 
}

/* ==================================================================
 * 3. TẦNG ỨNG DỤNG: BUSINESS LOGIC & CALLBACKS
 * ================================================================== */

// Callback: Xử lý dữ liệu UART
void HAL_UART_RxCallback(UART_HandleTypeDef *huart, uint8_t rx_data) {
    if (huart->Instance == UART0) {
        printf("\n[UART EVENT] Ban vua go: %c\n", rx_data);
        
        // Điều khiển LED qua chuẩn HAL
        if (rx_data == '1') {
            HAL_GPIO_WritePin(GPIO0, GPIO_PIN_0, GPIO_PIN_SET); 
            printf("-> Da bat LED tren Chan 0!\n");
        } 
        else if (rx_data == '0') {
            HAL_GPIO_WritePin(GPIO0, GPIO_PIN_0, GPIO_PIN_RESET);
            printf("-> Da tat LED tren Chan 0!\n");
        }
    }
}

// Callback: Xử lý sau khi nhấn nút trên mạch
void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin) {
    if (GPIO_Pin == GPIO_PIN_1) {
        printf("\n[GPIO EVENT] Phat hien nhan nut o Chan 1!\n");
        
        // Bạn có thể cho LED chớp 1 cái để phản hồi:
        HAL_GPIO_TogglePin(GPIO0, GPIO_PIN_0);
    }
}

// Callback: Xử lý sau khi DMA copy xong
void HAL_DMA_TransferCompleteCallback(DMA_Channel_TypeDef *dma_ch) {
    if (dma_ch == DMA_CH0) {
        printf("\n[DMA EVENT] Kenh 0 da copy xong du lieu!\n");
        #if CONFIG_HAS_DMA
        printf("-> Gia tri dst_arr[0]: %lu (Ky vong: 1)\n", dst_arr[0]); 
        #endif
    }
}