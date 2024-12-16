#!/system/bin/sh
MODDIR="${0%/*}"
API=$(grep_prop ro.build.version.sdk)
CONFIG_FILE="$MODDIR/.webview"
OVERLAY_LIST="/data/system/overlays.xml"
IS_REINSTALL=$(grep "IS_REINSTALL=" ${CONFIG_FILE} | cut -d"=" -f2)
RESET=$(grep "RESET=" ${CONFIG_FILE} | cut -d"=" -f2)
OVERLAY_PATH=$(grep "OVERLAY_PATH=" ${CONFIG_FILE} | cut -d"=" -f2)
OVERLAY_APK_FILE=$(grep "OVERLAY_APK_FILE=" ${CONFIG_FILE} | cut -d"=" -f2)
VW_OVERLAY_PACKAGE=$(grep "VW_OVERLAY_PACKAGE=" ${CONFIG_FILE} | cut -d"=" -f2)

if [[ $API -lt 27 ]]; then
	STATE=3
else
	STATE=6
fi

restore_original_files() {
	cp "$MODDIR"/backup/packages.list.bak /data/system/packages.list
	cp "$MODDIR"/backup/packages.xml.bak /data/system/packages.xml
	cp "$MODDIR"/backup/overlays.xml.bak $OVERLAY_LIST
}

backup_original_files() {
	cp /data/system/packages.list "$MODDIR"/backup/packages.list.bak
	cp /data/system/packages.xml "$MODDIR"/backup/packages.xml.bak
	cp $OVERLAY_LIST "$MODDIR"/backup/overlays.xml.bak
}

if [[ $RESET -eq 1 ]]; then
	if [[ -n $VW_OVERLAY_PACKAGE ]]; then
		if [[ $IS_REINSTALL -eq 1 ]]; then
			restore_original_files
		else
			backup_original_files
		fi
		# clear cache
		rm -rf /data/resource-cache/* /data/dalvik-cache/* /cache/dalvik-cache/* /data/system/package_cache/*
		# remove conflict
		sed -i "/com*webview/d" /data/system/packages.list
		sed -i "/com*webview/d" /data/system/packages.xml
		# register overlay
		sed -i "/item packageName=\"${VW_OVERLAY_PACKAGE}\"/d" $OVERLAY_LIST
		sed -i "s|</overlays>|    <item packageName=\"${VW_OVERLAY_PACKAGE}\" userId=\"0\" targetPackageName=\"android\" baseCodePath=\"${OVERLAY_PATH}/${OVERLAY_APK_FILE}\" state=\"${STATE}\" isEnabled=\"true\" isStatic=\"true\" priority=\"9999\" /></overlays>|" $OVERLAY_LIST
	fi
	sed -i "s/RESET=1/RESET=0/" $CONFIG_FILE
fi
