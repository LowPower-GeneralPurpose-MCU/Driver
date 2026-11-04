/* Startup toi thieu cho bring-up KV260. Chay tu boot ROM 0x0001_0000. */
    .section .text.init, "ax"
    .globl _start
_start:
    csrw    mstatus, zero
    csrw    mie, zero
    la      t0, trap_entry          /* mtvec mode direct (2 bit thap = 00) */
    csrw    mtvec, t0
    la      sp, __stack_top

    /* .data: ROM -> RAM */
    la      a0, __data_lma
    la      a1, __data_start
    la      a2, __data_end
1:  bgeu    a1, a2, 2f
    lw      t0, 0(a0)
    sw      t0, 0(a1)
    addi    a0, a0, 4
    addi    a1, a1, 4
    j       1b

    /* .bss = 0 */
2:  la      a1, __bss_start
    la      a2, __bss_end
3:  bgeu    a1, a2, 4f
    sw      zero, 0(a1)
    addi    a1, a1, 4
    j       3b

4:  call    main
5:  j       5b

/* Trap bat ky: in mcause/mepc/mtval ra UART roi dung. Khong tro ve. */
    .align  2
trap_entry:
    csrr    a0, mcause
    csrr    a1, mepc
    csrr    a2, mtval
    la      sp, __stack_top
    call    trap_report
6:  j       6b
