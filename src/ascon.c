/* ==================================================================
 * File: src/ascon.c
 * Mô tả: HAL cho ASCON-128 / ASCON-Hash / TRNG (xem inc/ascon.h)
 *
 * Trinh tu lay tu tests/tb_ascon_apb.sv (KAT ASCON v1.2 PASS):
 *   AEAD: KEY, NONCE -> CTRL = START -> cho WAIT_DATA
 *         -> moi khoi AD (AD .. AD_LAST, hoac EMPTY_AD) -> cho WAIT_DATA
 *         -> moi khoi PT: PT -> cho WAIT_DATA -> doc DATA_OUT
 *         -> PT_LAST -> cho IDLE -> doc DATA_OUT (cat ngan) va TAG
 *   HASH: CTRL = START | MODE -> cho WAIT_DATA -> HASH .. -> HASH_LAST
 *         -> cho IDLE -> doc TAG (= HASH[255:128]) va HASH_LO
 * "WAIT_DATA" = STATUS.READY & STATUS.BUSY; "IDLE" = READY & !BUSY
 * (ascon_core.v: busy = fsm_state != ST_IDLE).
 *
 * Thu tu ghi CTRL roi doc STATUS duoc bao dam: lenh doc uncached cho store
 * buffer cua D-cache xa het (dcache.v, rule 2).
 * ================================================================== */
#include "soc_config.h"

#if CONFIG_HAS_ASCON
#include "ascon.h"

/* Moi lan cho la vai chuc chu ky (12 vong hoan vi) - mot lan doc STATUS qua
   AXI -> APB da ton ~10-20 chu ky, nen gioi han nay rat rong. */
#define ASCON_POLL_LIMIT    100000u

static uint32_t ld_be32(const uint8_t *p)
{
    return ((uint32_t)p[0] << 24) | ((uint32_t)p[1] << 16) |
           ((uint32_t)p[2] << 8)  |  (uint32_t)p[3];
}

static void st_be32(uint8_t *p, uint32_t v)
{
    p[0] = (uint8_t)(v >> 24);
    p[1] = (uint8_t)(v >> 16);
    p[2] = (uint8_t)(v >> 8);
    p[3] = (uint8_t)v;
}

/* Bit TRNG phai giu nguyen qua moi lan ghi CTRL (CTRL ghi ca word). */
static uint32_t ctrl_keep(void)
{
    return ASCON->CTRL & (ASCON_CTRL_TRNG_EN | ASCON_CTRL_TRNG_RST);
}

static int wait_status(uint32_t mask, uint32_t value)
{
    uint32_t n = ASCON_POLL_LIMIT;
    while ((ASCON->STATUS & mask) != value) {
        if (--n == 0u) return HAL_ASCON_TIMEOUT;
    }
    return HAL_ASCON_OK;
}

static int wait_data(void)
{
    return wait_status(ASCON_STATUS_READY | ASCON_STATUS_BUSY,
                       ASCON_STATUS_READY | ASCON_STATUS_BUSY);
}

static int wait_idle(void)
{
    return wait_status(ASCON_STATUS_READY | ASCON_STATUS_BUSY, ASCON_STATUS_READY);
}

/* Nap mot khoi 8 byte va xung DATA_VALID voi lenh cmd. */
static void push_block(const uint8_t blk[8], uint32_t cmd, uint32_t ctrl_base)
{
    ASCON->DATA_IN[0] = ld_be32(&blk[0]);
    ASCON->DATA_IN[1] = ld_be32(&blk[4]);
    ASCON->CTRL = ctrl_base | ASCON_CTRL_DATA_VALID | ASCON_CTRL_CMD(cmd);
}

/* Khoi cuoi: rem (0..7) byte con lai + 0x80 + 0x00... (padding 10*). */
static void make_last_block(uint8_t blk[8], const uint8_t *src, uint32_t rem)
{
    uint32_t i;
    for (i = 0; i < 8u; i++) blk[i] = (i < rem) ? src[i] : 0u;
    blk[rem] = 0x80u;
}

static void read_ct(uint8_t *dst, uint32_t n)
{
    uint8_t tmp[8];
    uint32_t i;
    st_be32(&tmp[0], ASCON->DATA_OUT[0]);
    st_be32(&tmp[4], ASCON->DATA_OUT[1]);
    for (i = 0; i < n; i++) dst[i] = tmp[i];
}

/* Bat dau mot phep: tu choi neu loi dang ban, xoa DONE cu, xung START. */
static int start_op(uint32_t ctrl_base)
{
    if (ASCON->STATUS & ASCON_STATUS_BUSY) return HAL_ASCON_BUSY;
    ASCON->STATUS = ASCON_STATUS_DONE;            /* W1C */
    ASCON->CTRL   = ctrl_base | ASCON_CTRL_START;
    return wait_data();                           /* xong 12 vong khoi tao */
}

