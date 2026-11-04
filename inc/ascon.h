#ifndef ASCON_HAL_H
#define ASCON_HAL_H

/*
 * ASCON-128 (AEAD, CHI MA HOA) / ASCON-Hash + TRNG 128 bit
 * (RTL: apb_ascon/apb_ascon.v, ascon_core.v, trng_128b.v). Base 0x4000_C000.
 *
 * Gioi han cua phan cung (ghi o dau apb_ascon.v):
 *   - Loi chi MA HOA. Giai ma can lenh moi trong ascon_core - KHONG co API giai ma.
 *   - Padding 10* do phan mem lam (driver nay lo).
 *   - Chi duoc xung DATA_VALID khi STATUS.READY = 1; xung sai luc bi bo qua
 *     AM THAM. Driver cho READY & BUSY (= dang o ST_WAIT_DATA) truoc moi khoi.
 *   - Doc/ghi offset khong co trong bang -> PSLVERR (bus error). KEY / NONCE /
 *     DATA_IN la CHI GHI; DATA_OUT / TAG / HASH / TRNG la CHI DOC.
 *
 * Thu tu byte: word thap dia chi nhat chua 4 byte DAU TIEN, big-endian
 * (KEY[0] = key[0..3]). Khop KAT trong tests/tb_ascon_apb.sv.
 *
 * Ngat (CLIC ID 27) = STATUS.DONE (sticky, MUC). Cac ham duoi day la POLLING
 * va TU XOA DONE; chung khong dua vao DONE nen van dung neu ISR co bat. Chi bat
 * CLIC 27 neu tu dieu khien thanh ghi va muon nhan ngat khi xong.
 *
 * Clock: SYSCON bit 7 TAT sau reset nhung khong can - o_active / psel tu giu
 * clock khi loi dang chay hoac TRNG_EN = 1.
 */

#include <stdint.h>
#include "soc_hw.h"

typedef struct {
    volatile uint32_t CTRL;        /* 0x000 RW                                   */
    volatile uint32_t STATUS;      /* 0x004 RO, [1] DONE ghi 1 de xoa            */
    uint32_t          RSV0[2];     /* 0x008-0x00C KHONG truy cap (PSLVERR)       */
    volatile uint32_t KEY[4];      /* 0x010-0x01C WO, KEY[0] = key[127:96]       */
    volatile uint32_t NONCE[4];    /* 0x020-0x02C WO                             */
    volatile uint32_t DATA_IN[2];  /* 0x030-0x034 WO, DATA_IN[0] = khoi[63:32]   */
    uint32_t          RSV1[2];     /* 0x038-0x03C                                */
    volatile uint32_t DATA_OUT[2]; /* 0x040-0x044 RO ban ma cua khoi vua nap     */
    uint32_t          RSV2[2];     /* 0x048-0x04C                                */
    volatile uint32_t TAG[4];      /* 0x050-0x05C RO; MODE = HASH: HASH[255:128] */
    volatile uint32_t HASH_LO[4];  /* 0x060-0x06C RO HASH[127:0]                 */
    volatile uint32_t TRNG[4];     /* 0x070-0x07C RO                             */
} ASCON_TypeDef;

#define ASCON   ((ASCON_TypeDef *)ASCON_BASE)

/* CTRL */
#define ASCON_CTRL_START        (1u << 0)   /* xung, tu xoa */
#define ASCON_CTRL_MODE_HASH    (1u << 1)   /* 0 = AEAD, 1 = HASH */
#define ASCON_CTRL_TRNG_RST     (1u << 2)   /* muc cao, KHONG tu xoa */
#define ASCON_CTRL_TRNG_EN      (1u << 3)
#define ASCON_CTRL_DATA_VALID   (1u << 4)   /* xung, tu xoa */
#define ASCON_CTRL_CMD(c)       (((uint32_t)(c) & 7u) << 5)

#define ASCON_CMD_AD            0u
#define ASCON_CMD_AD_LAST       1u
#define ASCON_CMD_PT            2u
#define ASCON_CMD_PT_LAST       3u
#define ASCON_CMD_HASH          4u
#define ASCON_CMD_HASH_LAST     5u
#define ASCON_CMD_EMPTY_AD      6u

/* STATUS */
#define ASCON_STATUS_READY      (1u << 0)
#define ASCON_STATUS_DONE       (1u << 1)
#define ASCON_STATUS_TRNG_VALID (1u << 2)
#define ASCON_STATUS_BUSY       (1u << 3)

/* Ma tra ve */
#define HAL_ASCON_OK            0
#define HAL_ASCON_TIMEOUT      (-1)
#define HAL_ASCON_BUSY         (-2)   /* loi dang chay mot phep khac */

/* ASCON-128: ct dai pt_len byte (ct co the trung pt). ad / pt / ct duoc phep
 * NULL khi do dai tuong ung = 0. */
int HAL_ASCON_Encrypt(const uint8_t key[16], const uint8_t nonce[16],
                      const uint8_t *ad, uint32_t ad_len,
                      const uint8_t *pt, uint32_t pt_len,
                      uint8_t *ct, uint8_t tag[16]);

/* ASCON-Hash, digest 32 byte. msg duoc phep NULL khi len = 0. */
int HAL_ASCON_Hash(const uint8_t *msg, uint32_t len, uint8_t digest[32]);

/* TRNG: bat roi doi STATUS.TRNG_VALID (~128 chu ky clk sau khi bat).
 * Sau do rg_state chay lien tuc, nen 4 word cua mot lan doc lay o 4 thoi
 * diem khac nhau. Day KHONG phai danh gia entropy: trong mo phong ring
 * oscillator la song vuong tat dinh. */
void HAL_TRNG_Enable(void);
void HAL_TRNG_Disable(void);
int  HAL_TRNG_Read(uint32_t *out, uint32_t nwords);

/* Neu bat CLIC 27: goi tu system_trap_handler. Xoa DONE roi goi callback. */
void HAL_ASCON_IRQHandler(void);
void HAL_ASCON_DoneCallback(void);   /* weak */

#endif /* ASCON_HAL_H */
