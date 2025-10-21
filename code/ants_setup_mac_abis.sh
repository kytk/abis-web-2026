#!/bin/bash

## Google Drive file IDs
ants_arm64_gdid="1pZIZ4ICPo4kzoCTfoKanEXB4jvfv0LVZ"
ants_amd64_gdid="17pDj7ygzgRq_XoWgtO1vdnu9VxO5Cy1T"
fname_arm64="ANTS_arm64.zip"
fname_amd64="ANTS_amd64.zip"

cd ~/Downloads
arch=$(uname -m)
if [ $arch = 'arm64' ]; then
  file_id=${ants_arm64_gdid} 
  output_file=${fname_arm64}
else
  file_id=${ants_amd64_gdid} 
  output_file=${fname_amd64}
fi

curl -L curl -L "https://drive.usercontent.google.com/download?id=${file_id}&confirm=xxx" -o "$output_file"
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


