# =============================================================================
# Dung project Vivado KV260 cho MCU SoC, DUNG TRUOC synth.
#
# Lam tat ca nhung gi can co de bam "Run Synthesis":
#   project + board KV260, RTL golden (doi clock_gate.v sang BUFGCE), glue
#   kv260_*, model SRAM, include anh ROM firmware, define FPGA/XILINX,
#   block design PS (pl_clk0 100 MHz + pl_resetn0) + wrapper, top kv260_top,
#   generic SYS_CLK_MHZ, constraint.
#
# Chay trong Tcl Console cua Vivado GUI (dung dau "/" ca tren Windows):
#   source D:/GITHUB_PROJECT/MCU_LowPower_GeneralPurpose/Driver/kv260/scripts/setup_project.tcl
# roi bam Flow > Run Synthesis (hoac go: launch_runs synth_1 -jobs 6).
#
# Doi clock SoC: go `set KV260_SYS_CLK_MHZ 75` trong console truoc khi source
# (va build lai fw voi SYS_CLK_HZ=75000000). Mac dinh 50.
#
# scripts/build.tcl source file nay roi chay tiep synth/impl/bitstream o
# batch mode. File nay KHONG goi exit, nen an toan khi chay trong GUI.
#
# Project tao o kv260/vivado/mcu_kv260.xpr va bi XOA TAO LAI moi lan source.
# =============================================================================

proc kv_env_or {name dflt} {
    # Uu tien: bien Tcl global (go trong console) > bien moi truong > mac dinh
    if {[info exists ::$name] && [set ::$name] ne ""} { return [set ::$name] }
    if {[info exists ::env($name)] && $::env($name) ne ""} { return $::env($name) }
    return $dflt
}

set KV          [file normalize [file join [file dirname [info script]] ..]]
set GOLDEN      [file normalize [kv_env_or GOLDEN_RTL \
                    [file join $KV src rtl]]]
set SYS_CLK_MHZ [kv_env_or KV260_SYS_CLK_MHZ 50]

set PART      xck26-sfvc784-2LV-c
set PROJ_NAME mcu_kv260
set PROJ_DIR  [file join $KV vivado]
set ROM_INC   [file join $KV fw build rom_inc]

# -----------------------------------------------------------------------------
# 0. Kiem tra dau vao
# -----------------------------------------------------------------------------
if {![file isdirectory $GOLDEN]} {
    error "SETUP FAIL: khong thay RTL golden: $GOLDEN (chay scripts/sync_rtl.sh, hoac dat GOLDEN_RTL)"
}
if {![file isfile [file join $GOLDEN .. tcl rtl_filelist.tcl]]} {
    error "SETUP FAIL: khong thay [file join $GOLDEN .. tcl rtl_filelist.tcl]"
}
if {![file isfile [file join $ROM_INC memory boot_rom_image.vh]]} {
    error "SETUP FAIL: thieu fw/build/rom_inc/memory/boot_rom_image.vh - build firmware trong kv260/fw truoc (README muc 3, buoc 1)"
}
set clk_file [file join $KV fw build sys_clk_hz.txt]
if {[file isfile $clk_file]} {
    set fh [open $clk_file r]; set fw_hz [string trim [read $fh]]; close $fh
    if {$fw_hz != $SYS_CLK_MHZ * 1000000} {
        error "SETUP FAIL: firmware build cho $fw_hz Hz nhung SoC la $SYS_CLK_MHZ MHz - baud UART se sai"
    }
} else {
    puts "WARNING: khong co $clk_file, khong kiem duoc clock cua firmware"
}
if {[expr {fmod(1200.0 / $SYS_CLK_MHZ * 8.0, 1.0)}] != 0.0} {
    error "SETUP FAIL: 1200 / $SYS_CLK_MHZ khong phai boi 0.125 - MMCM khong chia duoc"
}

puts "== KV260 setup: SoC $SYS_CLK_MHZ MHz, golden RTL $GOLDEN"

