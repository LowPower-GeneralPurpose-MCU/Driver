#include "soc_config.h"

#if CONFIG_HAS_SPI
#include "spi.h"

void spi_init(uint8_t cpol, uint8_t cpha, uint32_t clock_div) {
    // Ghi CPOL và CPHA vào CTRL
    SPI0->CTRL = ((cpol & 1) << 1) | (cpha & 1);
    // Setup bộ chia tần số Clock
    SPI0->DIV = clock_div;
    // Mặc định nhả chân CS (Mức 1 = Không chọn Slave)
    SPI0->CS = 1;
}

void spi_set_cs(uint8_t state) {
    // Kéo CS xuống 0 để giao tiếp, 1 để ngắt
    SPI0->CS = state & 1;
}

// Truyền và nhận dữ liệu đồng thời (Đặc trưng của giao thức SPI)
uint8_t spi_transfer(uint8_t data) {
    // 1. Chờ đến khi SPI rảnh rỗi
    while (SPI0->STATUS & SPI_STATUS_BUSY);

    // 2. Ghi dữ liệu vào TX (Mạch RTL sẽ tự động kích hoạt quá trình truyền)
    SPI0->TXDATA = data;

    // 3. Chờ phần cứng báo DONE (Truyền xong 8 bit)
    while (!(SPI0->STATUS & SPI_STATUS_DONE));

    // 4. Đọc dữ liệu nhận được từ MISO (Phần cứng tự xóa cờ DONE khi đọc)
    return (uint8_t)(SPI0->RXDATA & 0xFF);
}

#endif // CONFIG_HAS_SPI