#!/bin/bash

cd ~/Downloads
curl -O https://www.nemotos.net/l4n-abis/macOS_2025/AlizaMS-1.8.3.dmg

DMG_PATH="~/Downloads/AlizaMS-1.8.3.dmg"
hdiutil attach $DMG_PATH
VOLUME=/Volumes/AlizaMS-1.8.3/
echo "AlizaMSをインストールします"
APP=$(find "$VOLUME" -name "*.app" -maxdepth 1)
cp -R "$APP" /Applications/

echo "dmgファイルをアンマウントします"
hdiutil detach "$VOLUME"

echo "AlizaMSのインストールが完了しました。"

