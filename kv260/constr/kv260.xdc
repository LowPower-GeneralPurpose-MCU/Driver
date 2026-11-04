## =============================================================================
## KV260 - chan PMOD J2 + timing cho MCU SoC
##
## !!! KIEM TRA CHAN TRUOC KHI CAM DAY !!!
## Board file KV260 (kv260_carrier 1.3) KHONG khai bao PMOD. Bang duoi lay tu XDC
## cong dong cho KV260 (hackster.io, "PMOD IP development for Kria KV260"), roi
## doi chieu voi kv260_som/1.4/part0_pins.xml cua Vivado:
##   E12=som240_1_b21  D11=som240_1_b22  B11=som240_1_c22
##   E10=som240_1_d20  D10=som240_1_d21  C11=som240_1_d22   (6/8 khop)
##   H12, B10 khong co trong part0_pins.xml (file chi liet ke chan ma board
##   interface dung) - chua doi chieu duoc.
## So chan PMOD ("pin N") theo cach danh so cua nguon tren; hay xac nhan voi so
## do carrier KV260 (UG1089) / chu in tren board truoc khi noi USB-UART va JTAG.
## Tat ca la bank HD 3.3 V -> LVCMOS33. Dung adapter 3.3 V, KHONG dung 5 V.
## =============================================================================

## ---- UART0 (PA0 TX / PA1 RX) -> USB-UART 3.3 V: TX<->RX cheo nhau, chung GND
set_property -dict {PACKAGE_PIN H12 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports pmod_uart_tx]  ;# PMOD pin 1
set_property -dict {PACKAGE_PIN B10 IOSTANDARD LVCMOS33 PULLTYPE PULLUP}  [get_ports pmod_uart_rx]  ;# PMOD pin 2

## ---- JTAG cua Debug Module RISC-V (OpenOCD), khong phai JTAG cua Zynq
set_property -dict {PACKAGE_PIN E10 IOSTANDARD LVCMOS33 PULLTYPE PULLDOWN} [get_ports pmod_jtag_tck] ;# PMOD pin 3
set_property -dict {PACKAGE_PIN E12 IOSTANDARD LVCMOS33 PULLTYPE PULLUP}   [get_ports pmod_jtag_tms] ;# PMOD pin 4
set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33 PULLTYPE PULLUP}   [get_ports pmod_jtag_tdi] ;# PMOD pin 5
set_property -dict {PACKAGE_PIN D11 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports pmod_jtag_tdo] ;# PMOD pin 6

## ---- GPIO: PA2 (firmware nhay LED 1 Hz), PA3 (dau vao, keo xuong)
set_property -dict {PACKAGE_PIN C11 IOSTANDARD LVCMOS33 DRIVE 8 SLEW SLOW} [get_ports {pmod_gpio[0]}] ;# PMOD pin 7 = PA2
set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33 PULLTYPE PULLDOWN} [get_ports {pmod_gpio[1]}] ;# PMOD pin 8 = PA3

## =============================================================================
## Timing
## =============================================================================
## sys_clk = MMCM CLKOUT0, Vivado tu suy ra tu clk_pl_0 (XDC cua khoi PS).
## 12 BUFGCE cua clock gate KHONG tao clock moi - cung clock voi sys_clk.

## TCK <= 10 MHz. Chan PMOD khong phai chan clock chuyen dung.
create_clock -period 100.000 -name jtag_tck [get_ports pmod_jtag_tck]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets tck_ibuf]

## CDC duy nhat la handshake DMI (req/ack qua 2-3 FF trong rv_jtag_dtm /
## rv_debug_module_sba, bus du lieu giu on dinh trong luc bat tay).
set_clock_groups -asynchronous \
    -group [get_clocks jtag_tck] \
    -group [get_clocks -of_objects [get_pins u_mmcm/CLKOUT0]]

## JTAG: adapter doi TMS/TDI o canh XUONG cua TCK va lay mau TDO o canh LEN.
set_input_delay  -clock jtag_tck -clock_fall -max 10.000 [get_ports {pmod_jtag_tms pmod_jtag_tdi}]
set_input_delay  -clock jtag_tck -clock_fall -min  0.000 [get_ports {pmod_jtag_tms pmod_jtag_tdi}]
set_output_delay -clock jtag_tck -max 10.000 [get_ports pmod_jtag_tdo]
set_output_delay -clock jtag_tck -min  0.000 [get_ports pmod_jtag_tdo]

## UART va GPIO bat dong bo voi moi clock: RTL da co 2FF o dau vao
## (uart_rx, GPIO sync_f2), dau ra khong co quan he pha voi ben ngoai.
set_false_path -from [get_ports {pmod_uart_rx pmod_gpio[*]}]
set_false_path -to   [get_ports {pmod_uart_tx pmod_gpio[*] }]

## Cau hinh bitstream
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
