# Bring-up firmware KV260.
#
#   make                      -> build/kv260_hello.{elf,bin,mem,dis}
#                                + build/rom_inc/memory/boot_rom_image.vh
#   make SYS_CLK_HZ=75000000  -> doi clock (phai khop SYS_CLK_MHZ cua build.tcl)
#
# Toolchain mac dinh: GCC RISC-V di kem Vitis 2025.1 (co multilib rv32im/ilp32).

XILINX_ROOT   ?= E:/Xillinx/2025.1
CROSS_COMPILE ?= $(XILINX_ROOT)/gnu/riscv/nt/riscv64-unknown-elf/bin/riscv64-unknown-elf-
PYTHON        ?= python

GOLDEN_RTL    ?= ../src/rtl
GEN_BOOT_ROM  := $(GOLDEN_RTL)/tests/gen_boot_rom.py

SYS_CLK_HZ    ?= 50000000
UART_BAUD     ?= 115200

CC      := $(CROSS_COMPILE)gcc
OBJCOPY := $(CROSS_COMPILE)objcopy
OBJDUMP := $(CROSS_COMPILE)objdump
SIZE    := $(CROSS_COMPILE)size

ARCH    := -march=rv32im_zicsr -mabi=ilp32
CFLAGS  := $(ARCH) -O2 -g -ffreestanding -fno-builtin -nostdlib -nostartfiles \
           -mno-relax -Wall -Wextra \
           -DSYS_CLK_HZ=$(SYS_CLK_HZ)u -DUART_BAUD=$(UART_BAUD)u
LDFLAGS := $(ARCH) -nostdlib -nostartfiles -mno-relax -T link.ld -Wl,--gc-sections \
           -Wl,-Map,build/kv260_hello.map

B := build
TARGET := $(B)/kv260_hello

all: $(B)/rom_inc/memory/boot_rom_image.vh

$(B):
	mkdir -p $(B)

$(TARGET).elf: crt0.S main.c link.ld | $(B)
	$(CC) $(CFLAGS) $(LDFLAGS) crt0.S main.c -lgcc -o $@
	$(SIZE) $@

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

# Mot word 32-bit hex moi dong, word 0 = 0x0001_0000 (dinh dang gen_boot_rom.py doc).
$(TARGET).mem: $(TARGET).bin
	od -An -v -tx4 -w4 $< | tr -d ' ' > $@

$(TARGET).dis: $(TARGET).elf
	$(OBJDUMP) -d $< > $@

# sys_clk_hz.txt: build.tcl so voi SYS_CLK_MHZ cua bitstream - lech la baud sai.
$(B)/rom_inc/memory/boot_rom_image.vh: $(TARGET).mem $(TARGET).dis
	$(PYTHON) $(GEN_BOOT_ROM) $< $(B)/rom_inc
	echo $(SYS_CLK_HZ) > $(B)/sys_clk_hz.txt

clean:
	rm -rf $(B)

.PHONY: all clean
