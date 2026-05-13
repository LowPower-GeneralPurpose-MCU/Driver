`timescale 1ns / 1ps

module tb_top_soc();
    reg [1023:0] firmware_hex;
    integer firmware_fd;
    integer debug_fd;
    integer core_cycle_count;
    integer pc_stall_count;
    reg [31:0] last_pc;
    reg [31:0] last_data_addr;
    reg        last_wfi_sleep;

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

    initial begin
        debug_fd = $fopen("tb_top_soc_debug.log", "w");
        if (debug_fd == 0) begin
            $display("[TB][WARN] Cannot open tb_top_soc_debug.log");
        end

        core_cycle_count = 0;
        pc_stall_count = 0;
        last_pc = 32'hFFFF_FFFF;
        last_data_addr = 32'hFFFF_FFFF;
        last_wfi_sleep = 1'b0;
    end

    always @(posedge clk_400m) begin
        if (!rst_n) begin
            core_cycle_count <= 0;
            pc_stall_count <= 0;
            last_pc <= 32'hFFFF_FFFF;
            last_data_addr <= 32'hFFFF_FFFF;
            last_wfi_sleep <= 1'b0;
        end else begin
            core_cycle_count <= core_cycle_count + 1;

            if (uut.u_core.pc_reg !== last_pc) begin
                $display("[TB][PC] t=%0t cyc=%0d pc=%08h inst_addr=%08h inst=%08h ireq=%b ihit=%b istall=%b",
                         $time, core_cycle_count, uut.u_core.pc_reg, uut.cpu_inst_addr,
                         uut.cpu_inst_data, uut.cpu_inst_req, uut.cpu_inst_hit, uut.cpu_inst_stall);
                if (debug_fd != 0) begin
                    $fdisplay(debug_fd, "[TB][PC] t=%0t cyc=%0d pc=%08h inst_addr=%08h inst=%08h ireq=%b ihit=%b istall=%b",
                              $time, core_cycle_count, uut.u_core.pc_reg, uut.cpu_inst_addr,
                              uut.cpu_inst_data, uut.cpu_inst_req, uut.cpu_inst_hit, uut.cpu_inst_stall);
                end
                last_pc <= uut.u_core.pc_reg;
                pc_stall_count <= 0;
            end else begin
                pc_stall_count <= pc_stall_count + 1;
                if (pc_stall_count == 1000 || pc_stall_count == 10000) begin
                    $display("[TB][STALL] t=%0t pc=%08h unchanged_cycles=%0d if_stall=%b d_stall=%b wfi=%b",
                             $time, uut.u_core.pc_reg, pc_stall_count,
                             uut.cpu_inst_stall, uut.cpu_data_stall, uut.wfi_sleep_state);
                    if (debug_fd != 0) begin
                        $fdisplay(debug_fd, "[TB][STALL] t=%0t pc=%08h unchanged_cycles=%0d if_stall=%b d_stall=%b wfi=%b",
                                  $time, uut.u_core.pc_reg, pc_stall_count,
                                  uut.cpu_inst_stall, uut.cpu_data_stall, uut.wfi_sleep_state);
                    end
                end
            end

            if (uut.u_core.trap_enter) begin
                $display("[TB][TRAP] t=%0t cause=%08h trap_pc=%08h mtvec=%08h mepc=%08h",
                         $time, uut.u_core.trap_cause, uut.u_core.trap_pc_value,
                         uut.u_core.mtvec_pc, uut.u_core.mepc_pc);
                if (debug_fd != 0) begin
                    $fdisplay(debug_fd, "[TB][TRAP] t=%0t cause=%08h trap_pc=%08h mtvec=%08h mepc=%08h",
                              $time, uut.u_core.trap_cause, uut.u_core.trap_pc_value,
                              uut.u_core.mtvec_pc, uut.u_core.mepc_pc);
                end
            end

            if ((uut.cpu_data_rd_req || uut.cpu_data_wr_req) &&
                (uut.cpu_data_addr !== last_data_addr || uut.cpu_data_stall)) begin
                $display("[TB][D-BUS] t=%0t rd=%b wr=%b addr=%08h wdata=%08h rdata=%08h hit=%b stall=%b size=%0d",
                         $time, uut.cpu_data_rd_req, uut.cpu_data_wr_req, uut.cpu_data_addr,
                         uut.cpu_data_wdata, uut.cpu_data_rdata, uut.cpu_data_hit,
                         uut.cpu_data_stall, uut.cpu_data_size);
                if (debug_fd != 0) begin
                    $fdisplay(debug_fd, "[TB][D-BUS] t=%0t rd=%b wr=%b addr=%08h wdata=%08h rdata=%08h hit=%b stall=%b size=%0d",
                              $time, uut.cpu_data_rd_req, uut.cpu_data_wr_req, uut.cpu_data_addr,
                              uut.cpu_data_wdata, uut.cpu_data_rdata, uut.cpu_data_hit,
                              uut.cpu_data_stall, uut.cpu_data_size);
                end
                last_data_addr <= uut.cpu_data_addr;
            end

            if (uut.wfi_sleep_state && !last_wfi_sleep) begin
                $display("[TB][WFI] t=%0t CPU entered WFI at pc=%08h", $time, uut.u_core.pc_reg);
                if (debug_fd != 0) begin
                    $fdisplay(debug_fd, "[TB][WFI] t=%0t CPU entered WFI at pc=%08h", $time, uut.u_core.pc_reg);
                end
            end
            last_wfi_sleep <= uut.wfi_sleep_state;
        end
    end

    always @(posedge clk_100m) begin
        if (rst_n && uut.apb_psel && uut.apb_penable && uut.apb_pready) begin
            if (uut.apb_pwrite) begin
                $display("[TB][APB-W] t=%0t addr=%08h data=%08h pslverr=%b",
                         $time, uut.apb_paddr, uut.apb_pwdata, uut.apb_pslverr);
                if (debug_fd != 0) begin
                    $fdisplay(debug_fd, "[TB][APB-W] t=%0t addr=%08h data=%08h pslverr=%b",
                              $time, uut.apb_paddr, uut.apb_pwdata, uut.apb_pslverr);
                end
                if (uut.apb_paddr == 32'h4000_0004) begin
                    $display("[TB][UART-TX] t=%0t byte=0x%02h char=%c",
                             $time, uut.apb_pwdata[7:0], uut.apb_pwdata[7:0]);
                    if (debug_fd != 0) begin
                        $fdisplay(debug_fd, "[TB][UART-TX] t=%0t byte=0x%02h char=%c",
                                  $time, uut.apb_pwdata[7:0], uut.apb_pwdata[7:0]);
                    end
                end
            end else begin
                $display("[TB][APB-R] t=%0t addr=%08h data=%08h pslverr=%b",
                         $time, uut.apb_paddr, uut.apb_prdata, uut.apb_pslverr);
                if (debug_fd != 0) begin
                    $fdisplay(debug_fd, "[TB][APB-R] t=%0t addr=%08h data=%08h pslverr=%b",
                              $time, uut.apb_paddr, uut.apb_prdata, uut.apb_pslverr);
                end
            end
        end
    end

    // ========================================================
    // Test sequence
    // ========================================================
    initial begin
        if (!$value$plusargs("FW_HEX=%s", firmware_hex)) begin
            firmware_hex = "my_soc_firmware_word.mem";
            firmware_fd = $fopen(firmware_hex, "r");
            if (firmware_fd != 0) begin
                $fclose(firmware_fd);
            end else begin
                firmware_hex = "Driver/my_soc_firmware_word.mem";
                firmware_fd = $fopen(firmware_hex, "r");
                if (firmware_fd != 0) begin
                    $fclose(firmware_fd);
                end else begin
                    firmware_hex = "../../../../Driver/my_soc_firmware_word.mem";
                end
            end
        end

        $display("Loading firmware: %0s", firmware_hex);
        if (debug_fd != 0) begin
            $fdisplay(debug_fd, "[TB][BOOT] Loading firmware: %0s", firmware_hex);
        end
        $readmemh(firmware_hex, uut.u_axi_rom.rom_memory);
        $display("[TB][ROM] word0=%08h word1=%08h word2=%08h word3=%08h",
                 uut.u_axi_rom.rom_memory[0], uut.u_axi_rom.rom_memory[1],
                 uut.u_axi_rom.rom_memory[2], uut.u_axi_rom.rom_memory[3]);
        if (debug_fd != 0) begin
            $fdisplay(debug_fd, "[TB][ROM] word0=%08h word1=%08h word2=%08h word3=%08h",
                      uut.u_axi_rom.rom_memory[0], uut.u_axi_rom.rom_memory[1],
                      uut.u_axi_rom.rom_memory[2], uut.u_axi_rom.rom_memory[3]);
        end

        tck = 0; trst_n = 1; tms = 0; tdi = 0;
        gpio_in = 0;
        rst_n = 0;
        $display("[TB][RESET] t=%0t assert rst_n=0", $time);
        if (debug_fd != 0) begin
            $fdisplay(debug_fd, "[TB][RESET] t=%0t assert rst_n=0", $time);
        end

        #100;
        rst_n = 1;
        $display("[TB][RESET] t=%0t deassert rst_n=1 reset_vector=%08h",
                 $time, uut.syscon_reset_vector);
        if (debug_fd != 0) begin
            $fdisplay(debug_fd, "[TB][RESET] t=%0t deassert rst_n=1 reset_vector=%08h",
                      $time, uut.syscon_reset_vector);
        end

        // TĂNG THỜI GIAN LÊN MỨC KHỔNG LỒ (5 ms)
        #5000000;

        gpio_in[1] = 1; 
        #5000;          
        gpio_in[1] = 0; 

        #2000000;
        $display("SIMULATION FINISHED");
        if (debug_fd != 0) begin
            $fdisplay(debug_fd, "[TB][DONE] t=%0t simulation finished", $time);
            $fclose(debug_fd);
        end
        $finish;
    end

endmodule
