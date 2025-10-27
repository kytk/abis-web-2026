#!/bin/bash

#!/usr/bin/env bash
# Script to install FreeSurfer on macOS
# This script downloads required files from Google Drive, installs them,
# and configures the subject directory under $HOME

# 22 Oct 2025 K. Nemoto
# Google Drive download integration version with Japanese/English messages

# Exit on error, undefined variables, and pipe failures
set -e
set -u
set -o pipefail

# Trap errors and provide helpful messages
trap 'echo "エラーが発生しました（Error on line $LINENO）。インストールに失敗しました（Installation failed）。"; exit 1' ERR

echo "FreeSurferのインストールを開始します（Begin installation of FreeSurfer）"
echo
echo "このスクリプトはmacOS用のFreeSurferをダウンロードしてインストールします"
echo "(This script will download and install FreeSurfer on macOS)"
echo "事前にlicense.txtを準備してください（You need to prepare license.txt beforehand）"
echo "license.txtは \$HOME/Downloads に配置してください"
echo "(license.txt should be placed in \$HOME/Downloads)"

## VERSION
fsver=8.1.0

## Google Drive file IDs
fid_arm64="1efZ5axKNgCsgGibphGE-uYHgvfXkpca7"
fid_amd64="1eV0GG_in3orQ6vqX_wekNFQ7P_HK7MIo"

## Package names and MD5 hashes
fname_arm64="freesurfer-macOS-darwin_arm64-${fsver}.pkg"
md5hash_arm64="8bbf749af50e4bdb8d25f6a40ca63af3"
fname_amd64="freesurfer-macOS-darwin_x86_64-${fsver}.pkg"
md5hash_amd64="0f524bb59195c1053a9a56d2713a34cf"

## Decide CPU
arch=$(uname -m)

case "$arch" in
  "arm64")
    archive="${fname_arm64}"
    md5hash="${md5hash_arm64}"
    gdid="${fid_arm64}"
    ;;
  "x86_64")
    archive="${fname_amd64}"
    md5hash="${md5hash_amd64}"
    gdid="${fid_amd64}"
    ;;
  *)
    echo "エラー: サポートされていないアーキテクチャです（Error: Unsupported architecture）: $arch" >&2
    exit 1
    ;;
esac

echo "検出されたアーキテクチャ（Detected architecture）: $arch"
echo "パッケージ（Package）: $archive"
echo

while true; do
    echo "FreeSurferのインストールを開始してもよろしいですか？"
    echo "(Are you sure you want to begin the installation of FreeSurfer?) (yes/no)"
    read -r answer
    case "$answer" in
        [Yy]*)
            echo "インストールを開始します（Begin installation）"
            break
            ;;
        [Nn]*)
            echo "インストールを中止します（Abort installation）"
            exit 0
            ;;
        *)
            echo "yesまたはnoを入力してください（Please type yes or no）"
            echo
            ;;
    esac
done

## Check for sudo access
echo "sudo権限を確認しています（パスワードの入力を求められる場合があります）"
echo "(Checking sudo access - you may be prompted for your password)..."
if ! sudo -v; then
    echo "エラー: このスクリプトはFreeSurferをインストールするためにsudo権限が必要です"
    echo "(Error: This script requires sudo access to install FreeSurfer)"
    exit 1
fi

## Homebrew
echo "Homebrewがインストールされているか確認しています..."
echo "(Checking if Homebrew is installed...)"

if ! command -v brew &> /dev/null; then
    echo "Homebrewをインストールしています..."
    echo "(Installing Homebrew...)"
    if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        echo "エラー: Homebrewのインストールに失敗しました（Error: Failed to install Homebrew）"
        exit 1
    fi
else
    echo "Homebrewは既にインストールされています。アップデート中..."
    echo "(Homebrew is already installed. Updating...)"
    brew update || echo "警告: Homebrewのアップデートに失敗しましたが、続行します（Warning: Failed to update Homebrew, continuing...）"
fi

## XQuartz
echo "XQuartzをインストールしています..."
echo "(Installing XQuartz...)"
if ! brew install --cask xquartz; then
    echo "警告: XQuartzのインストールに失敗したか、既にインストールされています"
    echo "(Warning: XQuartz installation failed or is already installed)"
fi

## Check license
echo "\$HOME/Downloads にlicense.txtがあるか確認しています..."
echo "(Checking if you have license.txt in \$HOME/Downloads...)"

