# MCU SoC trên Kria KV260 — hướng dẫn

Port FPGA cho SoC RISC-V golden (`Script_Backend/Asap7/run_workspace/mcu/genus/rtl`). Thư mục này nằm trong repo `Driver` (`Driver/kv260`) và cần `Script_Backend` nằm cạnh `Driver` (cùng thư mục `MCU_LowPower_GeneralPurpose`).

- Mọi thứ riêng của FPGA nằm trong `kv260/`. RTL golden chỉ bị sửa đúng một chỗ, là lỗi địa chỉ CLINT (mục 5), và bản sửa đó áp dụng cho cả ASIC.
- Build dùng project riêng `kv260/vivado/mcu_kv260.xpr` (tạo lại mỗi lần chạy). `MCU_SOC_IOT.xpr` không bị đụng tới.

## 0. Trạng thái (2026-11-04)

| Phần | Trạng thái |
|---|---|
| Firmware bring-up (`fw/`) | Build OK bằng GCC của Vitis, 1.3 KB |
| Mô phỏng `scripts/sim_core.sh` | **PASS**: UART TX giải mã đúng 115200, echo RX, GPIO PA2 out, PA3 in |
| Build Vivado `scripts/build.tcl` | **Chưa chạy hết.** Đã chạy tới bước tạo block design PS (board preset KV260 áp xong, chưa có lỗi) thì tạm dừng theo yêu cầu. Synth, impl, timing và bitstream chưa kiểm |
| Overlay `.dtsi` + `xmutil` | Chưa thử trên board |
| Chân PMOD | 6/8 đã đối chiếu với board file; **H12 và B10 chưa đối chiếu** (xem mục 5) |

## 1. Cấu trúc thư mục

```
kv260/
  rtl/clock_gate_bufgce.v     clock_gate bản FPGA (BUFGCE), thay utils/clock_gate.v
  rtl/kv260_soc_core.v        top_soc + reset sync, RTC 32.768 kHz, nối pad, tie flash/SDRAM
  rtl/kv260_top.v             PS (pl_clk0/pl_resetn0) -> MMCM -> SoC, IOBUF ra PMOD
  constr/kv260.xdc            chân PMOD + timing (TCK, JTAG I/O, false path UART/GPIO)
  constr/kv260_trng_impl.xdc  ALLOW_COMBINATORIAL_LOOPS cho ring oscillator TRNG
  fw/                         firmware bring-up, bake thẳng vào boot ROM
  sim/tb_kv260_core.v         testbench mức chân
  scripts/sim_core.sh         XSim: RTL golden + glue + firmware
  scripts/build.tcl           project + block design PS + synth/impl/bitstream + .bit.bin + .xsa
  overlay/                    mcu_kv260.dtsi + shell.json cho xmutil
  out/                        (sinh ra) bitstream, xsa, reports/
```

Sơ đồ clock và reset:

```
PS (Zynq MPSoC) --pl_clk0 100 MHz--> MMCM x12 /24 --> BUFG --> sys_clk 50 MHz --> top_soc
                                                              \-> 12 BUFGCE (clock gate cg_*)
PS pl_resetn0 AND MMCM locked --> 3FF reset sync --> top_soc rst_n (top_soc tự kéo dài thêm 64 chu kỳ)
```

## 2. Chuẩn bị

### 2.1 Trên PC

| Thứ cần | Ghi chú |
|---|---|
| Vivado 2025.1 | Đã có tại `E:\Xillinx\2025.1`, có device `xck26` và board file KV260 (`kv260_som` 1.4, `kv260_carrier` 1.3) |
| GCC RISC-V | Đã có, đi kèm Vitis: `E:\Xillinx\2025.1\gnu\riscv\nt\riscv64-unknown-elf\bin` (GCC 13.3, multilib `rv32im/ilp32`) |
| Git Bash, `mingw32-make`, `python` | Đã có (`mingw32-make` từ Strawberry Perl) |
| Driver USB-UART | CP210x hoặc FTDI, tùy loại bạn mua |
| Terminal serial | Tera Term hoặc PuTTY |
| SSH/SCP | Có sẵn trong Git Bash, để chép file sang board |

### 2.2 Phần cứng

