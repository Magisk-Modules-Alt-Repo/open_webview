#!/system/bin/sh
webviews=(
    ".com.android.webview"
    ".us.spotco.mulch_wv"
    ".app.vanadium.webview"
)

webview_directory=""
for file in "${webviews[@]}"; do
    webview_directory=$(find /data/app/ -type d -name "*$file*" | head -n 1)
    if [ -n "$webview_directory" ]; then
        break
    fi
done

if [ -n "$webview_directory" ]; then
    rm -rf "$webview_directory"
fi

for directory in "${webviews[@]}"; do
    if [ -d "/data/data/$directory" ]; then
        rm -rf "/data/data/$directory"
    fi
done

# Don't modify anything after this
if [ -f $INFO ]; then
  while read LINE; do
    if [ "$(echo -n $LINE | tail -c 1)" == "~" ]; then
      continue
    elif [ -f "$LINE~" ]; then
      mv -f $LINE~ $LINE
    else
      rm -f $LINE
      while true; do
        LINE=$(dirname $LINE)
        [ "$(ls -A $LINE 2>/dev/null)" ] && break 1 || rm -rf $LINE
      done
    fi
  done < $INFO
  rm -f $INFO
fi
