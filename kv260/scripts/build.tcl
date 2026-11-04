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
#   GOLDEN_RTL         cay RTL golden (mac dinh ../../Script_Backend/...)
#
# Dau ra (out/):
#   mcu_kv260.bit, mcu_kv260.bit.bin (cho xmutil/fpga_manager), mcu_kv260.xsa,
#   mcu_kv260.dtsi, shell.json, va reports/ (timing, utilization, drc, ...)
# =============================================================================

proc die {msg} {
    puts "\n*** BUILD FAIL: $msg\n"
    exit 1
}
proc env_or {name dflt} {
    if {[info exists ::env($name)] && $::env($name) ne ""} { return $::env($name) }
    return $dflt
}

set KV          [file normalize [file join [file dirname [info script]] ..]]
set GOLDEN      [file normalize [env_or GOLDEN_RTL \
                    [file join $KV .. .. Script_Backend Asap7 run_workspace mcu genus rtl]]]
set SYS_CLK_MHZ [env_or KV260_SYS_CLK_MHZ 50]
set JOBS        [env_or KV260_JOBS 6]
set STOP_AFTER  [expr {[llength $argv] > 0 ? [lindex $argv 0] : "bit"}]

set PART      xck26-sfvc784-2LV-c
set PROJ_NAME mcu_kv260
set PROJ_DIR  [file join $KV vivado]
set OUT_DIR   [file join $KV out]
set RPT_DIR   [file join $OUT_DIR reports]
set ROM_INC   [file join $KV fw build rom_inc]

# -----------------------------------------------------------------------------
# 0. Kiem tra dau vao
# -----------------------------------------------------------------------------
if {![file isdirectory $GOLDEN]} { die "khong thay RTL golden: $GOLDEN" }
if {![file isfile [file join $ROM_INC memory boot_rom_image.vh]]} {
    die "thieu fw/build/rom_inc/memory/boot_rom_image.vh - chay `mingw32-make` trong kv260/fw truoc"
}
set clk_file [file join $KV fw build sys_clk_hz.txt]
if {[file isfile $clk_file]} {
    set fh [open $clk_file r]; set fw_hz [string trim [read $fh]]; close $fh
    if {$fw_hz != $SYS_CLK_MHZ * 1000000} {
        die "firmware build cho $fw_hz Hz nhung bitstream la $SYS_CLK_MHZ MHz - baud UART se sai"
    }
} else {
    puts "WARNING: khong co $clk_file, khong kiem duoc clock cua firmware"
}
if {[expr {fmod(1200.0 / $SYS_CLK_MHZ * 8.0, 1.0)}] != 0.0} {
    die "1200 / $SYS_CLK_MHZ khong phai boi 0.125 - MMCM khong chia duoc"
}

puts "== KV260 build: SoC $SYS_CLK_MHZ MHz, golden RTL $GOLDEN, jobs $JOBS, dung sau '$STOP_AFTER'"

file mkdir $OUT_DIR $RPT_DIR

# -----------------------------------------------------------------------------
# 1. Project + board
# -----------------------------------------------------------------------------
create_project $PROJ_NAME $PROJ_DIR -part $PART -force

set have_board 0
set som [lindex [lsort [get_board_parts -quiet xilinx.com:kv260_som:part0:*]] end]
if {$som ne ""} {
    set_property board_part $som [current_project]
    set have_board 1
    set car [lindex [lsort [get_boards -quiet *kv260_carrier*]] end]
    if {$car ne ""} {
        lassign [split $car :] c_vendor c_name c_ver
        if {[catch {set_property board_connections \
                [list som240_1_connector "$c_vendor:$c_name:som240_1_connector:$c_ver"] \
                [current_project]} err]} {
            puts "WARNING: khong noi duoc carrier ($car): $err"
        }
    }
    puts "== board: $som  carrier: $car"
} else {
    puts "WARNING: khong co board file KV260 - PS cau hinh tay, XSA khong dung cho boot bare-metal"
}

