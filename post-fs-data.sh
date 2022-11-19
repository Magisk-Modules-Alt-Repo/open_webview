#!/system/bin/sh
MODDIR=${0%/*}
API=$(grep_prop ro.build.version.sdk)
OVERLAY_LIST="/data/system/overlays.xml"
BROMITE_OVERLAY_APK_FILE="WebviewOverlay.apk"
OVERLAY_PACKAGE_NAME="org.Bromite.WebviewOverlay"

find_overlay_path() {
	if [ -d /system_ext/overlay ]; then
		OVERLAY_PATH=system/system_ext/overlay
	elif [ -d /product/overlay ]; then
		OVERLAY_PATH=system/product/overlay
	elif [ -d /vendor/overlay ]; then
		OVERLAY_PATH=system/vendor/overlay
	elif [ -d /system/overlay ]; then
		OVERLAY_PATH=system/overlay
	else
		STATUS=0
	fi
}
set_state() {
	if [ $API -lt 27 ]; then
		STATE=3
	else
		STATE=6
	fi
}

find_overlay_path
set_state

if [ ! -f "$MODDIR"/.webview ]; then
	sed -i "/item packageName=\"${OVERLAY_PACKAGE_NAME}\"/d" $OVERLAY_LIST
	sed -i "s|</overlays>|    <item packageName=\"${OVERLAY_PACKAGE_NAME}\" userId=\"0\" targetPackageName=\"android\" baseCodePath=\"${OVERLAY_PATH}/${BROMITE_OVERLAY_APK_FILE}\" state=\"${STATE}\" isEnabled=\"true\" isStatic=\"true\" priority=\"9999\" /></overlays>|" $OVERLAY_LIST

	rm -rf /data/resource-cache/* /data/dalvik-cache/* /cache/dalvik-cache/* /data/system/package_cache/*

	touch "$MODDIR"/.webview
fi
