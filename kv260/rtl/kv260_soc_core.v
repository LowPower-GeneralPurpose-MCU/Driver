`timescale 1ns / 1ps

// =============================================================================
// kv260_soc_core - top_soc + phan "board glue" KHONG phu thuoc PS
//
// Tach rieng khoi kv260_top de mo phong duoc bang XSim ma khong can khoi Zynq
// MPSoC: testbench (sim/tb_kv260_core.v) cap thang sys_clk + reset vao day.
// kv260_top chi them PS (pl_clk0/pl_resetn0), MMCM va bo dem I/O.
//
// Nhung gi khoi nay lam thay cho pad ring / mach ngoai cua chip ASIC:
//   * dong bo reset: rst_n_async (PS reset AND MMCM locked) -> 2FF tren sys_clk
//   * rtc_clk 32.768 kHz: chia tu sys_clk (top_soc chi LAY MAU chan nay roi bat
//     canh, nen sai so vai ppm khong anh huong gi ngoai mtime)
//   * 32 pad PA0..PA31: chi PA0 (UART0_TX), PA1 (UART0_RX), PA2, PA3 (GPIO) ra
//     chan board; pad con lai doc 0
//   * QSPI flash: board KHONG co flash noi vao PL -> MISO keo len 1 (ROM doc
//     0xFFFF_FFFF, khong co header thi vao vong park). Firmware duoc bake thang
//     vao boot ROM (xem fw/ va scripts/), nen duong flash khong dung toi.
//   * SDRAM: KV260 khong co SDR SDRAM tren PL -> dq_i = 0, chan ra bo trong.
//     Firmware khong duoc truy cap 0x8000_0000.
// =============================================================================
module kv260_soc_core #(
    parameter integer SYS_CLK_HZ = 50_000_000,
    parameter integer RTC_HZ     = 32_768
)(
    input  wire       sys_clk,
    input  wire       rst_n_async,   // muc thap = reset, bat dong bo

    // JTAG cua Debug Module RISC-V (khong phai JTAG cua Zynq)
    input  wire       tck,
    input  wire       tms,
    input  wire       tdi,
    output wire       tdo,

    // UART0 (PA0 / PA1)
    output wire       uart_tx,
    input  wire       uart_rx,

    // GPIO PA2, PA3 - bo IOBUF nam o kv260_top
    input  wire [1:0] gpio_i,
    output wire [1:0] gpio_o,
    output wire [1:0] gpio_oe
);

    // -------------------------------------------------------------------------
    // Reset: assert bat dong bo, nha dong bo voi sys_clk.
    // top_soc con tu dong bo + keo dai reset ben trong (reset_sync, 64 chu ky).
    // -------------------------------------------------------------------------
    (* ASYNC_REG = "TRUE" *) reg [2:0] rst_pipe;
    always @(posedge sys_clk or negedge rst_n_async) begin
        if (!rst_n_async) rst_pipe <= 3'b000;
        else              rst_pipe <= {rst_pipe[1:0], 1'b1};
    end
    wire soc_rst_n = rst_pipe[2];

    // -------------------------------------------------------------------------
    // RTC 32.768 kHz tu sys_clk. 50 MHz -> nua chu ky 763 -> 32.765 kHz.
    // -------------------------------------------------------------------------
    localparam integer RTC_HALF = (SYS_CLK_HZ + RTC_HZ) / (2 * RTC_HZ);
    localparam integer RTC_W    = $clog2(RTC_HALF + 1);

    reg [RTC_W-1:0] rtc_cnt;
    reg             rtc_clk_r;
    always @(posedge sys_clk or negedge soc_rst_n) begin
        if (!soc_rst_n) begin
            rtc_cnt   <= {RTC_W{1'b0}};
            rtc_clk_r <= 1'b0;
        end else if (rtc_cnt == RTC_HALF - 1) begin
            rtc_cnt   <= {RTC_W{1'b0}};
            rtc_clk_r <= ~rtc_clk_r;
        end else begin
            rtc_cnt   <= rtc_cnt + 1'b1;
        end
    end

    // -------------------------------------------------------------------------
    // Pad
    // -------------------------------------------------------------------------
    wire [31:0] pad_in;
    wire [31:0] pad_out;
    wire [31:0] pad_oe;

    assign pad_in = {28'b0, gpio_i, uart_rx, 1'b1};

    // PA0 la dau ra UART0_TX sau reset. Khi pad khong dan (oe = 0) giu muc 1 =
    // trang thai nghi cua UART, de bo USB-UART khong doc ra byte rac.
    assign uart_tx = pad_oe[0] ? pad_out[0] : 1'b1;

    assign gpio_o  = pad_out[3:2];
    assign gpio_oe = pad_oe[3:2];

    // -------------------------------------------------------------------------
    // SoC
    // -------------------------------------------------------------------------
    wire [3:0]  flash_io_o_unused, flash_io_oe_unused;
    wire        flash_sck_unused, flash_cs_n_unused;
    wire [15:0] sdram_dq_o_unused;
    wire [12:0] sdram_addr_unused;
    wire [1:0]  sdram_ba_unused, sdram_dqm_unused;
    wire        sdram_clk_unused, sdram_cke_unused, sdram_cs_n_unused;
    wire        sdram_ras_n_unused, sdram_cas_n_unused, sdram_we_n_unused;
    wire        sdram_dq_oe_unused;

    top_soc u_soc (
        .clk         (sys_clk),
        .rtc_clk     (rtc_clk_r),
        .rst_n       (soc_rst_n),

        .tck         (tck),
        .trst_n      (rst_n_async),
        .tms         (tms),
        .tdi         (tdi),
        .tdo         (tdo),

        .pad_in      (pad_in),
        .pad_out     (pad_out),
        .pad_oe      (pad_oe),

        .flash_sck   (flash_sck_unused),
        .flash_cs_n  (flash_cs_n_unused),
        .flash_io_i  (4'b1111),
        .flash_io_o  (flash_io_o_unused),
        .flash_io_oe (flash_io_oe_unused),

        .sdram_clk   (sdram_clk_unused),
        .sdram_cke   (sdram_cke_unused),
        .sdram_cs_n  (sdram_cs_n_unused),
        .sdram_ras_n (sdram_ras_n_unused),
        .sdram_cas_n (sdram_cas_n_unused),
        .sdram_we_n  (sdram_we_n_unused),
        .sdram_ba    (sdram_ba_unused),
        .sdram_addr  (sdram_addr_unused),
        .sdram_dq_i  (16'h0000),
        .sdram_dq_o  (sdram_dq_o_unused),
        .sdram_dq_oe (sdram_dq_oe_unused),
        .sdram_dqm   (sdram_dqm_unused)
    );

endmodule
