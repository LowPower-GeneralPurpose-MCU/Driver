#include "soc_config.h"

#if CONFIG_HAS_I2C
#include "i2c.h"

// Chờ lệnh I2C thực thi xong
static void i2c_wait_done(void) {
    while (I2C0->STAT & I2C_STAT_TRANS);
}

void i2c_init(uint16_t prescaler) {
    I2C0->PRER = prescaler;
}

void i2c_start(void) {
    I2C0->CMD = I2C_CMD_STA;
    i2c_wait_done();
}

void i2c_stop(void) {
    I2C0->CMD = I2C_CMD_STO;
    i2c_wait_done();
}

// Trả về 0 nếu Slave nhận thành công (ACK=0), trả về 1 nếu NACK
uint8_t i2c_write(uint8_t data) {
    I2C0->TXR = data;
    I2C0->CMD = I2C_CMD_WR;
    i2c_wait_done();
    
    // Kiểm tra bit số 7 của STAT (RxACK)
    return (I2C0->STAT & I2C_STAT_RXACK) ? 1 : 0; 
}

// Nếu send_ack = 0, Host sẽ trả về ACK. Nếu send_ack = 1, Host trả về NACK (để kết thúc)
uint8_t i2c_read(uint8_t send_ack) {
    uint32_t cmd = I2C_CMD_RD;
    if (send_ack) {
        cmd |= I2C_CMD_ACK;
    }
    
    I2C0->CMD = cmd;
    i2c_wait_done();
    
    return (uint8_t)(I2C0->RXR & 0xFF);
}

#endif // CONFIG_HAS_I2C