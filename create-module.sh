#!/bin/bash
MODULE_NAME=open-webview.zip
TOOLS=tools.tar
ROOT_DIR="$(pwd)"

echo "deleting old files..."
rm -rf $MODULE_NAME
rm -rf common/tools/"${TOOLS}.xz"
echo -e "ok!\n\nzipping tools..."
cd common/tools/tools
7z a -ttar -r $TOOLS * >& /dev/null
7z a -txz -r "${TOOLS}.xz" $TOOLS >& /dev/null
rm -rf $TOOLS
mv -f "${TOOLS}.xz" ../
cd $ROOT_DIR
echo -e "ok!\n\ncreating module zip..."
7z a -tzip -r $MODULE_NAME * -xr!.git* -xr!img -xr!common/tools/tools -xr!overlays/extracted -x!*.md -x!create-module.* >& /dev/null
echo "done!"

