`timescale 1ns / 1ps

// =============================================================================
// tb_kv260_core - mo phong kv260_soc_core voi firmware fw/ bake trong boot ROM
//
// Kiem o MUC CHAN, nhu bo USB-UART tren board se thay:
//   1. UART TX duoc giai ma o 115200 baud; phai co "Hello KV260"
//   2. GPIO out: sau banner PA2 phai la output (gpio_oe[0] = 1)
//   3. UART RX : gui 'K' -> phai nhan lai 'K' (echo)
//   4. GPIO in : dat PA3 = 1 -> phai nhan "PA3=1"
// Bat ky trap nao cua core -> FAIL ngay.
// =============================================================================
module tb_kv260_core;

    localparam integer SYS_CLK_HZ = 50_000_000;
    localparam integer BAUD       = 115_200;
    // Firmware chia nguyen: clk / (clk / baud) - dung dung chu ky bit that.
    localparam real    BIT_NS     = 1.0e9 * (SYS_CLK_HZ / BAUD) / SYS_CLK_HZ;
    localparam real    TIMEOUT_NS = 15.0e6;

    reg        clk = 1'b0;
    reg        rst_n = 1'b0;
    reg        uart_rx = 1'b1;
    reg  [1:0] gpio_i = 2'b00;
    wire       uart_tx;
    wire       tdo;
    wire [1:0] gpio_o, gpio_oe;

    always #10.0 clk = ~clk;   // 50 MHz

    kv260_soc_core #(.SYS_CLK_HZ(SYS_CLK_HZ)) u_dut (
        .sys_clk     (clk),
        .rst_n_async (rst_n),
        .tck         (1'b0),
        .tms         (1'b1),
        .tdi         (1'b1),
        .tdo         (tdo),
        .uart_tx     (uart_tx),
        .uart_rx     (uart_rx),
        .gpio_i      (gpio_i),
        .gpio_o      (gpio_o),
        .gpio_oe     (gpio_oe)
    );

    // -------------------------------------------------------------------------
    // Giai ma UART TX
    // -------------------------------------------------------------------------
    reg [8*16-1:0] tail = 0;     // 16 ky tu cuoi cung nhan duoc
    reg [7:0]      rx_byte;
    integer        n_chars = 0;
    reg            framing_err = 1'b0;
    event          char_ev;

    integer i;
    always begin
        @(negedge uart_tx);
        #(BIT_NS * 1.5);
        for (i = 0; i < 8; i = i + 1) begin
            rx_byte[i] = uart_tx;
            #(BIT_NS);
        end
        if (uart_tx !== 1'b1) begin
            framing_err = 1'b1;
            $display("[TB][FAIL] t=%0t stop bit sai sau byte 0x%02h", $time, rx_byte);
        end
        tail    = {tail[8*15-1:0], rx_byte};
        n_chars = n_chars + 1;
        if (rx_byte == 8'h0A)      $write("\n");
        else if (rx_byte != 8'h0D) $write("%c", rx_byte);
        -> char_ev;
    end

    task wait_tail;
        input [8*16-1:0] pat;
        input integer    len;
        reg   [8*16-1:0] mask;
        begin
            mask = (len >= 16) ? {128{1'b1}} : ((128'd1 << (8 * len)) - 1);
            while ((tail & mask) !== (pat & mask)) @(char_ev);
        end
    endtask

    task uart_send;
        input [7:0] b;
        integer k;
        begin
            uart_rx = 1'b0; #(BIT_NS);
            for (k = 0; k < 8; k = k + 1) begin
                uart_rx = b[k]; #(BIT_NS);
            end
            uart_rx = 1'b1; #(BIT_NS);
        end
    endtask

    // -------------------------------------------------------------------------
    // Monitor slave CLINT (s5): in moi AR va R de thay ngay loi SLVERR/DECERR
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (u_dut.u_soc.s5_arvalid && u_dut.u_soc.s5_arready)
            $display("[TB][CLINT] t=%0t AR addr=%08h size=%0d len=%0d", $time,
                     u_dut.u_soc.s5_araddr, u_dut.u_soc.s5_arsize, u_dut.u_soc.s5_arlen);
        if (u_dut.u_soc.s5_rvalid && u_dut.u_soc.s5_rready)
            $display("[TB][CLINT] t=%0t R  resp=%b data=%08h", $time,
                     u_dut.u_soc.s5_rresp, u_dut.u_soc.s5_rdata);
        if (u_dut.u_soc.u_clint.u_regfile.req_valid_i && u_dut.u_soc.u_clint.u_regfile.rsp_error_o)
            $display("[TB][CLINT] t=%0t regfile addr_error req_addr=%08h write=%b", $time,
                     u_dut.u_soc.u_clint.u_regfile.req_addr_i, u_dut.u_soc.u_clint.u_regfile.req_write_i);
        // Moi phan hoi loi tu CLINT = FAIL (ban sua dia chi 2026-11-04)
        if ((u_dut.u_soc.s5_rvalid && u_dut.u_soc.s5_rready && u_dut.u_soc.s5_rresp != 2'b00) ||
            (u_dut.u_soc.s5_bvalid && u_dut.u_soc.s5_bready && u_dut.u_soc.s5_bresp != 2'b00)) begin
            $display("\n[TB][FAIL] t=%0t CLINT tra loi rresp=%b bresp=%b", $time,
                     u_dut.u_soc.s5_rresp, u_dut.u_soc.s5_bresp);
            $finish;
        end
    end

    // -------------------------------------------------------------------------
    // Trap cua core = FAIL
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst_n && u_dut.u_soc.u_core.trap_enter === 1'b1) begin
            $display("\n[TB][FAIL] t=%0t TRAP cause=%08h pc=%08h", $time,
                     u_dut.u_soc.u_core.trap_cause, u_dut.u_soc.u_core.trap_pc_value);
            $finish;
        end
    end

    initial begin
        #(TIMEOUT_NS);
        $display("\n[TB][FAIL] TIMEOUT sau %0.1f ms, da nhan %0d ky tu", TIMEOUT_NS / 1.0e6, n_chars);
        $finish;
    end

    // -------------------------------------------------------------------------
    // Kich ban
    // -------------------------------------------------------------------------
    initial begin
        $display("[TB] bit UART = %0.1f ns", BIT_NS);
        #(200.0);
        rst_n = 1'b1;

        wait_tail("Hello KV260", 11);
        $display("\n[TB][OK] t=%0t banner 'Hello KV260'", $time);

        wait_tail("CLINT OK", 8);
        $display("\n[TB][OK] t=%0t CLINT: mtime tang, mtimecmp/msip ghi-doc lai dung", $time);

        wait_tail("echo.\015\012", 7);
        if (gpio_oe[0] !== 1'b1) begin
            $display("[TB][FAIL] t=%0t PA2 chua la output (gpio_oe=%b)", $time, gpio_oe);
            $finish;
        end
        $display("[TB][OK] t=%0t PA2 la output", $time);

        uart_send("K");
        wait_tail("K", 1);
        $display("\n[TB][OK] t=%0t echo 'K'", $time);

        gpio_i[1] = 1'b1;      // PA3
        wait_tail("PA3=1\015\012", 7);
        $display("[TB][OK] t=%0t PA3=1 duoc doc", $time);

        if (framing_err) $display("[TB][FAIL] co loi stop bit");
        else             $display("[TB][PASS] kv260_soc_core: UART TX/RX, GPIO in/out OK (%0d ky tu)", n_chars);
        $finish;
    end

endmodule
