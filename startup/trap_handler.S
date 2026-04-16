/* ==================================================================
 * File: startup/trap_handler.S
 * Mô tả: Lưu và phục hồi Context khi có Ngắt/Lỗi (Exceptions & Interrupts)
 * ================================================================== */

.global trap_entry
.align 4 /* Vector ngắt  phải căn lề 4 byte */

trap_entry:
    /* 1. Xin cấp phát 128 byte (32 thanh ghi x 4 byte) trên đỉnh Stack hiện tại */
    addi sp, sp, -128

    /* 2. Lưu toàn bộ 31 thanh ghi đa dụng (x1 đến x31) vào Stack (Bỏ qua x0 vì luôn bằng 0) */
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2, 12(sp)
    sw a0, 16(sp)
    sw a1, 20(sp)
    sw a2, 24(sp)
    sw a3, 28(sp)
    sw a4, 32(sp)
    sw a5, 36(sp)
    sw a6, 40(sp)
    sw a7, 44(sp)
    sw t3, 48(sp)
    sw t4, 52(sp)
    sw t5, 56(sp)
    sw t6, 60(sp)

    /* 3. Gọi hàm C xử lý ngắt tổng (Truyền mcause và mepc làm tham số a0, a1) */
    csrr a0, mcause
    csrr a1, mepc
    call system_trap_handler

    /* 4. Phục hồi lại toàn bộ 31 thanh ghi từ Stack */
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    lw t2, 12(sp)
    lw a0, 16(sp)
    lw a1, 20(sp)
    lw a2, 24(sp)
    lw a3, 28(sp)
    lw a4, 32(sp)
    lw a5, 36(sp)
    lw a6, 40(sp)
    lw a7, 44(sp)
    lw t3, 48(sp)
    lw t4, 52(sp)
    lw t5, 56(sp)
    lw t6, 60(sp)

    /* 5. Trả lại 128 byte cho Stack */
    addi sp, sp, 128

    /* 6. Lệnh MRET: Yêu cầu phần cứng quay lại dòng code C đang chạy dở trước khi bị ngắt */
    mret