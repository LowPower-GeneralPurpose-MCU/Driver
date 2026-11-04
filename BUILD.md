# Build firmware

## 0. 2026-11-04 — driver theo RTL mới, ảnh `.mem` CHƯA build lại

Source đã đổi nhưng `my_soc_firmware_word.mem` vẫn là bản build 2026-09-12
(source cũ, PLIC). Phải `make` lại trên máy có toolchain rồi chạy
`run_soc_sim.sh fw` trước khi tin vào ảnh này. Máy Windows không build được:
mọi bản gcc ở đó thiếu `cc1`.

Đã đổi:

- **Ngắt: PLIC → CLIC.** `main.c` bật chế độ CLIC (`mtvec = trap_entry | 3`),
  UART0 RX qua CLIC ID 16. `trap.c` phân luồng theo `mcause[11:0]` = CLIC ID
  (`inc/soc_hw.h`). `trap_entry` căn lề 64 byte (bắt buộc ở chế độ CLIC).
  `plic.c` / `plic.h` đã xoá.
- **Driver mới:** `clic.c`, `timer.c` (TIM0/TIM1), `ascon.c` / `ascon.h`
  (ASCON-128 mã hoá, ASCON-Hash, TRNG); `pinmux.h` thêm `pinmux_get` /
  `pinmux_set_mask`; UART1 (`HAL_UART_IRQDispatch`).
- **Sửa theo RTL:** WDT sai offset (`CTRL` 0x04, `FEED` 0x08 + key
  `0x5A5A5A5A`) nên trước đây không bao giờ bật được; GPIO `INT_STAT` ở 0x1C
  (trước ghi nhầm vào `INT_TYPE`); SPI phải tự xoá `DONE` (sticky);
  SYSCON có bit 8/9/10 (UART1/TIM0/TIM1); `SYSTEM_BUS_CLOCK` = 250 MHz.
- **DMA giữ driver cũ** (`dma.c` / `dma.h` không đổi), mỗi kênh một CLIC ID 22–25.

Chuỗi UART của test (`HELLO RISC-V UART TEST!\n`) giữ nguyên nên
`tb_top_soc.v` không phải sửa.

## 1. Vì sao phải build lại

`Driver/inc/soc_config.h` đã đổi `CONFIG_HAS_FPU` từ **1 → 0** ngày 2026-09-05.

Lý do: `crt0.S` guard khối khởi tạo FPU bằng `#if CONFIG_HAS_FPU`, và khi cờ đó
bằng 1 thì ảnh firmware chứa

```
10010:  00301073   csrw fcsr, zero      # CSR 0x003, thuộc F extension
```

Core này **không có F extension** — `riscv_pipeline.v` đặt `ENABLE_FPU = 0`,
`control_unit.v` đặt `ENABLE_F_EXTENSION = 0`, và MISA không khai bit F. Trước
đây bảng CSR nuốt lệnh đó im lặng. Từ khi `register_file.v` báo
illegal-instruction cho CSR không hiện thực (mục C5 trong
`Asap7/run_workspace/mcu/CORE_FIX_PLAN.md`), nó trap ngay ở **lệnh thứ tư của
crt0** — trước khi `mtvec` được set — nên CPU nhảy vào địa chỉ 0 và đi lang thang.

Đây là nửa còn lại của chính bug MISA mà RTL đã sửa: MISA đã bỏ bit F, còn build
config thì chưa.

> **Trạng thái hiện tại:** vì máy phát triển không có toolchain RISC-V, ảnh
> `my_soc_firmware_word.mem` đã được **vá tay đúng một word**: `@00000004` từ
> `00301073` thành `00000013` (NOP). Layout giữ nguyên nên mọi địa chỉ khác
> không đổi. Đây là **cầu tạm** — source và ảnh hiện không khớp nhau. Build lại
> theo hướng dẫn dưới đây sẽ đồng bộ chúng.

## 2. Toolchain

Cần `riscv-none-elf-gcc` hỗ trợ `-march=rv32im_zicsr -mabi=ilp32`.

Nguồn khuyến nghị: **xPack GNU RISC-V Embedded GCC** — chính nó dùng tiền tố
`riscv-none-elf-` mà Makefile mong đợi.

```bash
npm install --global @xpack-dev-tools/riscv-none-elf-gcc@latest
```

hoặc tải bản portable từ trang release của xpack-dev-tools/riscv-none-elf-gcc và
thêm thư mục `bin/` vào `PATH`.

