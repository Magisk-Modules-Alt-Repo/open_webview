#!/system/bin/sh
SKIP_INSTALLATION=0
ANDROID_VANADIUM_VERSION=13
OVERLAY_API=28
OVERLAY_APK_FILE="WebviewOverlay.apk"
IS_REINSTALL=0
CONFIG_FILE="$MODPATH"/.webview
LOG="$MODPATH"/webview.log

get_version_github() {
	local repo=$1
    local asset_name=$2

	echo "[$(date "+%H:%M:%S")] Get correct github versione using repo=${repo} and asset_name=${asset_name}" >>$LOG

	curl -s "https://api.github.com/repos/$repo/releases" | \
    awk -v asset_name="$asset_name" '
        BEGIN { tag_name = "" }
        /"tag_name":/ { tag_name = $2; gsub(/"|,/, "", tag_name) }
        /"name":/ { name = $2; gsub(/"|,/, "", name) }
        name == asset_name { print tag_name; exit }
    '
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
get_system_path_according_to_rom() {
	local is_los=$(getprop | grep -o -c "lineage")

	if [[ $is_los -gt 0 ]]; then
		echo "system/product/app"
	else
		echo "system/app"
	fi
}
mulch() {
	VW_APK_URL=https://gitlab.com/divested-mobile/mulch/-/raw/master/prebuilt/${ARCH}/webview.apk
	VW_TRICHROME_APK_URL=""
	VW_SHA=$(get_sha_gitlab_lfs "30111188" "prebuilt%2F${ARCH}%2Fwebview.apk/raw?ref=master")
	VW_SYSTEM_PATH=$(get_system_path_according_to_rom)/MulchWebview
	VW_PACKAGE="us.spotco.mulch_wv"
	VW_OVERLAY_PACKAGE="us.spotco.WebviewOverlay"
	OVERLAY_ZIP_FILE="mulch-overlay${OVERLAY_API}.zip"
}
vanadium() {
	VW_APK_URL=https://gitlab.com/api/v4/projects/40905333/repository/files/prebuilt%2F${1}%2FTrichromeWebView.apk/raw?ref=${ANDROID_VANADIUM_VERSION}
	VW_TRICHROME_APK_URL=https://gitlab.com/api/v4/projects/40905333/repository/files/prebuilt%2F${1}%2FTrichromeLibrary.apk/raw?ref=${ANDROID_VANADIUM_VERSION}
	# VW_SHA=$(get_sha_gitlab "40905333" "prebuilt%2F${1}%2FTrichromeWebView.apk?ref=${ANDROID_VANADIUM_VERSION}")
	VW_SHA=""
	VW_SYSTEM_PATH=$(get_system_path_according_to_rom)/VanadiumWebview
	VW_PACKAGE="app.vanadium.webview"
	VW_OVERLAY_PACKAGE="app.vanadium.WebviewOverlay"
	OVERLAY_ZIP_FILE="vanadium-overlay${OVERLAY_API}.zip"
}
cromite() {
	VW_APK_URL=https://github.com/uazo/cromite/releases/download/$(get_version_github "uazo/cromite" "${ARCH}_SystemWebView64.apk")/${ARCH}_SystemWebView64.apk
	VW_TRICHROME_APK_URL=""
	VW_SHA=""
	VW_SYSTEM_PATH=""
	VW_PACKAGE="cromite"
	VW_OVERLAY_PACKAGE=""
	OVERLAY_ZIP_FILE=""
}
download_file() {
	ui_print "  Downloading $1..."
	echo "[$(date "+%H:%M:%S")] Downloading file: $1 from source: $2" >>$LOG

	curl -skLf "$2" -o "$TMPDIR"/$1

	if [[ ! -f "$TMPDIR"/$1 ]]; then
		echo "[$(date "+%H:%M:%S")] Dowload failed" >>$LOG
		ui_print ""
		ui_print "  !!! Dowload failed !!!"
		ui_print ""
		clean_up 1
	fi
	echo "[$(date "+%H:%M:%S")] File downloaded: $TMPDIR/$1" >>$LOG
}
check_integrity() {
	if [ -f "/sbin/sha256sum" ]; then
		echo "[$(date "+%H:%M:%S")] SHA256SUM calculated with magisk lib" >>$LOG
		SHA_FILE_CALCULATED=$(/sbin/sha256sum $1 | cut -d' ' -f1)
	else
		echo "[$(date "+%H:%M:%S")] SHA256SUM calculated with system native lib" >>$LOG
		SHA_FILE_CALCULATED=$(sha256sum $1 | cut -d' ' -f1)
	fi
	
	echo "[$(date "+%H:%M:%S")] SHA256SUM calculated: $SHA_FILE_CALCULATED" >>$LOG
	echo "[$(date "+%H:%M:%S")] SHA256SUM from file: $2" >>$LOG

	if [[ $SHA_FILE_CALCULATED = $2 ]]; then
		echo "[$(date "+%H:%M:%S")] Integrity checked" >>$LOG
		ui_print "  Integrity checked!"
	else
		echo "[$(date "+%H:%M:%S")] Integrity not checked" >>$LOG
		ui_print "  Integrity not checked!"
		clean_up 1
	fi
}
replace_old_webview() {
	echo "[$(date "+%H:%M:%S")] Exclude installed package that can create conflict" >>$LOG
	ui_print "  Excluding installed package that can create conflict..."
	for i in "com.android.chrome" "com.android.webview" "com.google.android.webview" "org.mozilla.webview_shell" "com.sec.android.app.chromecustomizations" "com.google.android.trichromelibrary"; do
		local IS_OLD_WEBVIEW_INSTALLED OLD_WEBVIEW_PATH
		IS_OLD_WEBVIEW_INSTALLED=$(cmd package dump "$i" | grep codePath)
		if [[ -n $IS_OLD_WEBVIEW_INSTALLED ]]; then
			ui_print "  Detecting webview: $i"
			OLD_WEBVIEW_PATH=${IS_OLD_WEBVIEW_INSTALLED##*=}
			if [[ ! -z $OLD_WEBVIEW_PATH ]]; then
				echo "[$(date "+%H:%M:%S")] Webview replaced: $OLD_WEBVIEW_PATH" >>$LOG
				ui_print "  Webview $OLD_WEBVIEW_PATH detected"
				mktouch "$MODPATH"$OLD_WEBVIEW_PATH/.replace
			fi
		fi
	done
}
extract_lib() {
	echo "[$(date "+%H:%M:%S")] Extracting lib from downloaded webview as zip" >>$LOG
	mkdir -p "$MODPATH"/$VW_SYSTEM_PATH/lib/arm64 "$MODPATH"/$VW_SYSTEM_PATH/lib/arm
	echo "[$(date "+%H:%M:%S")] Copying from $TMPDIR/webview/lib/arm64-v8a/ to $MODPATH/$VW_SYSTEM_PATH/lib/arm64" >>$LOG
	cp -rf "$TMPDIR"/webview/lib/arm64-v8a/* "$MODPATH"/$VW_SYSTEM_PATH/lib/arm64
	echo "[$(date "+%H:%M:%S")] Copying from $TMPDIR/webview/lib/armeabi-v7a/ to $MODPATH/$VW_SYSTEM_PATH/lib/arm" >>$LOG
	cp -rf "$TMPDIR"/webview/lib/armeabi-v7a/* "$MODPATH"/$VW_SYSTEM_PATH/lib/arm
}
copy_webview_file() {
	echo "[$(date "+%H:%M:%S")] Copy webview.apk from: $TMPDIR  -  to: $VW_SYSTEM_PATH" >>$LOG
	cp_ch "$TMPDIR"/webview.apk "$MODPATH"/$VW_SYSTEM_PATH/webview.apk
	cp_ch "$TMPDIR"/webview.apk "$TMPDIR"/webview.zip
}
install_webview() {
	echo "[$(date "+%H:%M:%S")] Install webview" >>$LOG
	ui_print "  Installing webview..."
	mktouch "$MODPATH"/$VW_SYSTEM_PATH/.replace
	copy_webview_file
	su -c pm install --install-location 1 trichrome.apk  >&2
	mkdir -p "$TMPDIR"/webview
	unzip -qo "$TMPDIR"/webview.zip -d "$TMPDIR"/webview >&2
	extract_lib
}
download_install_webview() {
	download_file webview.apk $VW_APK_URL

	if [[ ! -z $VW_TRICHROME_APK_URL ]]; then
		download_file trichrome.apk $VW_TRICHROME_APK_URL
	fi

	if [[ ! -z $VW_SHA ]]; then
		ui_print "  Checking integrity..."
		check_integrity webview.apk $VW_SHA
	fi
	replace_old_webview
	install_webview
}
create_overlay() {
	echo "[$(date "+%H:%M:%S")] Create overlay" >>$LOG
	ui_print "  Creating overlay..."
	unzip -qo "$MODPATH"/overlays/$OVERLAY_ZIP_FILE -d "$MODPATH"/overlays/overlay >&2
	MODTMPDIR="$(mktemp -d)"
	if [ -n "$MODTMPDIR" ] && [ -d "$MODTMPDIR" ]; then
		aapt2 compile -v --dir "$MODPATH"/overlays/overlay/res -o "$MODTMPDIR" && \
			aapt2 link -o "$MODPATH"/unsigned.apk -I /system/framework/framework-res.apk --manifest "$MODPATH"/overlays/overlay/AndroidManifest.xml "$MODTMPDIR"/* >&2
		rm -rf "$MODTMPDIR"
	fi
}
sign_framework_res() {
	echo "[$(date "+%H:%M:%S")] Sign modified framework-res" >>$LOG
	sign "$MODPATH"/unsigned.apk "$MODPATH"/signed.apk
	mv -f "$MODPATH"/signed.apk "$MODPATH"/common/$OVERLAY_APK_FILE
}
find_overlay_path() {
	echo "[$(date "+%H:%M:%S")] Finding overlay path" >>$LOG
	if [[ -d /product/overlay ]]; then
		OVERLAY_PATH=system/product/overlay/
	elif [[ -d /system_ext/overlay ]]; then
		OVERLAY_PATH=system/system_ext/overlay/
	elif [[ -d /system/overlay ]]; then
		OVERLAY_PATH=system/overlay/
	elif [[ -d /system/vendor/overlay ]]; then
		OVERLAY_PATH=system/vendor/overlay/
	else
		echo "[$(date "+%H:%M:%S")] Unable to find overlay path" >>$LOG
		ui_print "  Unable to find a correct overlay path."
		clean_up 1
	fi
	echo "[$(date "+%H:%M:%S")] Overlay path: $OVERLAY_PATH" >>$LOG
}
force_overlay() {
	echo "[$(date "+%H:%M:%S")] Forcing overlay" >>$LOG
	mkdir -p "$MODPATH"/$OVERLAY_PATH
	echo "[$(date "+%H:%M:%S")] Copy $OVERLAY_APK_FILE  -  to: $OVERLAY_PATH" >>$LOG
	cp_ch "$MODPATH"/common/$OVERLAY_APK_FILE "$MODPATH"/$OVERLAY_PATH
	if [[ -d "$MODPATH"/product ]]; then
		if [[ -d "$MODPATH"/system/product ]]; then
			echo "[$(date "+%H:%M:%S")] Using /system/product as overlay path" >>$LOG
			cp -rf "$MODPATH"/product/* "$MODPATH"/system/product/
			rm -rf "$MODPATH"/product/
		else
			echo "[$(date "+%H:%M:%S")] Moving from /product to /system" >>$LOG
			mv "$MODPATH"/product/ "$MODPATH"/system/
		fi
	fi
}
create_config_file() {
	echo "IS_REINSTALL=${IS_REINSTALL}" >>$CONFIG_FILE
	echo "RESET=1" >>$CONFIG_FILE
	echo "OVERLAY_PATH=${OVERLAY_PATH}" >>$CONFIG_FILE
	echo "OVERLAY_APK_FILE=${OVERLAY_APK_FILE}" >>$CONFIG_FILE
	echo "VW_PACKAGE=${VW_PACKAGE}" >>$CONFIG_FILE
	echo "VW_OVERLAY_PACKAGE=${VW_OVERLAY_PACKAGE}" >>$CONFIG_FILE
}
clean_up() {
	if [[ $1 -eq 1 ]]; then
		echo "[$(date "+%H:%M:%S")] Abort installation" >>$LOG
		ui_print ""
		cp_ch $LOG /sdcard/
		abort "  Aborting..."
	fi

	ui_print "  Cleaning up..."
	rm -rf "$MODPATH"/overlays/overlay
	ui_print "  !!! Dalvik cache will be cleared next boot."
	ui_print "  !!! Boot time may be longer."
	echo "[$(date "+%H:%M:%S")] Installation success" >>$LOG
}

echo "# open-webview v2.4.0" > $LOG
echo -e "# Author: @f3ffo (Github)\n" >>$LOG
echo "[$(date "+%H:%M:%S")] Brand: $(getprop ro.product.system.brand)" >>$LOG
echo "[$(date "+%H:%M:%S")] Device: $(getprop ro.product.system.device)" >>$LOG
echo "[$(date "+%H:%M:%S")] Manufacter: $(getprop ro.product.system.manufacter)" >>$LOG
echo "[$(date "+%H:%M:%S")] Model: $(getprop ro.product.system.model)" >>$LOG
echo "[$(date "+%H:%M:%S")] Arch: $ARCH" >>$LOG
echo "[$(date "+%H:%M:%S")] System name: $(getprop ro.product.system.name)" >>$LOG
echo -e "[$(date "+%H:%M:%S")] Android Version: $(getprop ro.system.build.version.release)\n" >>$LOG

if [[ ! $BOOTMODE ]]; then
	echo "[$(date "+%H:%M:%S")] Install through recovery" >>$LOG
	ui_print "  Installing through recovery NOT supported!"
	ui_print "  Install this module via Magisk Manager"
	clean_up 1
fi

if [[ $API -ge 29 ]]; then
	OVERLAY_API=29
fi

if [[ $API -eq 33 ]]; then
	ANDROID_VANADIUM_VERSION=13
elif [[ $API -eq 34 ]]; then
	ANDROID_VANADIUM_VERSION=14
elif [[ $API -eq 35 ]]; then
	ANDROID_VANADIUM_VERSION=15
fi

ui_print "  Choose between:"
if [[ $IS64BIT ]]; then
	if [[ $API -ge 29 ]] && [[ $API -lt 33 ]]; then
		ui_print "    Mulch, Cromite"
	elif [[ $API -ge 33 ]]
		ui_print "    Mulch, Vanadium, Cromite"
	fi
else
	ui_print "    Mulch"
fi
sleep 3
ui_print ""
ui_print "  Select: [Vol+ = yes, Vol- = no]"

ui_print "  -> Mulch"
if chooseport 3; then
	echo "[$(date "+%H:%M:%S")] Select mulch" >>$LOG
	mulch
else
	SKIP_INSTALLATION=1
fi

if [[ $IS64BIT ]]; then
	if [[ $API -ge 33 ]] && [[ $SKIP_INSTALLATION -eq 1 ]]; then
		SKIP_INSTALLATION=0
		ui_print "  -> Vanadium"
		if chooseport 3; then
			if [[ $ARCH = "arm64" ]]; then
				echo "[$(date "+%H:%M:%S")] Select vanadium for arm64" >>$LOG
				vanadium "arm64"
			else
				echo "[$(date "+%H:%M:%S")] Select vanadium for x86_64" >>$LOG
				vanadium "x86_64"
			fi
		else
			SKIP_INSTALLATION=1
		fi
	fi
	if [[ $API -ge 29 ]] && [[ $SKIP_INSTALLATION -eq 1 ]]; then
			SKIP_INSTALLATION=0
			ui_print "  -> Cromite"
			if chooseport 3; then
				echo "[$(date "+%H:%M:%S")] Select cromite" >>$LOG
				cromite
			else
				SKIP_INSTALLATION=1
			fi
		fi
	fi
fi

if [[ $SKIP_INSTALLATION -eq 0 ]]; then
	if [[ -f $CONFIG_FILE ]]; then
		echo "[$(date "+%H:%M:%S")] Remove old config file" >>$LOG
		rm -rf $CONFIG_FILE
		IS_REINSTALL=1
	fi
	
	if [[ $VW_PACKAGE == "cromite" ]]; then
		download_file webview.apk $VW_APK_URL
		su -c pm install --install-location 1 webview.apk  >&2
	else
		if [[ $VW_PACKAGE == "us.spotco.mulch_wv" ]]; then
			ui_print ""
			ui_print "  Do you want this module to download and install the latest Mulch webview as a system app?"
			ui_print ""
			ui_print "  [Vol+ = Yes, download and install]"
			ui_print "  [Vol- = No, minimal setup for manual installation]"
			if chooseport 5; then
				ui_print "  CPU architecture: ${ARCH}"
				download_install_webview
			fi
		else
			ui_print "  CPU architecture: ${ARCH}"
			download_install_webview
		fi

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
			echo "[$(date "+%H:%M:%S")] Overlay file missing in path: $OVERLAY_PATH" >>$LOG
			ui_print "  Missing overlay apk file"
			clean_up 1
		fi
	fi

	create_config_file
	clean_up 0
else
	echo "[$(date "+%H:%M:%S")] No webview selected" >>$LOG
	ui_print "  No webview selected!"
	clean_up 0
fi
