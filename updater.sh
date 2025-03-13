#!/bin/bash

set -e

# 保存ディレクトリ設定
BASE_DIR="$HOME/.discord-deb"
LOG_FILE="$BASE_DIR/update.log"
mkdir -p "$BASE_DIR"

URLS=(
    "https://discord.com/api/download?platform=linux&format=deb"      # Stable
    "https://discord.com/api/download/ptb?platform=linux&format=deb"  # PTB
    "https://discord.com/api/download/canary?platform=linux&format=deb" # Canary
)


PACKAGES=("discord" "discord-ptb" "discord-canary")

for i in "${!PACKAGES[@]}"; do
    PACKAGE="${PACKAGES[$i]}"
    URL="${URLS[$i]}"
    DEB_FILE="$BASE_DIR/${PACKAGE}.deb"

    # バージョンを取得
    CURRENT_VERSION=$(dpkg-query -W -f='${Version}' "$PACKAGE" 2>/dev/null || echo "not installed")
    echo "Current $PACKAGE version: $CURRENT_VERSION" | tee -a "$LOG_FILE"

    # 最新ファイルダウンロード
    echo "Downloading latest $PACKAGE .deb..." | tee -a "$LOG_FILE"
    curl -L "$URL" -o "$DEB_FILE" 2>> "$LOG_FILE"

    # ファイルのバージョンを取得
    LATEST_VERSION=$(dpkg-deb -f "$DEB_FILE" Version)
    echo "Latest $PACKAGE version: $LATEST_VERSION" | tee -a "$LOG_FILE"

    # アプデ処理
    if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
        echo "Updating $PACKAGE..." | tee -a "$LOG_FILE"
        sudo apt install -y "$DEB_FILE" | tee -a "$LOG_FILE"
        echo "$PACKAGE has been updated to version $LATEST_VERSION" | tee -a "$LOG_FILE"
    else
        echo "$PACKAGE is already up to date." | tee -a "$LOG_FILE"
    fi

    # 一時ファイル削除
    rm -f "$DEB_FILE"
    echo "Temporary file removed: $DEB_FILE" | tee -a "$LOG_FILE"

done

echo "Update process completed." | tee -a "$LOG_FILE"
