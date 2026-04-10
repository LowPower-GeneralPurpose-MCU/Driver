// File: src/syscalls.c
// Mô tả: Cung cấp vùng nhớ Heap cho thư viện C

void *_sbrk(int incr) {
    extern char _ebss; // Lấy địa chỉ cuối vùng biến BSS từ Linker Script
    static char *heap_end;
    char *prev_heap_end;

    if (heap_end == 0) {
        heap_end = &_ebss;
    }
    prev_heap_end = heap_end;
    heap_end += incr;

    return (void *)prev_heap_end;
}

// Các hàm rỗng để chống báo lỗi thư viện
int _close(int file) { return -1; }
int _fstat(int file, void *st) { return 0; }
int _isatty(int file) { return 1; }
int _lseek(int file, int ptr, int dir) { return 0; }
int _read(int file, char *ptr, int len) { return 0; }