int HAL_ASCON_Encrypt(const uint8_t key[16], const uint8_t nonce[16],
                      const uint8_t *ad, uint32_t ad_len,
                      const uint8_t *pt, uint32_t pt_len,
                      uint8_t *ct, uint8_t tag[16])
{
    uint8_t blk[8];
    uint32_t base, i, off, rem;
    int rc;

    if (ASCON->STATUS & ASCON_STATUS_BUSY) return HAL_ASCON_BUSY;

    for (i = 0; i < 4u; i++) {
        ASCON->KEY[i]   = ld_be32(&key[4u * i]);
        ASCON->NONCE[i] = ld_be32(&nonce[4u * i]);
    }

    base = ctrl_keep();                           /* MODE = 0: AEAD */
    rc = start_op(base);
    if (rc != HAL_ASCON_OK) goto out;

    /* ---- Associated data ---- */
    if (ad_len == 0u) {
        /* Khong AD: chi lat bit phan tach mien. Loi o lai WAIT_DATA. */
        for (i = 0; i < 8u; i++) blk[i] = 0u;
        push_block(blk, ASCON_CMD_EMPTY_AD, base);
        rc = wait_data();
        if (rc != HAL_ASCON_OK) goto out;
    } else {
        for (off = 0; off + 8u <= ad_len; off += 8u) {
            push_block(&ad[off], ASCON_CMD_AD, base);
            rc = wait_data();
            if (rc != HAL_ASCON_OK) goto out;
        }
        /* Luon con mot khoi padded (ke ca khi ad_len chia het cho 8). */
        rem = ad_len - off;
        make_last_block(blk, (rem != 0u) ? &ad[off] : blk, rem);
        push_block(blk, ASCON_CMD_AD_LAST, base);
        rc = wait_data();
        if (rc != HAL_ASCON_OK) goto out;
    }

    /* ---- Plaintext ---- */
    for (off = 0; off + 8u <= pt_len; off += 8u) {
        push_block(&pt[off], ASCON_CMD_PT, base);
        rc = wait_data();
        if (rc != HAL_ASCON_OK) goto out;
        read_ct(&ct[off], 8u);
    }
    rem = pt_len - off;
    make_last_block(blk, (rem != 0u) ? &pt[off] : blk, rem);
    push_block(blk, ASCON_CMD_PT_LAST, base);
    rc = wait_idle();                             /* finalization xong -> IDLE */
    if (rc != HAL_ASCON_OK) goto out;
    if (rem != 0u) read_ct(&ct[off], rem);

    for (i = 0; i < 4u; i++) {
        st_be32(&tag[4u * i], ASCON->TAG[i]);
    }
    ASCON->STATUS = ASCON_STATUS_DONE;            /* W1C */

out:
    /* Khong de key nam lai trong thanh ghi sau phep tinh. */
    for (i = 0; i < 4u; i++) ASCON->KEY[i] = 0u;
    return rc;
}

int HAL_ASCON_Hash(const uint8_t *msg, uint32_t len, uint8_t digest[32])
{
    uint8_t blk[8];
    uint32_t base, i, off, rem;
    int rc;

    base = ctrl_keep() | ASCON_CTRL_MODE_HASH;
    rc = start_op(base);
    if (rc != HAL_ASCON_OK) return rc;

    for (off = 0; off + 8u <= len; off += 8u) {
        push_block(&msg[off], ASCON_CMD_HASH, base);
        rc = wait_data();
        if (rc != HAL_ASCON_OK) return rc;
    }
    rem = len - off;
    make_last_block(blk, (rem != 0u) ? &msg[off] : blk, rem);
    push_block(blk, ASCON_CMD_HASH_LAST, base);
    rc = wait_idle();                             /* 4 lan squeeze xong -> IDLE */
    if (rc != HAL_ASCON_OK) return rc;

    /* MODE = 1 van dang dat nen 0x050..0x05C la HASH[255:128]. */
    for (i = 0; i < 4u; i++) {
        st_be32(&digest[4u * i],       ASCON->TAG[i]);
        st_be32(&digest[16u + 4u * i], ASCON->HASH_LO[i]);
    }
    ASCON->STATUS = ASCON_STATUS_DONE;            /* W1C */
    return HAL_ASCON_OK;
}

void HAL_TRNG_Enable(void)
{
    uint32_t c = ASCON->CTRL & ~(ASCON_CTRL_START | ASCON_CTRL_DATA_VALID | ASCON_CTRL_TRNG_RST);
    ASCON->CTRL = c | ASCON_CTRL_TRNG_EN;
}

void HAL_TRNG_Disable(void)
{
    uint32_t c = ASCON->CTRL & ~(ASCON_CTRL_START | ASCON_CTRL_DATA_VALID | ASCON_CTRL_TRNG_EN);
    ASCON->CTRL = c;
}

int HAL_TRNG_Read(uint32_t *out, uint32_t nwords)
{
    uint32_t i;
    int rc;

    if ((ASCON->CTRL & ASCON_CTRL_TRNG_EN) == 0u) HAL_TRNG_Enable();
    rc = wait_status(ASCON_STATUS_TRNG_VALID, ASCON_STATUS_TRNG_VALID);
    if (rc != HAL_ASCON_OK) return rc;

    for (i = 0; i < nwords; i++) {
        out[i] = ASCON->TRNG[i & 3u];
    }
    return HAL_ASCON_OK;
}

void HAL_ASCON_IRQHandler(void)
{
    ASCON->STATUS = ASCON_STATUS_DONE;   /* ngat MUC = DONE: xoa truoc */
    HAL_ASCON_DoneCallback();
}

__attribute__((weak)) void HAL_ASCON_DoneCallback(void)
{
}

#endif /* CONFIG_HAS_ASCON */
