#!/system/bin/sh
MANUFACTER=$(getprop ro.product.manufacturer)
ABI=$(grep_prop ro.product.cpu.abi)
STATUS=0
BROMITE_VERSION=108.0.5359.109
BROMITE_URL=https://github.com/bromite/bromite/releases/download/${BROMITE_VERSION}/${ARCH}_SystemWebView.apk
BROMITE_SHA_URL=https://github.com/bromite/bromite/releases/download/${BROMITE_VERSION}/brm_${BROMITE_VERSION}.sha256.txt
BROMITE_APK_FILE="BromiteWebview.apk"
BROMITE_SHA_FILE=brm_${BROMITE_VERSION}.sha256.txt
BROMITE_NAME="Bromite"
BROMITE_PACKAGE_NAME="org.bromite.webview"
BROMITE_SYSTEM_PATH=system/app/BromiteWebview
OVERLAY_APK_FILE="WebviewOverlay.apk"

download_file() {
	STATUS=0
	ui_print "  Downloading ${1}..."

	curl -kLo "$TMPDIR"/$1 $2

	if [[ ! -f "$TMPDIR"/$1 ]]; then
		STATUS=0
	else
		STATUS=1
	fi
}
check_status() {
	if [ $STATUS -eq 0 ]; then
		ui_print ""
		ui_print "  !!! Dowload failed !!!"
		ui_print ""
		exit 1
	fi
}
check_integrity() {
	SHA_FILE_CALCULATED=$(sha256sum $1 | awk '{print $1}')
	SHA_FILE=$(cat $2 | awk -v val="${ARCH}_SystemWebView.apk" '$2 == val {print $1}')
	if [ $SHA_FILE_CALCULATED == $SHA_FILE ]; then
		ui_print "  Integrity checked!"
	else
		ui_print "  Integrity not checked!"
		exit 1
	fi
}
extract_lib() {
	#mktouch "$MODPATH"/$BROMITE_SYSTEM_PATH/.placeholder
	mkdir -p "$MODPATH"/$BROMITE_SYSTEM_PATH
	cp_ch "$TMPDIR"/$BROMITE_APK_FILE "$MODPATH"/$BROMITE_SYSTEM_PATH/webview.apk
	cp_ch "$TMPDIR"/$BROMITE_APK_FILE "$TMPDIR"/"${BROMITE_NAME}Webview.zip"
	mkdir -p "$TMPDIR"/"${BROMITE_NAME}Webview" "$MODPATH"/$BROMITE_SYSTEM_PATH/lib/arm64 "$MODPATH"/$BROMITE_SYSTEM_PATH/lib/arm
	unzip -qo "$TMPDIR"/"${BROMITE_NAME}Webview.zip" -d "$TMPDIR"/"${BROMITE_NAME}Webview" >&2
	cp_ch "$TMPDIR"/"${BROMITE_NAME}Webview"/lib/arm64-v8a/* "$MODPATH"/$BROMITE_SYSTEM_PATH/lib/arm64
	cp_ch "$TMPDIR"/"${BROMITE_NAME}Webview"/lib/armeabi-v7a/* "$MODPATH"/$BROMITE_SYSTEM_PATH/lib/arm
}
create_overlay_min_api_29() {
	sed -i "s/__webview-name__/${BROMITE_NAME}/g" "$MODPATH"/common/overlay29/res/xml/config_webview_packages.xml
	sed -i "s/__webview-package__/${BROMITE_PACKAGE_NAME}/g" "$MODPATH"/common/overlay29/res/xml/config_webview_packages.xml
	aapt p -f -v -M "$MODPATH"/common/overlay29/AndroidManifest.xml -I /system/framework/framework-res.apk -S "$MODPATH"/common/overlay29/res -F "$MODPATH"/unsigned.apk >&2
}
create_overlay_max_api_28() {
	sed -i "s/__webview-name__/${BROMITE_NAME}/g" "$MODPATH"/common/overlay28/res/xml/config_webview_packages.xml
	sed -i "s/__webview-package__/${BROMITE_PACKAGE_NAME}/g" "$MODPATH"/common/overlay28/res/xml/config_webview_packages.xml
	aapt p -f -v -M "$MODPATH"/common/overlay28/AndroidManifest.xml -I /system/framework/framework-res.apk -S "$MODPATH"/common/overlay28/res -F "$MODPATH"/unsigned.apk >&2
}
sign_framework_res() {
	sign "$MODPATH"/unsigned.apk "$MODPATH"/signed.apk
	cp -rf "$MODPATH"/signed.apk "$MODPATH"/common/$OVERLAY_APK_FILE
	rm -rf "$MODPATH"/signed.apk "$MODPATH"/unsigned.apk
}
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
force_overlay() {
	mkdir -p "$MODPATH"/$OVERLAY_PATH
	cp_ch "$MODPATH"/common/$OVERLAY_APK_FILE "$MODPATH"/$OVERLAY_PATH
}
clean_up() {
	if [ ${1} -eq 1 ]; then
		ui_print "  Cleaning up..."
		#rm -rf "$MODPATH"/$BROMITE_SYSTEM_PATH/.placeholder
		ui_print "  !!! Dalvik cache will be cleared next boot !!!"
		ui_print "  !!! Boot time may be longer !!!"
	else
		ui_print ""
		ui_print "  Installation failed."
		ui_print "  Cleaning up..."
		#rm -rf "$MODPATH"/$BROMITE_SYSTEM_PATH "$MODPATH"/$OVERLAY_PATH
		exit 1
	fi
}

# ui_print "  Detecting architecture..."
# ui_print "  CPU architecture: ${ARCH}."
download_file $BROMITE_APK_FILE $BROMITE_URL
check_status
download_file $BROMITE_SHA_FILE $BROMITE_SHA_URL
check_status
ui_print "  Checking integrity..."
check_integrity $BROMITE_APK_FILE $BROMITE_SHA_FILE
ui_print "  Installing webview..."
extract_lib
ui_print "    creating overlays..."
if [ $API -ge 29 ]; then
	create_overlay_min_api_29
else
	create_overlay_max_api_28
fi
if [ -f "${MODPATH}/unsigned.apk" ]; then
	sign_framework_res
else
	ui_print ""
	ui_print "  !!! Overlay creation has failed !!!"
	ui_print "  Compatibility is unlikely, please report this to your ROM developer."
	ui_print "  Some ROMs need a patch to fix this."
	ui_print "  Do NOT report this issue to me."
	ui_print ""
	STATUS=0
	clean_up $STATUS
fi
find_overlay_path
if [ $STATUS -eq 1 ]; then
	force_overlay
fi
if [ ! -f "${MODPATH}/$OVERLAY_PATH/$OVERLAY_APK_FILE" ]; then
	STATUS=0
fi

clean_up $STATUS