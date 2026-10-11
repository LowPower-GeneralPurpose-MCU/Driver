`timescale 1ns / 1ps

module tb_top_soc();
    reg [1023:0] firmware_hex;
    integer firmware_fd;
    integer debug_fd;
    integer core_cycle_count;
    integer pc_stall_count;
    integer data_stall_count;
    integer apb_busy_count;
    reg [31:0] last_pc;
    reg [31:0] last_data_addr;
    reg        last_data_rd;
    reg        last_data_wr;
    reg        last_wfi_sleep;
    reg        last_apb_psel;
    integer    uart_tx_count;
    reg        uart_mismatch;
    reg        uart_done;

    localparam integer UART_EXPECT_LEN = 24;

    function [7:0] expected_uart_byte;
        input integer idx;
        begin
            case (idx)
                0:  expected_uart_byte = 8'h48; // H
                1:  expected_uart_byte = 8'h45; // E
                2:  expected_uart_byte = 8'h4c; // L
                3:  expected_uart_byte = 8'h4c; // L
                4:  expected_uart_byte = 8'h4f; // O
                5:  expected_uart_byte = 8'h20; // space
                6:  expected_uart_byte = 8'h52; // R
                7:  expected_uart_byte = 8'h49; // I
                8:  expected_uart_byte = 8'h53; // S
                9:  expected_uart_byte = 8'h43; // C
                10: expected_uart_byte = 8'h2d; // -
                11: expected_uart_byte = 8'h56; // V
                12: expected_uart_byte = 8'h20; // space
                13: expected_uart_byte = 8'h55; // U
                14: expected_uart_byte = 8'h41; // A
                15: expected_uart_byte = 8'h52; // R
                16: expected_uart_byte = 8'h54; // T
                17: expected_uart_byte = 8'h20; // space
                18: expected_uart_byte = 8'h54; // T
                19: expected_uart_byte = 8'h45; // E
                20: expected_uart_byte = 8'h53; // S
                21: expected_uart_byte = 8'h54; // T
                22: expected_uart_byte = 8'h21; // !
                23: expected_uart_byte = 8'h0a; // newline
                default: expected_uart_byte = 8'h00;
            endcase
        end
    endfunction

    // Clock signals - SoC chi con MOT clock he thong tu 2026-09-11 (clk 250 MHz)
    reg clk, rtc_clk;
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
    // Clock
    // ========================================================
    initial begin clk      = 0; forever #2.0   clk      = ~clk;      end // 250 MHz
    initial begin rtc_clk  = 0; forever #15258 rtc_clk  = ~rtc_clk;  end // ~32 kHz

    // ========================================================
    // Instantiate SoC
    // ========================================================
    // -------------------------------------------------------------------
    // MO HINH PAD - top_soc khong con port hai chieu, moi chan chia se duoc
    // dua ra thanh `_i` / `_o` / `_oe` de bat vao pad cell.  `_oe` la enable
    // MUC CAO.  Testbench dong vai tro pad de giu lai cac net `tri` cu.
    // -------------------------------------------------------------------
    wire        dut_i2c_scl_o, dut_i2c_scl_oe;
    wire        dut_i2c_sda_o, dut_i2c_sda_oe;
    wire [3:0]  dut_flash_io_o, dut_flash_io_oe;
    wire [15:0] dut_sdram_dq_o;
    wire        dut_sdram_dq_oe;

    // Pad: PA0 la UART0_TX, PA1 (UART0_RX) nhan vong lap uart_rx, cac pad khac
    // la GPIO vao. SPI/I2C/PWM khong con la chan top: lay tu ben trong uut.
    wire [31:0] pad_in_w = {gpio_in[31:2], uart_rx, gpio_in[0]};
    assign uart_tx        = gpio_out[0];
    assign pwm_out        = uut.pwm_out;
    assign spi_sck        = uut.spi_sck;
    assign spi_mosi       = uut.spi_mosi;
    assign spi_ss         = uut.spi_ss;
    assign dut_i2c_scl_o  = uut.i2c_scl_o;
    assign dut_i2c_scl_oe = uut.i2c_scl_oe;
    assign dut_i2c_sda_o  = uut.i2c_sda_o;
    assign dut_i2c_sda_oe = uut.i2c_sda_oe;

    assign i2c_scl     = dut_i2c_scl_oe    ? dut_i2c_scl_o    : 1'bz;
    assign i2c_sda     = dut_i2c_sda_oe    ? dut_i2c_sda_o    : 1'bz;
    assign flash_io[0] = dut_flash_io_oe[0] ? dut_flash_io_o[0] : 1'bz;
    assign flash_io[1] = dut_flash_io_oe[1] ? dut_flash_io_o[1] : 1'bz;
    assign flash_io[2] = dut_flash_io_oe[2] ? dut_flash_io_o[2] : 1'bz;
    assign flash_io[3] = dut_flash_io_oe[3] ? dut_flash_io_o[3] : 1'bz;
    assign sdram_dq    = dut_sdram_dq_oe   ? dut_sdram_dq_o   : 16'hzzzz;

    top_soc uut (
        .clk           (clk),
        .rtc_clk       (rtc_clk),
        .rst_n         (rst_n),

        .tck(tck), .trst_n(trst_n), .tms(tms), .tdi(tdi), .tdo(tdo),

        // 2026-09-11: 32 pad qua pinmux. Mac dinh sau reset PA0 = UART0_TX,
        // PA1 = UART0_RX - firmware (khong biet pinmux) van in ra PA0.
        .pad_in (pad_in_w),
        .pad_out(gpio_out),
        .pad_oe (gpio_oe),

        .flash_sck(flash_sck), 
        .flash_cs_n(flash_cs_n), 
        .flash_io_i(flash_io), .flash_io_o(dut_flash_io_o), .flash_io_oe(dut_flash_io_oe),

        .sdram_clk(sdram_clk), 
        .sdram_cke(sdram_cke), 
        .sdram_cs_n(sdram_cs_n),
        .sdram_ras_n(sdram_ras_n), 
        .sdram_cas_n(sdram_cas_n), 
        .sdram_we_n(sdram_we_n),
        .sdram_ba(sdram_ba), 
        .sdram_addr(sdram_addr), 
        .sdram_dq_i(sdram_dq), .sdram_dq_o(dut_sdram_dq_o), .sdram_dq_oe(dut_sdram_dq_oe),
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
        data_stall_count = 0;
        apb_busy_count = 0;
        last_pc = 32'hFFFF_FFFF;
        last_data_addr = 32'hFFFF_FFFF;
        last_data_rd = 1'b0;
        last_data_wr = 1'b0;
        last_wfi_sleep = 1'b0;
        last_apb_psel = 1'b0;
        uart_tx_count = 0;
        uart_mismatch = 1'b0;
        uart_done = 1'b0;
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            core_cycle_count <= 0;
            pc_stall_count <= 0;
            last_pc <= 32'hFFFF_FFFF;
            last_data_addr <= 32'hFFFF_FFFF;
            last_data_rd <= 1'b0;
            last_data_wr <= 1'b0;
            data_stall_count <= 0;
            last_wfi_sleep <= 1'b0;
            uart_tx_count <= 0;
            uart_mismatch <= 1'b0;
            uart_done <= 1'b0;
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

            if (uut.cpu_data_rd_req || uut.cpu_data_wr_req) begin
                if (uut.cpu_data_stall) begin
                    data_stall_count <= data_stall_count + 1;
                end else begin
                    data_stall_count <= 0;
                end

                if ((uut.cpu_data_addr !== last_data_addr) ||
                    (uut.cpu_data_rd_req !== last_data_rd) ||
                    (uut.cpu_data_wr_req !== last_data_wr) ||
                    (data_stall_count == 0) ||
                    (data_stall_count == 100) ||
                    (data_stall_count == 1000) ||
                    (data_stall_count == 10000)) begin
                    $display("[TB][D-BUS] t=%0t stall_cnt=%0d rd=%b wr=%b addr=%08h wdata=%08h rdata=%08h hit=%b stall=%b size=%0d",
                             $time, data_stall_count, uut.cpu_data_rd_req, uut.cpu_data_wr_req,
                             uut.cpu_data_addr, uut.cpu_data_wdata, uut.cpu_data_rdata,
                             uut.cpu_data_hit, uut.cpu_data_stall, uut.cpu_data_size);
                    if (debug_fd != 0) begin
                        $fdisplay(debug_fd, "[TB][D-BUS] t=%0t stall_cnt=%0d rd=%b wr=%b addr=%08h wdata=%08h rdata=%08h hit=%b stall=%b size=%0d",
                                  $time, data_stall_count, uut.cpu_data_rd_req, uut.cpu_data_wr_req,
                                  uut.cpu_data_addr, uut.cpu_data_wdata, uut.cpu_data_rdata,
                                  uut.cpu_data_hit, uut.cpu_data_stall, uut.cpu_data_size);
                    end
                end

                if (data_stall_count == 20000) begin
                    $display("[TB][ERROR] D-BUS timeout t=%0t pc=%08h addr=%08h rd=%b wr=%b wdata=%08h",
                             $time, uut.u_core.pc_reg, uut.cpu_data_addr,
                             uut.cpu_data_rd_req, uut.cpu_data_wr_req, uut.cpu_data_wdata);
                    if (debug_fd != 0) begin
                        $fdisplay(debug_fd, "[TB][ERROR] D-BUS timeout t=%0t pc=%08h addr=%08h rd=%b wr=%b wdata=%08h",
                                  $time, uut.u_core.pc_reg, uut.cpu_data_addr,
                                  uut.cpu_data_rd_req, uut.cpu_data_wr_req, uut.cpu_data_wdata);
                        $fclose(debug_fd);
                    end
                    $finish;
                end

                last_data_addr <= uut.cpu_data_addr;
                last_data_rd <= uut.cpu_data_rd_req;
                last_data_wr <= uut.cpu_data_wr_req;
            end else begin
                data_stall_count <= 0;
                last_data_rd <= 1'b0;
                last_data_wr <= 1'b0;
            end

            if (uut.wfi_sleep_state && !last_wfi_sleep) begin
                $display("[TB][WFI] t=%0t CPU entered WFI at pc=%08h", $time, uut.u_core.pc_reg);
                if (debug_fd != 0) begin
                    $fdisplay(debug_fd, "[TB][WFI] t=%0t CPU entered WFI at pc=%08h", $time, uut.u_core.pc_reg);
                end
                if (uart_done && !uart_mismatch) begin
                    $display("[TB][PASS] t=%0t UART message matched and CPU reached WFI", $time);
                    if (debug_fd != 0) begin
                        $fdisplay(debug_fd, "[TB][PASS] t=%0t UART message matched and CPU reached WFI", $time);
                        $fclose(debug_fd);
                    end
                    $finish;
                end
            end
            last_wfi_sleep <= uut.wfi_sleep_state;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            apb_busy_count <= 0;
            last_apb_psel <= 1'b0;
        end else begin
            if (uut.apb_psel && !last_apb_psel) begin
                $display("[TB][APB-START] t=%0t addr=%08h write=%b data=%08h psel7=%b pen7=%b pready7=%b bridge_fsm=%0d",
                         $time, uut.apb_paddr, uut.apb_pwrite, uut.apb_pwdata,
                         uut.psel_7, uut.penable_7, uut.pready_7, uut.u_axi_to_apb.apb_fsm);
                if (debug_fd != 0) begin
                    $fdisplay(debug_fd, "[TB][APB-START] t=%0t addr=%08h write=%b data=%08h psel7=%b pen7=%b pready7=%b bridge_fsm=%0d",
                              $time, uut.apb_paddr, uut.apb_pwrite, uut.apb_pwdata,
                              uut.psel_7, uut.penable_7, uut.pready_7, uut.u_axi_to_apb.apb_fsm);
                end
            end

            if (uut.apb_psel && !uut.apb_pready) begin
                apb_busy_count <= apb_busy_count + 1;
                if (apb_busy_count == 10 || apb_busy_count == 100 || apb_busy_count == 1000) begin
                    $display("[TB][APB-BUSY] t=%0t busy=%0d addr=%08h pen=%b wr=%b pready=%b psel7=%b pen7=%b pready7=%b clk_gate=%02h fsm=%0d cmd_empty=%b resp_empty=%b",
                             $time, apb_busy_count, uut.apb_paddr, uut.apb_penable,
                             uut.apb_pwrite, uut.apb_pready, uut.psel_7, uut.penable_7,
                             uut.pready_7, uut.u_apb_syscon.clk_gate_reg,
                             uut.u_axi_to_apb.apb_fsm, uut.u_axi_to_apb.cmd_fifo_empty,
                             uut.u_axi_to_apb.resp_fifo_empty);
                    if (debug_fd != 0) begin
                        $fdisplay(debug_fd, "[TB][APB-BUSY] t=%0t busy=%0d addr=%08h pen=%b wr=%b pready=%b psel7=%b pen7=%b pready7=%b clk_gate=%02h fsm=%0d cmd_empty=%b resp_empty=%b",
                                  $time, apb_busy_count, uut.apb_paddr, uut.apb_penable,
                                  uut.apb_pwrite, uut.apb_pready, uut.psel_7, uut.penable_7,
                                  uut.pready_7, uut.u_apb_syscon.clk_gate_reg,
                                  uut.u_axi_to_apb.apb_fsm, uut.u_axi_to_apb.cmd_fifo_empty,
                                  uut.u_axi_to_apb.resp_fifo_empty);
                    end
                end
            end else begin
                apb_busy_count <= 0;
            end
            last_apb_psel <= uut.apb_psel;
        end

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
                    if (uart_tx_count < UART_EXPECT_LEN) begin
                        if (((^uut.apb_pwdata[7:0]) === 1'bx) ||
                            (uut.apb_pwdata[7:0] !== expected_uart_byte(uart_tx_count))) begin
                            $display("[TB][ERROR] UART mismatch idx=%0d got=0x%02h expected=0x%02h",
                                     uart_tx_count, uut.apb_pwdata[7:0],
                                     expected_uart_byte(uart_tx_count));
                            if (debug_fd != 0) begin
                                $fdisplay(debug_fd, "[TB][ERROR] UART mismatch idx=%0d got=0x%02h expected=0x%02h",
                                          uart_tx_count, uut.apb_pwdata[7:0],
                                          expected_uart_byte(uart_tx_count));
                                $fclose(debug_fd);
                            end
                            uart_mismatch <= 1'b1;
                            $finish;
                        end

                        if (uart_tx_count == UART_EXPECT_LEN - 1) begin
                            $display("[TB][UART-DONE] t=%0t matched HELLO RISC-V UART TEST!", $time);
                            if (debug_fd != 0) begin
                                $fdisplay(debug_fd, "[TB][UART-DONE] t=%0t matched HELLO RISC-V UART TEST!", $time);
                            end
                            uart_done <= 1'b1;
                        end

                        uart_tx_count <= uart_tx_count + 1;
                    end else begin
                        $display("[TB][ERROR] Unexpected UART byte idx=%0d got=0x%02h",
                                 uart_tx_count, uut.apb_pwdata[7:0]);
                        if (debug_fd != 0) begin
                            $fdisplay(debug_fd, "[TB][ERROR] Unexpected UART byte idx=%0d got=0x%02h",
                                      uart_tx_count, uut.apb_pwdata[7:0]);
                            $fclose(debug_fd);
                        end
                        uart_mismatch <= 1'b1;
                        $finish;
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

        // -------------------------------------------------------------------
        // NAP FIRMWARE
        //
        // axi_rom KHONG con mang `rom_memory` de $readmemh ghi de: no da thanh
        // mot bang `case` tong hop duoc, sinh tu boot.mem thanh
        // rtl/memory/boot_rom_image.vh boi tcl/genus.tcl.  Vi vay firmware phai
        // duoc BAKE VAO truoc khi bien dich, khong nap duoc luc chay:
        //
        //     python rtl/tests/gen_boot_rom.py <file.mem> <thu_muc_include_sim>
        //     xvlog -i <thu_muc_include_sim> ...      # dat TRUOC rtl/ tren -i
        //
        // rtl/tests/run_soc_sim.sh lam san viec nay.  `firmware_hex` chi con la
        // nhan de doc log cho biet ban ROM nao dang chay.
        // -------------------------------------------------------------------
        $display("[TB][BOOT] ROM image compiled in (expected source: %0s)", firmware_hex);
        if (debug_fd != 0) begin
            $fdisplay(debug_fd, "[TB][BOOT] ROM image compiled in (expected source: %0s)", firmware_hex);
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
