## =============================================================================
## TRNG ring oscillator (apb_ascon/trng_128b.v, nhanh `XILINX` = LUT6)
##
## RingOscillator la vong to hop co chu y: 1 NAND + 6 NOT. Khong co thuoc tinh
## nay, write_bitstream dung o DRC LUTLP-1 (Combinatorial Loop). DONT_TOUCH /
## KEEP_HIERARCHY trong RTL giu nguyen cac LUT nen ten net on dinh sau synth.
## Chi dung cho implementation (build.tcl dat USED_IN_SYNTHESIS false).
## Neu Vivado bao "No nets matched" o day thi ten hierarchy da doi - sua filter,
## dung bo qua, khong thi bitstream se dung o LUTLP-1.
## =============================================================================
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets -hierarchical -filter {NAME =~ "*u_trng/ro/*"}]