- KV260 Starter Kit + nguồn 12 V đi kèm.
- Thẻ microSD ≥ 16 GB.
- Cáp Ethernet (cài gói, chép file qua `scp`).
- Cáp micro-USB (console Linux của board).
- USB-UART **3.3 V** (CP2102 hoặc FT232). **Không dùng loại 5 V**, bank PMOD là 3.3 V.
- Dây jumper cái-cái, 1 LED + điện trở 330 Ω (tùy chọn, để nhìn PA2 nháy).
- Bước sau (tùy chọn): adapter JTAG 3.3 V (FT2232H, Olimex ARM-USB-TINY-H, J-Link) để debug RISC-V bằng OpenOCD.

### 2.3 Trên board (làm một lần)

1. Tải image **Ubuntu 22.04 cho AMD Kria** (trang ubuntu.com/download/amd), ghi lên thẻ SD bằng Balena Etcher.
2. Cắm thẻ, Ethernet, micro-USB, rồi cấp nguồn. Mở terminal vào cổng COM của micro-USB (115200 8N1), hoặc SSH khi đã có IP.
   Image Kria Ubuntu thường đăng nhập lần đầu bằng `ubuntu` / `ubuntu` và bắt đổi mật khẩu.
3. KV260 xuất xưởng có thể mang boot firmware cũ, chỉ boot được Ubuntu 20.04. Nếu Ubuntu 22.04 không boot,
   cập nhật boot firmware theo trang *Kria Wiki / boot firmware update* của AMD
   (`xmutil bootfw_update`, hoặc Boot Image Recovery Tool).
4. Kiểm tra trình quản lý ứng dụng PL có chạy không:
   ```bash
   sudo xmutil listapps
   ```
   Nếu báo không có lệnh, cài theo hướng dẫn Kria Ubuntu của AMD (gói `xlnx-config` / `dfx-mgr`).
5. Cài trình biên dịch device tree:
   ```bash
   sudo apt install device-tree-compiler
   ```

## 3. Hướng dẫn từng bước

### Bước 1 — Build firmware

```bash
cd /d/GITHUB_PROJECT/MCU_LowPower_GeneralPurpose/Driver/kv260/fw && mingw32-make SHELL=/usr/bin/bash
```

Kết quả nằm trong `fw/build/`:
- `kv260_hello.elf/.dis/.mem`: ảnh firmware (word 0 nằm ở 0x0001_0000).
- `rom_inc/memory/boot_rom_image.vh`: bảng `case` của boot ROM, do `gen_boot_rom.py` của golden sinh ra.
- `sys_clk_hz.txt`: clock mà firmware tính baud theo; `build.tcl` dùng file này để kiểm tra.

Firmware làm bốn việc: in banner (có chuỗi `Hello KV260`), echo ký tự nhận được, in `tick N` mỗi giây, cho PA2 nháy 1 Hz, và báo `PA3=0/1` khi PA3 đổi mức. Gặp trap thì nó in `*** TRAP mcause=... mepc=... mtval=...` rồi dừng.

### Bước 2 — Mô phỏng (nên chạy mỗi khi đổi RTL hoặc firmware)

```bash
cd /d/GITHUB_PROJECT/MCU_LowPower_GeneralPurpose/Driver/kv260 && bash scripts/sim_core.sh
```

Mong đợi (khoảng 1 phút):
```
[TB][OK] ... banner 'Hello KV260'
[TB][OK] ... PA2 la output
[TB][OK] ... echo 'K'
[TB][OK] ... PA3=1 duoc doc
[TB][PASS] kv260_soc_core: UART TX/RX, GPIO in/out OK (98 ky tu)
== SIM PASS
```
Log đầy đủ ở `sim/work/xsim.log`. Testbench lấy danh sách RTL từ `genus/tcl/rtl_filelist.tcl`, cùng nguồn với Genus, nên RTL golden đổi gì thì sim thấy ngay.

### Bước 3 — Build bitstream

Đóng các project Vivado khác nếu máy thiếu RAM (16 GB là vừa đủ), rồi chạy:

```bash
cd /d/GITHUB_PROJECT/MCU_LowPower_GeneralPurpose/Driver/kv260 && /e/Xillinx/2025.1/Vivado/bin/vivado.bat -mode batch -nojournal -log out/build.log -source scripts/build.tcl
```

