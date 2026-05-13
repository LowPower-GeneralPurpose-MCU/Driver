#ifndef PLIC_H
#define PLIC_H

#include <stdint.h>
#include "soc_hw.h"

/* PLIC register map implemented by RTL plic_apb_reg. */
#define PLIC_PRIORITY(id)  (*(volatile uint32_t*)(PLIC_BASE + ((id) * 4)))
#define PLIC_PENDING       (*(volatile uint32_t*)(PLIC_BASE + 0x001000))
#define PLIC_ENABLE        (*(volatile uint32_t*)(PLIC_BASE + 0x002000))
#define PLIC_THRESHOLD     (*(volatile uint32_t*)(PLIC_BASE + 0x200000))
#define PLIC_CLAIM         (*(volatile uint32_t*)(PLIC_BASE + 0x200004))

void plic_set_priority(uint32_t irq_id, uint32_t priority);
void plic_enable_interrupt(uint32_t irq_id);
void plic_set_threshold(uint32_t threshold);
uint32_t plic_claim(void);
void plic_complete(uint32_t irq_id);

#endif
