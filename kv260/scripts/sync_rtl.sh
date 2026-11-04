#!/usr/bin/env bash
# =============================================================================
# Chep RTL golden (Script_Backend) vao kv260/src/ de thu muc kv260 tu chay duoc
# tren may khac, khong can Script_Backend.
#
#   bash scripts/sync_rtl.sh                     (chay tu kv260/, tren may co Script_Backend)
#   GOLDEN_SRC=/duong/dan/genus bash scripts/sync_rtl.sh
#
# Bo cuc giu nguyen nhu golden de cac script dung chung duong dan:
#   src/tcl/rtl_filelist.tcl          danh sach file (ban sao)
#   src/rtl/<cay con nhu golden>      chi cac file trong rtl_filelist.tcl + *.vh
#   src/rtl/tests/models/srambank_*   model SRAM hanh vi (thay macro ASAP7)
#   src/rtl/tests/gen_boot_rom.py     tao boot_rom_image.vh tu firmware
# KHONG chep memory/boot_rom_image.vh cua golden: anh ROM lay tu fw/build/rom_inc.
# src/SOURCE.txt ghi commit golden da chep.
# =============================================================================
set -euo pipefail

KV="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GENUS="${GOLDEN_SRC:-$KV/../../Script_Backend/Asap7/run_workspace/mcu/genus}"
[ -d "$GENUS/rtl" ] || { echo "khong thay $GENUS/rtl - dat GOLDEN_SRC=<.../mcu/genus>"; exit 1; }
GENUS="$(cd "$GENUS" && pwd)"
FL="$GENUS/tcl/rtl_filelist.tcl"
[ -f "$FL" ] || { echo "khong thay $FL"; exit 1; }

DST="$KV/src"
rm -rf "$DST"
mkdir -p "$DST/tcl" "$DST/rtl"
cp "$FL" "$DST/tcl/"

n=0
copy_rel() {   # $1 = duong dan tuong doi trong rtl/
    mkdir -p "$DST/rtl/$(dirname "$1")"
    cp "$GENUS/rtl/$1" "$DST/rtl/$1"
    n=$((n + 1))
}

# "[file join $RTL_ROOT a b c.v]" -> a/b/c.v
while read -r rel; do
    copy_rel "$rel"
done < <(sed -n 's/.*\[file join \$RTL_ROOT \([^]]*\.v\)\].*/\1/p' "$FL" | tr ' ' '/')

while read -r rel; do
    [ "$rel" = "memory/boot_rom_image.vh" ] && continue
    copy_rel "$rel"
done < <(cd "$GENUS/rtl" && find . -name '*.vh' -not -path './tests/*' | sed 's|^\./||')

copy_rel tests/models/srambank_256x4x32_6t122.v
copy_rel tests/models/srambank_128x4x20_6t122.v
copy_rel tests/gen_boot_rom.py

{
    echo "Ban sao RTL golden cho kv260 - KHONG sua o day, sua o Script_Backend roi chay scripts/sync_rtl.sh"
    echo "nguon : Script_Backend/Asap7/run_workspace/mcu/genus"
    echo "commit: $(git -C "$GENUS" log -1 --format='%h %ad %s' --date=short 2>/dev/null || echo unknown)"
    if [ -n "$(git -C "$GENUS" status --porcelain -- rtl ':!rtl/tests' tcl/rtl_filelist.tcl 2>/dev/null)" ]; then
        echo "CANH BAO: luc chep golden co thay doi chua commit"
    fi
    echo "so file: $n"
} > "$DST/SOURCE.txt"

cat "$DST/SOURCE.txt"
