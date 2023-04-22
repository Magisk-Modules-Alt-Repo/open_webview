#!/system/bin/sh
MODDIR="${0%/*}"
CONFIG_FILE="$MODDIR/.webview"
VW_PACKAGE=$(grep "VW_PACKAGE=" ${CONFIG_FILE} | cut -d"=" -f2)

"pm install -r -g ${MODDIR}/webview.apk"
rm -rf "$MODDIR"/webview.apk

PROPFILE="$MODDIR/module.prop"
if [ -n "$(ls -a /data/misc/shared_relro)" ]; then
    if [ "pm list packages -a | grep -q ${VW_PACKAGE}" ]; then
        sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ ✅ Module is working ] /g' "$PROPFILE"
    fi
else
    sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ 🙁 Module installed but you need to install webview manually ] /g' "$PROPFILE"
fi