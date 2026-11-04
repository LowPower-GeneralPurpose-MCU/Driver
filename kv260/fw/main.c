/* =============================================================================
 * Bring-up firmware cho MCU SoC tren KV260 - KHONG dung Driver/ (doc lap).
 *
 * Kiem tra 4 duong co ban, theo thu tu:
 *   1. UART0 TX  (PA0) : in banner, trong do co chuoi "Hello KV260"
 *   2. UART0 RX  (PA1) : moi ky tu nhan duoc duoc gui lai (echo)
 *   3. CLINT           : mtime phai tang theo RTC 32.768 kHz, mtimecmp va
 *                        msip ghi/doc lai dung -> in "CLINT OK". Truoc ban sua
 *                        top_soc.v 2026-11-04 moi truy cap CLINT tra SLVERR.
 *      CSR cycle       : in "tick N" moi giay.
 *   4. GPIO            : PA2 dao trang thai moi 0.5 s (LED), PA3 la dau vao,
 *                        doi muc thi in "PA3=x"
 *
 * Thanh ghi lay tu RTL golden (genus/rtl/peripheral/), khong tu Driver/inc.
 * ========================================================================== */
#include <stdint.h>

#ifndef SYS_CLK_HZ
#define SYS_CLK_HZ 50000000u
#endif
#ifndef UART_BAUD
#define UART_BAUD 115200u
#endif


#define REG32(a) (*(volatile uint32_t *)(uintptr_t)(a))

/* UART0 - apb_uart.v (APB S0) */
#define UART0_CLK_DIV    REG32(0x40000000u)  /* [15:0] clk/baud, [31:16] clk/(16*baud) */
#define UART0_TXDATA     REG32(0x40000004u)
#define UART0_RXDATA     REG32(0x40000008u)  /* doc = pop RX FIFO */
#define UART0_STATUS     REG32(0x4000000Cu)
#define UART_ST_TX_FULL  (1u << 2)
#define UART_ST_RX_EMPTY (1u << 3)
#define UART_ST_TX_BUSY  (1u << 4)            /* dang phat HOAC FIFO con byte */

/* GPIO - apb_gpio.v (APB S1) */
#define GPIO_IN          REG32(0x40001000u)
#define GPIO_OUT         REG32(0x40001004u)
#define GPIO_DIR         REG32(0x40001008u)  /* 1 = output */

/* SYSCON - apb_syscon.v (APB S7) */
#define SYSCON_CLK_GATE  REG32(0x40007004u)  /* [1] UART  [4] GPIO */

/* CLINT - interrupt/CLINT (AXI S5, 0x0200_0000) */
#define CLINT_MSIP0      REG32(0x02000000u)
#define CLINT_MTIMECMP_LO REG32(0x02004000u)
#define CLINT_MTIMECMP_HI REG32(0x02004004u)
#define CLINT_MTIME_LO   REG32(0x0200BFF8u)
#define CLINT_MTIME_HI   REG32(0x0200BFFCu)

static inline uint32_t read_cycle(void)
{
    uint32_t c;
    __asm__ volatile ("csrr %0, cycle" : "=r"(c));
    return c;
}

#define PA2 (1u << 2)
#define PA3 (1u << 3)

static void uart_putc(char c)
{
    while (UART0_STATUS & UART_ST_TX_FULL) { }
    UART0_TXDATA = (uint8_t)c;
}

static void uart_puts(const char *s)
{
    while (*s) {
        uart_putc(*s++);
    }
}

static void uart_put_hex(uint32_t v)
{
    static const char hex[] = "0123456789ABCDEF";
    for (int i = 28; i >= 0; i -= 4) {
        uart_putc(hex[(v >> i) & 0xFu]);
    }
}

static void uart_put_dec(uint32_t v)
{
    char buf[11];
    int n = 0;
    do {
        buf[n++] = (char)('0' + (v % 10u));
        v /= 10u;
    } while (v != 0u);
    while (n > 0) {
        uart_putc(buf[--n]);
    }
}

void trap_report(uint32_t mcause, uint32_t mepc, uint32_t mtval)
{
    uart_puts("\r\n*** TRAP mcause=0x");
    uart_put_hex(mcause);
    uart_puts(" mepc=0x");
    uart_put_hex(mepc);
    uart_puts(" mtval=0x");
    uart_put_hex(mtval);
    uart_puts(" ***\r\n");
    for (;;) { }
}

