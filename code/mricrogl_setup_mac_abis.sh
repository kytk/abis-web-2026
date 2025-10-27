#!/bin/bash

cd ~/Downloads
curl -OL -C - https://github.com/rordenlab/MRIcroGL/releases/download/v1.2.20220720/MRIcroGL_macOS.dmg

sleep 3

echo "MRIcroGLをインストールします"
hdiutil attach MRIcroGL_macOS.dmg
cp -R /Volumes/MRIcroGL/MRIcroGL.app /Applications/

echo "dmgファイルをアンマウントします"
hdiutil detach /Volumes/MRIcroGL/

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

