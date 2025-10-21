#!/bin/bash

cd ~/Downloads
curl -OL https://github.com/rordenlab/dcm2niix/releases/download/v1.0.20250506/dcm2niix_mac.zip
[[ -e dcm2niix_mac.zip ]] && unzip dcm2niix_mac.zip
[[ -d /Applications/dcm2niix ]] || mkdir /Applications/dcm2niix
cp dcm2niix /Applications/dcm2niix/

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

if ! grep -q '#dcm2niix' "$CONFIG_FILE"; then
    echo '' >> "$CONFIG_FILE"
    echo '#dcm2niix' >> "$CONFIG_FILE"
    echo 'PATH=/Applications/dcm2niix:$PATH' >> "$CONFIG_FILE"
    echo "$CONFIG_FILE に dcm2niix の設定を追加しました"
fi

