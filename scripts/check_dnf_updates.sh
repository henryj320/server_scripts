#!/bin/bash

DEVICE_NAME="Be Quiet PC"
DEVICE_EMOJI="⬆️"

if [ "$(date +%u)" -ne 6 ]; then
    echo "Not Saturday, exiting early."
    exit 0
fi

UPDATES=$(dnf check-update --quiet | grep -E '^[a-zA-Z0-9]' | wc -l)
SECURITY_UPDATES=$(dnf updateinfo list --security --quiet | grep -E '^[A-Z]' | wc -l)
DOWNLOAD_SIZE=$(dnf upgrade --assumeno 2>&1 | sed -nE 's/.*Need to download ([0-9.]+ [A-Za-z]+).*/\1/p')

curl -d "${DEVICE_EMOJI} ${DEVICE_NAME} - $UPDATES updates available totalling $DOWNLOAD_SIZE. $SECURITY_UPDATES are security updates." "ntfy.sh/whale_server_1"
