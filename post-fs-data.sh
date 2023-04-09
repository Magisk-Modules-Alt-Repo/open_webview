#!/system/bin/sh
API=$(grep_prop ro.build.version.sdk)
OVERLAY_LIST="/data/system/overlays.xml"

RESET=$(grep "RESET=" /sdcard/.webview | cut -d"=" -f2)
OVERLAY_APK_FILE=$(grep "OVERLAY_APK_FILE=" /sdcard/.webview | cut -d"=" -f2)
OVERLAY_PACKAGE_NAME=$(grep "OVERLAY_PACKAGE_NAME=" /sdcard/.webview | cut -d"=" -f2)
OVERLAY_PATH=$(grep "OVERLAY_PATH=" /sdcard/.webview | cut -d"=" -f2)

set_state() {
	if [ $API -lt 27 ]; then
		STATE=3
	else
		STATE=6
	fi
}

set_state

if [ $RESET -eq 1 ]; then
	rm -rf /data/resource-cache/* /data/dalvik-cache/* /cache/dalvik-cache/* /data/system/package_cache/*

	sed -i "/com*webview/d" /data/system/packages.list
	sed -i "/com*webview/d" /data/system/packages.xml
	sed -i "/com.linuxandria.WebviewOverlay/d" $OVERLAY_LIST
	sed -i "/com.linuxandria.android.webviewoverlay/d" $OVERLAY_LIST

	sed -i "/item packageName=\"${OVERLAY_PACKAGE_NAME}\"/d" $OVERLAY_LIST
	sed -i "s|</overlays>|    <item packageName=\"${OVERLAY_PACKAGE_NAME}\" userId=\"0\" targetPackageName=\"android\" baseCodePath=\"${OVERLAY_PATH}/${OVERLAY_APK_FILE}\" state=\"${STATE}\" isEnabled=\"true\" isStatic=\"true\" priority=\"9999\" /></overlays>|" $OVERLAY_LIST

	sed -i "s/RESET=1/RESET=0/" /sdcard/.webview
fi  
