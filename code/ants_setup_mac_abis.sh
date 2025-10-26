#!/bin/bash

## Google Drive file IDs
fid_arm64="1pZIZ4ICPo4kzoCTfoKanEXB4jvfv0LVZ"
fid_amd64="17pDj7ygzgRq_XoWgtO1vdnu9VxO5Cy1T"
fname_arm64="ANTS_arm64.zip"
fname_amd64="ANTS_amd64.zip"

cd ~/Downloads
arch=$(uname -m)
if [ $arch = 'arm64' ]; then
  file_id=${fid_arm64} 
  output_file=${fname_arm64}
else
  file_id=${fid_amd64} 
  output_file=${fname_amd64}
fi

curl -L "https://drive.usercontent.google.com/download?id=${file_id}&confirm=xxx" -o "$output_file"
  unzip ${output_file} -d ~/

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

if ! grep -q '$HOME/ANTS/install/bin' "$CONFIG_FILE"; then
    echo  >> "$CONFIG_FILE"
    echo '# ANTs' >> "$CONFIG_FILE"
    echo 'export ANTSPATH=$HOME/ANTS/install/bin' >> "$CONFIG_FILE"
    echo 'export PATH=$PATH:$ANTSPATH' >> "$CONFIG_FILE"
    echo  >> "$CONFIG_FILE"
    echo "$CONFIG_FILE に ANTs の設定を追加しました"
else
    echo "$CONFIG_FILE には既に ANTs の設定が存在します"
fi