/* Tra 0 neu dung, khac 0 = so buoc hong dau tien. */
static uint32_t clint_check(void)
{
    /* mtime tang theo rtc_tick (~1526 chu ky @50 MHz): cho 2 lan doi, gioi han
     * 50000 chu ky (~16 tick). */
    uint32_t t0 = CLINT_MTIME_LO;
    uint32_t start = read_cycle();
    uint32_t changes = 0u, prev = t0;
    while (changes < 2u) {
        uint32_t t = CLINT_MTIME_LO;
        if (t != prev) { changes++; prev = t; }
        if ((read_cycle() - start) > 50000u) return 1u;
    }
    if ((uint32_t)(prev - t0) < 2u) return 2u;
    if (CLINT_MTIME_HI != 0u) return 3u;

    /* mtimecmp: giu HI = all-ones de mtip khong len khi viet LO. */
    CLINT_MTIMECMP_HI = 0xFFFFFFFFu;
    CLINT_MTIMECMP_LO = 0xA5A55A5Cu;
    if (CLINT_MTIMECMP_LO != 0xA5A55A5Cu) return 4u;
    if (CLINT_MTIMECMP_HI != 0xFFFFFFFFu) return 5u;
    CLINT_MTIMECMP_LO = 0xFFFFFFFFu;
    if (CLINT_MTIMECMP_LO != 0xFFFFFFFFu) return 6u;

    /* msip (mie = 0 nen khong vao ngat). */
    CLINT_MSIP0 = 1u;
    if ((CLINT_MSIP0 & 1u) != 1u) return 7u;
    CLINT_MSIP0 = 0u;
    if ((CLINT_MSIP0 & 1u) != 0u) return 8u;
    return 0u;
}

int main(void)
{
    /* UART da bat sau reset (CLK_GATE_CTRL = 0x43); bat them GPIO. */
    SYSCON_CLK_GATE = SYSCON_CLK_GATE | (1u << 1) | (1u << 4);

    UART0_CLK_DIV = ((SYS_CLK_HZ / (16u * UART_BAUD)) << 16)
                  |  (SYS_CLK_HZ / UART_BAUD);

    uart_puts("\r\n=== MCU SoC on KV260 ===\r\n");
    uart_puts("Hello KV260\r\n");
    uart_puts("sys_clk=");
    uart_put_dec(SYS_CLK_HZ);
    uart_puts(" Hz, baud=");
    uart_put_dec(UART_BAUD);
    uart_puts("\r\n");

    uint32_t ce = clint_check();
    if (ce == 0u) {
        uart_puts("CLINT OK mtime=");
        uart_put_dec(CLINT_MTIME_LO);
        uart_puts("\r\n");
    } else {
        uart_puts("CLINT FAIL step ");
        uart_put_dec(ce);
        uart_puts("\r\n");
    }
    uart_puts("Type to echo.\r\n");

    GPIO_DIR = PA2;            /* PA2 output, PA3 input */
    GPIO_OUT = 0u;

    uint32_t last   = read_cycle();
    uint32_t halves = 0u;
    uint32_t pa3    = GPIO_IN & PA3;

    for (;;) {
        uint32_t now = read_cycle();
        if ((now - last) >= (SYS_CLK_HZ / 2u)) {
            last += SYS_CLK_HZ / 2u;
            GPIO_OUT = GPIO_OUT ^ PA2;
            if ((++halves & 1u) == 0u) {
                uart_puts("tick ");
                uart_put_dec(halves >> 1);
                uart_puts("\r\n");
            }
        }

        if (!(UART0_STATUS & UART_ST_RX_EMPTY)) {
            char c = (char)(UART0_RXDATA & 0xFFu);
            uart_putc(c);
            if (c == '\r') {
                uart_putc('\n');
            }
        }

        uint32_t pa3_now = GPIO_IN & PA3;
        if (pa3_now != pa3) {
            pa3 = pa3_now;
            uart_puts(pa3 ? "PA3=1\r\n" : "PA3=0\r\n");
        }
    }
}
