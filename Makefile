# 1. Tên dự án và tiền tố của Toolchain
TARGET = my_soc_firmware
TOOLCHAIN = /mnt/d/HK252/Soc_Sim/soc_firmware/xpack-riscv-none-elf-gcc-14.2.0-2/bin/riscv-none-elf-

CC      = $(TOOLCHAIN)gcc
OBJCOPY = $(TOOLCHAIN)objcopy
OBJDUMP = $(TOOLCHAIN)objdump

# 2. Các cờ biên dịch (Compiler Flags)
ARCH_FLAGS = -march=rv32imf -mabi=ilp32f
CFLAGS = -Wall -O2 -g $(ARCH_FLAGS) -Iinc

LDFLAGS = -T ld/soc.ld -nostartfiles --specs=nano.specs -Wl,-Map=$(TARGET).map

# 4. Tìm kiếm file tự động
C_SRCS   = $(wildcard src/*.c)
ASM_SRCS = $(wildcard startup/*.S)
OBJS     = $(C_SRCS:.c=.o) $(ASM_SRCS:.S=.o)

# SỬA ĐIỂM SỐ 1: Thêm $(TARGET).hex vào danh sách xuất xưởng
all: $(TARGET).elf $(TARGET).bin $(TARGET).hex $(TARGET).dis

$(TARGET).elf: $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) -O verilog $< $@

$(TARGET).dis: $(TARGET).elf
	$(OBJDUMP) -d -S $< > $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f src/*.o startup/*.o $(TARGET).elf $(TARGET).bin $(TARGET).hex $(TARGET).map $(TARGET).dis

.PHONY: all clean