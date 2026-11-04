/* ==================================================================
 * File: startup/trap_handler.S
 * Mô tả: Lưu và phục hồi Context khi có Ngắt/Lỗi (Exceptions & Interrupts)
 *
 * trap_entry la loi vao CHUNG cho moi ngoai le va moi ngat:
 *   - che do CLINT (mtvec = trap_entry, mode 00, do crt0.S dat)
 *   - che do CLIC  (mtvec = trap_entry | 3, do main.c dat; ngat shv = 0)
 * O che do CLIC, core lay base = mtvec voi 6 bit thap ep ve 0 (register_file.v,
 * WARL cua mtvec) - nen trap_entry PHAI can le 64 byte, neu khong core nhay
 * vao giua mot ham khac.
 * ================================================================== */

.section .text
/* norelax: de .balign duoc dien ngay luc assemble (offset 0 trong section,
   section can le 2^6). Voi relax, gas chen 60 byte NOP + R_RISCV_ALIGN va
   phu thuoc linker cat bot - khong can dua vao do. */
.option norelax
.global trap_entry
.balign 64

trap_entry:
    /* 1. Xin cấp phát 128 byte trên đỉnh Stack hiện tại (chỉ dùng 64 byte cho
          16 thanh ghi caller-saved; s0-s11 do chính hàm C tự lưu nếu dùng) */
    addi sp, sp, -128

    /* 2. Lưu các thanh ghi caller-saved (ra, t0-t6, a0-a7) */
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

    /* 4. Phục hồi lại các thanh ghi từ Stack */
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

    /* 6. MRET: quay lai lenh dang chay do. O che do CLIC, mret con khoi phuc
          mintstatus.mil <- mcause.mpil. */
    mret
