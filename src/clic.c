/* ==================================================================
 * File: src/clic.c
 * Mô tả: Khoi tao CLIC (xem inc/clic.h)
 * ================================================================== */
#include "clic.h"

void clic_init(void)
{
    uint32_t id;

    /* ID 0 khong bao gio duoc phan xu (trung loi vao ngoai le) nhung tat luon
       cho gon. Xoa ie truoc roi moi xoa ip. */
    for (id = 0; id < CLIC_NUM_IRQ; id++) {
        CLIC_INTIE(id) = 0;
        CLIC_INTIP(id) = 0;   /* chi co tac dung voi nguon kich canh */
    }
    clic_set_threshold(0);
}