- Muốn chỉ synth để xem tài nguyên và latch thì thêm `-tclargs synth` vào cuối lệnh.
- Script in số latch sau synth (phải bằng 0) và số BUFGCE (phải bằng 12).
- Kết quả: `out/mcu_kv260.bit`, `out/mcu_kv260.bit.bin`, `out/mcu_kv260.xsa`, `out/mcu_kv260.dtsi`, `out/shell.json`.
- Report trong `out/reports/`: `timing_impl.rpt`, `utilization_impl.rpt`, `drc.rpt`, `methodology.rpt`, `clock_utilization.rpt`, `io.rpt`.
- Script **thoát mã 2 nếu WNS hoặc WHS âm**. Khi đó đừng nạp bitstream; hạ clock (bước 6) rồi build lại.

### Bước 4 — Đấu dây

Tắt nguồn board trước khi cắm dây.

| Tín hiệu | Chân FPGA | PMOD J2 | Nối tới |
|---|---|---|---|
| UART0_TX (PA0) | H12 | 1 | **RX** của USB-UART |
| UART0_RX (PA1) | B10 | 2 | **TX** của USB-UART |
| JTAG TCK | E10 | 3 | để trống (có pull-down) hoặc TCK của adapter |
| JTAG TMS | E12 | 4 | để trống hoặc TMS |
| JTAG TDI | D10 | 5 | để trống hoặc TDI |
| JTAG TDO | D11 | 6 | để trống hoặc TDO |
| GPIO PA2 (out) | C11 | 7 | LED + 330 Ω xuống GND |
| GPIO PA3 (in) | B11 | 8 | jumper lên 3.3 V để thử (có pull-down) |
| GND | — | GND | **GND của USB-UART (bắt buộc)** |

Đọc mục 5 về độ tin cậy của bảng chân này trước khi cắm.

### Bước 5 — Nạp lên board

Trên PC, chép 3 file sang board (thay `<ip>` bằng IP của board):

```bash
cd /d/GITHUB_PROJECT/MCU_LowPower_GeneralPurpose/Driver/kv260/out && scp mcu_kv260.bit.bin mcu_kv260.dtsi shell.json ubuntu@<ip>:~
```

Trên board:

```bash
dtc -@ -I dts -O dtb -o mcu_kv260.dtbo mcu_kv260.dtsi
```
```bash
sudo mkdir -p /lib/firmware/xilinx/mcu_kv260
```
```bash
sudo cp mcu_kv260.bit.bin mcu_kv260.dtbo shell.json /lib/firmware/xilinx/mcu_kv260/
```
```bash
sudo xmutil unloadapp
```
```bash
sudo xmutil loadapp mcu_kv260
```

Mở terminal trên PC vào cổng COM của USB-UART, **115200 8N1, không flow control**. Sẽ thấy:

```
=== MCU SoC on KV260 ===
Hello KV260
sys_clk=50000000 Hz, baud=115200
Type to echo.
tick 1
tick 2
```

Nếu banner đã in trước khi bạn kịp mở terminal: chạy lại `sudo xmutil unloadapp`, rồi `sudo xmutil loadapp mcu_kv260`. Cặp lệnh này cũng là cách reset SoC.

### Bước 6 — Đổi firmware hoặc clock

- **Đổi firmware:** sửa `fw/main.c`, chạy lại bước 1, 2, 3, 5. Boot ROM là bảng `case` tổng hợp thành logic, nên đổi firmware thì phải synth và impl lại.
- **Đổi clock SoC** (ví dụ 75 MHz):
  ```bash
  cd /d/GITHUB_PROJECT/MCU_LowPower_GeneralPurpose/Driver/kv260/fw && mingw32-make SHELL=/usr/bin/bash clean all SYS_CLK_HZ=75000000
  ```
  ```bash
  cd /d/GITHUB_PROJECT/MCU_LowPower_GeneralPurpose/Driver/kv260 && KV260_SYS_CLK_MHZ=75 /e/Xillinx/2025.1/Vivado/bin/vivado.bat -mode batch -nojournal -log out/build.log -source scripts/build.tcl
  ```
  `build.tcl` dừng nếu clock của firmware và của bitstream lệch nhau. Giá trị hợp lệ là những MHz mà 1200 / MHz là bội của 0.125 (ví dụ 25, 40, 48, 50, 60, 75, 80, 96, 100).