# -----------------------------------------------------------------------------
# 2. RTL: danh sach golden + doi clock_gate.v sang BUFGCE
# -----------------------------------------------------------------------------
set RTL_ROOT $GOLDEN
source [file join $GOLDEN .. tcl rtl_filelist.tcl]   ;# -> RTL_FILES, RTL_INCLUDE_DIRS

set gold_cg [file join $GOLDEN utils clock_gate.v]
set idx [lsearch -exact $RTL_FILES $gold_cg]
if {$idx < 0} { die "rtl_filelist.tcl khong con utils/clock_gate.v - cap nhat build.tcl" }
set RTL_FILES [lreplace $RTL_FILES $idx $idx [file join $KV rtl clock_gate_bufgce.v]]

set ALL_SRC [concat $RTL_FILES [list \
    [file join $GOLDEN tests models srambank_256x4x32_6t122.v] \
    [file join $GOLDEN tests models srambank_128x4x20_6t122.v] \
    [file join $KV rtl kv260_soc_core.v] \
    [file join $KV rtl kv260_top.v]]]
add_files -norecurse -fileset sources_1 $ALL_SRC
# Mo phong da compile toan bo bang `xvlog -sv`; doc giong vay khi synth.
set_property file_type SystemVerilog [get_files -of_objects [get_filesets sources_1] *.v]

# rom_inc TRUOC rtl/ de `include "memory/boot_rom_image.vh"` lay anh firmware.
set_property include_dirs [concat [list $ROM_INC] $RTL_INCLUDE_DIRS] [get_filesets sources_1]
# FPGA  : ram_style hint trong register_file / BPU.
# XILINX: TRNG dung LUT6 (khong dung cell ASAP7 / mo hinh co tre).
set_property verilog_define {FPGA XILINX} [get_filesets sources_1]

# -----------------------------------------------------------------------------
# 3. Block design: chi khoi PS, xuat pl_clk0 + pl_resetn0
# -----------------------------------------------------------------------------
create_bd_design kv260_ps
set ps_def [lindex [lsort [get_ipdefs -all xilinx.com:ip:zynq_ultra_ps_e:*]] end]
if {$ps_def eq ""} { die "khong thay IP zynq_ultra_ps_e" }
set ps [create_bd_cell -type ip -vlnv $ps_def ps]
if {$have_board} {
    apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e \
        -config {apply_board_preset "1"} $ps
}
# Bo cac cong AXI master (khong dung - chung can clock tu PL) va dat pl_clk0.
set_property -dict [list \
    CONFIG.PSU__USE__M_AXI_GP0                 {0} \
    CONFIG.PSU__USE__M_AXI_GP1                 {0} \
    CONFIG.PSU__USE__M_AXI_GP2                 {0} \
    CONFIG.PSU__FPGA_PL0_ENABLE                {1} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__NUM_FABRIC_RESETS              {1} \
] $ps

create_bd_port -dir O -type clk pl_clk0
create_bd_port -dir O -type rst pl_resetn0
connect_bd_net [get_bd_pins ps/pl_clk0]    [get_bd_ports pl_clk0]
connect_bd_net [get_bd_pins ps/pl_resetn0] [get_bd_ports pl_resetn0]
validate_bd_design
save_bd_design

set bd_file [get_files kv260_ps.bd]
set_property synth_checkpoint_mode None $bd_file
generate_target all $bd_file
add_files -norecurse [make_wrapper -files $bd_file -top]

set_property top kv260_top [get_filesets sources_1]
set_property generic "SYS_CLK_MHZ=$SYS_CLK_MHZ" [get_filesets sources_1]
update_compile_order -fileset sources_1

# -----------------------------------------------------------------------------
# 4. Constraint
# -----------------------------------------------------------------------------
add_files -fileset constrs_1 -norecurse [file join $KV constr kv260.xdc]
add_files -fileset constrs_1 -norecurse [file join $KV constr kv260_trng_impl.xdc]
set_property used_in_synthesis false [get_files kv260_trng_impl.xdc]

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