if [ ! -e "$HOME/Downloads/license.txt" ]; then
    echo "エラー: $HOME/Downloads にlicense.txtが見つかりません"
    echo "(Error: license.txt not found in $HOME/Downloads)"
    echo "FreeSurferライセンスを取得して $HOME/Downloads に配置してください"
    echo "(Please obtain a FreeSurfer license and place it in $HOME/Downloads)"
    echo "ライセンスは以下から取得できます（You can get a license from）:"
    echo "https://surfer.nmr.mgh.harvard.edu/registration.html"
    exit 1
fi
echo "license.txtが見つかりました。インストールを続行します"
echo "(license.txt found. Continuing installation)"

## Download FreeSurfer
downloads_dir="$HOME/Downloads"
archive_path="${downloads_dir}/${archive}"

# Function to download from Google Drive
download_from_gdrive() {
    local file_id="$1"
    local output_file="$2"

    echo "Google Driveからダウンロードしています..."
    echo "(Downloading from Google Drive...)"
    if curl -L "https://drive.usercontent.google.com/download?id=${file_id}&confirm=xxx" -o "$output_file"; then
        return 0
    else
        return 1
    fi
}

# Function to download from official site (fallback)
download_from_official() {
    local file="$1"

    echo "FreeSurfer公式サイトからダウンロードしています..."
    echo "(Downloading from official FreeSurfer site...)"
    if curl -fL -O "https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/${fsver}/${file}"; then
        return 0
    else
        return 1
    fi
}

# Function to verify MD5
verify_md5() {
    local file="$1"
    local expected_hash="$2"

    # Get actual hash
    local actual_hash
    actual_hash=$(openssl md5 "$file" | awk '{print $2}')

    if [ "$actual_hash" = "$expected_hash" ]; then
        return 0
    else
        return 1
    fi
}

## Download and verify with retry logic
cd "$downloads_dir"

max_attempts=3
attempt=1
download_success=false

while [ $attempt -le $max_attempts ]; do
    # Download if file doesn't exist or if previous verification failed
    if [ ! -e "$archive_path" ] || [ "$download_success" = false ]; then
        echo "ダウンロード試行 $attempt / $max_attempts..."
        echo "(Download attempt $attempt of $max_attempts...)"

        # Remove corrupted file if it exists
        [ -e "$archive_path" ] && rm "$archive_path"

        # Try Google Drive first
        if download_from_gdrive "$gdid" "$archive_path"; then
            echo "Google Driveからのダウンロードが完了しました"
            echo "(Download from Google Drive completed)"
        else
            echo "警告: Google Driveからのダウンロードに失敗しました"
            echo "(Warning: Google Drive download failed)"
            echo "フォールバックとして公式サイトから試行します..."
            echo "(Trying official site as fallback...)"
            if download_from_official "$archive"; then
                echo "公式サイトからのダウンロードが完了しました"
                echo "(Download from official site completed)"
            else
                if [ $attempt -lt $max_attempts ]; then
                    echo "ダウンロードに失敗しました。再試行します..."
                    echo "(Download failed. Retrying...)"
                    attempt=$((attempt + 1))
                    continue
                else
                    echo "エラー: $max_attempts 回の試行後もFreeSurferパッケージのダウンロードに失敗しました"
                    echo "(Error: Failed to download FreeSurfer package after $max_attempts attempts)"
                    exit 1
                fi
            fi
        fi
    fi

    # Verify MD5
    echo "アーカイブの整合性を検証しています..."
    echo "(Verifying archive integrity...)"
    if verify_md5 "$archive" "$md5hash"; then
        echo "MD5検証に成功しました！"
        echo "(MD5 verification successful!)"
        download_success=true
        break
    else
        echo "MD5検証に失敗しました"
        echo "(MD5 verification failed)"
        if [ $attempt -lt $max_attempts ]; then
            echo "期待値（Expected）: $md5hash"
            echo "取得値（Got）: $(openssl md5 "$archive" | awk '{print $2}')"
            echo "再ダウンロードします..."
            echo "(Re-downloading...)"
            download_success=false
            attempt=$((attempt + 1))
        else
            echo "エラー: $max_attempts 回の試行後もMD5検証に失敗しました"
            echo "(Error: MD5 verification failed after $max_attempts attempts)"
            echo "期待値（Expected）: $md5hash"
            echo "取得値（Got）: $(openssl md5 "$archive" | awk '{print $2}')"
            exit 1
        fi
    fi
done

## Install FreeSurfer
echo "FreeSurferをインストールしています（sudoが必要です）..."
echo "(Installing FreeSurfer - this requires sudo...)"
if ! sudo installer -pkg "$archive_path" -target /; then
    echo "エラー: FreeSurferのインストールに失敗しました"
    echo "(Error: FreeSurfer installation failed)"
    exit 1
fi
echo "FreeSurferのインストールに成功しました！"
echo "(FreeSurfer installed successfully!)"

