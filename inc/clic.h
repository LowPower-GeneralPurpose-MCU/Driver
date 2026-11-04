#ifndef CLIC_H
#define CLIC_H

/*
 * CLIC - thay PLIC tu 2026-09-11 (RTL: interrupt/clic/clic.v,
 * core/register_file/register_file.v, core/riscv_pipeline.v).
 *
 * Khong con claim/complete. CLIC dua thang {id, muc, shv} vao core; core nhay
 * vao vector va mcause[11:0] = id. Ngat kich CANH tu xoa pending khi core nhan.
 * Ngat MUC: ISR phai xoa nguyen nhan o ngoai vi (doc RX FIFO, ghi W1C...).
 *
 * BAT CHE DO CLIC: clic_mode_enable(base) - mtvec = base | 3, base can le 64
 * byte (RTL ep 6 bit thap ve 0, nen base khong can le se nhay SAI cho).
 *   - ngat shv = 0 va MOI ngoai le  -> nhay vao base
 *   - ngat shv = 1                  -> nhay vao base + 4 * id; o do phai la
 *                                      MOT lenh `j handler_id`
 * Khac Smclic chuan: KHONG co mtvt (0x307 -> illegal). Firmware nay dung
 * shv = 0: trap_entry (startup/trap_handler.S, can le 64) la base, va
 * system_trap_handler() phan luong theo id.
 *
 * O che do CLIC, msip (id 3) va mtip (id 7) cua CLINT cung di qua CLIC: bit
 * mie.MSIE / mie.MTIE KHONG con tac dung (mie, mip doc ra 0). Phai
 * clic_config + clic_enable id 3 / 7 nhu moi nguon khac.
 *
 * mcause o che do CLIC (doc ra):
 *   [31] interrupt  [30] minhv = 0  [29:28] mpp = 11  [27] mpie
 *   [23:16] mpil (muc truoc trap)    [11:0] exccode (id ngat / ma ngoai le)
 * => luon so sanh MCAUSE_CODE(mcause), KHONG so sanh nguyen mcause.
 *
 * Muc 8 bit = {ctl[7:5], 5'b11111}. Ngat duoc nhan khi
 * muc > max(mintstatus.mil, mintthresh) va mstatus.MIE = 1. Long nhau: ISR
 * luu mepc + mcause (mcause mang mpil), set MIE, ..., clear MIE, khoi phuc
 * mepc + mcause, mret. (trap_handler.S hien KHONG long nhau.)
 */

#include <stdint.h>
#include "soc_hw.h"

#define CLIC_CFG            (*(volatile uint32_t *)(CLIC_BASE + 0x0000))
#define CLIC_INFO           (*(volatile uint32_t *)(CLIC_BASE + 0x0004))
#define CLIC_INT(id)        (*(volatile uint32_t *)(CLIC_BASE + 0x1000 + 4u * (id)))
/* Truy cap tung byte: CLIC giai ma pstrb, D-cache dat WSTRB dung lane (sb). */
#define CLIC_INTIP(id)      (*(volatile uint8_t  *)(CLIC_BASE + 0x1000 + 4u * (id) + 0))
#define CLIC_INTIE(id)      (*(volatile uint8_t  *)(CLIC_BASE + 0x1000 + 4u * (id) + 1))
#define CLIC_INTATTR(id)    (*(volatile uint8_t  *)(CLIC_BASE + 0x1000 + 4u * (id) + 2))
#define CLIC_INTCTL(id)     (*(volatile uint8_t  *)(CLIC_BASE + 0x1000 + 4u * (id) + 3))

/* clicintattr */
#define CLIC_ATTR_SHV           0x01u   /* vector rieng cho nguon nay */
#define CLIC_TRIG_LEVEL_HIGH    (0u << 1)
#define CLIC_TRIG_EDGE_RISE     (1u << 1)
#define CLIC_TRIG_LEVEL_LOW     (2u << 1)
#define CLIC_TRIG_EDGE_FALL     (3u << 1)

#define CSR_MINTTHRESH  0x347
#define CSR_MINTSTATUS  0xFB1

/* mcause */
#define MCAUSE_INTERRUPT        0x80000000u
#define MCAUSE_IS_INT(m)        (((m) & MCAUSE_INTERRUPT) != 0u)
#define MCAUSE_CODE(m)          ((m) & 0xFFFu)

/* level: 1..7 (3 bit ctl; muc 0 cung vuot nguong 0 vi 8 bit = 0x1F, nhung
 * nen dung 1..7). attr: CLIC_ATTR_SHV | CLIC_TRIG_*. Nguon bi tat (ie = 0) sau
 * ham nay; pending cua nguon canh duoc xoa. */
static inline void clic_config(uint32_t id, uint32_t level, uint32_t attr)
{
    CLIC_INTIE(id)   = 0;
    CLIC_INTATTR(id) = (uint8_t)attr;
    CLIC_INTCTL(id)  = (uint8_t)((level & 7u) << 5);
    CLIC_INTIP(id)   = 0;   /* chi co tac dung voi nguon kich canh */
}

static inline void clic_enable(uint32_t id)  { CLIC_INTIE(id) = 1; }
static inline void clic_disable(uint32_t id) { CLIC_INTIE(id) = 0; }
/* Chi co tac dung voi nguon kich CANH (ngat muc: ip = muc chan). */
static inline void clic_pend(uint32_t id)    { CLIC_INTIP(id) = 1; }
static inline void clic_clear(uint32_t id)   { CLIC_INTIP(id) = 0; }
static inline uint32_t clic_is_pending(uint32_t id) { return CLIC_INTIP(id) & 1u; }

/* config + enable trong mot lan goi. */
static inline void clic_irq_enable(uint32_t id, uint32_t level, uint32_t attr)
{
    clic_config(id, level, attr);
    clic_enable(id);
}

/* Nguong 8 bit: chi ngat co muc 8 bit > nguong moi duoc nhan.
 * Muc ctl n tuong ung muc 8 bit (n << 5) | 0x1F. */
static inline void clic_set_threshold(uint32_t level8)
{
    __asm__ volatile("csrw 0x347, %0" :: "r"(level8 & 0xFFu));
}

/* mintstatus.mil - muc cua ngat dang phuc vu (0 = code thuong). */
static inline uint32_t clic_current_level(void)
{
    uint32_t v;
    __asm__ volatile("csrr %0, 0xFB1" : "=r"(v));
    return v >> 24;
}

/* base: dia chi vao trap (can le 64 byte). Bat che do CLIC. */
static inline void clic_mode_enable(uintptr_t base)
{
    __asm__ volatile("csrw mtvec, %0" :: "r"((base & ~(uintptr_t)0x3Fu) | 3u));
}

/* Tat moi nguon, xoa pending canh, nguong = 0. Khong doi trig/muc.
 * Sau reset CLIC da o trang thai nay - chi can goi khi khoi dong lai mem. */
void clic_init(void);

#endif /* CLIC_H */
