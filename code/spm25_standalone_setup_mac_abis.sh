#!/bin/bash

## Google Drive file IDs
fid_arm64="1BCHhsVwcqQFR8IoYxh8t5JR9XfWn4RsO"
fid_amd64="1YST4g38UJ7HfyhWtqfhekJW7UY64Bv8E"
fname_arm64="spm25_standalone_arm64_R2025b.zip"
fname_amd64="spm25_standalone_amd64_R2025b.zip"

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

if ! grep -q 'Alias for SPM25 R2025b' "$CONFIG_FILE"; then
  echo "" >> "$CONFIG_FILE"
  echo "# Alias for SPM25 R2025b" >> "$CONFIG_FILE"
  echo "alias spm25='/opt/standalone/spm25_standalone/run_spm25.sh /Applications/MATLAB/MATLAB_Runtime/R2025b'" >> "$CONFIG_FILE"
  echo "SPM25 standaloneの設定が完了しました"
  echo "ターミナルを新たに立ち上げて spm25 とタイプするとSPM25が起動します"
else
  echo "$CONFIG_FILE にはすでに SPM25 の設定が存在します"
fi

