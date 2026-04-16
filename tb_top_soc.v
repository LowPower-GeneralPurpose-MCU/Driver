`timescale 1ns / 1ps

module tb_top_soc();
    // Clock signals
    reg clk_400m, clk_200m, clk_100m, rtc_clk;
    reg rst_n;

    // JTAG interface
    reg tck, trst_n, tms, tdi;
    wire tdo;

    // Peripheral signals
    wire uart_tx, uart_rx;
    wire spi_sck, spi_mosi, spi_miso, spi_ss;
    wire i2c_scl, i2c_sda;
    reg  [31:0] gpio_in;
    wire [31:0] gpio_out;
    wire [31:0] gpio_oe;
    wire pwm_out;

    // Flash & SDRAM
    wire flash_sck, flash_cs_n;
    wire [3:0] flash_io;
    wire sdram_clk, sdram_cke, sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n;
    wire [1:0] sdram_ba;
    wire [1:0] sdram_dqm; // Sửa lại thành 2 bit cho phù hợp với top_soc (16-bit data)
    wire [12:0] sdram_addr;
    wire [15:0] sdram_dq; // Sửa lại thành 16 bit

    // ========================================================
    // Tạo các clock với tần số khác nhau
    // ========================================================
    initial begin clk_400m = 0; forever #1.25  clk_400m = ~clk_400m; end // 400 MHz
    initial begin clk_200m = 0; forever #2.5   clk_200m = ~clk_200m; end // 200 MHz
    initial begin clk_100m = 0; forever #5.0   clk_100m = ~clk_100m; end // 100 MHz
    initial begin rtc_clk  = 0; forever #15258 rtc_clk  = ~rtc_clk;  end // ~32 kHz

    // ========================================================
    // Instantiate SoC
    // ========================================================
    top_soc uut (
        .clk_core      (clk_400m),
        .clk_axi       (clk_200m),
        .clk_apb       (clk_100m),
        
        // FIX WARNING: Đã nối dây clk_sdram_ctrl bị thiếu!
        .clk_sdram_ctrl(clk_100m), 
        
        .clk_sdram_ext (clk_200m),
        .uart_clk      (clk_100m),
        .spi_clk       (clk_100m),
        .i2c_clk       (clk_100m),
        .rtc_clk       (rtc_clk),
        .rst_n         (rst_n),

        .tck(tck), .trst_n(trst_n), .tms(tms), .tdi(tdi), .tdo(tdo),

        .uart_rx(uart_rx),
        .uart_tx(uart_tx),

        .gpio_in(gpio_in),
        .gpio_out(gpio_out),
        .gpio_oe(gpio_oe),
        .pwm_out(pwm_out),

        .spi_sck(spi_sck),    
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        .spi_ss(spi_ss), 

        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda),

        .flash_sck(flash_sck), 
        .flash_cs_n(flash_cs_n), 
        .flash_io(flash_io),

        .sdram_clk(sdram_clk), 
        .sdram_cke(sdram_cke), 
        .sdram_cs_n(sdram_cs_n),
        .sdram_ras_n(sdram_ras_n), 
        .sdram_cas_n(sdram_cas_n), 
        .sdram_we_n(sdram_we_n),
        .sdram_ba(sdram_ba), 
        .sdram_addr(sdram_addr), 
        .sdram_dq(sdram_dq), 
        .sdram_dqm(sdram_dqm)
    );

    // ========================================================
    // MÔ HÌNH CHIP SDRAM (NẾU BẠN CÓ FILE CHUẨN THÌ XÓA ĐOẠN NÀY ĐI
    // VÀ INSTANTIATE FILE ĐÓ VÀO ĐÂY)
    // ========================================================
    // mt48lc16m16a2 my_sdram_chip (
    //     .Dq(sdram_dq), .Addr(sdram_addr), .Ba(sdram_ba),
    //     .Clk(sdram_clk), .Cke(sdram_cke), .Cs_n(sdram_cs_n),
    //     .Ras_n(sdram_ras_n), .Cas_n(sdram_cas_n), .We_n(sdram_we_n), .Dqm(sdram_dqm)
    // );
    
    // NẾU BẠN KHÔNG CÓ MÔ HÌNH: PHẢI DÙNG LỆNH FORCE ĐỂ ÉP MẠCH CHẠY
    // Ép cờ báo hoàn thành khởi tạo của Controller lên 1 sau 200us
    initial begin
        // Đường dẫn này tùy thuộc vào cách bạn đặt tên bên trong top_soc.v và axi_sdram_controller.v
        // Thường là: uut.u_axi_sdram.init_done
        #200000; // Đợi 200us
        // force uut.u_axi_sdram.init_done = 1'b1; 
    end

    // ========================================================
    // Loopback để tự test
    // ========================================================
    assign uart_rx  = uart_tx;   
    assign spi_miso = spi_mosi;  
    pullup(i2c_scl);             
    pullup(i2c_sda);

    // ========================================================
    // Test sequence
    // ========================================================
    initial begin
        // Đổi đường dẫn tuyệt đối cho phù hợp với máy bạn
        $readmemh("D:/HK252/Soc_Sim/soc_firmware/my_soc_firmware_word.hex", uut.u_axi_rom.rom_memory);

        tck = 0; trst_n = 1; tms = 0; tdi = 0;
        gpio_in = 0;
        rst_n = 0;

        #100;
        rst_n = 1;

        // TĂNG THỜI GIAN LÊN MỨC KHỔNG LỒ (5 ms)
        #5000000;

        gpio_in[1] = 1; 
        #5000;          
        gpio_in[1] = 0; 

        #2000000;
        $display("SIMULATION FINISHED");
        $finish;
    end

endmodule