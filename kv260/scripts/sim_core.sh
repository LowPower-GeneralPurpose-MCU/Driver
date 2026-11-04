#!/usr/bin/env bash
# =============================================================================
# Mo phong kv260_soc_core (SoC + glue, khong PS) bang XSim voi firmware fw/.
#
#   bash scripts/sim_core.sh            (chay tu thu muc kv260/)
#
# Can: fw/build/rom_inc/memory/boot_rom_image.vh (chay `make` trong fw/ truoc).
# Danh sach RTL lay tu genus/tcl/rtl_filelist.tcl - CUNG nguon voi Genus va
# build.tcl - roi doi utils/clock_gate.v lay ban BUFGCE.
# Define: FPGA (khong XILINX - nhanh LUT6 cua TRNG khong co tre, XSim se treo
# neu firmware bat TRNG; ban mo phong dung nhanh hanh vi co tre 50 ps).
# =============================================================================
set -euo pipefail

if command -v cygpath >/dev/null 2>&1; then
    winpath() { cygpath -m "$1"; }
else
    winpath() { printf '%s\n' "$1"; }
fi

KV="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
XILINX_ROOT="${XILINX_ROOT:-/e/Xillinx/2025.1}"
GOLDEN="${GOLDEN_RTL:-$KV/../../Script_Backend/Asap7/run_workspace/mcu/genus/rtl}"
GOLDEN="$(cd "$GOLDEN" && pwd)"
FILELIST_TCL="$GOLDEN/../tcl/rtl_filelist.tcl"
ROM_INC="$KV/fw/build/rom_inc"
WORK="$KV/sim/work"

export PATH="$XILINX_ROOT/Vivado/bin:$PATH"
command -v xvlog.bat >/dev/null 2>&1 || { echo "khong thay xvlog.bat trong $XILINX_ROOT/Vivado/bin"; exit 1; }
[ -f "$ROM_INC/memory/boot_rom_image.vh" ] || { echo "thieu $ROM_INC/memory/boot_rom_image.vh - chay make trong fw/"; exit 1; }
[ -f "$FILELIST_TCL" ] || { echo "thieu $FILELIST_TCL"; exit 1; }

mkdir -p "$WORK"
cd "$WORK"

# "[file join $RTL_ROOT a b c.v]" -> "<golden>/a/b/c.v"
sed -n 's/.*\[file join \$RTL_ROOT \([^]]*\.v\)\].*/\1/p' "$FILELIST_TCL" \
    | tr ' ' '/' \
    | while read -r rel; do
          if [ "$rel" = "utils/clock_gate.v" ]; then
              winpath "$KV/rtl/clock_gate_bufgce.v"
          else
              winpath "$GOLDEN/$rel"
          fi
      done > rtl_files.f

n_rtl=$(wc -l < rtl_files.f)
grep -q clock_gate_bufgce rtl_files.f || { echo "khong thay utils/clock_gate.v trong filelist - kiem tra rtl_filelist.tcl"; exit 1; }

{
    winpath "$GOLDEN/tests/models/srambank_256x4x32_6t122.v"
    winpath "$GOLDEN/tests/models/srambank_128x4x20_6t122.v"
    winpath "$KV/rtl/kv260_soc_core.v"
    winpath "$KV/sim/tb_kv260_core.v"
    winpath "$XILINX_ROOT/Vivado/data/verilog/src/glbl.v"
} >> rtl_files.f

echo "== $n_rtl file RTL golden (+ clock_gate BUFGCE) + 2 model SRAM + glue + tb"

INC=(-i "$(winpath "$ROM_INC")"
     -i "$(winpath "$GOLDEN")"
     -i "$(winpath "$GOLDEN/interrupt/CLINT")"
     -i "$(winpath "$GOLDEN/interrupt/dma")")

xvlog.bat -sv -d FPGA "${INC[@]}" -f rtl_files.f > xvlog.log 2>&1 \
    || { tail -30 xvlog.log; echo "xvlog FAIL - xem $WORK/xvlog.log"; exit 1; }
xelab.bat -relax -timescale 1ns/1ps -L unisims_ver -s kv260_core_sim \
    work.tb_kv260_core work.glbl > xelab.log 2>&1 \
    || { tail -30 xelab.log; echo "xelab FAIL - xem $WORK/xelab.log"; exit 1; }

printf 'run all\nquit\n' > run.tcl
xsim.bat kv260_core_sim -tclbatch run.tcl > xsim.log 2>&1 || true

grep -E '^\[TB\]' xsim.log || true
if grep -q '\[TB\]\[PASS\]' xsim.log; then
    echo "== SIM PASS"
else
    echo "== SIM FAIL - xem $WORK/xsim.log"
    exit 1
fi
