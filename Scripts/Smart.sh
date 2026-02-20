#!/bin/bash
CONFIG_FILE="./.config"

if ! [ -f "$CONFIG_FILE" ]; then
  echo ".config not found, skip smart kernel download"
  exit 0
fi

if ! grep -q '^CONFIG_PACKAGE_nikki=y' "$CONFIG_FILE"; then
  echo "Nikki package not enabled, skip smart kernel download"
  exit 0
fi

mkdir -p ./files/etc/nikki/run

ARCH_KEY="arm64"
if [[ "$WRT_TARGET" == "x86" ]]; then
  ARCH_KEY="amd64"
fi

DOWNLOAD_URL=$(wget -qO- https://api.github.com/repos/taamarin/smart/releases \
  | grep -oP '"browser_download_url":\s*"\K[^"]*mihomo-linux-'"$ARCH_KEY"'-alpha-smart-[^"]*\.gz' \
  | head -n1)

if [ -n "$DOWNLOAD_URL" ]; then
  TMP_FILE="$(mktemp)"
  wget -O "$TMP_FILE" "$DOWNLOAD_URL"
  gunzip -c "$TMP_FILE" > ./files/etc/nikki/run/smart
  rm -f "$TMP_FILE"
  chmod +x ./files/etc/nikki/run/smart
  echo "Smart kernel downloaded and extracted: $DOWNLOAD_URL"
else
  echo "Smart kernel download URL not found for arch ${ARCH_KEY}"
fi
