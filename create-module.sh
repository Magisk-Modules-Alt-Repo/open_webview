#!/bin/bash
MODULE_NAME=open-webview.zip
TOOLS=tools.tar.xz

echo "deleting old files..."
rm -rf $MODULE_NAME
rm -rf common/tools/$TOOLS
echo -e "ok!\n\nzipping tools..."
tar -cJf common/tools/$TOOLS common/tools/tools
echo -e "ok!\n\ncreating module zip..."
7z a -tzip -r $MODULE_NAME ./* -x!./git/\* -x!./.github/\* -x!./img/\* -x!./common/tools/tools/\* -x!./README.md\* -x!./CHANGELOG.md\* -x!./gitignore\* >& /dev/null
echo "done!"