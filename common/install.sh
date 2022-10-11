#!/system/bin/sh
MANUFACTER=$(getprop ro.product.manufacturer)
ABI=$(grep_prop ro.product.cpu.abi)
STATUS=0
# bromite data
BROMITE_VERSION=105.0.5195.147
BROMITE_DESCRIPTION_NAME="Bromite"
BROMITE_PACKAGE_NAME="org.bromite.webview"
BROMITE_APK_FILE="BromiteWebview.apk"
BROMITE_OVERLAY_APK_FILE="WebviewOverlay.apk"
BROMITE_SHA_FILE=brm_${BROMITE_VERSION}.sha256.txt
BROMITE_URL=https://github.com/bromite/bromite/releases/download/${BROMITE_VERSION}/${ARCH}_SystemWebView.apk
BROMITE_SHA_URL=https://github.com/bromite/bromite/releases/download/${BROMITE_VERSION}/brm_${BROMITE_VERSION}.sha256.txt

ui_print "  Detecting architecture..."
ui_print "  CPU architecture: ${ARCH}."
# download webview
ui_print "  Downloading bromite webview..."
for i in 1 2 3; do
	if [ $STATUS -eq 0 ]; then
		if [[ ! -f "${BROMITE_APK_FILE}" ]]; then
			curl -kLo "${BROMITE_APK_FILE}" "${BROMITE_URL}"
		fi

		if [[ ! -f "${BROMITE_SHA_FILE}" ]]; then
			curl -kLo "${BROMITE_SHA_FILE}" "${BROMITE_SHA_URL}"
		fi

		if [[ ! -f "${BROMITE_APK_FILE}" ]]; then
			STATUS=0
		elif [[ ! -f "${BROMITE_SHA_FILE}" ]]; then
			STATUS=0
		else
			STATUS=1
		fi
	fi
done

if [ $STATUS -eq 0 ]; then
	ui_print ""
	ui_print "  !!! Dowload failed !!!"
	ui_print "  Check your connection and try again."
	ui_print ""
	exit 1
fi

# check integrity
ui_print "  Checking bromite webview integrity..."
SHA_FILE_CALCULATED=$(sha256sum ${BROMITE_APK_FILE} | awk '{print $1}')
SHA_FILE=$(cat ${BROMITE_SHA_FILE} | awk -v val="${ARCH}_SystemWebView.apk" '$2 == val {print $1}')
if [ $SHA_FILE_CALCULATED == $SHA_FILE ]; then
	ui_print "  Integrity checked!"
else
	ui_print "  Integrity not checked!"
	exit 1
fi

# extract bromite
ui_print "  Installing bromite webview..."
# extract lib
BROMITE_SYSTEM_PATH=system/app/${BROMITE_DESCRIPTION_NAME}Webview
mktouch "$MODPATH"/$BROMITE_SYSTEM_PATH/.replace
cp -rf ./$BROMITE_APK_FILE "$MODPATH"/$BROMITE_SYSTEM_PATH/webview.apk
cp -rf ./$BROMITE_APK_FILE "$TMPDIR"/bromite_webview.zip
mkdir -p "$TMPDIR"/bromite_webview "$MODPATH"/$BROMITE_SYSTEM_PATH/lib/arm64 "$MODPATH"/$BROMITE_SYSTEM_PATH/lib/arm
unzip -qo "$TMPDIR"/bromite_webview.zip -d "$TMPDIR"/bromite_webview >&2
cp -rf "$TMPDIR"/bromite_webview/lib/arm64-v8a/* "$MODPATH"/$BROMITE_SYSTEM_PATH/lib/arm64
cp -rf "$TMPDIR"/bromite_webview/lib/armeabi-v7a/* "$MODPATH"/$BROMITE_SYSTEM_PATH/lib/arm
rm -rf ./$BROMITE_APK_FILE "$MODPATH"/$BROMITE_SYSTEM_PATH/.replace "$TMPDIR"/bromite_webview "$TMPDIR"/bromite_webview.zip

# create overlay
ui_print "    creating overlays..."
ui_print "      fixing system webview whitelist..."
if [ $API -ge 29 ]; then
	sed -i "s/__webview-name__/${BROMITE_DESCRIPTION_NAME}/g" "$MODPATH"/common/overlay29/res/xml/config_webview_packages.xml
	sed -i "s/__webview-package__/${BROMITE_PACKAGE_NAME}/g" "$MODPATH"/common/overlay29/res/xml/config_webview_packages.xml
	aapt p -f -v -M "$MODPATH"/common/overlay29/AndroidManifest.xml -I /system/framework/framework-res.apk -S "$MODPATH"/common/overlay29/res -F "$MODPATH"/unsigned.apk >&2
else
	sed -i "s/__webview-name__/${BROMITE_DESCRIPTION_NAME}/g" "$MODPATH"/common/overlay28/res/xml/config_webview_packages.xml
	sed -i "s/__webview-package__/${BROMITE_PACKAGE_NAME}/g" "$MODPATH"/common/overlay28/res/xml/config_webview_packages.xml
	aapt p -f -v -M "$MODPATH"/common/overlay28/AndroidManifest.xml -I /system/framework/framework-res.apk -S "$MODPATH"/common/overlay28/res -F "$MODPATH"/unsigned.apk >&2
fi

# sign framework_res
if [ -f "${MODPATH}/unsigned.apk" ]; then
	sign "$MODPATH"/unsigned.apk "$MODPATH"/signed.apk
	cp -rf "$MODPATH"/signed.apk "$MODPATH"/common/$BROMITE_OVERLAY_APK_FILE
	rm -rf "$MODPATH"/signed.apk "$MODPATH"/unsigned.apk
else
	ui_print ""
	ui_print "  !!! Overlay creation has failed !!!"
	ui_print "  Compatibility is unlikely, please report this to your ROM developer."
	ui_print "  Some ROMs need a patch to fix this."
	ui_print "  Do NOT report this issue to me."
	ui_print ""
	STATUS=0
fi

# force overlay
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

if [ $STATUS -eq 1 ]; then
	mkdir -p "$MODPATH"/$OVERLAY_PATH
	cp_ch "$MODPATH"/common/$BROMITE_OVERLAY_APK_FILE "$MODPATH"/$OVERLAY_PATH
fi

if [ $STATUS -eq 1 ]; then
	ui_print "  Cleaning up..."
	rm -rf "$MODPATH"/system/placeholder
else
	ui_print ""
	ui_print "  Installation failed."
	ui_print "  Cleaning up..."
	rm -rf "$MODPATH"/$BROMITE_SYSTEM_PATH "$MODPATH"/$OVERLAY_PATH
	exit 1
fi
