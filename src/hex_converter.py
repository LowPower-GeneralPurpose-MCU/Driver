import sys

def convert_and_format_hex(input_file, output_file, base_addr=0x10000):
    with open(input_file, 'r') as f_in, open(output_file, 'w') as f_out:
        for line in f_in:
            line = line.strip()
            if not line:
                continue
            
            if line.startswith('@'):
                # Xử lý dời gốc tọa độ về 0 cho Vivado ROM
                byte_addr_int = int(line[1:], 16)
                if byte_addr_int >= base_addr:
                    byte_addr_int -= base_addr
                    
                current_word_addr = byte_addr_int // 4
                f_out.write(f"@{current_word_addr:08X}\n")
            else:
                # Xóa dấu cách
                data_string = line.replace(" ", "")
                # Cắt thành các cục 8 ký tự (4 bytes)
                chunks = [data_string[i:i+8] for i in range(0, len(data_string), 8)]
                
                for chunk in chunks:
                    chunk = chunk.zfill(8)
                    # LẬT NGƯỢC BYTE (Little Endian Fix)
                    # byte0 (0:2), byte1 (2:4), byte2 (4:6), byte3 (6:8)
                    # Sắp xếp lại: byte3 + byte2 + byte1 + byte0
                    le_chunk = chunk[6:8] + chunk[4:6] + chunk[2:4] + chunk[0:2]
                    
                    f_out.write(f"{le_chunk}\n")
                    


if __name__ == "__main__":
    convert_and_format_hex("my_soc_firmware.hex", "my_soc_firmware_word.hex", 0x10000)