#!/system/bin/sh
# environment
API=$(grep_prop ro.build.version.sdk)
# bromite data
OL_PACKAGE_NAME="org.Bromite.WebviewOverlay"
LIST="/data/system/overlays.xml"

# force overlay
if [ -d /system_ext/overlay ]; then
	OLP=/system/system_ext/overlay
elif [ -d /product/overlay ]; then
	OLP=/system/product/overlay
elif [ -d /vendor/overlay ]; then
	OLP=/system/vendor/overlay
elif [ -d /system/overlay ]; then
	OLP=/system/overlay
fi

if [ $API -lt 27 ]; then
	STATE="3"
else
	STATE="6"
fi

sed -i "/item packageName=\"${OL_PACKAGE_NAME}\"/d" /data/system/overlays.xml
sed -i "s|</overlays>|    <item packageName=\"${OL_PACKAGE_NAME}\" userId=\"0\" targetPackageName=\"android\" baseCodePath=\"${OLP}/WebviewOverlay.apk\" state=\"${STATE}\" isEnabled=\"true\" isStatic=\"true\" priority=\"9999\" /></overlays>|" $LIST