# Project da co -> CHI MO, khong xoa (create_project -force xoa ca synth_1/impl_1).
# Muon dung lai tu dau: `set KV260_RECREATE 1` truoc khi source.
set xpr_file [file join $PROJ_DIR $PROJ_NAME.xpr]
if {[file isfile $xpr_file] && [kv_env_or KV260_RECREATE 0] != 1} {
    if {[llength [get_projects -quiet $PROJ_NAME]] == 0} {
        open_project $xpr_file
    }
    puts "== Project da ton tai, chi MO (giu nguyen synth/impl): $xpr_file"
    puts "   Muon xoa va tao lai: set KV260_RECREATE 1 ; source <script nay>"
    return
}

# Dang mo dung project nay trong GUI thi dong lai truoc khi tao lai.
if {[llength [get_projects -quiet $PROJ_NAME]] > 0} {
    close_project
}

# -----------------------------------------------------------------------------
# 1. Project + board
# -----------------------------------------------------------------------------
create_project $PROJ_NAME $PROJ_DIR -part $PART -force

set have_board 0
set car ""
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
if {$idx < 0} { error "SETUP FAIL: rtl_filelist.tcl khong con utils/clock_gate.v - cap nhat setup_project.tcl" }
set RTL_FILES [lreplace $RTL_FILES $idx $idx [file join $KV rtl clock_gate_bufgce.v]]

set ALL_SRC [concat $RTL_FILES [list \
    [file join $GOLDEN tests models srambank_256x4x32_6t122.v] \
    [file join $GOLDEN tests models srambank_128x4x20_6t122.v] \
    [file join $KV rtl kv260_soc_core.v] \
    [file join $KV rtl kv260_top.v]]]
foreach f $ALL_SRC {
    if {![file isfile $f]} { error "SETUP FAIL: thieu file nguon $f" }
}
add_files -norecurse -fileset sources_1 $ALL_SRC
# Mo phong da compile toan bo bang `xvlog -sv`; doc giong vay khi synth.
set_property file_type SystemVerilog [get_files -of_objects [get_filesets sources_1] *.v]

# rom_inc TRUOC rtl/ de `include "memory/boot_rom_image.vh"` lay anh firmware.
set_property include_dirs [concat [list $ROM_INC] $RTL_INCLUDE_DIRS] [get_filesets sources_1]
# FPGA  : ram_style hint trong register_file / BPU.
# XILINX: TRNG dung LUT6 (khong dung cell ASAP7 / mo hinh co tre).
set_property verilog_define {FPGA XILINX} [get_filesets sources_1]
# sim_1 KHONG ke thua include_dirs/define cua sources_1: thieu thi Vivado phan
# tich sim_1 bao "undefined macro FPOP_ADD" (core/fpu_defines.vh) x179.
set_property include_dirs   [get_property include_dirs   [get_filesets sources_1]] [get_filesets sim_1]
set_property verilog_define [get_property verilog_define [get_filesets sources_1]] [get_filesets sim_1]

# -----------------------------------------------------------------------------
# 3. Block design: chi khoi PS, xuat pl_clk0 + pl_resetn0
# -----------------------------------------------------------------------------
create_bd_design kv260_ps
set ps_def [lindex [lsort [get_ipdefs -all xilinx.com:ip:zynq_ultra_ps_e:*]] end]
if {$ps_def eq ""} { error "SETUP FAIL: khong thay IP zynq_ultra_ps_e" }
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

set n_src [llength [get_files -of_objects [get_filesets sources_1]]]
puts ""
puts "================================================================"
puts " KV260 project san sang de synth: [get_property DIRECTORY [current_project]]/$PROJ_NAME.xpr"
puts "   top       = [get_property top [get_filesets sources_1]]"
puts "   SoC clock = $SYS_CLK_MHZ MHz (generic SYS_CLK_MHZ)"
puts "   nguon     = $n_src file trong sources_1"
puts "   board     = [expr {$have_board ? $som : {KHONG CO}}]"
puts " Buoc tiep: Flow > Run Synthesis, hoac: launch_runs synth_1 -jobs 6"
puts " Sau synth mong doi: 0 latch, 12 BUFGCE."
puts "================================================================"
