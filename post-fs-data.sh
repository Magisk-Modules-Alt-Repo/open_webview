#!/system/bin/sh
API=$(grep_prop ro.build.version.sdk)
# bromite data
BROMITE_OVERLAY_APK_FILE="WebviewOverlay.apk"
OVERLAY_PACKAGE_NAME="org.Bromite.WebviewOverlay"
OVERLAY_LIST="/data/system/overlays.xml"

# force overlay
if [ -d /system_ext/overlay ]; then
	OVERLAY_PATH=/system/system_ext/overlay
elif [ -d /product/overlay ]; then
	OVERLAY_PATH=/system/product/overlay
elif [ -d /vendor/overlay ]; then
	OVERLAY_PATH=/system/vendor/overlay
elif [ -d /system/overlay ]; then
	OVERLAY_PATH=/system/overlay
fi

if [ $API -lt 27 ]; then
	STATE="3"
else
	STATE="6"
fi

sed -i "/item packageName=\"${OVERLAY_PACKAGE_NAME}\"/d" /data/system/overlays.xml
sed -i "s|</overlays>|    <item packageName=\"${OVERLAY_PACKAGE_NAME}\" userId=\"0\" targetPackageName=\"android\" baseCodePath=\"${OVERLAY_PATH}/${BROMITE_OVERLAY_APK_FILE}\" state=\"${STATE}\" isEnabled=\"true\" isStatic=\"true\" priority=\"9999\" /></overlays>|" $OVERLAY_LIST
