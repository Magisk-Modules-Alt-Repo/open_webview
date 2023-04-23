#!/system/bin/sh
MANUFACTER=$(getprop ro.product.manufacturer)
ABI=$(grep_prop ro.product.cpu.abi)
CONFIG_FILE="$MODPATH/.webview"
STATUS=0
SKIP_INSTALLATION=0
NEXT_SELECTION=1
OVERLAY_API=28
OVERLAY_APK_FILE="WebviewOverlay.apk"
OVERLAY_ZIP_FILE="overlay.zip"
bromite() {
	VW_VERSION=108.0.5359.156
	VW_APK_URL=https://github.com/bromite/bromite/releases/download/${VW_VERSION}/${ARCH}_SystemWebView.apk
	VW_SHA_URL=https://github.com/bromite/bromite/releases/download/${VW_VERSION}/brm_${VW_VERSION}.sha256.txt
	VW_OVERLAY_URL=https://github.com/Magisk-Modules-Alt-Repo/open_webview/raw/master/overlays/bromite-overlay${OVERLAY_API}.zip
	VW_SHA_FILE=brm_${VW_VERSION}.sha256.txt
	VW_NAME="Bromite"
	VW_SYSTEM_PATH=system/app/BromiteWebview
	VW_PACKAGE="org.bromite.webview"
	VW_OVERLAY_PACKAGE="org.Bromite.WebviewOverlay"
}
mulch() {
	VW_APK_URL=https://gitlab.com/divested-mobile/mulch/-/raw/master/prebuilt/${ARCH}/webview.apk
	VW_SHA_URL=
	VW_OVERLAY_URL=https://github.com/Magisk-Modules-Alt-Repo/open_webview/raw/master/overlays/mulch-overlay${OVERLAY_API}.zip
	VW_NAME="Mulch"
	VW_SYSTEM_PATH=system/app/MulchWebview
	VW_PACKAGE="us.spotco.mulch_wv"
	VW_OVERLAY_PACKAGE="us.spotco.WebviewOverlay"
}
download_file() {
	STATUS=0
	ui_print "  Downloading..."

	curl -kLo "$TMPDIR"/$1 $2

	if [[ ! -f "$TMPDIR/$1" ]]; then
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
	if [ $SHA_FILE_CALCULATED = $SHA_FILE ]; then
		ui_print "  Integrity checked!"
	else
		ui_print "  Integrity not checked!"
		exit 1
	fi
}
replace_old_webview() {
	for i in "com.android.chrome" "com.android.webview" "com.google.android.webview"; do
		unsanitized_path=$(cmd package dump "$i" | grep codePath)
		path=${unsanitized_path##*=}
		if [ -d "$path" ]; then
			mktouch "$MODPATH"$path/.replace
		fi
	done
}
copy_webview_file() {
	cp_ch "$TMPDIR"/webview.apk "$MODPATH"/$VW_SYSTEM_PATH/webview.apk
	cp_ch "$TMPDIR"/webview.apk "$TMPDIR"/webview.zip
}
extract_lib() {
	mkdir -p "$MODPATH"/$VW_SYSTEM_PATH/lib/arm64 "$MODPATH"/$VW_SYSTEM_PATH/lib/arm
	cp -rf "$TMPDIR"/webview/lib/arm64-v8a/* "$MODPATH"/$VW_SYSTEM_PATH/lib/arm64
	cp -rf "$TMPDIR"/webview/lib/armeabi-v7a/* "$MODPATH"/$VW_SYSTEM_PATH/lib/arm
}
install_webview() {
	mktouch "$MODPATH"/$VW_SYSTEM_PATH/.replace
	copy_webview_file
	su -c "pm install -r -t --user 0 ${TMPDIR}/webview.apk" >&2
	mkdir -p "$TMPDIR"/webview
	unzip -qo "$TMPDIR"/webview.zip -d "$TMPDIR"/webview >&2
	extract_lib
}
create_overlay() {
	cp_ch "$TMPDIR"/$OVERLAY_ZIP_FILE "$MODPATH"/common
	unzip -qo "$MODPATH"/common/$OVERLAY_ZIP_FILE -d "$MODPATH"/common >&2
	aapt p -f -v -M "$MODPATH"/common/overlay/AndroidManifest.xml -I /system/framework/framework-res.apk -S "$MODPATH"/common/overlay/res -F "$MODPATH"/unsigned.apk >&2
}
sign_framework_res() {
	sign "$MODPATH"/unsigned.apk "$MODPATH"/signed.apk
	cp_ch "$MODPATH"/signed.apk "$MODPATH"/common/$OVERLAY_APK_FILE
}
find_overlay_path() {
	if [ -d /system_ext/overlay ]; then
		OVERLAY_PATH=system/system_ext/overlay/
	elif [ -d /product/overlay ]; then
		OVERLAY_PATH=system/product/overlay/
	elif [ -d /vendor/overlay ]; then
		OVERLAY_PATH=system/vendor/overlay/
	elif [ -d /system/overlay ]; then
		OVERLAY_PATH=system/overlay/
	else
		STATUS=0
	fi
}
force_overlay() {
	mkdir -p "$MODPATH"/$OVERLAY_PATH
	cp_ch "$MODPATH"/common/$OVERLAY_APK_FILE "$MODPATH"/$OVERLAY_PATH
	if [[ -d "$MODPATH"/product ]]; then
		if [[ -d "$MODPATH"/system/product ]]; then
			cp -rf "$MODPATH"/product/* "$MODPATH"/system/product/
			rm -rf "$MODPATH"/product/
		else
			mv "$MODPATH"/product/ "$MODPATH"/system/
		fi
	fi
}
clean_up() {
	if [ $1 -eq 1 ]; then
		ui_print "  Cleaning up..."
		rm -rf "$MODPATH"/common/$OVERLAY_ZIP_FILE
		rm -rf "$MODPATH"/signed.apk "$MODPATH"/unsigned.apk
		ui_print "  !!! Dalvik cache will be cleared next boot."
		ui_print "  !!! Boot time may be longer."
	else
		ui_print ""
		abort "  Aborting..."
	fi
}

if [ ! "$BOOTMODE" ]; then
	ui_print "  Installing through recovery NOT supported"
	ui_print "  Intsall this module via Magisk Manager"
	STATUS=0
	clean_up $STATUS
fi

if [ $API -ge 29 ]; then
	OVERLAY_API=29
fi

ui_print "  Choose between:"
ui_print "    Bromite, Mulch"
sleep 3
ui_print ""
ui_print "  Select:"
ui_print "  -> Bromite [Vol+ = yes, Vol- = no]"
if chooseport 3; then
	bromite
	NEXT_SELECTION=0
fi
if [ "${NEXT_SELECTION}" -eq 1 ]; then
	ui_print "  -> Mulch [Vol+ = yes, Vol- = no]"
	if chooseport 3; then
		mulch
		NEXT_SELECTION=0
	else
		SKIP_INSTALLATION=1
	fi
fi

if [ $SKIP_INSTALLATION -eq 0 ]; then
	ui_print "  Detecting architecture..."
	ui_print "  CPU architecture: ${ARCH}"
	download_file webview.apk $VW_APK_URL
	check_status
	if [ ! -z "$VW_SHA_URL" ]; then
		download_file $VW_SHA_FILE $VW_SHA_URL
		check_status
		ui_print "  Checking integrity..."
		check_integrity webview.apk $VW_SHA_FILE
	fi

	ui_print "  Installing webview..."
	replace_old_webview
	install_webview
	download_file $OVERLAY_ZIP_FILE $VW_OVERLAY_URL
	ui_print "  Creating overlay..."
	create_overlay
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

		if [ ! -f "${MODPATH}/$OVERLAY_PATH$OVERLAY_APK_FILE" ]; then
			STATUS=0
		fi

		if [ -f $CONFIG_FILE ]; then
			rm -rf $CONFIG_FILE
		fi
		echo "RESET=1" >> $CONFIG_FILE
		echo "VW_NAME=${VW_NAME}" >> $CONFIG_FILE
		echo "OVERLAY_PATH=${OVERLAY_PATH}" >> $CONFIG_FILE
		echo "OVERLAY_APK_FILE=${OVERLAY_APK_FILE}" >> $CONFIG_FILE
		echo "VW_PACKAGE=${VW_PACKAGE}" >> $CONFIG_FILE
		echo "VW_OVERLAY_PACKAGE=${VW_OVERLAY_PACKAGE}" >> $CONFIG_FILE
	fi
else
	ui_print "  Webview will not be replaced!"
fi

clean_up $STATUS