## Prepare FreeSurfer directory in $HOME
echo "\$HOME にFreeSurferディレクトリをセットアップしています..."
echo "(Setting up FreeSurfer directory in \$HOME...)"
fs_home_dir="$HOME/freesurfer/${fsver}"

if [ ! -d "$fs_home_dir" ]; then
    mkdir -p "$fs_home_dir"
fi

if [ ! -d "$fs_home_dir/subjects" ]; then
    echo "subjectsディレクトリをコピーしています..."
    echo "(Copying subjects directory...)"
    if ! cp -r "/Applications/freesurfer/${fsver}/subjects" "$fs_home_dir/"; then
        echo "エラー: subjectsディレクトリのコピーに失敗しました"
        echo "(Error: Failed to copy subjects directory)"
        exit 1
    fi
fi

## Copy license.txt
license_dest="$HOME/freesurfer/license.txt"
if [ ! -e "$license_dest" ]; then
    echo "license.txtをコピーしています..."
    echo "(Copying license.txt...)"
    mkdir -p "$HOME/freesurfer"
    cp "$HOME/Downloads/license.txt" "$license_dest"
fi

## Append settings to shell profile
echo "シェル環境を設定しています..."
echo "(Configuring shell environment...)"

# Detect shell
shell=$(basename "$SHELL")
profile=""

case "$shell" in
    "bash")
        profile=".bash_profile"
        ;;
    "zsh")
        profile=".zprofile"
        ;;
    *)
        echo "警告: サポートされていないシェルが検出されました（Warning: Unsupported shell detected）: $shell"
        echo "以下の設定を手動でシェル設定ファイルに追加してください"
        echo "(Please manually add the following to your shell configuration:)"
        echo ""
        echo "export SUBJECTS_DIR=\$HOME/freesurfer/${fsver}/subjects"
        echo "export FREESURFER_HOME=/Applications/freesurfer/${fsver}"
        echo "export FS_LICENSE=\$HOME/freesurfer/license.txt"
        echo "source \$FREESURFER_HOME/SetUpFreeSurfer.sh"
        echo ""
        profile=""
        ;;
esac

if [ -n "$profile" ]; then
    profile_path="$HOME/$profile"

    # Check if already configured
    if grep -q "freesurfer/${fsver}" "$profile_path" 2>/dev/null; then
        echo "$profile は既に設定されています"
        echo "($profile is already configured)"
    else
        echo "FreeSurfer設定を $profile に追加しています..."
        echo "(Adding FreeSurfer configuration to $profile...)"
        {
            echo ""
            echo "#FreeSurfer ${fsver}"
            echo "export SUBJECTS_DIR=\$HOME/freesurfer/${fsver}/subjects"
            echo "export FREESURFER_HOME=/Applications/freesurfer/${fsver}"
            echo "export FS_LICENSE=\$HOME/freesurfer/license.txt"
            echo 'source $FREESURFER_HOME/SetUpFreeSurfer.sh'
        } >> "$profile_path"
        echo "設定が $profile_path に追加されました"
        echo "(Configuration added to $profile_path)"
    fi
fi

## Download bert example data
echo "bertサンプルデータをダウンロードしています..."
echo "(Downloading bert example data...)"
cd "$fs_home_dir/subjects/"
if [ ! -d "bert" ]; then
    if curl -fL -O "http://www.lin4neuro.net/lin4neuro/neuroimaging_software_packages/bert.zip"; then
        if unzip -q bert.zip; then
            rm bert.zip
            echo "bertサンプルデータのダウンロードと展開が完了しました"
            echo "(bert example data downloaded and extracted)"
        else
            echo "警告: bert.zipの展開に失敗しました"
            echo "(Warning: Failed to extract bert.zip)"
            rm -f bert.zip
        fi
    else
        echo "警告: bert.zipのダウンロードに失敗しました（オプションです）"
        echo "(Warning: Failed to download bert.zip - this is optional)"
    fi
else
    echo "bertサンプルデータは既に存在します"
    echo "(bert example data already exists)"
fi

echo ""
echo "============================================"
echo "インストールが正常に完了しました！"
echo "(Installation finished successfully!)"
echo "============================================"
echo ""
echo "次のステップ（Next steps）:"
echo "1. このターミナルを閉じてください（Close this terminal）"
echo "2. 新しいターミナルを開いてください（Open a new terminal）"
echo "3. 'freeview' を実行してインストールをテストしてください"
echo "   (Run 'freeview' to test the installation)"
echo ""
if [ -n "$profile" ]; then
    echo "FreeSurfer環境は ~/$profile に設定されました"
    echo "(FreeSurfer environment has been configured in ~/$profile)"
fi
echo ""

exit 0