> **Không dùng được** toolchain `riscv32-esp-elf` trong `.platformio` — nó nhắm
> target ESP, không phải build `rv32im_zicsr` này.

Kiểm tra:

```bash
riscv-none-elf-gcc --version
```

```bash
riscv-none-elf-gcc -march=rv32im_zicsr -mabi=ilp32 -x c -c /dev/null -o /dev/null
```

Lệnh thứ hai phải chạy im lặng. Nếu nó báo `unrecognized argument in option
-march` thì bản GCC quá cũ — `zicsr` tách khỏi `i` từ GCC 12; hãy dùng GCC 12
trở lên.

Ngoài ra cần `python` trên `PATH` (Makefile gọi `src/hex_converter.py` để sinh
`.mem`/`.hex`).

## 3. Build

```bash
cd Driver && make clean && make
```

Nếu tiền tố toolchain khác, ghi đè mà không sửa Makefile:

```bash
make CROSS_COMPILE=riscv64-unknown-elf-
```

Sản phẩm — `all` tạo đủ bộ:

| File | Dùng ở đâu |
|---|---|
| `my_soc_firmware.elf` | GDB / OpenOCD |
| `my_soc_firmware.bin` | nạp flash |
| `my_soc_firmware.hex` | trung gian (định dạng `-O verilog`) |
| `my_soc_firmware_word.mem` | **testbench `fw` đọc file này** |
| `my_soc_firmware_word.hex` | biến thể hex của trên |
| `my_soc_firmware.dis` | disassembly, để đối chiếu |
| `my_soc_firmware.map` | bản đồ linker |

`HEX_BASE` mặc định `0x10000` — khớp base của boot ROM trong `top_soc.v`
(slave 0, `0x0001_0000`). Đừng đổi trừ khi bản đồ địa chỉ đổi.

## 4. Kiểm tra bản build đúng

Sau khi build, xác nhận lệnh `csrw fcsr` đã biến mất:

```bash
grep -n "fcsr" my_soc_firmware.dis
```

Phải **không có kết quả nào**. Nếu vẫn còn thì `CONFIG_HAS_FPU` chưa về 0, hoặc
file `.o` cũ chưa bị xoá — chạy `make clean` rồi build lại.

Sau đó chạy lại testbench SoC.

> ### ⚠️ Hai cái bẫy khi chạy trên Windows
>
> **1. Phải dùng Git Bash, KHÔNG dùng `bash` trên PATH.**
> Trên máy này `bash` phân giải ra `C:\Windows\system32\bash.exe` — đó là **WSL
> bash**. Nó không chạy được `run_soc_sim.sh`: script cần `cygpath` để đổi đường
> dẫn MSYS sang dạng ổ đĩa cho các binary Windows của Vivado, mà WSL không có
> `cygpath`, và cũng không gọi được `xvlog.bat`. Phải gọi Git Bash tường minh:
> `C:\Program Files\Git\bin\bash.exe`.
>
> **2. Đường dẫn tính từ `Script_Backend`, không phải từ thư mục cha.**
> Thư mục gốc của git repo là `Script_Backend`. Các lệnh dưới đây giả định bạn
> đang đứng ở đó.

Trong **PowerShell**, từ `D:\...\MCU_LowPower_GeneralPurpose\Script_Backend`:

```powershell
& "C:\Program Files\Git\bin\bash.exe" Asap7/run_workspace/mcu/genus/rtl/tests/run_soc_sim.sh fw
```

Trong **Git Bash**, từ cùng thư mục đó:

```bash
bash Asap7/run_workspace/mcu/genus/rtl/tests/run_soc_sim.sh fw
```

Kỳ vọng:

```
[TB][PASS] t=... UART message matched and CPU reached WFI
UART: HELLO RISC-V UART TEST!
```

Và chạy cả bộ để chắc không hồi quy chỗ khác — đổi `fw` thành `all`:

```powershell
& "C:\Program Files\Git\bin\bash.exe" Asap7/run_workspace/mcu/genus/rtl/tests/run_soc_sim.sh all
```

| Testbench | Kỳ vọng |
|---|---|
| `apb` | PASS 256 / FAIL 0 |
| `fw` | PASS — UART + WFI |
| `mem` | PASS 99 / FAIL 0 / TIMEOUT 0 |

## 5. Ba thay đổi RTL mà firmware phải biết

