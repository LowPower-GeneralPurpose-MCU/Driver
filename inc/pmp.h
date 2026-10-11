#ifndef PMP_H
#define PMP_H

/*
 * PMP 8 entry, granularity 4 byte (RTL: core/block_unit/pmp_unit.v, 2026-09-11).
 *
 * Core chi co M-mode: CHI entry co bit L (khoa) moi rang buoc code M-mode, va
 * entry da khoa thi bat bien toi reset. Dung trong boot ROM truoc khi nhay vao
 * firmware, vi du:
 *     pmp_set(0, PMP_NAPOT_ADDR(KEY_BASE, 256), PMP_L | PMP_NAPOT);          // cam het
 *     pmp_set(1, PMP_NAPOT_ADDR(0x00010000, 0x8000), PMP_L | PMP_NAPOT | PMP_X); // ROM chi X
 * Ghi co hieu luc voi load/store tu lenh ke tiep, voi lay lenh tu lenh thu ba -
 * ket thuc doan khoa bang mot lenh nhay (vao firmware) la du.
 *
 * PMP chi chan truy cap cua CPU. DMA va SBA cua debugger khong qua PMP; SBA
 * bi khoa bang SYSCON SEC_CTRL.DBG_LOCK.
 */

#include <stdint.h>

#define PMP_R       0x01u
#define PMP_W       0x02u
#define PMP_X       0x04u
#define PMP_OFF     (0u << 3)
#define PMP_TOR     (1u << 3)
#define PMP_NA4     (2u << 3)
#define PMP_NAPOT   (3u << 3)
#define PMP_L       0x80u

/* Vung NAPOT [base, base + size), size la luy thua 2 >= 8, base can le size. */
#define PMP_NAPOT_ADDR(base, size)  ((((uint32_t)(base)) >> 2) | ((((uint32_t)(size)) >> 3) - 1u))
/* NA4 / TOR: dia chi byte >> 2. */
#define PMP_ADDR(a)                 (((uint32_t)(a)) >> 2)

#define PMP_WRITE_ADDR_CASE(n) case n: __asm__ volatile("csrw pmpaddr" #n ", %0" :: "r"(addr)); break;

static inline void pmp_write_addr(uint32_t idx, uint32_t addr)
{
    switch (idx) {
        PMP_WRITE_ADDR_CASE(0) PMP_WRITE_ADDR_CASE(1) PMP_WRITE_ADDR_CASE(2)
        PMP_WRITE_ADDR_CASE(3) PMP_WRITE_ADDR_CASE(4) PMP_WRITE_ADDR_CASE(5)
        PMP_WRITE_ADDR_CASE(6) PMP_WRITE_ADDR_CASE(7)
        default: break;
    }
}

/* Dat entry idx (0..7): pmpaddr truoc, roi byte cfg (khoa cuoi cung). */
static inline void pmp_set(uint32_t idx, uint32_t pmpaddr, uint32_t cfg)
{
    uint32_t shift = (idx & 3u) * 8u;
    uint32_t mask  = 0xFFu << shift;
    uint32_t val   = (cfg & 0xFFu) << shift;

    pmp_write_addr(idx, pmpaddr);
    if (idx < 4) {
        __asm__ volatile("csrc pmpcfg0, %0" :: "r"(mask));
        __asm__ volatile("csrs pmpcfg0, %0" :: "r"(val));
    } else if (idx < 8) {
        __asm__ volatile("csrc pmpcfg1, %0" :: "r"(mask));
        __asm__ volatile("csrs pmpcfg1, %0" :: "r"(val));
    }
}

#endif /* PMP_H */
