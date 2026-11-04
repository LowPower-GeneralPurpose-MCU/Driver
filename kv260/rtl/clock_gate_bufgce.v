`timescale 1ns / 1ps

// =============================================================================
// clock_gate - BAN FPGA (UltraScale+ / KV260)
//
// Thay the 1:1 cho genus/rtl/utils/clock_gate.v trong build FPGA: CUNG ten
// module, CUNG cong. Script build/sim bo file golden ra khoi danh sach va dua
// file nay vao, nen RTL golden (luong ASIC) khong bi sua mot dong nao.
//
// Vi sao khong dung ban golden tren FPGA: ban golden la latch + cong AND. Tren
// FPGA ca hai thanh LUT/LDCE roi, clock da gate di tren mang dinh tuyen thuong
// (khong phai mang clock), glitch va skew khong kiem soat duoc.
//
// BUFGCE voi CE_TYPE = "SYNC" la DUNG cau truc do o dang phan cung: model unisim
// (Vivado/data/verilog/src/unisims/BUFGCE.v) chot CE khi I THAP roi AND voi I -
// dung nghia "latch trong suot khi clock thap + AND" cua ban ASIC. Nen ngu nghia
// gating giu nguyen tung chu ky, ke ca cg_cpu ma WFI dua vao de dung CPU.
//
// Ghi chu tai nguyen: top_soc co 12 cong (cg_cpu, cg_dbg, cg_pwm, cg_gpio,
// cg_cordic, cg_ascon, cg_uart, cg_spi, cg_i2c, cg_uart1, cg_tim0, cg_tim1) ->
// 12 BUFGCE, cong them clk he thong, tck va pl_clk0 - con xa gioi han clock
// toan cuc cua XCK26.
// =============================================================================
module clock_gate (
    input  wire clk_in,
    input  wire en,
    input  wire test_en,
    output wire clk_out
);

    BUFGCE #(
        .CE_TYPE        ("SYNC"),
        .IS_CE_INVERTED (1'b0),
        .IS_I_INVERTED  (1'b0),
        .SIM_DEVICE     ("ULTRASCALE_PLUS")
    ) u_bufgce (
        .O  (clk_out),
        .CE (en | test_en),
        .I  (clk_in)
    );

endmodule