## 4. Xử lý sự cố

| Triệu chứng | Kiểm tra |
|---|---|
| Terminal im lặng | GND chung chưa? TX/RX đã bắt chéo chưa? `sudo xmutil listapps` có báo `mcu_kv260` đang active? Chân H12/B10 (mục 5)? |
| Ra ký tự rác | Baud 115200? `fw/build/sys_clk_hz.txt` có khớp `KV260_SYS_CLK_MHZ`? `pl_clk0` có đúng 100 MHz (overlay đã nạp)? |
| `*** TRAP mcause=...` | Tra `mepc` trong `fw/build/kv260_hello.dis`. mcause 5/7 thường là truy cập địa chỉ không có slave. Bitstream build từ RTL trước 2026-11-04 còn trap ở CLINT (mục 5) |
| `loadapp` báo lỗi | Tên thư mục, `firmware-name` trong `.dtsi` và tên file `.bit.bin` phải giống hệt nhau (`mcu_kv260`) |
| Build: `BUILD FAIL: thieu .../boot_rom_image.vh` | Chạy bước 1 trước |
| Build: DRC `LUTLP-1` | Filter net TRNG trong `constr/kv260_trng_impl.xdc` không còn khớp tên hierarchy |
| Build thoát mã 2 | Timing âm. Xem `out/reports/timing_impl.rpt` và hạ clock |
| Latch sau synth > 0 | File `utils/clock_gate.v` golden đã lọt vào thay vì bản BUFGCE, hoặc RTL có latch thật |

## 5. Khác biệt so với chip ASIC và vấn đề đã biết

- **CLINT: đã sửa trong RTL golden ngày 2026-11-04.** Trước đó `top_soc.v` truyền nguyên địa chỉ
  `0x0200_BFF8` vào `axi_clint` trong khi `clint_regfile` decode theo offset `0xBFF8`, nên mọi
  truy cập msip/mtimecmp/mtime trả SLVERR (mcause 5/7). Bản sửa chỉ đưa `s5_aw/araddr[15:0]`
  (cửa sổ CLINT 64 KB) vào CLINT. Firmware bring-up giờ kiểm CLINT lúc khởi động: mtime phải
  tăng theo RTC, mtimecmp và msip phải ghi/đọc lại đúng, rồi in `CLINT OK mtime=N` (hỏng thì in
  `CLINT FAIL step K`, K là bước trong `clint_check()`). Testbench chờ dòng này và FAIL ngay
  nếu CLINT trả lỗi. Netlist Genus/Innovus và các kết quả signoff hiện có là của bản CHƯA sửa.
- **Chân PMOD:** board file KV260 không khai báo PMOD. Bảng ở bước 4 lấy từ XDC cộng đồng
  (hackster.io, "PMOD IP development for Kria KV260"). E10, E12, D10, D11, C11, B11 khớp
  `kv260_som/1.4/part0_pins.xml` (som240_1_d20, b21, d21, b22, d22, c22). **H12 và B10 chưa
  đối chiếu được**, và cách đánh số chân PMOD cũng cần so với sơ đồ carrier (UG1089) hoặc chữ
  in trên board.
- **Erratum E1 (ITCM):** không chạy code từ ITCM. Firmware chạy trong ROM, RAM `0x2000_0000` hoặc XIP.
- **Không có SDRAM và QSPI flash trên PL:** `sdram_dq_i = 0`, `flash_io_i = 1111`. Firmware không được
  chạm `0x8000_0000`; boot ROM gốc (khi không bake firmware) sẽ dừng ở vòng `park`.
- **Clock gating:** 12 BUFGCE (`CE_TYPE = SYNC`). Model unisim của nó là latch trong suốt khi clock
  thấp + AND, đúng ngữ nghĩa bản ASIC, nên WFI vẫn dừng được CPU.
- **TRNG:** synth dùng nhánh `XILINX` (LUT6), là ring oscillator thật trên FPGA. Mô phỏng dùng nhánh
  hành vi có trễ (sóng tất định, không phải entropy).
- **Clock:** 50 MHz (ASIC chạy 250 MHz). Timing ở 50 MHz chưa được kiểm (bước 3 chưa chạy hết).
- **Reset:** chỉ có `pl_resetn0` từ PS. Muốn reset SoC thì `unloadapp` + `loadapp`.
