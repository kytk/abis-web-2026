#!/bin/bash

cd ~/Downloads
echo "AlizaMSをダウンロードします"
curl -O -C -  https://www.nemotos.net/l4n-abis/macOS_2025/AlizaMS-1.8.3.dmg

sleep 3

echo "AlizaMSをインストールします"
hdiutil attach AlizaMS-1.8.3.dmg
cp -R /Volumes/AlizaMS-1.8.3/AlizaMS.app /Applications/

echo "dmgファイルをアンマウントします"
hdiutil detach /Volumes/AlizaMS-1.8.3

echo "AlizaMSのインストールが完了しました。"

