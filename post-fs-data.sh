#!/system/bin/sh
MODDIR="${0%/*}"
API=$(grep_prop ro.build.version.sdk)
CONFIG_FILE="$MODDIR/.webview"
OVERLAY_LIST="/data/system/overlays.xml"
RESET=$(grep "RESET=" ${CONFIG_FILE} | cut -d"=" -f2)
OVERLAY_PATH=$(grep "OVERLAY_PATH=" ${CONFIG_FILE} | cut -d"=" -f2)
OVERLAY_APK_FILE=$(grep "OVERLAY_APK_FILE=" ${CONFIG_FILE} | cut -d"=" -f2)
VW_OVERLAY_PACKAGE=$(grep "VW_OVERLAY_PACKAGE=" ${CONFIG_FILE} | cut -d"=" -f2)

if [ $API -lt 27 ]; then
	STATE=3
else
	STATE=6
fi

if [ $RESET -eq 1 ]; then
	# clear cache
	rm -rf /data/resource-cache/* /data/dalvik-cache/* /cache/dalvik-cache/* /data/system/package_cache/*
	# remove conflict
	sed -i "/com*webview/d" /data/system/packages.list
	sed -i "/com*webview/d" /data/system/packages.xml
	sed -i "/com.linuxandria.WebviewOverlay/d" $OVERLAY_LIST
	sed -i "/com.linuxandria.android.webviewoverlay/d" $OVERLAY_LIST
	# register overlay
	sed -i "/item packageName=\"${VW_OVERLAY_PACKAGE}\"/d" $OVERLAY_LIST
	sed -i "s|</overlays>|    <item packageName=\"${VW_OVERLAY_PACKAGE}\" userId=\"0\" targetPackageName=\"android\" baseCodePath=\"${OVERLAY_PATH}/${OVERLAY_APK_FILE}\" state=\"${STATE}\" isEnabled=\"true\" isStatic=\"true\" priority=\"9999\" /></overlays>|" $OVERLAY_LIST
	sed -i "s/RESET=1/RESET=0/" $CONFIG_FILE
fi  

RESET=$(grep "RESET=" ${CONFIG_FILE} | cut -d"=" -f2)

if [ $RESET -eq 1 ]; then
	sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ ⛔ Module is not working! Try reinstalling the module ] /g' "$MODDIR/module.prop"
fi