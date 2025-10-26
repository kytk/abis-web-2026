#!/bin/bash

## Google Drive file IDs
fid_arm64="1S6MZap-eWCB29ZYhOsWWYMM6EMByQgky"
fid_amd64="13Io0eaIse7142HIr7A8CXdTOY1jwXMB_"
fname_arm64="conn22v2407_standalone_arm64_R2025b.zip"
fname_amd64="conn22v2407_standalone_amd64_R2025b.zip"

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
  sudo mkdir /opt/standalone && sudo chown -R $USER /opt/standalone
  unzip ${output_file} -d /opt/standalone

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

# 過去のバージョンを削除する
if [ -d /opt/standalone/conn22v2407_standalone ]; then
    rm -rf /opt/standalone/conn22v2407
fi

# 設定ファイルをアップデートする
sed -i '' '/conn22v2407_standalone/s/R2024b/R2025b/' "$CONFIG_FILE"

if ! grep -q 'Alias for CONN22v2407' "$CONFIG_FILE"; then
  echo "" >> "$CONFIG_FILE"
  echo "# Alias for CONN22v2407" >> "$CONFIG_FILE"
  echo "alias conn='/opt/standalone/conn22v2407_standalone/run_conn.sh /Applications/MATLAB/MATLAB_Runtime/R2025b'" >> "$CONFIG_FILE"
  echo "CONN22 v2407 standaloneの設定が完了しました"
  echo "ターミナルを新たに立ち上げて conn とタイプすると CONN が起動します"
else
  echo "$CONFIG_FILE にはすでに CONN22 v2407 の設定が存在します"
fi

