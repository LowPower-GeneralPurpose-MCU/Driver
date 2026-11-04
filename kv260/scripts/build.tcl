# =============================================================================
# Build bitstream KV260 cho MCU SoC.
#
# Project RIENG (kv260/vivado/mcu_kv260.xpr), tao lai tu dau moi lan chay.
# KHONG dung va KHONG sua MCU_SOC_IOT.xpr (project mo phong K7 cua ban).
#
#   cd D:/GITHUB_PROJECT/MCU_LowPower_GeneralPurpose/Driver/kv260
#   vivado -mode batch -source scripts/build.tcl                 ;# tron bo -> out/
#   vivado -mode batch -source scripts/build.tcl -tclargs synth  ;# dung sau synth
#
# Bien moi truong (tuy chon):
#   KV260_SYS_CLK_MHZ  clock SoC, mac dinh 50 (phai khop `make SYS_CLK_HZ=` cua fw/)
#   KV260_JOBS         so job song song, mac dinh 6
#   GOLDEN_RTL         cay RTL (mac dinh kv260/src/rtl - ban sao golden, xem sync_rtl.sh)
#
# Dau ra (out/):
#   mcu_kv260.bit, mcu_kv260.bit.bin (cho xmutil/fpga_manager), mcu_kv260.xsa,
#   mcu_kv260.dtsi, shell.json, va reports/ (timing, utilization, drc, ...)
# =============================================================================

# Buoc 0-4 (kiem tra dau vao, project, RTL, block design PS, constraint) nam
# trong setup_project.tcl - cung file dung trong Tcl Console cua GUI.
proc die {msg} {
    puts "\n*** BUILD FAIL: $msg\n"
    exit 1
}
set STOP_AFTER [expr {[llength $argv] > 0 ? [lindex $argv 0] : "bit"}]
if {[catch {source [file join [file dirname [info script]] setup_project.tcl]} err]} {
    die $err
}
set JOBS    [kv_env_or KV260_JOBS 6]
set OUT_DIR [file join $KV out]
set RPT_DIR [file join $OUT_DIR reports]
file mkdir $OUT_DIR $RPT_DIR
puts "== KV260 build: jobs $JOBS, dung sau '$STOP_AFTER'"

# -----------------------------------------------------------------------------
# 5. Synth
# -----------------------------------------------------------------------------
launch_runs synth_1 -jobs $JOBS
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {
    die "synth_1 that bai - xem [get_property DIRECTORY [get_runs synth_1]]/runme.log"
}
open_run synth_1 -name synth_1
report_utilization    -file [file join $RPT_DIR utilization_synth.rpt]
report_timing_summary -file [file join $RPT_DIR timing_synth.rpt] -max_paths 10
# Latch con sot = clock_gate golden lot vao, hoac RTL co latch that.
set latches [get_cells -quiet -hierarchical -filter {PRIMITIVE_SUBGROUP == latch}]
puts "== latch sau synth: [llength $latches]"
set n_bufgce [llength [get_cells -quiet -hierarchical -filter {REF_NAME == BUFGCE}]]
puts "== BUFGCE sau synth: $n_bufgce (mong doi 12)"
close_design
if {$STOP_AFTER eq "synth"} { puts "== dung sau synth"; exit 0 }

# -----------------------------------------------------------------------------
# 6. Impl + bitstream
# -----------------------------------------------------------------------------
launch_runs impl_1 -to_step write_bitstream -jobs $JOBS
wait_on_run impl_1
set impl_dir [get_property DIRECTORY [get_runs impl_1]]
set bit_src  [file join $impl_dir kv260_top.bit]
if {![file isfile $bit_src]} { die "impl_1 khong ra bitstream - xem $impl_dir/runme.log" }

open_run impl_1
report_timing_summary    -file [file join $RPT_DIR timing_impl.rpt] -max_paths 20 -report_unconstrained
report_utilization       -file [file join $RPT_DIR utilization_impl.rpt]
report_utilization -hierarchical -hierarchical_depth 3 \
                         -file [file join $RPT_DIR utilization_hier.rpt]
report_clock_utilization -file [file join $RPT_DIR clock_utilization.rpt]
report_drc               -file [file join $RPT_DIR drc.rpt]
report_methodology       -file [file join $RPT_DIR methodology.rpt]
report_clock_interaction -file [file join $RPT_DIR clock_interaction.rpt]
report_io                -file [file join $RPT_DIR io.rpt]

set wns [get_property SLACK [lindex [get_timing_paths -setup -max_paths 1 -nworst 1] 0]]
set whs [get_property SLACK [lindex [get_timing_paths -hold  -max_paths 1 -nworst 1] 0]]

# -----------------------------------------------------------------------------
# 7. Dau ra cho board
# -----------------------------------------------------------------------------
set bit_out [file join $OUT_DIR mcu_kv260.bit]
file copy -force $bit_src $bit_out
write_hw_platform -fixed -include_bit -force [file join $OUT_DIR mcu_kv260.xsa]

# .bit.bin cho fpga_manager cua Linux (xmutil): bootgen -process_bitstream bin
set bif [file join $OUT_DIR mcu_kv260.bif]
set fh [open $bif w]; puts $fh "all:\n{\n    mcu_kv260.bit\n}"; close $fh
set bootgen [auto_execok bootgen]
if {$bootgen eq ""} {
    puts "WARNING: khong thay bootgen - tu chay: bootgen -image mcu_kv260.bif -arch zynqmp -process_bitstream bin -w on"
} else {
    set here [pwd]; cd $OUT_DIR
    if {[catch {exec {*}$bootgen -image mcu_kv260.bif -arch zynqmp -process_bitstream bin -w on} msg]} {
        puts "WARNING: bootgen: $msg"
    }
    cd $here
}
foreach f {mcu_kv260.dtsi shell.json} {
    file copy -force [file join $KV overlay $f] [file join $OUT_DIR $f]
}

puts ""
puts "================================================================"
puts " KV260 build xong - SoC $SYS_CLK_MHZ MHz"
puts "   WNS setup = $wns ns   WHS hold = $whs ns"
puts "   out/: [join [lsort [glob -nocomplain -tails -directory $OUT_DIR *.bit *.bin *.xsa *.dtsi *.json]] {  }]"
puts "================================================================"
if {$wns < 0 || $whs < 0} {
    puts "*** TIMING FAIL - KHONG nap bitstream nay. Xem out/reports/timing_impl.rpt"
    exit 2
}
exit 0
