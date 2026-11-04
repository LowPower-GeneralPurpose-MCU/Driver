`timescale 1ns / 1ps

// =============================================================================
// kv260_top - top cua bitstream KV260
//
//   PS (Zynq MPSoC) --pl_clk0 100 MHz--> MMCM --SYS_CLK_MHZ--> BUFG --> SoC
//                   --pl_resetn0------->  AND MMCM locked ----> reset SoC
//
// KV260 khong co thach anh rieng cho PL dung san, nen clock lay tu PS. Khoi PS
// nam trong block design `kv260_ps` (scripts/build.tcl tao); o day chi goi
// wrapper cua no. Linux (xmutil + overlay .dtbo) dat tan so pl_clk0 = 100 MHz
// va nha pl_resetn0 khi nap bitstream.
//
// Tat ca I/O ra PMOD J2 - xem constr/kv260_pmod.xdc cho chan cu the.
// =============================================================================
module kv260_top #(
    parameter integer SYS_CLK_MHZ = 50     // 1200 / SYS_CLK_MHZ phai la boi 0.125
)(
    output wire       pmod_uart_tx,    // PA0  UART0_TX  -> chan RX cua USB-UART
    input  wire       pmod_uart_rx,    // PA1  UART0_RX  <- chan TX cua USB-UART
    input  wire       pmod_jtag_tck,
    input  wire       pmod_jtag_tms,
    input  wire       pmod_jtag_tdi,
    output wire       pmod_jtag_tdo,
    inout  wire [1:0] pmod_gpio        // PA3, PA2
);

    // -------------------------------------------------------------------------
    // PS: chi lay pl_clk0 va pl_resetn0
    // -------------------------------------------------------------------------
    wire pl_clk0;
    wire pl_resetn0;

    kv260_ps_wrapper u_ps (
        .pl_clk0    (pl_clk0),
        .pl_resetn0 (pl_resetn0)
    );

    // -------------------------------------------------------------------------
    // MMCM: 100 MHz x 12 = VCO 1200 MHz (dai hop le 800-1600 MHz cho -2LV),
    // CLKOUT0 = 1200 / SYS_CLK_MHZ.  50 MHz -> chia 24.
    // -------------------------------------------------------------------------
    localparam real CLKOUT0_DIV = 1200.0 / SYS_CLK_MHZ;

    wire mmcm_fb;
    wire mmcm_clk0;
    wire mmcm_locked;
    wire sys_clk;

    MMCME4_BASE #(
        .BANDWIDTH        ("OPTIMIZED"),
        .CLKIN1_PERIOD    (10.0),
        .DIVCLK_DIVIDE    (1),
        .CLKFBOUT_MULT_F  (12.0),
        .CLKFBOUT_PHASE   (0.0),
        .CLKOUT0_DIVIDE_F (CLKOUT0_DIV),
        .CLKOUT0_PHASE    (0.0),
        .CLKOUT0_DUTY_CYCLE (0.5),
        .STARTUP_WAIT     ("FALSE")
    ) u_mmcm (
        .CLKIN1   (pl_clk0),
        .CLKFBIN  (mmcm_fb),
        .CLKFBOUT (mmcm_fb),
        .CLKOUT0  (mmcm_clk0),
        .LOCKED   (mmcm_locked),
        .PWRDWN   (1'b0),
        .RST      (~pl_resetn0)
    );

    BUFG u_sys_bufg (.I(mmcm_clk0), .O(sys_clk));

    // -------------------------------------------------------------------------
    // TCK: chan PMOD khong phai chan clock chuyen dung -> IBUF + BUFG tuong
    // minh, constr/kv260_timing.xdc dat CLOCK_DEDICATED_ROUTE FALSE tren net
    // `tck_ibuf`. 10 MHz tren mang clock thuong la du.
    // -------------------------------------------------------------------------
    wire tck_ibuf;
    wire tck;
    IBUF u_tck_ibuf (.I(pmod_jtag_tck), .O(tck_ibuf));
    BUFG u_tck_bufg (.I(tck_ibuf),      .O(tck));

    // -------------------------------------------------------------------------
    // GPIO PA2/PA3: hai chieu
    // -------------------------------------------------------------------------
    wire [1:0] gpio_i, gpio_o, gpio_oe;

    genvar g;
    generate
        for (g = 0; g < 2; g = g + 1) begin : G_GPIO
            IOBUF u_iobuf (
                .IO (pmod_gpio[g]),
                .I  (gpio_o[g]),
                .O  (gpio_i[g]),
                .T  (~gpio_oe[g])
            );
        end
    endgenerate

    // -------------------------------------------------------------------------
    // SoC + glue
    // -------------------------------------------------------------------------
    kv260_soc_core #(
        .SYS_CLK_HZ (SYS_CLK_MHZ * 1_000_000)
    ) u_core (
        .sys_clk     (sys_clk),
        .rst_n_async (pl_resetn0 & mmcm_locked),
        .tck         (tck),
        .tms         (pmod_jtag_tms),
        .tdi         (pmod_jtag_tdi),
        .tdo         (pmod_jtag_tdo),
        .uart_tx     (pmod_uart_tx),
        .uart_rx     (pmod_uart_rx),
        .gpio_i      (gpio_i),
        .gpio_o      (gpio_o),
        .gpio_oe     (gpio_oe)
    );

endmodule
