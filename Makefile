TARGET = my_soc_firmware
CROSS_COMPILE ?= riscv-none-elf-
PYTHON_CMD ?= python
HEX_BASE ?= 0x10000

override PYTHONHOME :=
override PYTHONPATH :=
export PYTHONHOME
export PYTHONPATH

CC      = $(CROSS_COMPILE)gcc
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
ROM_HEX = $(TARGET)_word.hex
ROM_MEM = $(TARGET)_word.mem

ARCH_FLAGS = -march=rv32im_zicsr -mabi=ilp32
CFLAGS = -Wall -O2 -g $(ARCH_FLAGS) -Iinc
LDFLAGS = -T ld/soc.ld -nostartfiles -Wl,-Map=$(TARGET).map

C_SRCS   = $(wildcard src/*.c)
ASM_SRCS = $(wildcard startup/*.S)
OBJS     = $(C_SRCS:.c=.o) $(ASM_SRCS:.S=.o)

all: $(TARGET).elf $(TARGET).bin $(TARGET).hex $(ROM_HEX) $(ROM_MEM) $(TARGET).dis

$(TARGET).elf: $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) -O verilog $< $@

$(ROM_HEX): $(TARGET).hex
	$(PYTHON_CMD) src/hex_converter.py $< $@ $(HEX_BASE)

$(ROM_MEM): $(TARGET).hex
	$(PYTHON_CMD) src/hex_converter.py $< $@ $(HEX_BASE)

$(TARGET).dis: $(TARGET).elf
	$(OBJDUMP) -d -S $< > $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f src/*.o startup/*.o $(TARGET).elf $(TARGET).bin $(TARGET).hex $(ROM_HEX) $(ROM_MEM) $(TARGET).map $(TARGET).dis

.PHONY: all clean
