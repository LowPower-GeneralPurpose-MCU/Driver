import sys

def convert_and_format_hex(input_file, output_file):
    with open(input_file, 'r') as f_in, open(output_file, 'w') as f_out:
        current_word_addr = 0
        
        for line in f_in:
            line = line.strip()
            if not line:
                continue
            
            if line.startswith('@'):
                byte_addr_hex = line[1:]
                byte_addr_int = int(byte_addr_hex, 16)
                current_word_addr = byte_addr_int // 4
                f_out.write(f"@{current_word_addr:08X}\n")
            else:
                data_string = line.replace(" ", "")
                chunks = [data_string[i:i+8] for i in range(0, len(data_string), 8)]
                
                for chunk in chunks:
                    padded_chunk = chunk.zfill(8)
                    f_out.write(f"{padded_chunk}\n")

    print(f"Chuyen doi thanh cong tu {input_file} sang {output_file}")

if __name__ == "__main__":
    convert_and_format_hex("my_soc_firmware.hex", "my_soc_firmware_word.hex")