#ifndef CLIC_H
#define CLIC_H

/*
 * CLIC - thay PLIC tu 2026-09-11 (RTL: interrupt/clic/clic.v).
 *
 * Khong con claim/complete: core nhay thang vao vector cua nguon ngat
 * (mtvec_base + 4 * id khi shv = 1), mcause.exccode = id. Ngat kich canh tu
 * xoa pending khi core nhan. Ngat muc: ISR xoa nguyen nhan o ngoai vi.
 *
 * Bat che do CLIC: clic_mode_enable(vtab) voi vtab can le 64 byte; o i cua
 * bang la MOT lenh `j handler_i` (o 0 = ngoai le / ngat shv = 0). Khac Smclic
 * chuan: KHONG co mtvt (bang dia chi) - xem ghi chu trap_vector trong
 * core/riscv_pipeline.v.
 *
 * Long nhau: muc 8 bit = {ctl[7:5], 5'b11111}. Ngat duoc nhan khi
 * muc > max(mintstatus.mil, mintthresh) va mstatus.MIE = 1. ISR muon cho
 * phep ngat cao hon preempt: luu mepc + mcause (mcause mang mpil), set MIE,
 * ..., clear MIE, khoi phuc mepc + mcause, mret.
 */

#include <stdint.h>
#include "soc_hw.h"

#define CLIC_CFG            (*(volatile uint32_t *)(CLIC_BASE + 0x0000))
#define CLIC_INFO           (*(volatile uint32_t *)(CLIC_BASE + 0x0004))
#define CLIC_INT(id)        (*(volatile uint32_t *)(CLIC_BASE + 0x1000 + 4u * (id)))
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

/* level: 0..7 (3 bit ctl). attr: CLIC_ATTR_SHV | CLIC_TRIG_* */
static inline void clic_config(uint32_t id, uint32_t level, uint32_t attr)
{
    CLIC_INTIE(id)   = 0;
    CLIC_INTATTR(id) = (uint8_t)attr;
    CLIC_INTCTL(id)  = (uint8_t)((level & 7u) << 5);
}

static inline void clic_enable(uint32_t id)  { CLIC_INTIE(id) = 1; }
static inline void clic_disable(uint32_t id) { CLIC_INTIE(id) = 0; }
/* Chi co tac dung voi nguon kich CANH (ngat muc: ip = muc chan). */
static inline void clic_pend(uint32_t id)    { CLIC_INTIP(id) = 1; }
static inline void clic_clear(uint32_t id)   { CLIC_INTIP(id) = 0; }

static inline void clic_set_threshold(uint32_t level8)
{
    __asm__ volatile("csrw 0x347, %0" :: "r"(level8 & 0xFFu));
}

static inline uint32_t clic_current_level(void)
{
    uint32_t v;
    __asm__ volatile("csrr %0, 0xFB1" : "=r"(v));
    return v >> 24;
}

/* vtab: dia chi bang vector (can le 64 byte). */
static inline void clic_mode_enable(uintptr_t vtab)
{
    __asm__ volatile("csrw mtvec, %0" :: "r"((vtab & ~(uintptr_t)0x3Fu) | 3u));
}

#endif /* CLIC_H */