Cả ba đến từ Phase A của `CORE_FIX_PLAN.md`.

### 5.1. `rdtime` không còn dùng được

`time` (CSR `0xC01`) và `timeh` (`0xC81`) trước đây được alias vào `mcycle`.
Sai: `time` theo đặc tả là `mtime` của CLINT chạy bằng `rtc_clk` 32.768 kHz, còn
`mcycle` đếm chu kỳ `clk_cpu` 400 MHz — lệch hệ số khoảng 12 200 lần. Mọi tick
RTOS, delay, timeout đều sai và sai **im lặng** vì giá trị vẫn tăng đều.

Hai CSR đó nay raise illegal-instruction. Firmware phải đọc `mtime` qua MMIO —
đúng như `src/clint.c` đang làm rồi:

```c
uint64_t clint_get_mtime(void) {
    uint32_t hi, lo;
    do { hi = CLINT_MTIME_HI; lo = CLINT_MTIME_LO; } while (hi != CLINT_MTIME_HI);
    return (((uint64_t)hi) << 32) | lo;
}
```

`mtime` nằm ở `0x0200_BFF8`. **Đừng** thêm `rdtime` vào code mới.

### 5.2. CSR không hiện thực nay trap

Danh sách CSR **có thật** trong core (xem `csr_exists()` trong
`register_file.v`):

```
0xF11 mvendorid   0xF12 marchid    0xF13 mimpid    0xF14 mhartid
0x300 mstatus     0x301 misa       0x304 mie       0x305 mtvec
0x340 mscratch    0x341 mepc       0x342 mcause    0x343 mtval    0x344 mip
0xB00/0xB80 mcycle(h)              0xB02/0xB82 minstret(h)
0xC00/0xC80 cycle(h)               0xC02/0xC82 instret(h)
0x7B0/0x7B1/0x7B2 dcsr/dpc/dscratch0  — CHỈ trong Debug Mode
```

Truy cập bất cứ CSR nào ngoài danh sách → `mcause = 2`, `mtval` = mã lệnh. Đáng
chú ý là **không có**: `mcountinhibit`, `mstatush`, `mcounteren`, toàn bộ nhóm
PMP, toàn bộ nhóm floating-point (`fflags`/`frm`/`fcsr`), `time`/`timeh`.

Nhóm debug `0x7B0`–`0x7B2` chỉ tồn tại khi hart đang halt. Firmware M-mode ghi
`dcsr` sẽ trap — có chủ đích, vì trước đây firmware có thể tự đặt bit `step` và
đưa mình vào single-step mà không có debugger nào đang gắn.

### 5.3. Bảng exception đã đầy đủ hơn

Trước đây handler chỉ có thể thấy `mcause` 2, 3, 11 và ba interrupt. Nay thêm:

| mcause | Nghĩa | `mtval` |
|---|---|---|
| 1 | Instruction access fault | PC gây lỗi |
| 4 | Load address misaligned | địa chỉ |
| 5 | Load access fault | địa chỉ |
| 6 | Store address misaligned | địa chỉ |
| 7 | Store access fault | địa chỉ |

`trap.c` nên xử lý các mã này thay vì rơi vào nhánh mặc định. Đặc biệt: một con
trỏ hỏng trước đây cho ra **dữ liệu sai im lặng**, giờ cho ra trap có `mtval` chỉ
đúng địa chỉ — dùng nó để in ra khi debug.

### 5.4. `mtvec` nay hỗ trợ chế độ vectored

`mtvec[1:0]` là trường MODE, WARL:

* `0` = DIRECT — mọi trap vào BASE (hành vi cũ, mặc định)
* `1` = VECTORED — **interrupt** vào `BASE + 4*cause`, exception vẫn vào BASE

Giá trị 2 và 3 là reserved, ghi vào sẽ bị ép về 0. Firmware hiện tại dùng DIRECT
nên không phải đổi gì; nếu chuyển sang VECTORED thì bảng vector phải căn lề 4
byte và đủ chỗ cho `cause` lớn nhất đang dùng (cause 11 = external → offset 44).

## 6. Việc còn lại

Sau khi build lại, xoá đoạn ghi chú "vá tay một word" ở mục 1 của file này và ở
mục A6 của `Asap7/run_workspace/mcu/CORE_FIX_PLAN.md` — lúc đó source và ảnh đã
khớp lại và bản vá không còn tồn tại.
