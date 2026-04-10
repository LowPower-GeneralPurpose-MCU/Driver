#ifndef I2C_H
#define I2C_H

#include <stdint.h>
#include "soc_hw.h"
#include "soc_config.h"

#if CONFIG_HAS_I2C

typedef struct {
    volatile uint32_t PRER; // 0x00: Prescaler
    volatile uint32_t TXR;  // 0x04: Dữ liệu cần truyền
    volatile uint32_t RXR;  // 0x08: Dữ liệu nhận
    volatile uint32_t CMD;  // 0x0C: Lệnh điều khiển
    volatile uint32_t STAT; // 0x10: Trạng thái
} I2C_TypeDef;

#define I2C0 ((I2C_TypeDef *)I2C_BASE)

// CMD Bits
#define I2C_CMD_STA  (1 << 7) // Start
#define I2C_CMD_STO  (1 << 6) // Stop
#define I2C_CMD_RD   (1 << 5) // Read
#define I2C_CMD_WR   (1 << 4) // Write
#define I2C_CMD_ACK  (1 << 3) // ACK host trả về cho Slave

// STAT Bits
#define I2C_STAT_RXACK (1 << 7) // ACK từ Slave trả về
#define I2C_STAT_TRANS (1 << 1) // Đang truyền (Transferring)

void i2c_init(uint16_t prescaler);
void i2c_start(void);
void i2c_stop(void);
uint8_t i2c_write(uint8_t data);
uint8_t i2c_read(uint8_t send_ack);

#endif // CONFIG_HAS_I2C
#endif // I2C_H