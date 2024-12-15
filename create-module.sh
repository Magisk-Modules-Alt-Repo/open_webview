#!/bin/bash
set -e

MODULE_NAME="open-webview.zip"
TOOLS="tools.tar"
ROOT_DIR="$(pwd)"
OVERLAY_DIR="overlays"
TOOLS_DIR="common/tools"

compress() {
    local type="$1"
    local output="$2"
    shift 2
    local input=("$@")
    echo "compressing $output..."
    7z a -t"$type" -r "$output" "${input[@]}" >& /dev/null
}

echo "deleting old files..."
rm -f "$MODULE_NAME"
rm -f "$TOOLS_DIR/${TOOLS}.xz"
rm -f "$OVERLAY_DIR/*.zip"

echo "zipping tools..."
cd "$TOOLS_DIR/tools"
compress tar "$TOOLS" *
compress xz "${TOOLS}.xz" "$TOOLS"
rm -f "$TOOLS"
mv -f "${TOOLS}.xz" ../
cd "$ROOT_DIR"

echo "Zipping overlays..."
cd "$OVERLAY_DIR"
declare -A overlays=(
    ["mulch-overlay28.zip"]="./extracted/mulch-overlay28/*"
    ["mulch-overlay29.zip"]="./extracted/mulch-overlay29/*"
    ["vanadium-overlay29.zip"]="./extracted/vanadium-overlay29/*"
)

for zip_name in "${!overlays[@]}"; do
    compress zip "$zip_name" "${overlays[$zip_name]}"
done

cd "$ROOT_DIR"
echo -e "creating module zip..."
7z a -tzip -r $MODULE_NAME * -xr!.git* -xr!img -xr!common/tools/tools -xr!overlays/extracted -x!*.md -x!create-module.* >& /dev/null
echo "done!"
