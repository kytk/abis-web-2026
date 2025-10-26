#!/bin/bash

cd ~/Downloads
curl -OL https://github.com/rordenlab/MRIcroGL/releases/download/v1.2.20220720/MRIcroGL_macOS.dmg

DMG_PATH="~/Downloads/MRIcroGL_macOS.dmg"
hdiutil attach "$DMG_PATH"
VOLUME=/Volumes/MRIcroGL
echo "MRIcroGLをインストールします"
APP=$(find "$VOLUME" -name "*.app" -maxdepth 1)
cp -R "$APP" /Applications/

echo "dmgファイルをアンマウントします"
hdiutil detach "$VOLUME"

case "$SHELL" in
  */bash)
    CONFIG_FILE="$HOME/.bash_profile"
    ;;
  */zsh)
    CONFIG_FILE="$HOME/.zprofile"
    ;;
  *)
    echo "エラー: bash/zsh のみ対応しています（現在のシェル: $SHELL）" >&2
    exit 1
    ;;
esac

if ! grep -q '# MRIcroGL' "$CONFIG_FILE"; then
    echo '' >> "$CONFIG_FILE"
    echo '# MRIcroGL' >> "$CONFIG_FILE"
    echo 'PATH=$PATH:/Applications/MRIcroGL.app/Contents/MacOS' >> "$CONFIG_FILE"
    echo "$CONFIG_FILE に MRIcroGL の設定を追加しました"
fi

echo "MRIcroGLのインストールが完了しました。"

