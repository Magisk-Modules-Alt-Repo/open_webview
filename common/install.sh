#!/system/bin/sh
# environment
MANUFACTER=$(getprop ro.product.manufacturer)
ABI=$(grep_prop ro.product.cpu.abi)
# utility
STATUS=0
# bromite data
VERSION=105.0.5195.41
APK_NAME="BromiteWebview.apk"
SHA_NAME=brm_${VERSION}.sha256.txt
WV_URL=https://github.com/bromite/bromite/releases/download/${VERSION}/${ARCH}_SystemWebView.apk
WV_SHA_URL=https://github.com/bromite/bromite/releases/download/${VERSION}/brm_${VERSION}.sha256.txt

ui_print "  Detecting architecture..."
ui_print "  CPU architecture: ${ARCH}."
# download webview
ui_print "  Downloading bromite webview..."
for i in 1 2 3; do
	if [ $STATUS -eq 0 ]; then
		if [[ ! -f "${APK_NAME}" ]]; then
			curl -Lso "${APK_NAME}" "${WV_URL}"
		fi

		if [[ ! -f "${SHA_NAME}" ]]; then
			curl -Lso "${SHA_NAME}" "${WV_SHA_URL}"
		fi

		if [[ ! -f "${APK_NAME}" ]]; then
			STATUS=0
		elif [[ ! -f "${SHA_NAME}" ]]; then
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
SHA_CALC=$(sha256sum ${APK_NAME} | awk '{print $1}')
SHA_FILE=$(cat ${SHA_NAME} | awk -v val="${ARCH}_SystemWebView.apk" '$2 == val {print $1}')
if [ $SHA_CALC == $SHA_FILE ]; then
	ui_print "  Integrity checked!"
else
	ui_print "  Integrity not checked!"
	exit 1
fi

# extract bromite
NAME="Bromite"
PACKAGE_NAME="org.bromite.webview"
ui_print "  Installing bromite webview..."
# extract lib
WV_PATH=system/app/${NAME}Webview
mktouch "$MODPATH"/$WV_PATH/.replace
cp -rf ./$APK_NAME "$MODPATH"/$WV_PATH/webview.apk
cp -rf ./$APK_NAME "$TMPDIR"/bromite_webview.zip
mkdir -p "$TMPDIR"/bromite_webview "$MODPATH"/$WV_PATH/lib/arm64 "$MODPATH"/$WV_PATH/lib/arm
unzip -qo "$TMPDIR"/bromite_webview.zip -d "$TMPDIR"/bromite_webview >&2
cp -rf "$TMPDIR"/bromite_webview/lib/arm64-v8a/* "$MODPATH"/$WV_PATH/lib/arm64
cp -rf "$TMPDIR"/bromite_webview/lib/armeabi-v7a/* "$MODPATH"/$WV_PATH/lib/arm
rm -rf ./$APK_NAME "$MODPATH"/$WV_PATH/.replace "$TMPDIR"/bromite_webview "$TMPDIR"/bromite_webview.zip

# create overlay
ui_print "    creating overlays..."
ui_print "      fixing system webview whitelist..."
if [ $API -ge 29 ]; then
	sed -i "s/__wv-name__/${NAME}/g" "$MODPATH"/common/overlay29/res/xml/config_webview_packages.xml
	sed -i "s/__wv-pkg__/${PACKAGE_NAME}/g" "$MODPATH"/common/overlay29/res/xml/config_webview_packages.xml
	aapt p -f -v -M "$MODPATH"/common/overlay29/AndroidManifest.xml -I /system/framework/framework-res.apk -S "$MODPATH"/common/overlay29/res -F "$MODPATH"/unsigned.apk >&2
else
	sed -i "s/__wv-name__/${NAME}/g" "$MODPATH"/common/overlay28/res/xml/config_webview_packages.xml
	sed -i "s/__wv-pkg__/${PACKAGE_NAME}/g" "$MODPATH"/common/overlay28/res/xml/config_webview_packages.xml
	aapt p -f -v -M "$MODPATH"/common/overlay28/AndroidManifest.xml -I /system/framework/framework-res.apk -S "$MODPATH"/common/overlay28/res -F "$MODPATH"/unsigned.apk >&2
fi
# sign framework_res
if [ -f "${MODPATH}/unsigned.apk" ]; then
	sign "$MODPATH"/unsigned.apk "$MODPATH"/signed.apk
	cp -rf "$MODPATH"/signed.apk "$MODPATH"/common/WebviewOverlay.apk
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

if [ -d /system_ext/overlay ]; then
	OL_PATH=system/system_ext/overlay
elif [ -d /product/overlay ]; then
	OL_PATH=system/product/overlay
elif [ -d /vendor/overlay ]; then
	OL_PATH=system/vendor/overlay
elif [ -d /system/overlay ]; then
	OL_PATH=system/overlay
else
	STATUS=0
fi

if [ $STATUS -eq 1 ]; then
	mkdir -p "$MODPATH"/$OL_PATH
	cp_ch "$MODPATH"/common/WebviewOverlay.apk "$MODPATH"/$OL_PATH
fi

if [ $STATUS -eq 1 ]; then
	ui_print "  Cleaning up..."
	rm -rf "$MODPATH"/system/placeholder
	ui_print "  Dalvik cache will be cleared next boot"
	ui_print "  Expect longer boot time"
else
	ui_print ""
	ui_print "  Installation failed."
	ui_print "  Cleaning up..."
	rm -rf "$MODPATH"/$WV_PATH "$MODPATH"/$OL_PATH
	exit 1
fi
