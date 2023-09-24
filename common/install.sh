#!/system/bin/sh
SKIP_INSTALLATION=0
ANDROID_VANADIUM_VERSION=13
OVERLAY_API=28
OVERLAY_APK_FILE="WebviewOverlay.apk"
CONFIG_FILE="$MODPATH/.webview"

get_version_github() {
	curl -kLs "https://api.github.com/repos/$1/releases/latest" |
		grep '"tag_name":' |
		sed -E 's/.*"(.*)".*/\1/'
}
get_sha_gitlab_lfs() {
	curl -kLs "https://gitlab.com/api/v4/projects/$1/repository/files/$2" |
		grep 'oid sha256:' |
		cut -d":" -f2
}
get_sha_gitlab() {
	curl -kLs "https://gitlab.com/api/v4/projects/$1/repository/files/$2" |
		grep 'content_sha256:' |
		cut -d":" -f2
}
mulch() {
	VW_APK_URL=https://gitlab.com/divested-mobile/mulch/-/raw/master/prebuilt/${ARCH}/webview.apk
	VW_TRICHROME_LIB_URL=""
	VW_SHA=$(get_sha_gitlab_lfs "30111188" "prebuilt%2F${ARCH}%2Fwebview.apk/raw?ref=master")
	VW_SYSTEM_PATH=system/app/MulchWebview
	VW_PACKAGE="us.spotco.mulch_wv"
	VW_OVERLAY_PACKAGE="us.spotco.WebviewOverlay"
	OVERLAY_ZIP_FILE="mulch-overlay${OVERLAY_API}.zip"
}
vanadium() {
	VW_APK_URL=https://gitlab.com/api/v4/projects/40905333/repository/files/prebuilt%2F${1}%2FTrichromeWebView.apk/raw?ref=${ANDROID_VANADIUM_VERSION}
	VW_TRICHROME_LIB_URL=https://gitlab.com/api/v4/projects/40905333/repository/files/prebuilt%2F${1}%2FTrichromeLibrary.apk/raw?ref=${ANDROID_VANADIUM_VERSION}
	# VW_SHA=$(get_sha_gitlab "40905333" "prebuilt%2F${1}%2FTrichromeWebView.apk?ref=13")
	VW_SHA=""
	VW_SYSTEM_PATH=system/app/VanadiumWebview
	VW_PACKAGE="app.vanadium.webview"
	VW_OVERLAY_PACKAGE="app.vanadium.WebviewOverlay"
	OVERLAY_ZIP_FILE="vanadium-overlay${OVERLAY_API}.zip"
}
download_file() {
	ui_print "  Downloading..."

	curl -skL "$2" -o "$TMPDIR"/$1

	if [[ ! -f "$TMPDIR"/$1 ]]; then
		check_status 1
	fi
}
check_status() {
	if [[ $1 -eq 0 ]]; then
		ui_print ""
		ui_print "  !!! Dowload failed !!!"
		ui_print ""
		clean_up $1
	fi
}
check_integrity() {
	if [ -f "/sbin/sha256sum" ]; then
		SHA_FILE_CALCULATED=$(/sbin/sha256sum $1 | cut -d' ' -f1)
	else
		SHA_FILE_CALCULATED=$(sha256sum $1 | cut -d' ' -f1)
	fi
	
	if [[ $SHA_FILE_CALCULATED = $2 ]]; then
		ui_print "  Integrity checked!"
	else
		ui_print "  Integrity not checked!"
		clean_up 1
	fi
}
replace_old_webview() {
	for i in "com.android.chrome" "com.android.webview" "com.google.android.webview" "org.mozilla.webview_shell"; do
		local IS_OLD_WEBVIEW_INSTALLED OLD_WEBVIEW_PATH
		IS_OLD_WEBVIEW_INSTALLED=$(cmd package dump "$i" | grep codePath)
		if [[ -n $IS_OLD_WEBVIEW_INSTALLED ]]; then
			ui_print "  Detecting webview: $i"
			OLD_WEBVIEW_PATH=${IS_OLD_WEBVIEW_INSTALLED##*=}
			ui_print "  Webview $OLD_WEBVIEW_PATH detected"
			if [[ -d $OLD_WEBVIEW_PATH ]]; then
				mktouch "$MODPATH"/$OLD_WEBVIEW_PATH/.replace
			fi
		fi
	done
}
extract_lib() {
	mkdir -p "$MODPATH"/$VW_SYSTEM_PATH/lib/arm64 "$MODPATH"/$VW_SYSTEM_PATH/lib/arm
	cp -rf "$TMPDIR"/webview/lib/arm64-v8a/* "$MODPATH"/$VW_SYSTEM_PATH/lib/arm64
	cp -rf "$TMPDIR"/webview/lib/armeabi-v7a/* "$MODPATH"/$VW_SYSTEM_PATH/lib/arm
}
copy_webview_file() {
	cp_ch "$TMPDIR"/webview.apk "$MODPATH"/$VW_SYSTEM_PATH/webview.apk
	cp_ch "$TMPDIR"/webview.apk "$TMPDIR"/webview.zip
}
install_webview() {
	mktouch "$MODPATH"/$VW_SYSTEM_PATH/.replace
	mkdir -p "$TMPDIR"/webview
	unzip -qo "$TMPDIR"/webview.zip -d "$TMPDIR"/webview >&2
	extract_lib
	copy_webview_file
	if [[ ! -z $VW_TRICHROME_LIB_URL ]]; then
		download_file trichrome.apk $VW_TRICHROME_LIB_URL
		ui_print "  Installing trichrome library..."
		su -c "pm install -r -t --user 0 ${TMPDIR}/trichrome.apk" >&2
	fi
	su -c "pm install -r -t --user 0 ${TMPDIR}/webview.apk" >&2
}
create_overlay() {
	unzip -qo "$MODPATH"/overlays/$OVERLAY_ZIP_FILE -d "$MODPATH"/overlays/overlay >&2
	aapt p -fvM "$MODPATH"/overlays/overlay/AndroidManifest.xml -I /system/framework/framework-res.apk -S "$MODPATH"/overlays/overlay/res -F "$MODPATH"/unsigned.apk >&2
}
sign_framework_res() {
	sign "$MODPATH"/unsigned.apk "$MODPATH"/signed.apk
	mv -f "$MODPATH"/signed.apk "$MODPATH"/common/$OVERLAY_APK_FILE
}
find_overlay_path() {
	if [[ -d /product/overlay ]]; then
		OVERLAY_PATH=system/product/overlay/
	elif [[ -d /system_ext/overlay ]]; then
		OVERLAY_PATH=system/system_ext/overlay/
	elif [[ -d /system/overlay ]]; then
		OVERLAY_PATH=system/overlay/
	elif [[ -d /system/vendor/overlay ]]; then
		OVERLAY_PATH=system/vendor/overlay/
	else
		ui_print "  Unable to find a correct overlay path."
		clean_up 1
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
	if [[ $1 -eq 1 ]]; then
		ui_print ""
		abort "  Aborting..."
	fi

	ui_print "  Cleaning up..."
	rm -rf "$MODPATH"/overlays/overlay
	ui_print "  !!! Dalvik cache will be cleared next boot."
	ui_print "  !!! Boot time may be longer."
}

if [[ ! $BOOTMODE ]]; then
	ui_print "  Installing through recovery NOT supported!"
	ui_print "  Install this module via Magisk Manager"
	clean_up 1
fi

if [[ $API -ge 29 ]]; then
	OVERLAY_API=29
fi

if [[ $API -ge 34 ]]; then
	ANDROID_VANADIUM_VERSION=14
fi

ui_print "  Choose between:"
if [[ $IS64BIT ]]; then
	ui_print "    Mulch, Vanadium"
else
	ui_print "    Mulch"
fi
sleep 3
ui_print ""
ui_print "  Select: [Vol+ = yes, Vol- = no]"
ui_print "  -> Mulch"
if chooseport 3; then
	mulch
else
	if [[ $IS64BIT ]]; then
		ui_print "  -> Vanadium"
		if chooseport 3; then
			if [[ $ARCH = "arm64" ]]; then
				vanadium "arm64"
			else
				vanadium "x86_64"
			fi
		else
			SKIP_INSTALLATION=1
		fi
	else
		SKIP_INSTALLATION=1
	fi
fi

if [[ $SKIP_INSTALLATION -eq 0 ]]; then
	ui_print "  Detecting architecture..."
	ui_print "  CPU architecture: ${ARCH}"
	download_file webview.apk $VW_APK_URL
	if [[ ! -z $VW_SHA ]]; then
		ui_print "  Checking integrity..."
		check_integrity webview.apk $VW_SHA
	fi
	ui_print "  Installing webview..."
	replace_old_webview
	install_webview
	ui_print "  Creating overlay..."
	create_overlay
	if [[ ! -f "$MODPATH"/unsigned.apk ]]; then
		ui_print ""
		ui_print "  !!! Overlay creation has failed !!!"
		ui_print "  Compatibility is unlikely, please report this to your ROM developer."
		ui_print "  Some ROMs need a patch to fix this."
		ui_print "  Do NOT report this issue to me."
		clean_up 1
	fi
	sign_framework_res
	find_overlay_path
	force_overlay

	if [[ ! -f "$MODPATH"/$OVERLAY_PATH$OVERLAY_APK_FILE ]]; then
		ui_print "  Missing overlay apk file"
		clean_up 1
	fi

	if [[ -f $CONFIG_FILE ]]; then
		rm -rf $CONFIG_FILE
	fi
	echo "RESET=1" >>$CONFIG_FILE
	echo "OVERLAY_PATH=${OVERLAY_PATH}" >>$CONFIG_FILE
	echo "OVERLAY_APK_FILE=${OVERLAY_APK_FILE}" >>$CONFIG_FILE
	echo "VW_PACKAGE=${VW_PACKAGE}" >>$CONFIG_FILE
	echo "VW_OVERLAY_PACKAGE=${VW_OVERLAY_PACKAGE}" >>$CONFIG_FILE
	clean_up 0
else
	abort "  Webview will not be replaced!"
fi
