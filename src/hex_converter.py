import sys


def parse_int(value):
    return int(value, 0)


def iter_hex_bytes(line):
    data = "".join(line.split())
    if len(data) % 2:
        data = "0" + data

    for index in range(0, len(data), 2):
        yield int(data[index:index + 2], 16)


def convert_and_format_hex(input_file, output_file, base_addr=0x10000):
    current_addr = None
    word_addr = None
    word_bytes = []

    def flush_word(f_out):
        nonlocal word_addr, word_bytes
        if not word_bytes:
            return

        while len(word_bytes) < 4:
            word_bytes.append(0)

        word = (
            word_bytes[0]
            | (word_bytes[1] << 8)
            | (word_bytes[2] << 16)
            | (word_bytes[3] << 24)
        )
        f_out.write(f"@{word_addr:08X}\n")
        f_out.write(f"{word:08X}\n")
        word_addr = None
        word_bytes = []

    with open(input_file, "r", encoding="utf-8") as f_in, open(output_file, "w", encoding="utf-8") as f_out:
        for raw_line in f_in:
            line = raw_line.strip()
            if not line:
                continue

            if line.startswith("@"):
                flush_word(f_out)
                current_addr = int(line[1:], 16) - base_addr
                if current_addr < 0:
                    current_addr = int(line[1:], 16)
                continue

            if current_addr is None:
                current_addr = 0

            for byte in iter_hex_bytes(line):
                next_word_addr = current_addr // 4
                byte_lane = current_addr % 4

                if word_addr is None:
                    word_addr = next_word_addr
                    word_bytes = []
                elif next_word_addr != word_addr:
                    flush_word(f_out)
                    word_addr = next_word_addr
                    word_bytes = []

                while len(word_bytes) < byte_lane:
                    word_bytes.append(0)

                word_bytes.append(byte)
                current_addr += 1

                if len(word_bytes) == 4:
                    flush_word(f_out)

        flush_word(f_out)


if __name__ == "__main__":
    in_file = sys.argv[1] if len(sys.argv) > 1 else "my_soc_firmware.hex"
    out_file = sys.argv[2] if len(sys.argv) > 2 else "my_soc_firmware_word.hex"
    base = parse_int(sys.argv[3]) if len(sys.argv) > 3 else 0x10000
    convert_and_format_hex(in_file, out_file, base)
